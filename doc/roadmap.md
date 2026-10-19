# ax-plots Roadmap: Graphical Elements and Rendering Options

Status: **proposal, not committed.**  Rough priority order within each
section.  This roadmap covers *what ax-plots can draw and how it lays
the figure out*.  The reactivity / animation / streaming roadmap lives
in [design/reactive-views.md § Roadmap](design/reactive-views.md#roadmap-rough-order-not-committed)
and is not repeated here.

## Motivating case

Reproducing a textbook Penrose–Carter diagram of Schwarzschild
spacetime (four regions, constant-r / constant-t families, horizons,
zigzag singularities, an infalling worldline with light cones, wavy
photons, and labels such as `i⁺`, `𝓘⁻`, "horizon r = 2M") with
`ax_draw2d` exposed the gaps below.  The curves were easy; everything
*around* the curves was not:

- **No text.**  Region numerals I–IV had to be drawn as line strokes;
  `i⁺`, `i⁰`, `𝓘±` and the rotated horizon labels could not be drawn
  at all.
- **No arrows.**  Direction of the worldline and photons could not be
  shown.
- **No polygon.**  Shaded regions and light-cone hourglasses were
  `lines(...)` + `fill="toself"` + a transparent `color` + `line_width=0`.
- **Sticky-only styling.**  Every decorative element needed a run of
  `color=..., fill=..., line_width=...` set/reset arguments, so the
  figure was built programmatically as a list and passed via
  `apply(ax_draw2d, objs)`.
- **Silent nulls.**  `lines(xs, ys)` with symbolic entries (`%pi/2`,
  `atan(3)`) serialised them as `null` (`ax__float_to_json` returns
  `"null"` for anything not `numberp`), so the plot rendered blank with
  no error.
- **Layout control.**  No `margin`; `aspect_ratio` is boolean only;
  sizing interacts badly with the host (see
  [§ Host constraints](#host-constraints)).

## 1. Correctness and ergonomics (do first, cheap)

1. ~~**Numeric coercion in data objects.**~~ **Done.**
   `ax__float_to_json` floats numeric constants (`%pi/2`, `atan(3)`), so
   they no longer become `null` anywhere (data, `xrange`/`yrange`,
   margins).  `lines` / `points` (2D and 3D) error with object, axis and
   index on non-numeric data; `false`, `inf`, `minf`, `und`, `ind` are
   explicit gaps.
2. ~~**Per-object options.**~~ **Done.**  Trailing option equations inside
   an object apply to that object only
   (`lines(xs, ys, color="red", dash="dot")`); top-level options keep
   their sticky semantics.  Split in the 2D/3D trace dispatchers and in
   the `animate()` scan pass (so `explicit(..., color=...)` inside
   `animate` still qualifies for the `compile_grid` fast path).
3. **Per-object legend and hover control.**  ~~`showlegend`, `hoverinfo`,
   `hover_text`~~ **done** (`hover_text` was accepted but never emitted;
   it now maps to Plotly `hovertext`) and `legendgroup` **done**.
4. ~~**Document programmatic use.**~~ **Done** in `ax_draw2d.md`.

Found and fixed along the way:

- `ax__style_set` silently dropped any option not already in
  `ax__default_style()`, so `colorscale="Viridis"` (used in the README)
  had no effect.  Missing keys are now appended.
- JSON strings were not escaped; a `"` or `\` in a title, name, label or
  hover text produced invalid JSON.  `ax__json_string` now escapes
  backslash, quote and newline.
- `aspect_ratio=false` still locked the aspect ratio.

## 2. Graphical elements

Names follow Maxima's `draw` package where an equivalent exists
(`label`, `polygon`, `vector`, `rectangle`, `ellipse`), consistent with
the existing reuse of `explicit` / `parametric` / `points` / `implicit`.

### Must-have

`label`, `vector` and `polygon` are **done** (2D) with the draw-package
calling forms below.  `label` and `vector` emit layout annotations
(builders return `ax__annotations([...])`, collected by
`ax__draw2d_impl`); they are rejected inside `animate(...)` for now (see
open question 1) and are not yet in `ax_draw3d`.  Label options:
`font_size` / `font_color` / `font_family`, `label_alignment` (xanchor),
`label_valign` (yanchor), `label_angle` (degrees CCW, negated into
Plotly's clockwise `textangle`) and draw's `label_orientation`.  Vector
options: `color`, `line_width`, `head_size` (arrowsize), `head_style`
(arrowhead), and draw's `head_both`.  Polygon: `fill_color`, outline via
`color` / `line_width` / `dash`, draw's `transparent`.

Arrowheads on curves are **done**: `head_end`, `head_start` and
`head_count=n` (evenly spaced by arc length, replacing the proposed
`head_every`) on `lines` / `explicit` / `parametric`, as `arrow` markers
with `angleref:"previous"`; marker size is 0 except at heads, so one
trace keeps the auto colour.  Fill between curves is **done** as the
draw package's `filled_func` option on `explicit` (`true` → `tozeroy`;
`g(x)` → an invisible g trace plus `tonexty`) instead of a new
`fill_between` object.  Both make the `compile_grid` animation fast path
stand aside, since they change the trace shape.

`head_direction="chord"` (opt-in; tangent stays the default, as in
Mathematica, matplotlib recipes, Plotly and TikZ) points heads along the
curve's overall direction for wavy or noisy data.  Plotly places an
arrow marker's *tip* on the point and `marker.standoff` only moves it
backwards (negative values are rejected), so a head can't be pushed past
the end of the line; for wavy lines the docs recommend ending the data
with a straight run about one head long (TikZ's `post length` idiom).
Head markers set `line.width` 0 and `opacity` 1: Plotly's default marker
outline cut a light rim into the line, and an array-valued `size` makes
Plotly fade markers to 0.7 as for bubble charts.  Curves with heads also set
`line.simplify` false: with markers present, Plotly's simplification
split the line into two-point paths and dropped one next to a head,
leaving a visible gap (found by rendering to SVG and checking the paths).

| Object | Proposed syntax | Plotly mapping | Notes |
|--------|-----------------|----------------|-------|
| Text label | `label([text, x, y], ...)` (draw form) | `scatter` `mode:"text"` or layout `annotations` | Options: `font_size`, `font_color`, `font_family`, `text_angle`, `xanchor`/`yanchor`.  Unicode must round-trip (`i⁺`, `𝓘`, Greek).  Rotation needs annotations (`textangle`), not text traces. |
| Arrow / vector | `vector([x, y], [dx, dy])` (draw form) | layout `annotations` with `showarrow`, `ax`/`ay` in data coords (`axref:"x"`) | Options: `head_size`, `head_style`, `color`, `line_width`. |
| Arrowheads on curves | `head_end=true` / `head_start=true` option on `lines` / `parametric` / `explicit` | `marker.symbol:"arrow"` + `marker.angleref:"previous"` on the last point (Plotly ≥ 2.x; Aximar bundles plotly.js 3.5) | Also `head_every=n` for direction ticks along a curve (worldlines, streamlines). |
| Polygon | `polygon([[x1,y1], ...])` | `scatter` with `fill:"toself"`, closed path | `fill_color` + outline `color` independent; `line_width=0` for fill-only.  Removes the transparent-line hack. |
| Fill between curves | `fill="tonexty"` already passes through; add `fill_between(expr1, expr2, x, lo, hi)` | two traces, second `fill:"tonexty"` | Common for regions / inequalities. |

### Should-have

Shapes are **done** (2D) as layout `shapes`: draw-form
`rectangle([x1,y1],[x2,y2])`, `ellipse(xc,yc,a,b)` and the sector form
`ellipse(xc,yc,a,b,ang1,ang2)` (an SVG path), and `hline(...)` /
`vline(...)` spanning the plot in paper coordinates; `layer` puts them
below the data.  `line_shape` is **done**.

| Object | Proposed syntax | Plotly mapping | Notes |
|--------|-----------------|----------------|-------|
| Shapes | `rectangle([x1,y1],[x2,y2])`, `ellipse(xc, yc, a, b, ...)`, `hline(y)`, `vline(x)` | layout `shapes` (`type:"rect"/"circle"/"line"`) | `layer:"below"/"above"` so decorations sit under or over data; not hover targets. |
| Annotation / callout | `annotation(text, [x, y], [tx, ty])` | layout `annotations` with arrow | Leader-line labels. |
| Per-point marker attributes | list-valued `marker_size`, `color`, `marker_angle` | array-valued `marker.size` / `marker.color` / `marker.angle` | Light cones, oriented glyphs, bubble plots. |
| Error bars | `error_y=[...]`, `error_x=[...]` on `points` / `lines` | `error_y` / `error_x` | |
| Line shape | `line_shape="spline"/"hv"/"vh"` | `line.shape` | Step plots, smoothing. |

### Later

- Subplots / shared axes (`ax_subplots(rows, cols, ...)` → Plotly
  `grid` + `xaxis2`/`yaxis2`).
- Secondary y-axis (`yaxis2`, `overlaying:"y"`).
- Raster image with data coordinates (`layout.images`).
- 3D parity: `label` (`scatter3d` `mode:"text"`), arrows (`cone`), and
  `polygon` (`mesh3d`) in `ax_draw3d`.

## 3. Rendering options

### Layout

`margin` (2D, 3D, polar), numeric `aspect_ratio` and `constrain` (2D)
are **done**.  `width=auto` / `height=auto` already dropped the default
size; now documented.  `autosize`, `legend_position` and
`legend_orientation` are **done** for 2D, 3D and polar.

| Option | Proposed | Plotly mapping |
|--------|----------|----------------|
| ~~`margin`~~ | `margin=[l, r, t, b]` or `margin=10` | `layout.margin` |
| ~~`aspect_ratio`~~ | accept a number as well as `true` (`true` ≡ `1`) | `yaxis.scaleanchor:"x"` + `scaleratio` |
| ~~`constrain`~~ | `"range"` (Plotly default) / `"domain"` | `xaxis/yaxis.constrain` — `"domain"` shrinks the plot area instead of widening a range, so explicit `xrange`/`yrange` are honoured exactly under `aspect_ratio` |
| ~~`autosize`~~ | `autosize=true` drops the 700×700 / 700×450 defaults | omit `width`/`height`, `layout.autosize` |
| ~~`title` styling~~ | `title_font_size`, `title_x`, `title_align` | `layout.title.font`, `.x`, `.xanchor` |
| `font` | `font_family`, `font_size`, `font_color` (global) | `layout.font` |
| ~~Legend~~ | ~~`legend_position`~~ (`"top-right"`, `"bottom"`, `[x, y]`), ~~`legend_orientation`~~, ~~`legend_title`~~ | `layout.legend` |
| ~~Theme~~ | ~~`theme="light"/"dark"`~~ **done** (2D, 3D, polar); `"auto"` needs the host to report its mode | background / grid / text colours, plus template `annotationdefaults` / `shapedefaults` so uncoloured arrows and shape outlines follow the theme |

### Axes

Per-axis (prefix `x`/`y`/`z`): `ticks` / `tickvals` / `ticktext`,
`tickformat`, `tickangle`, `showticklabels`, `zeroline`, `mirror`,
axis line colour / width, `reversed`, axis-title font.  `xaxis=false`
(hide entirely) already works.

**Done (2D):** `xtickvals` / `ytickvals`, `xticktext` / `yticktext`,
`xtickformat` / `ytickformat`, `xreversed` / `yreversed` (swaps an
explicit range, else `autorange:"reversed"`), `xzeroline` / `yzeroline`.
`tickangle` is deferred until the angle convention is settled: Plotly's
is clockwise, `label_angle` is counterclockwise.

### Colour

- ~~Discrete colour sequences for multi-trace plots (`colorway`), not
  only continuous `colorscale`.~~ **Done** (`colorway=[...]`).
- Named palettes, consistent between 2D, 3D and contour/heatmap.

## 4. Output and verification

1. **Static image alongside the JSON.**  Optionally return an SVG/PNG
   (as `plot2d` does) so non-GUI callers — the Aximar MCP server,
   tests, LLM agents — can check a plot without a human looking at the
   GUI.  Today the MCP `run_cell` result for an `ax_draw2d` cell has
   `plot_svg: null`.  Likely host-side (Plotly `toImage` in the
   renderer, or kaleido), with an ax-plots option to request it.
   Meanwhile, rendering the emitted `.plotly.json` with plotly.py +
   kaleido 0.2.1 (bundled Chromium) in a throwaway venv works for
   checking output by eye; it is how the arrowhead issues above were
   found.  An `rtest`-adjacent script doing this would make a cheap
   visual regression check.
2. **Export.**  `ax_export(plot, "file.svg" | ".png" | ".html" | ".json")`.
3. ~~**Raw escape hatch.**~~ **Done** (2D, 3D; `layout_raw` also polar).
   `ax_trace(json_string)` to inject an
   arbitrary Plotly trace and `layout_raw=json_string` merged into the
   layout, so anything not yet wrapped is still reachable.

## 5. API shape

- ~~**Lists and groups.**~~ **Done** (2D, 3D).  List arguments are
  spliced, so `ax_draw2d(objs, title=...)` replaces
  `apply(ax_draw2d, append(objs, [...]))`; `group(objs..., opt=val)`
  applies options to its objects only.  Both expand before the main loop,
  so the reactive path sees a plain argument list.
- **Figure builder.**  An incremental figure value
  (`f: ax_figure()$  f: ax_add(f, lines(...))$  ax_show(f)`).  Less
  pressing now that lists work: `objs: endcons(..., objs)` then
  `ax_draw2d(objs)` covers most of it.  Should desugar to the same
  `ax_draw2d` argument list so the reactive path (`ax__replot`) keeps
  working.
- **Sticky vs per-object options** (§ 1.2): support both, document the
  precedence.

## 6. Diagram helpers

Grunt work left in the Penrose–Carter notebook after § 1–5:

1. ~~**Lists and groups**~~ (§ 5).  **Done.**
2. ~~**Path decorations.**~~ **Done** (2D).  `decoration="snake"` /
   `"zigzag"` on `lines` / `explicit` / `parametric`, with
   `decoration_wavelength`, `decoration_amplitude`, `decoration_pre`,
   `decoration_post` (TikZ's segment length, amplitude, pre/post length).
   End heads default the straight end to half a wavelength.  Data units, so
   it assumes `aspect_ratio=true`.  Specification and a plot2d/gnuplot reference
   implementation: https://gist.github.com/cmsd2/b19d20316b62719e10cd9e3840cdf2d2
3. ~~**Label pixel offsets.**~~ **Done.**  `label_offset=[dx, dy]` →
   annotation `xshift` / `yshift`.
4. **Label along a line.**  Place a label on a segment at fraction t, on
   one side, with the angle computed.  The angle must be in screen space,
   which depends on the host's margins (§ Host constraints).
5. ~~**Fit sizing**~~ **done**: `height=fit` derives the height from
   `width`, margins, the aspect ratio and both ranges.  **Label-aware
   ranges** remain open.  Plotly's autorange ignores annotations; an
   invisible marker trace sized to each label's text was tried and
   dropped: marker padding is symmetric (an anchored label needs twice
   its size) and Plotly abandons padding larger than the axis, so it
   over-widened one axis and did nothing to the other.  Doing it properly
   needs the data extent and pixel scale before Plotly's layout.
6. **Coordinate transforms.**  A `transform=f` option on curves and
   polygons, as in the draw package, plus `reflect="x"` / `"y"`.
7. ~~**Diagram preset.**~~ **Done**: `diagram=true` turns axes, grid,
   legend and hover off, locks the aspect ratio and sets `height=fit`;
   explicit options win.

## Host constraints

Some layout problems are in the renderer, not ax-plots.  Aximar
v0.14.0 `src/components/PlotlyChart.tsx` and `src/styles/global.css`:

- `.plotly-output { max-width: 700px; margin: 4px auto; overflow: hidden; }`
  — plots are capped at 700 px, **centred** (visible left indent in wide
  windows), and anything wider is clipped.
- `layout.margin` is **overwritten** with `{l:50, r:30, t:40, b:50}`
  after the spec is merged, so an ax-plots `margin` option (§ 3) has no
  effect in Aximar until the renderer merges instead of replacing.
- `paper_bgcolor` / `plot_bgcolor` are forced to `transparent`.

Proposed renderer changes (aximar, and the vscode-extension renderer
for parity): left-align (`margin: 4px 0`), use the spec's `width` as
`max-width` when fixed, and merge `spec.layout.margin` over the
defaults.  Until then ax-plots docs should state the 700 px cap and
fixed margins.

**Bundled copy drift.**  Aximar embeds its own `ax_plotting.mac`
(`crates/aximar-core/src/maxima/ax_plotting.mac`, 1474 lines at
v0.14.0) loaded at session start, which has fallen behind this package
(2214 lines; e.g. missing `logx`/`logy`, background defaults, the
aspect-ratio default height).  Either have aximar load the
mxpm-installed `ax-plots` when present, or sync the bundle as part of
each ax-plots release; otherwise every item above lands twice.

~~**Registry `numerics` lacks `compile_grid`.**~~  Fixed: the index now
pins `numerics` at `8fa7bf7`, which has `compile_grid`, so
`mxpm install numerics` setups get the `animate()` fast path.

## Suggested order

1. ~~§ 1 items 1–4 (coercion, per-object options, legend/hover, docs).~~
   Done.
2. ~~`label` with rotation and Unicode.~~ Done (2D).
3. ~~`vector` and arrowheads on curves.~~ Done (2D).
4. ~~`polygon` and `fill_between`.~~ Done (2D; fill between via `filled_func`).
5. ~~`margin`, numeric `aspect_ratio`, `constrain`, `autosize`.~~ Done;
   `margin` still needs the aximar renderer fix to take effect there.
6. Static image output (§ 4.1) for headless verification.
7. ~~Raw escape hatch (§ 4.3).~~ Done.
8. ~~Shapes~~, annotations, per-point markers, ~~axes/tick options~~ (done,
   2D, except `tickangle`), ~~legend title~~, ~~theme~~ (light/dark).
9. Figure builder (§ 5), subplots, 3D parity.

Items 1–5 are enough to reproduce the Penrose–Carter diagram at
roughly the fidelity of the source slide.

## Open questions

1. `label` via text traces (hoverable, legend-able, no rotation) or
   annotations (rotation, arrows, but layout-level so harder to
   animate per frame)?  Possibly both: annotations by default, text
   traces when the label participates in `animate()` frames.
2. LaTeX in labels: Plotly only renders `$...$` with MathJax loaded,
   while aximar ships KaTeX.  Unicode-only for v1, or a renderer hook
   that typesets with KaTeX?
3. Should the bundled aximar copy be retired in favour of the mxpm
   package (see § Host constraints)?
