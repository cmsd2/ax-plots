# Animated Plots: `animate()` as a Draw-Object Wrapper

Status: **shipped.**  Lives in `ax-plots/ax-plots.mac` as
`animate(...)`, wired through `ax_draw2d` / `ax_draw3d`.  An
example notebook is at `ax-plots/examples/animations.macnb`.
Renderer support shipped in both the vscode-extension Plotly
renderer and aximar's Tauri PlotlyChart (each calls
`Plotly.addFrames` when the figure JSON carries a `frames` array).

Scope, as built: `ax-plots` plus a one-line `Plotly.addFrames`
addition in each renderer (the original "no renderer changes
required" assumption was almost right — `Plotly.newPlot`'s
default signature accepts data + layout + config but not frames;
`addFrames` registers them after).  aximar's bundled
`ax_plotting.mac` got the same animate machinery surgically
patched in.

See also: [reactive-views.md](reactive-views.md) — the north-star
architecture this fits into. `animate(...)` is the paradigm-2 (precomputed
frames) leaf of a larger reactive-views system; this doc and that one are
written so the immediate `animate()` work doesn't paint the larger
architecture out of the picture.

The remainder of this doc describes the design as built, with
deliberate divergences from the original proposal flagged where
they happened.

## What changed during implementation

Three things turned out differently from the original design, in
roughly decreasing order of how much it surprised me:

1. **The dominant cost was JSON construction, not sampling.**
   When `compile_grid` from `numerics` was wired in (paradigm-2
   fast path), the sampling cost dropped from ~170 ms to ~30 ms
   for the default 60-frame `sin(k*x)` case — but the end-to-end
   ax_draw2d time barely moved.  Per-frame stringification of
   500-point x and y arrays was eating ~10 ms × 60 frames.  The
   shipped fast path caches the x-axis JSON once (it's identical
   across every frame) and uses a faster per-element stringifier
   that skips the NaN / infinity guard for known-finite floats.
   Combined with the bulk sampling, end-to-end speedup ended up at
   ~2.7× rather than the 10-30× the perf section originally
   projected.

2. **`Plotly.addFrames` was needed in the renderer.**  The
   `Plotly.newPlot(div, data, layout, config)` signature used by
   both existing renderers doesn't accept a `frames` parameter.
   Plotly does support an object form
   `newPlot(div, {data, layout, frames, config})`, but the existing
   TypeScript type signatures don't reflect it.  Easier to register
   frames after newPlot resolves: `Plotly.addFrames(div, frames)`.
   One-line change in each renderer.

3. **Two Maxima parser gotchas while writing the dispatcher.**
   `if cond then a else b, next-stmt` parses ambiguously in
   `,`-separated block syntax — the `if` swallows the comma and
   `next-stmt`.  Split the conditional into two statements.  Also:
   Maxima's `fboundp` is *not* an actual function; it returns a
   noun form.  The real runtime check is the Lisp escape
   `?fboundp(name) = false`.  Both gotchas now have entries in the
   ax-plots README and have been retroactively fixed across the
   workspace (numerics, mochi, numerics-sundials all had silent
   dead `fboundp` guards).

## Summary

Add `animate(obj, [param, lo, hi, n])` as a new draw-object wrapper that can be
passed to any `ax_draw*` function. The wrapped object is sampled `n` times along
`param`, and the resulting traces are emitted as Plotly `frames`. A slider and
play/pause control are added to the figure layout. Plotly handles playback,
scrubbing, and (where supported) tween interpolation between frames.

```maxima
ax_draw2d(animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0.1, 5]))$
ax_draw2d(animate(ax_contour(sin(k*x)*cos(y), x, -%pi, %pi, y, -%pi, %pi),
                  [k, 0.1, 3]))$
ax_draw3d(animate(explicit(sin(k*x)*cos(y), x, -%pi, %pi, y, -%pi, %pi),
                  [k, 0.5, 2.0]))$
```

## Motivation

`ax-plots` exposes static `draw`-style objects (`explicit`, `parametric`,
`ax_contour`, `ax_heatmap`, `ax_vector_field`, …). Many of these are most
illuminating when *something* changes — a frequency, an eigenvalue, a coupling
constant, a time variable in an ODE solution. Today users approximate this with
many cells and many static plots.

The desired UX is one cell, one plot, a slider, a play button. Plotly already
supports this end-to-end via `frames` + `sliders` + `updatemenus`. The work is
to expose it from Maxima.

## Design choice: wrapper vs sibling

The wrapper composes; a sibling does not.

| Approach | Generalises to all `ax_*` types? | New top-level API per type? | Mime type changes? | Renderer changes? |
|----------|----------------------------------|------------------------------|--------------------|-------------------|
| **A. `animate(obj, ...)` wrapper inside `ax_draw*`** | Yes, automatically | No | None | None |
| B. `ax_animate(expr, ...)` sibling of `ax_draw2d` | No — would need `ax_animate_contour`, `ax_animate_heatmap`, … | One per type | New `application/x-maxima-ndarray` | Per-kind dispatch + client-side interpolation |
| C. Generic `ax_ndarray` + per-kind renderer | Yes, but the work moves to the renderer | One internal kind per type | New mime type | One per kind |

A wins on every dimension *except* one: smoothness of scrubbing for very large
frames or trace types Plotly cannot tween. That is a real concern but a
performance one — the right answer is to ship A first, profile, and only reach
for B/C if Plotly redraw proves too slow. See [§ Future work](#future-work).

## Surface

```
animate(obj, [param, lo, hi])
animate(obj, [param, lo, hi, n])
```

- `obj` — any draw object supported by the surrounding `ax_draw*` call.
  Free symbols other than the animated `param` are sampled as normal at frame
  build time.
- `param` — a Maxima symbol that appears in `obj`.
- `lo`, `hi` — numeric endpoints of the parameter sweep.
- `n` — number of frames (default `60`).

`animate` is itself a draw-object (added to `ax__draw_object_names`), so it
flows through the existing argument parser in `ax_draw2d` /  `ax_draw3d`. Style
options preceding it (`color=…`, `line_width=…`, etc.) apply to every frame.

### Examples

```maxima
/* Sweep a frequency */
ax_draw2d(animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0.1, 5]))$

/* Sweep with style + layout options */
ax_draw2d(
  color="crimson", line_width=3,
  animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0.1, 5]),
  title="Frequency sweep", yrange=[-1.2, 1.2]
)$

/* Animated + static traces in one figure */
ax_draw2d(
  color="grey", explicit(sin(x), x, -%pi, %pi),
  color="red", animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0.5, 3])
)$

/* 2D field animation */
ax_draw2d(animate(
  ax_vector_field(-y, k*x, x, -3, 3, y, -3, 3),
  [k, 0.5, 2.0]
))$

/* 3D surface morph */
ax_draw3d(animate(
  explicit(sin(k*x)*cos(y), x, -%pi, %pi, y, -%pi, %pi),
  [k, 0.5, 2.0]
), colorscale="Viridis")$
```

### Playback options

| Option | Default | Description |
|--------|---------|-------------|
| `fps` | `12` | Playback rate. Translates to `frame.duration = 1000/fps` ms. |
| `transition_duration` | matches frame duration | Tween length between frames. Set `0` for hard step. |
| `loop` | `"repeat"` | One of `"once"`, `"repeat"`, `"pingpong"` (matches Desmos's three modes). |
| `slider_label` | name of `param` | Slider prefix label. |

These are layout-level options (siblings of `title`, `xrange`, …), not options
of `animate` itself — that way they apply globally to the figure and are not
specified per-wrapped-object.

## Implementation sketch

### 1. Recognise `animate` as a draw object

```maxima
ax__draw_object_names : append(ax__draw_object_names, [animate])$
```

### 2. Detect animation inside `ax_draw2d` / `ax_draw3d`

Replace the per-object trace build with a two-pass walk:

1. **Scan pass**: identify any `animate(...)` wrappers. Require all wrappers in
   one figure to share the same `param`. (Multi-parameter support is future
   work — see [§ Future work](#future-work).)
2. **Sample pass**:
   - For each `i ∈ 0..n-1` compute `pᵢ = lo + i·(hi-lo)/(n-1)`.
   - For each animated object: substitute `param = pᵢ` into the wrapped
     `obj`, then build a trace via the existing `ax__build_trace_2d` /
     `ax__build_trace_3d` dispatcher. This is the key generalisation — no
     per-type animation code; the trace builder already knows how to render
     every supported object.
   - For each static object: build its trace once (same as today).
3. **Emit**:
   - `data`: the frame-0 traces, in original order (static + animated mixed).
   - `frames`: array of `{name: "i", data: [traceᵢ_animated_1, traceᵢ_animated_2, …]}`.
     Plotly applies frame data in order to the matching base-trace indices, so
     only the animated traces need to be in each frame.
   - `layout.sliders`, `layout.updatemenus`: see below.

### 3. Layout: slider + play/pause

```json
{
  "sliders": [{
    "active": 0,
    "currentvalue": {"prefix": "k = "},
    "steps": [
      {"label": "0.10", "method": "animate",
       "args": [["0"], {"mode": "immediate",
                        "frame": {"duration": 0, "redraw": true},
                        "transition": {"duration": 0}}]},
      ...
    ]
  }],
  "updatemenus": [{
    "type": "buttons",
    "showactive": false,
    "buttons": [
      {"label": "▶", "method": "animate",
       "args": [null, {"frame": {"duration": 83, "redraw": true},
                       "fromcurrent": true,
                       "transition": {"duration": 83, "easing": "linear"}}]},
      {"label": "❚❚", "method": "animate",
       "args": [[null], {"mode": "immediate",
                         "frame": {"duration": 0, "redraw": false},
                         "transition": {"duration": 0}}]}
    ]
  }]
}
```

Slider step labels show the parameter value formatted to a sensible precision
(e.g. 2–3 significant figures, matching axis tick formatting).

### 4. JSON schema (what `ax__emit_plotly` writes)

The existing `application/x-maxima-plotly` payload gains a `frames` key and
layout extensions. Schema:

```json
{
  "data":   [<trace>, ...],          // frame 0; static traces remain across frames
  "layout": {
    ...existing layout...,
    "sliders":     [<slider>],
    "updatemenus": [<play_pause>]
  },
  "frames": [
    {"name": "0", "data": [<animated_trace_0>, ...]},
    {"name": "1", "data": [<animated_trace_1>, ...]},
    ...
  ]
}
```

No new mime type. The vscode-extension renderer already calls
`Plotly.newPlot(div, spec.data, spec.layout, config)` — if the spec also
contains `frames`, Plotly picks them up automatically. A small renderer audit
is needed to confirm `Plotly.newPlot` is called with the full spec (not split),
but no functional change is expected.

## What can and cannot be animated

This is a complete enumeration of every object in `ax__draw_object_names`.
Each object is in one of three categories.

### Supported with smooth tween

Plotly interpolates between frames element-wise on the trace's data arrays.
Visually smooth at any fps.

| Wrapped object | Plotly trace | Tween mechanism | Notes |
|----------------|--------------|------------------|-------|
| `explicit(expr, x, ...)` | `scatter` | x/y arrays tween element-wise | Most common case |
| `parametric(x(t), y(t), t, ...)` | `scatter` | x/y arrays tween | |
| `points(...)` | `scatter` (markers) | marker positions tween | |
| `lines(xs, ys)` | `scatter` | x/y arrays tween *iff* both frames have the same length | Mismatched lengths fall back to step |
| `explicit(expr, x, ..., y, ...)` (3D) | `surface` | z-array tweens | Smooth provided grid shape is stable |
| `parametric_surface(...)` | `surface` | x/y/z arrays tween | Smooth provided grid shape is stable |
| `points(...)` (3D) | `scatter3d` | marker positions tween | |
| `lines(...)` (3D) | `scatter3d` | x/y/z arrays tween | |
| `parametric(x(t), y(t), z(t), t, ...)` (3D) | `scatter3d` | x/y/z arrays tween | |

### Supported as step animation

Frames are valid and Plotly swaps them on schedule, but interpolation between
frames doesn't make geometric sense, so Plotly snaps. Recommend
`transition_duration=0` to suppress the half-tweened intermediate frame.

| Wrapped object | Plotly trace | Why step, not tween | Per-frame cost |
|----------------|--------------|----------------------|-----------------|
| `implicit(eqn, x, ..., y, ...)` | `scatter` (computed) | Topology of the curve changes; element correspondence breaks | High: re-meshing |
| `ax_contour(expr, ...)` | `contour` | Level sets re-thread between frames | Medium |
| `ax_contour3d(...)` | 3D contour family | Same as above | Medium |
| `ax_heatmap(matrix \| expr, ...)` | `heatmap` | z-array swap, no element correspondence to tween | Low |
| `ax_vector_field(Fx, Fy, ...)` | `scatter` (arrow segments) | Arrows are independent glyphs; tween would mangle them | Low |
| `ax_vector_field3d(Fx, Fy, Fz, ...)` | `scatter3d` (arrow glyphs) | Same as above | Medium |
| `ax_streamline(Fx, Fy, ...)` | `scatter` (RK4 trajectories) | Trajectories are integrated per frame; lengths/shape differ | High: RK4 reruns |
| `ax_error_bar(...)` | `scatter` (with error_y/error_x) | Discrete points with error whiskers; tween would smear whiskers | Low |
| `ax_bar(categories, values)` | `bar` | Categorical x-axis (no continuous interpolation) | Low |
| `ax_histogram(data)` | `histogram` (or pre-binned `bar`) | Bin edges re-snap between frames | Low |

### Not supported in initial scope

These objects are valid draw-objects today, but `animate(...)` will reject them
with a clear error. We can lift any of them later if real use cases emerge.

| Wrapped object | Reason | Possible path |
|----------------|--------|----------------|
| `ax_box(data)` | Aggregate statistic over a static dataset. Animating the *data* (e.g. a parameter that filters/reweights it) is the meaningful operation, but that's not expressible through expression-substitution. | Add `animate_data(...)` (see future work) |
| `ax_violin(data)` | Same as `ax_box` | Same |
| `ax_pie(categories, values)` | Categorical proportions. Tweening a pie tends to misread as motion-as-meaning. | If requested: step animation with `transition_duration=0` |
| `ax_bar` with a categorical x-axis whose *categories* change between frames | Plotly cannot interpolate label sets | None — use `lines` / `points` for ordered numeric x |

### General rules across categories

- **"Step" animations are still smooth-looking at modest `fps`** because each
  redraw is fast — set `fps=12` (default) and `transition_duration=0` and the
  result reads as a stop-motion sweep rather than a janky tween.
- **Mixing trace types in one figure works.** A figure can combine tween and
  step traces; Plotly applies the transition spec per trace independently.
- **Free symbols other than `param` are evaluated at frame build time.** If a
  symbol is unbound and isn't the animated parameter, the existing trace
  builder's behaviour applies (typically: an error from `float`).

## Animating styles and layout

Any value passed to `ax_draw*` — style option, layout option, or sub-expression
of a draw object — that mentions the animated `param` is treated as per-frame
and re-evaluated on each sample pass. Values that don't mention `param` are
evaluated once and stay constant. This is detected with `freeof(param, val)`
on the right-hand side of each option.

This rule covers, uniformly:

- **Data** (already covered): `explicit(sin(k*x), ...)` — `k` appears in the
  inner expression.
- **Trace styles**: `color`, `line_width`, `opacity`, `marker_size`,
  `marker_symbol`, `fill_color`, `colorscale`, `dash`.
- **Layout**: `title`, `xrange`, `yrange`, `xlabel`, `ylabel`, `plot_bgcolor`.

### Examples

```maxima
/* Colour sweep alongside frequency sweep */
ax_draw2d(
  color = ax_color_lerp("blue", "red", k),
  line_width = 2 + 4*k,
  animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0, 1])
)$

/* Title and axis range follow the parameter */
ax_draw2d(
  animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0.5, 4]),
  title = sconcat("frequency = ", string(k)),
  yrange = [-1.2, 1.2],
  xrange = [-%pi/k, %pi/k]
)$
```

### What tweens, what steps

Plotly's per-frame transition behaviour by attribute kind:

| Attribute kind | Examples | Tween? |
|----------------|----------|--------|
| Numeric scalar | `line_width`, `opacity`, `marker_size` | Yes — linear |
| Numeric array | trace `x`, `y`, `z`, `marker.color` (as array through a colorscale) | Yes — element-wise linear |
| CSS colour string | `color="#ff0000"`, `color="rgb(...)"` | No — hard swap |
| Text | `title`, `xlabel` | No — hard swap |
| Range arrays | `xrange`, `yrange` | Yes — linear |
| Categorical | x-axis labels, `dash` | No — hard swap |

For smooth colour transitions, encode the colour through `marker.color` as an
array of indices into a `colorscale` rather than as a CSS string per frame —
Plotly will then tween in colour space. The `ax_color_lerp` helper exists for
the per-frame string case (cheap and good enough for most pedagogic uses); a
future `ax_color_scale_index(scale, t)` helper would cover the tween-in-colour
case.

### Helpers (added to `ax-plots`)

```
ax_color_lerp(c1, c2, t)
  /* Linear interpolate between two CSS colours; returns "rgb(...)" string.
     t clamped to [0,1].  Accepts hex, named, or rgb() colours. */

ax_color_scale(scale_name, t)
  /* Sample a named Plotly colorscale ("Viridis", "Hot", ...) at t in [0,1].
     Returns "rgb(...)" string. */
```

These have no special status — they're just colour utilities that happen to
compose naturally with the `param` substitution mechanism.

## Composition rules

1. **One animated parameter per figure.** All `animate(...)` wrappers in one
   `ax_draw*` call must use the same `param` symbol. Differing endpoints/`n`
   are an error in the initial scope; we may relax this later.
2. **Static and animated traces coexist.** Static traces render once and
   remain visible across all frames.
3. **Style options apply per-frame.** A style option preceding an `animate(...)`
   applies to every frame of that wrapper (because the underlying trace is
   built with the same style state on each substitution pass).
4. **Layout options are global.** `title`, `xrange`, `yrange`, etc. are
   evaluated once. Animating an axis range or title is not in scope (Plotly
   supports it via per-frame `layout`, but the cost-benefit is poor; see
   [§ Future work](#future-work)).
5. **Range is fixed across frames.** If the user does not specify `xrange` /
   `yrange`, Plotly autoscales using the union of all frame data — preventing
   the disorienting "axis jumping" you get when each frame autoscales itself.
   The sample pass computes this union.

## Performance considerations

- **Sampling cost.** For `explicit(expr, x, x0, x1)` with `nticks` x-samples
  and `n` frames, total evaluations are `n · nticks`. At defaults `n=60`,
  `nticks=500`, that is 30k evaluations of `expr`. Acceptable for typical
  expressions; the existing `ax__sample_1d` does no `compile`/`translate`
  precompilation, and we inherit that.
- **JSON size.** Each frame for a 1D curve is `~2 · nticks · ~12 bytes`. At
  the defaults, a full figure is ~360 kB — fine to ship through the existing
  temp-file path.
- **Browser redraw cost.** Plotly redraws each frame fully unless the trace
  type supports incremental update (scatter does; surface mostly does; heatmap
  swaps the z-array). For 1D curves with 500 points this is well under 16 ms
  on a modern laptop; surfaces with 100×100 grids may approach 30 ms. We
  target 12 fps default playback to leave headroom.

## Out of scope (initial implementation)

- Multi-parameter animation (multiple independent sliders).
- Per-frame layout (animating axis ranges, titles, colorscale bounds).
- Animation of pre-sampled data passed as nested lists / ndarrays without an
  expression and parameter (e.g. animating a sequence of matrices).
- Cross-cell widgets where a slider in one cell drives a plot in another.

These are addressed below.

## Future work

### Multi-parameter widgets

Two parameters → two sliders. Plotly supports multiple slider rows. The
constraint moves from "one param symbol per figure" to "≤ M params". The frame
array becomes a flattened `n₁ · n₂` grid; size grows multiplicatively, so we
likely cap at two parameters.

### Per-frame layout

Useful for "zoom into the interesting region as the parameter sweeps". Plotly's
frame supports a `layout` key. The Maxima side gains layout-per-frame options
(e.g. `xrange = lambda([p], [-p, p])`).

### Pre-sampled data input

`animate_data(frames_matrix, [param, lo, hi])` where `frames_matrix` is an
`(n, …)` ndarray. Useful for ODE solutions where the per-frame data is already
in a `numerics` ndarray and we should not re-evaluate symbolically. The
wrapper would dispatch to `ax__trace_lines_2d` / `ax__trace_heatmap_2d` /
etc. with each row.

### Streamline / implicit acceleration

Per-frame RK4 integration and per-frame implicit meshing are expensive. We
could (1) parallelise frame computation on the Maxima side (currently
single-threaded), or (2) cache and reuse the previous frame's mesh as a
starting point.

### ndarray + client-side interpolation (path B from the design choice)

If, in practice, Plotly's per-frame redraw is too slow for smooth scrubbing
(measured, not assumed), add a second mode that ships a precomputed grid as a
new `application/x-maxima-ndarray` payload and does linear blending in the
renderer between sampled frames. This is a renderer-side optimisation that
*replaces* the Plotly frames for the curve case; it does not change the
Maxima-facing API (`animate(...)` would internally choose between
"Plotly frames" and "ndarray + interp" based on a config flag or trace type).

Scope of that follow-up:

- aximar-core: new `NDARRAY_PATH_RE`, `is_safe_ndarray_path`, `grid_data` field
  on `EvalResult`, parser tests.
- aximar-mcp: propagate `grid_data` through `convert.rs` / `server.rs`.
- vscode-extension: `grid_data` on `EvalResult`, new mime type, renderer
  handler with slider + Plotly `restyle` on row blend.

## Open questions

1. **`n` default of 60** — is this right for "feels smooth" without bloating
   payload size? May want type-specific defaults (lower for heatmaps/surfaces,
   higher for curves).
2. **Parameter discovery** — do we require the user to name `param` explicitly,
   or could we infer it from the single free symbol that isn't already bound
   by the inner draw object's range? Explicit is safer; inference is more
   ergonomic. Initial implementation: explicit.
3. **Easing curve** — Plotly supports `linear`, `cubic`, `sin`, `quad`, etc.
   Default is `linear` which matches the "watch the parameter sweep" mental
   model. Worth exposing?
4. **Range union strategy** — computing the union of frame ranges requires
   sampling all frames before emitting. For surface/heatmap this means the
   z-range is consistent across frames (good). For curves it means y-axis
   doesn't jump (good). Cost is one extra reduction per frame — cheap.

## References

- [Plotly: Animations](https://plotly.com/javascript/animations/)
- [Plotly: Sliders](https://plotly.com/javascript/sliders/)
- `ax_draw2d` ([doc](../ax_draw2d.md))
- `ax__build_trace_2d` dispatch (`ax-plots.mac:1232`)
- `ax__emit_plotly` (`ax-plots.mac:1419`)
- vscode-extension renderer (`renderers/maxima/index.ts:137`)
