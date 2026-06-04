# Reactive Views for Maxima — A Layered Architecture

Status: **partially shipped** (Components 1, 2, and the precomputed-
frames path of Component 5 are live; see [§ Implementation
status](#implementation-status) for the live table).  Originally
a north-star vision; pieces have landed as the design has held up
under contact with real code.

Scope: spans `numerics`, `ax-plots`, a new `reactive` / `widgets` / `views`
package family, the `aximar` MCP server, and the vscode-extension renderer.
Includes a small set of upstream-contributable hooks in Maxima core.

This document is the long-horizon companion to [animate.md](animate.md). It
captures the architectural target so that the immediate `animate(...)`
implementation can be aligned with it (and not paint itself into a corner)
without committing to building all of it now.

## Implementation status

What has actually shipped so far, by component number from
[§ Layered architecture](#layered-architecture):

| Component | What | Where | Status |
| --- | --- | --- | --- |
| 1 | `compile_grid(expr, [[var, lo, hi, n], ...])` | `numerics/lisp/core/compile_grid.lisp` | **shipped**; 3-7× speedup vs `subst+float` baseline |
| 2 | `signal()`, `widget_slider(name, lo, hi)`, `signal_set`, `resolve_signals`, registry | new `reactive` package | **shipped (v0)**; relies on explicit `resolve_signals` rather than a meval read hook |
| 3 | Subscription model | (renderer side) | not yet — currently the renderer pulls; subscription tables come with widgets |
| 4 | Widgets — bidirectional protocol | aximar push channel + renderer messaging + `widget_*` package | not yet — sliders work as a control over precomputed frames via `animate()`, but the live round-trip path doesn't exist |
| 5 | Views — compute / display separation | `views` package | partially: the precomputed-frames strategy is live as `animate()` in `ax-plots`; the `view` abstraction itself is not built |
| 6 | Streaming — incremental computation | `views` + `kernel-events` envelopes | the wire protocol exists (`stream_begin`/`frame`/`progress`/`stream_end` in `kernel-events`); no consumer yet |
| — | Maxima core: `meval` read hook | maxima `feature/kernel-events` | not yet — `collect_signals` walks expressions explicitly in the meantime |
| — | Maxima core: cooperative cancel | maxima `feature/kernel-events` | not yet — kernel-events package has `request-cancel`; without the core patch it's a no-op for stock loops |

See [§ Roadmap](#roadmap-rough-order-not-committed) at the bottom for
what's left and why.

## Summary

Stop treating "animation" as a primitive. Instead, build a layered system
where the primitive is the **signal** (a typed, ranged parameter), and the
abstraction is the **view** (a binding of a signal graph to a display target).
Animation, interactive widgets, streaming simulations, and live exploration
all fall out as different *strategies* the runtime chooses given the same
declarative input.

Crucially: **every layer is an opt-in package**, and Maxima core gains only a
small set of additive hooks that are no-ops when no package uses them. The
existing pattern (`load("numerics")`, `load("ax-plots")` compose with vanilla
Maxima) extends to the new packages. There is no parallel evaluator, no fork,
no incompatible type system.

## Why now / motivation

Three observations:

1. **`animate(obj, [param, lo, hi, n])`** as currently designed solves one
   case of a much more general problem. The wrapper-inside-`ax_draw*`
   placement is correct (see [animate.md](animate.md)), but the same input
   could drive: a slider with smooth client-side scrubbing; a live re-render
   each time the slider moves; a streamed simulation that produces frames
   over time; a side panel showing the parameter value as a symbolic
   expression instead of a plot. Today those are four separate engineering
   projects. They shouldn't be.
2. **The performance ceiling is set by `subst` + `float`**, not by the
   transport or the renderer. Until per-frame symbolic substitution gets
   faster, every animation system we build will inherit the same ~milliseconds-
   per-frame cost. A small package-level compiler (`compile_grid`) gives a
   10–100× speedup and unlocks everything downstream.
3. **The frontend (vscode-extension renderer) already does most of what we
   need**, and aximar already does half of bidirectional messaging (kernel →
   renderer). The remaining work is mostly Maxima-side: representing the
   computation in a form the runtime can sample, cache, and stream. That
   work *should* live in Maxima, not in the frontend, because it's
   re-usable across frontends (CLI replay, headless export, future renderers).

## Design constraints

These constraints are load-bearing and non-negotiable; the rest of the doc
should be read as solving the design problem *subject to them*.

1. **No fork.** Every component is an opt-in `load(...)`-able package or a
   small backwards-compatible hook in Maxima core. Users who never load any
   of this pay zero cost.
2. **Compose with vanilla Maxima.** A signal-valued expression must still
   work with `diff`, `integrate`, `solve`, `subst`, `ev`, `expand`, etc.
   Signals are values, not a parallel computation system. When a signal is
   bound (slider at a value), the expression simplifies to ordinary Maxima.
3. **No parallel evaluator.** All evaluation goes through `meval` (Maxima's
   main evaluator). Reactivity is implemented by *hooking* `meval`, not by
   replacing it.
4. **Use existing types where possible.** Lists, matrices, atoms, and
   strings already exist; don't reinvent them. Add new types (`signal`,
   `view`, `widget`) only where genuinely new semantics are needed.
5. **Core changes are minimal, additive, no-ops without the packages,
   upstream-contributable.** Anything we'd patch in Maxima itself should
   land as a PR to `maxima/maxima` that benefits the broader community,
   not as a private fork we maintain.
6. **Existing notebooks keep working unchanged.** New features are
   additive; nothing about today's `ax_draw2d(explicit(sin(x), x, -%pi, %pi))`
   changes.

## Layered architecture

```
   ┌──────────────────────────────────────────────────────────────────┐
   │ Layer 5: Display targets  (ax-plots, ax-tables, ax-3d, ax-eqn)   │
   │   render hints → Plotly frames, animated tables, three.js, KaTeX │
   └──────────────────────────────────────────────────────────────────┘
                                  ▲
   ┌──────────────────────────────────────────────────────────────────┐
   │ Layer 4: Views  (package: views)                                 │
   │   bind signal graphs to display hints; choose precompute vs live │
   └──────────────────────────────────────────────────────────────────┘
                                  ▲
   ┌──────────────────────────────────────────────────────────────────┐
   │ Layer 3: Widgets  (package: widgets)                             │
   │   slider, button, picker, click-on-plot; bidirectional protocol  │
   └──────────────────────────────────────────────────────────────────┘
                                  ▲
   ┌──────────────────────────────────────────────────────────────────┐
   │ Layer 2: Reactive  (package: reactive)                           │
   │   signal(), dependency tracking, sampling strategies             │
   └──────────────────────────────────────────────────────────────────┘
                                  ▲
   ┌──────────────────────────────────────────────────────────────────┐
   │ Layer 1: Compiled grid eval  (in: numerics)                      │
   │   compile_grid(expr, vars) → batched Float64 array               │
   └──────────────────────────────────────────────────────────────────┘
                                  ▲
   ┌──────────────────────────────────────────────────────────────────┐
   │ Layer 0: Maxima core  (small hooks: meval, displa, evalflag)     │
   │   no-op without the packages above                               │
   └──────────────────────────────────────────────────────────────────┘
```

Each layer can be loaded and used without the layers above it. `compile_grid`
alone is useful for `numerics` users who want fast batch evaluation with no
animation. `reactive` alone is useful for caching/dependency tracking in
non-visual code. `widgets` without `views` gives ipywidgets-style bindings
without the auto-rendering. Layers are additive, not all-or-nothing.

**A note on where state lives across this stack.** The Maxima kernel is
stateless about which views, widgets, and subscriptions currently exist
— it just evaluates expressions and reports which signals were read.
The vscode-extension renderer owns the subscription tables and the
displayed view nodes. The aximar MCP server is a stateless message
relay between the two. This mirrors Mathematica's frontend/kernel split
(the Cocoa/Qt frontend owns `Dynamic` subscription tables; the kernel
just evaluates), and it's what makes the kernel safely restartable
without losing the notebook's interactive state. See
[§ Prior art: Mathematica](#prior-art-mathematica) for the deeper
comparison.

## Component 1: `compile_grid` — fast batch evaluation

**Status:** **shipped** in `numerics/lisp/core/compile_grid.lisp`.
What follows describes the design as built, with the corrections
that came out of implementation.

**Lives in:** `numerics` (core module).  `load("numerics")` makes it
available; no separate package.

**What it is:** a function that takes a Maxima expression and a list of
variables-with-ranges, compiles to a tight Lisp loop, and returns the result
as a pre-allocated `Float64` ndarray.

```maxima
load("numerics")$

K: compile_grid(sin(k*x), [[k, 0, 1, 60], [x, -%pi, %pi, 500]])$
/* K is an ndarray of shape (60, 500), populated.  ~30ms. */
```

**Why it's first.** Every layer above depends on fast batch evaluation. With
today's `subst` + `float`, a 60×500 grid of `sin(k*x)` takes ~170ms;
with `compile_grid` it's ~30ms.  Smaller win than the original
projection (3-7× rather than 10-100×) — see the perf note below.

**Implementation, as built.** Uses Maxima's plot-internal
`coerce-float-fun` (`maxima/src/plot.lisp:443`) to translate the
expression to a CL lambda accepting double-float args — no new
translator needed; the one plot2d uses for the same job is already
present in stock Maxima and works for nearly every expression we
care about.  The inner loop writes to the tensor's backing
`simple-array` directly (computing the column-major offset by
hand) rather than going through `magicl:tref`'s dispatch — that
indirection was the dominant cost at small per-cell loads.
Fallback to `msubst`+`$float` per cell when `coerce-float-fun`
refuses an expression (rare in practice).

**Maxima core changes:** none.  `coerce-float-fun` and the magicl FFI
already exist; this is purely a numerics-package extension.

**Honest perf note.** The original design-doc number ("60×500 in
~5ms vs 3s") assumed a much heavier expression than `sin(k*x)` for
the baseline.  Measured on the shipping implementation:

| case | grid | `subst+float` | `compile_grid` | speedup |
| --- | --- | --- | --- | --- |
| `sin(k*x)` | 60×500 | 173 ms | 55 ms | 3.1× |
| `sin(k*x)` | 200×1000 | 1296 ms | 175 ms | 7.4× |
| `sin·exp` | 60×500 | 229 ms | 56 ms | 4.1× |
| 3-term × Gaussian | 60×500 | 420 ms | 121 ms | 3.5× |

The speedup scales better at larger grid sizes and richer
expressions.  Even at the modest end it's enough to drop the
default 60-frame animation from "noticeably slow" to "feels
instant".  An end-to-end perf surprise: when wired into `animate()`,
the sampling savings were initially eaten by per-frame JSON
construction — bigger wins came from caching the x-axis JSON
across frames (it's identical every time) and a faster
stringifier for known-finite double-floats.  See the matching
`ax__can_fast_sample_2d` path in `ax-plots/ax-plots.mac`.

**Generalisations enabled:** sweep grids over 1, 2, or 3 parameters; sample
ODE solutions on a `t`-grid; precompute Bayesian likelihoods over a parameter
mesh. None of these need animation; all of them benefit from this layer.

## Component 2: `signal()` — first-class parameters

**Status:** **shipped (v0)** as the `reactive` package at
`reactive/` in the workspace.  v0 uses explicit walk-based
dependency collection (`collect_signals` + `resolve_signals`); the
upstream `meval` read hook that would make tracking automatic is
**not yet sent**.

**Lives in:** new package `reactive`.

**What it is:** a Maxima primitive that declares a value as a named,
ranged parameter the runtime tracks.

```maxima
load("reactive")$

k : widget_slider("freq", 0.1, 5)$
/* k = signal("freq"); initial value 0.1 */
```

A signal is a noun form `signal(name)` where `name` is a string;
its current value is held in a global registry indexed by name (a
Lisp hash table on the kernel side).  Expressions that mention
`k` are *signal-valued* — they survive symbolic processing:

```maxima
diff(sin(k*x), x);
/* signal("freq") * cos(signal("freq") * x) */
```

Maxima happily differentiates, integrates, simplifies — the
signal noun form is transparent to those passes.  When the
expression needs a number (sampling, float coercion,
`compile_grid`), call `resolve_signals(expr)` first:

```maxima
resolve_signals(sin(k*x));    /* sin(0.1*x) */
signal_set("freq", 2.5)$
resolve_signals(sin(k*x));    /* sin(2.5*x) */
```

This is the load-bearing claim of "compose with vanilla Maxima":
the symbolic system never has to know about reactivity.

**Why v0 is explicit (`resolve_signals`) instead of automatic.**
The clean way is a `meval` read hook that registers any
signal-symbol read into a thread-local dependency set during view
evaluation.  That's the same primitive Solid / MobX use in JS;
in Maxima it's ~15-30 lines of Lisp around `meval1` in
`mlisp.lisp`.  v0 punts on this by walking the expression
explicitly with `collect_signals`, which works for figures
constructed in the obvious way (signals appear as leaves of the
expression) but misses signals hidden behind `ev`, user
functions, or `funmake`.  The upstream PR is the natural next
upgrade and the API doesn't change when it lands.

**Public API (shipped):**

| Function | Purpose |
| --- | --- |
| `widget_slider(name, lo, hi)` | register a slider signal; returns `signal(name)` |
| `signal_p`, `signal_name`, `signal_value`, `signal_meta`, `signal_list` | inspection |
| `signal_set(target, v)` | update current value |
| `collect_signals(expr)` | unique signal names appearing in `expr` |
| `resolve_signals(expr)` | substitute current values for every signal |
| `reactive_reset()` | drop the registry (tests / notebook restarts) |

**API design decisions worth noting:**

- *Atoms-keyed-by-string* (Recoil model).  The renderer thinks in
  names; the kernel thinks in expressions containing those names.
  No synthetic IDs.  See
  [§ Prior art: JS reactivity](#prior-art-js-reactivity) for why
  this is the right choice.
- *Global registry* by default; explicit scoping (per-notebook,
  per-cell) added when cross-leakage becomes a problem.  Same path
  Recoil took.
- Validation in `widget_slider`: name must be string,
  `lo < hi`, numeric bounds, etc.  Errors at construction not at
  use.

**Maxima core changes (when we add automatic tracking):** one.
The same `mlisp.lisp` `meval1` read hook described in
[§ Maxima core changes](#maxima-core-changes--minimal-hooks).
~15-30 lines, no-op without `reactive` loaded, upstream-
contributable on its own merits.

## Component 3: Subscription model — expression-level reactivity

**Lives in:** `reactive` (uses the core hook from Component 2).

**What it is:** the runtime mechanism that knows, for each *reactive
container* (a `view`, a widget update handler, etc.), which signals it
depends on. When a signal changes, only the dependent containers
re-evaluate — not whole cells, and certainly not the whole notebook.

This matches Mathematica's `Dynamic[expr]` model, which is **expression-
level** rather than cell-level: a `Dynamic` *anywhere* in any expression
subscribes that fragment to its referenced symbols, and only that fragment
re-runs on change. (See [§ Prior art: Mathematica](#prior-art-mathematica)
for the explicit comparison; this design choice is a deliberate departure
from Marimo and Pluto.jl, both of which are cell-level.)

```maxima
load("reactive")$

k: signal(0, 1)$
v: view(sin(k*x), hint = plot2d())$     /* v subscribes to k */
w: view(cos(k*x), hint = plot2d())$     /* w subscribes to k */
u: view(sin(x),   hint = plot2d())$     /* u does NOT subscribe to k */

set_signal(k, 0.5)$    /* re-evaluates v and w; u is untouched */
```

### How subscription frames work

The reactive container is the scoping device — no user-facing
`with_reactive` block needed. When the runtime begins evaluating a `view`
(or any reactive container), it pushes a dependency frame onto a
thread-local stack. The Component 2 read hook records signal reads into
the top frame. When the view's evaluation completes, the frame is popped
and registered as the view's subscription set.

```
push_frame()                            ─┐
  evaluate sin(k*x)                      │ frame records {k}
    read k → recorded                    │
    read x → not a signal, not recorded  │
pop_frame() → {k}                       ─┘
register subscription: view v ← {k}
```

Outside a reactive container, the frame stack is empty and the read hook
is a no-op. There is no cost for non-reactive code paths.

### Where subscriptions live

**In the renderer, not the kernel.** This is a critical architecture
choice borrowed directly from Mathematica (whose frontend owns the
`Dynamic` subscription tables). The kernel is *stateless* about which
views exist; it just evaluates when asked and reports which signals were
read. The renderer maintains:

- A table `signal_id → [view_id, …]`
- A table `view_id → render_target_dom_node`

When a widget posts `set_signal(k, 0.5)` through the controller, the
*renderer* looks up which views to re-render and asks the kernel to
re-evaluate just those. The kernel does not track "view v is currently
displayed in cell 3 of notebook X" — that's pure UI state.

Consequences:

- Reloading a notebook reconstructs subscriptions from the rendered views
  on demand, not from any kernel-side state.
- The kernel can be restarted without losing subscription topology
  (re-evaluation rebuilds it).
- Multiple frontends could subscribe to the same kernel session;
  subscription is per-frontend.

**Maxima core changes:** the same `meval` hook as Component 2. No
additional hooks.

**Cost estimate:** 1 week for the subscription-frame mechanism in the
`reactive` package; 2 weeks more for the renderer-side subscription table
and re-evaluation request protocol.

**Caveat — usability.** Expression-level reactivity is the right default
for *new* reactive constructs (views, widgets). Existing notebook cells
remain non-reactive — running them is still imperative and one-shot, just
as today. Reactivity is opt-in *by using a reactive construct*, not by
flagging a cell.

## Component 4: Widgets — bidirectional protocol

**Lives in:** new package `widgets`. Transport changes in `aximar` (MCP
server) and `vscode-extension` (renderer ↔ controller messaging).

**What it is:** a small library of UI primitives (`widget_slider`,
`widget_button`, `widget_pick_point`, `widget_text`) that each produce a
signal *and* render a control. The control is a Plotly slider, an HTML
button, a click-handler on the plot, etc.

```maxima
load("widgets")$

k: widget_slider(0, 1, label="frequency")$
ax_draw2d(explicit(sin(k*x), x, -%pi, %pi))$
```

When the user moves the slider, the renderer sends a message to the
controller, which sets the signal value. The renderer's subscription table
(Component 3) determines which views to re-render and asks the kernel to
re-evaluate just them.

### Control-spec sugar

Mathematica's `Manipulate` infers the widget type from the iterator shape;
we should do the same. The `widget(spec)` constructor dispatches on shape:

| Spec form | Inferred widget | Example |
|-----------|------------------|---------|
| `[lo, hi]` (numeric) | continuous slider | `k: widget([0, 1])` |
| `[lo, hi, step]` (numeric) | stepped slider | `n: widget([0, 100, 1])` |
| `[a, b, c, ...]` (list of values) | popup / dropdown | `mode: widget(["fit", "predict", "compare"])` |
| `[true, false]` | checkbox | `show_grid: widget([true, false])` |
| `[[xlo, xhi], [ylo, yhi]]` | 2D draggable point (click-on-plot) | `p: widget([[-1,1], [-1,1]])` |
| `[lo, hi, integer]` | integer slider | `n: widget([1, 10, integer])` |
| `[colour]` (atom) | colour picker | `c: widget([colour], default="red")` |
| `[text]` (atom) | text input | `s: widget([text])` |

The explicit `widget_slider(...)`, `widget_popup(...)`, `widget_pick_point(...)`
constructors remain available for the cases where inference is wrong or
where you want a specific widget regardless of spec shape. The sugar layer
just makes the common cases terse.

This is high UX leverage for tiny implementation cost: a dispatch table
on the shape of the spec list.

**Transport — the missing half of aximar.** Today aximar pushes results
kernel → renderer through the MCP `evaluate_expression` reply. We need a
push channel renderer → kernel: a new MCP tool `set_signal(signal_id,
value)` and a server-sent event stream for renderer → kernel notifications.
This is roughly a week of work in aximar (HTTP transport already exists)
plus protocol design.

**Renderer changes** — the vscode-extension renderer gains
`createRendererMessaging` wiring (VS Code API supports this natively, we
just haven't used it). Slider DOM events post messages to the controller;
controller forwards to aximar; aximar pushes to the kernel.

**Click-on-plot, drag, hover, select** — these are the killer use cases.
"Click on the phase portrait to set the initial condition for the
streamline" is one line of Maxima with widgets. Today it's impossible
without a custom webview.

**Maxima core changes:** none (uses Components 2 and 3). Widgets are pure
package.

**Cost estimate:** 2–3 weeks total — protocol design, aximar push channel,
renderer messaging, widget package implementation, tests.

## Component 5: Views — compute/display separation

**Lives in:** new package `views`.

**What it is:** a Maxima object that binds a signal graph (a computation)
to a *display hint* (what the renderer should make of it). Views are the
unifying abstraction that lets the same signal graph drive different
displays.

```maxima
load("views")$

v: view(
  sin(k*x),
  /* render hint: this is a 1D curve in x, parameterised by k */
  hint = plot2d(x_range = [-%pi, %pi])
)$
```

A `view` knows three things:
1. The expression (a signal-valued AST).
2. The display hint (one of `plot2d`, `plot3d`, `table`, `equation`, `text`,
   `scene3d`, …).
3. Sampling metadata (how many samples along each signal, default frame
   count, etc.).

The view object knows how to render itself:
- If hint is `plot2d`: dispatch to `ax-plots` to build a Plotly figure with
  frames (the current `animate()` path).
- If hint is `equation`: dispatch to a new `ax-eqn` package that renders
  step-by-step KaTeX morphs.
- If hint is `table`: dispatch to a new `ax-tables` package.
- If hint is `scene3d`: dispatch to a future `ax-3d` package using three.js.

`animate()` becomes a *convenience wrapper* over `view` with the plot2d
hint. The wrapper is still useful (`animate(obj, [k, 0, 1])` is shorter
than the full view declaration), but it's no longer the abstraction.

**Strategy selection.** The view decides whether to precompute frames
(paradigm 2, today's `animate`) or evaluate live on signal change
(paradigm 1, Desmos/Marimo) based on:
- Cost estimate (number of samples × cost per sample, from `compile_grid`'s
  profiling).
- Display target's update model (Plotly frames want precompute; tables can
  do either; equations want live).
- User override (`view(..., strategy = "live")`).

**Maxima core changes:** none. Views are pure package.

**Cost estimate:** 1 week for the abstraction + plot2d/3d dispatch. Other
display targets (equation, table, scene3d) are additive packages, each
2–4 weeks depending on scope.

## Component 6: Streaming — incremental computation

See [kernel-events.md](kernel-events.md) for the transport protocol
and general envelope schemas, and [streaming.md](streaming.md) for
streaming-specific envelopes, cancellation, and the SUNDIALS-based
proof of concept. Summary below.

**Lives in:** `aximar` transport layer + `views` (consumes the stream).

**What it is:** a protocol for the kernel to emit intermediate results
during a long evaluation, with the renderer playing them as they arrive.

Use cases this opens:
- ODE integration: each timestep emits the current state; the renderer
  shows the trajectory growing.
- MCMC: each sample updates a histogram or trace plot live.
- Gradient descent: each iteration shows the parameter vector and loss.
- Search: each candidate evaluated updates a leaderboard.

**Why it's last in the stack.** Streaming requires reactive (so the
renderer knows what to update), widgets (to pause/resume/cancel), and
views (to know how to display intermediate state). It's the last building
block on top of the rest.

**Transport.** Server-sent events from aximar to renderer, with a defined
message envelope (`{view_id, frame_index, partial_data}`). The kernel
calls `emit_frame(view_id, data)` from `.mac` code; aximar pushes; renderer
appends.

**Maxima core changes:** one optional hook for cooperative interruption.
Without it, a long stream blocks the kernel from accepting `set_signal`
messages (so the user can't change parameters mid-simulation). With it,
every `meval` step checks a thread-local cancellation flag. This is
~30 lines in `mlisp.lisp`, again upstream-contributable as a generic
"interruptible evaluation" feature.

**Cost estimate:** 2 weeks for the transport + the consumer side in views.
The cooperative interruption upstream patch is a longer process (it
touches a hot path; review cycle could be months).

## How they compose — worked example

Consider: "watch a damped harmonic oscillator's phase portrait evolve, with
sliders for damping coefficient and natural frequency, and the user can
click on the phase plane to set the initial condition."

```maxima
load("numerics")$
load("reactive")$
load("widgets")$
load("views")$
load("ax-plots")$

/* Signals — three things the user controls */
zeta:  widget_slider(0, 1, default=0.1, label="damping")$
omega: widget_slider(0.5, 5, default=1, label="ω₀")$
ic:    widget_pick_point(default=[1, 0])$    /* click on plot to set */

/* Computation — depends on all three signals */
sol: ode_solve(
  [diff(y, t, 2) + 2*zeta*omega*diff(y, t) + omega^2*y = 0],
  y, t,
  initial = ic,
  t_range = [0, 20*%pi/omega]
)$

/* View — phase portrait + streaming as the solver runs */
view(
  ax_streamline(sol, x, -3, 3, y, -3, 3),
  hint = plot2d(aspect_ratio = true),
  strategy = "stream"   /* show trajectory growing as integrator runs */
)$
```

What happens when the user changes a slider:
1. Slider widget posts `set_signal(omega_id, 1.5)` to the controller.
2. Controller forwards to aximar, which calls `set_signal` in the kernel.
3. The hook from Component 2 records that `sol` and the view depend on
   `omega`.
4. Component 3 invalidates the view's cached frames and re-evaluates `sol`.
5. Because `strategy = "stream"`, the ODE solver emits frames as it
   integrates; aximar pushes each frame; the renderer appends to the
   trajectory in real time.
6. If the user moves the slider again before the integration finishes,
   Component 6's cooperative interruption cancels the running integration
   and starts the new one.

All six layers participate; none of them know about the others except
through their declared interfaces.

## Maxima core changes — minimal hooks

A summary of every upstream-contributable change. Each is additive,
no-op-without-package, and benefits the broader Maxima community.

| Hook | Location | Purpose | Without it |
|------|----------|---------|------------|
| Evaluation-time symbol read hook | `mlisp.lisp:meval1` | Records signal dependencies | No reactive |
| Cooperative cancellation flag check | `mlisp.lisp:meval` (every N steps) | Interruptible long-running evals | Streaming blocks kernel |
| Optional: structured rich-result channel | `displa.lisp` | Cleaner attachment passing than temp files | Use today's `.plotly.json` temp-file pattern |

The first two are the only *required* core changes; the third is a
quality-of-life improvement we can defer indefinitely (the temp-file
pattern works fine).

Each lands as a separate upstream PR with a generic motivation. If upstream
rejects, we maintain a small patch series — but the API surface is so small
(two hooks, ~50 lines total) that even a rejected upstream is sustainable
as a thin patch.

## Usability story

The system has three usability surfaces, addressed separately:

**1. Existing user.** Loads `ax-plots` as today. Writes `ax_draw2d(...)`.
Nothing changes. Everything in this document is invisible.

**2. Animation user.** Loads `ax-plots` and writes
`ax_draw2d(animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0, 1]))$`.
Internally, `animate` desugars to a `view` with plot2d hint, but the
surface API stays terse. No need to learn about signals, views, or
strategies until they want to.

**3. Interactive user.** Wants click-on-plot, multiple sliders, live
recomputation. Explicitly opts in:

```maxima
load("widgets")$
k: widget_slider(...)$
ax_draw2d(explicit(sin(k*x), ...))$
```

The complexity is graduated — each layer is opt-in, each layer is a
concrete vocabulary expansion, none of it leaks into simpler usage.

**Anti-goal.** Don't make notebook authors write `view(..., hint=...,
strategy=...)` for the common case. The convenience wrappers (`animate`,
`widget_slider`, etc.) are the user-facing API; `view` is a power-user /
package-author primitive.

## Performance story

Performance budget for the common case (1 animated parameter, 1 curve, 60
frames, 500 x-samples):

| Layer | Today | With this system |
|-------|-------|------------------|
| Sampling | 60 × 500 × ~100µs subst = 3s | `compile_grid` 60 × 500 = 5ms |
| JSON serialisation | ~50ms | ~50ms (unchanged) |
| Renderer load | ~500ms first plot | ~500ms first plot |
| Per-frame Plotly redraw | ~2ms | ~2ms (unchanged) |
| Slider scrub responsiveness | bounded by Plotly | bounded by Plotly |

The headline number: **3 seconds → 5 milliseconds** for the sampling pass,
courtesy of `compile_grid`. This is the single most valuable component.

For the live (Desmos-style) case:

| Operation | Target | Realistic |
|-----------|--------|-----------|
| Slider move → re-evaluation start | <1ms | ~5ms (transport) |
| Re-evaluation | <16ms (60fps) | 1–10ms (`compile_grid` + cache) |
| Re-render | <16ms | ~2ms (Plotly restyle) |
| Total latency | <33ms | ~10–20ms |

This is feasible for the common case (1D curves, simple expressions). For
expensive computations (PDE solutions, large simulations) the strategy
selector should choose precompute (paradigm 2) automatically.

## Ecosystem story — avoiding the split

This is the constraint that shaped the architecture; restating the
guarantees explicitly:

1. **All packages are `load`-able.** No special build flags, no
   compile-time choices. A user with stock Maxima installs `numerics`,
   `reactive`, `widgets`, `views` independently as needed.
2. **Core changes are upstream PRs**, not a fork. If upstream lands them
   (likely — they're generic and small), there's nothing to maintain.
   If upstream rejects, we maintain a 50-line patch series, distributed
   via the `mxpm` package manager as an optional core patch.
3. **Signal-valued expressions are still Maxima expressions.** Every
   Maxima operator works on them (diff, integrate, solve, expand, …).
   Bound signals collapse to numbers; symbolic operations propagate the
   signal dependency. There is no signal-specific operator zoo.
4. **No new evaluator.** Everything goes through `meval`. The only
   addition is a thread-local read hook that records dependencies into a
   subscription frame; outside a reactive container (Component 3) the
   frame stack is empty and the hook is a no-op.
5. **Types are minimal.** `signal`, `widget`, and `view` are the only
   new types. They use Maxima's `defstruct` machinery so they print, get
   passed around, and serialise like other Maxima objects.
6. **Existing packages keep working.** `numerics` gains `compile_grid`
   but its other functions are unchanged. `ax-plots` gains the `animate`
   wrapper but its existing functions are unchanged. There is no
   "ax-plots v2" — features are additive.
7. **Fall-back paths everywhere.** `compile_grid` falls back to
   `subst`+`float` when an expression can't be translated. `widgets` work
   in a non-interactive frontend (slider becomes a noop with the default
   value). `views` with `hint=plot2d` work in a frontend that doesn't know
   about views (it just sees a Plotly figure).

The acid test: a user installs stock Maxima from upstream, loads
`ax-plots`, and runs a notebook that uses `animate()`. Animation works.
They install `widgets` and use a slider in the next notebook. The slider
works. They never have to know about `view`, `signal`, or the strategy
selector. They never have to leave the Maxima ecosystem.

## Prior art: Mathematica

Mathematica's `Manipulate` / `Dynamic` / `Animate` / `Locator` / `Compile`
/ CDF stack has analogs for **every one of our six layers**, bundled into
one product. The architecture is not novel — it's 20+ years of validated
prior art. This section maps each of our layers to its Mathematica analog
and names the deliberate departures.

### Mapping

| Our layer | Mathematica analog | Notes |
|-----------|---------------------|-------|
| 1. `compile_grid` | `Compile[]`, `CompilationTarget -> "C"` | Mathematica does not auto-compile inside `Manipulate`; users must wrap manually. We auto-route — see "improvements" below. |
| 2. `signal()` | `DynamicModule[{x = …}, …]` local symbols + `Slider[Dynamic[x]]` | Same shape: a typed, ranged, bound parameter with reactive identity. |
| 3. Subscription model | `Dynamic[expr]` + automatic free-symbol tracking + `TrackedSymbols` override | We borrow expression-level scoping wholesale. |
| 4. Widgets | `Manipulate` control specs + `Slider`/`Locator`/`Checkbox`/`PopupMenu` primitives | Control-spec sugar adopted directly (Component 4). |
| 5. Views | `Dynamic[Plot[…]]`, `Manipulate[Plot[…], …]` | Mathematica fuses computation + display via `Dynamic` wrapping; we separate them explicitly into `view` because we want multiple display targets (plot, equation, table, scene). |
| 6. Streaming | `Refresh[]`, `ProgressIndicator[]` (both weak) | No real analog — Mathematica's kernel is synchronous within an evaluation. We're ahead here. |

### What we steal

1. **Expression-level reactivity.** `Dynamic[x]` works anywhere — inside
   a plot title, inside a list, inside another `Dynamic`. Only the
   specific fragment re-evaluates on change, not the enclosing cell.
   This is the single biggest design lesson and shaped Component 3.
2. **Control-spec sugar for widget inference.** `Manipulate[expr, {a, 1,
   5}]` → slider; `{a, {True, False}}` → checkbox; `{a, {"x","y","z"}}`
   → popup; `{a, Locator}` → click-on-plot point. High UX leverage for
   tiny implementation cost. Adopted in Component 4.
3. **`TrackedSymbols` manual override.** When automatic dependency
   tracking is wrong (too noisy or missed a dependency), Mathematica
   lets you specify the set explicitly. We need the same escape hatch.
4. **Separate gesture handling from kernel writes.** Mouse-drag events
   in Mathematica are handled entirely frontend-side; only the
   committed value (mouse-up, with `ContinuousAction -> False`) round-
   trips to the kernel. The raw mouse stream never touches the
   evaluator. Adopted in Component 4: widget DOM events stay in the
   renderer until a value is committed, then go through aximar to the
   kernel.
5. **Subscription state lives in the renderer.** Mathematica's frontend
   (Cocoa/Qt) owns the `Dynamic` subscription tables; the kernel just
   evaluates when notified. We mirror this — the vscode-extension
   renderer owns the subscription tables (Component 3); the Maxima
   kernel is stateless about which views exist.

### Where we improve

1. **Automatic `compile_grid` routing.** Mathematica's `Manipulate` does
   **not** auto-invoke `Compile`. Users must hand-write
   `f = Compile[{x, a}, sin[a x] + cos[a x^2]]` and call `f[x, a]`
   inside `Manipulate` themselves. This is a well-known foot-gun and
   the primary reason Mathematica animations are often slower than
   they should be. Our reactive layer auto-detects numeric
   subexpressions and routes them through `compile_grid` without user
   intervention. (Ref: Wolfram, `ref/Compile`.)
2. **Strategy selector (precompute vs live).** Mathematica's `Animate`
   is *always* live — even when a monotonic-timer-driven sweep over
   expensive computation would be vastly better served by precomputing
   60 frames once. We pick automatically based on cost. See Component 5.
3. **Streaming / progressive computation.** Mathematica has no native
   "yield intermediate results from a long evaluation" mechanism. Our
   streaming protocol (Component 6) is a genuine differentiator — ODE
   integration, MCMC, gradient descent, search all become natively
   animatable as they compute.
4. **In-flight cancellation.** A known Mathematica wart is that
   `Manipulate` evaluations pile up when the user drags faster than
   the kernel can keep up. Our cooperative interruption hook (the
   second small `meval` patch in [§ Maxima core changes —
   minimal hooks](#maxima-core-changes--minimal-hooks)) addresses
   this from the start.

### What we deliberately don't copy

1. **Lack of paradigm selection for `Animate`** — we always evaluate
   cost and pick.
2. **Manual `Compile` invocation** — we auto-route.
3. **No cancellation of in-flight evaluations during slider drag** — we
   cancel.
4. **The monolithic bundling of `Manipulate`.** Mathematica fuses
   widget + reactivity + view + display into one construct. We
   deliberately layer them so each is composable. This is the cost
   we pay for not being a single-vendor product; it's also the reason
   our system can have multiple display targets without rewriting the
   reactive substrate.

### A note on architectural constraint

Mathematica has two things Maxima can't easily copy:

1. **WSTP binary protocol with zero-copy packed arrays** between
   frontend and kernel. Our transport (aximar/MCP/JSON) is textual.
   Mitigation: `compile_grid` returns native ndarrays the renderer can
   blit, and large numeric payloads can use the deferred binary mime
   type from [animate.md § Transport format](animate.md) if needed.
2. **Single-process integration.** Mathematica's frontend and kernel
   are tightly coupled with shared memory and a custom IPC. We have
   three processes (renderer / extension / aximar) and a network
   transport. This adds latency (a few ms per round-trip) but the win
   is multi-frontend support and clean process isolation. Worth the
   trade.

**Primary sources:**
- Wolfram, [*Introduction to Dynamic Interactivity*](https://reference.wolfram.com/language/guide/IntroductionToDynamicInteractivity.html)
- [ref/Manipulate](https://reference.wolfram.com/language/ref/Manipulate.html)
- [ref/Dynamic](https://reference.wolfram.com/language/ref/Dynamic.html)
- [ref/Animate](https://reference.wolfram.com/language/ref/Animate.html)
- [ref/Compile](https://reference.wolfram.com/language/ref/Compile.html)
- [ref/Locator](https://reference.wolfram.com/language/ref/Locator.html)
- Theodore Gray, *"Manipulate: The Story"* (Wolfram Blog, 2007)

## Prior art: JS reactivity

The JS ecosystem spent 2018–2024 converging from many directions on
roughly the same architecture for reactive state.  Solid signals,
Jotai/Recoil atoms, MobX observables, Vue 3 refs, and Svelte runes all
landed on the same shape: identity-bearing containers of a current
value, automatic dependency tracking, surgical updates to whatever
reads them.  This convergence is direct evidence the model works at
scale and across very different problem domains; importing it
shortens our design conversation by years.

### Mapping

| Our piece | JS analog | Same idea? |
| --- | --- | --- |
| `signal()` noun form with a registered name | Jotai atom keyed by string; Recoil atom; Solid `createSignal`; Vue `ref()` | Yes — atom with identity |
| `collect_signals` + `resolve_signals` (manual walk) | MobX/Solid auto-tracking via a "running reactive context" | Same goal; manual today, will become automatic when the `meval` read hook lands |
| `signal_set("freq", v)` | Zustand `set(state => ({ k: v }))`; Solid signal setter | Same — explicit mutation |
| (future) `derived(...)` | Solid `createMemo`; Jotai derived atom; MobX `computed` | Same |
| (future) selector subscription per view | Zustand selector subscription; Recoil `useRecoilValue` per atom | Same — view depends on the specific atoms it reads, not "all state" |
| Renderer pulls "what's the figure look like now" via a Tauri command | RxJS pull stream / React Query refetch | Same |
| (future) coalesce queued renders for the same `(view, signal)` | TanStack Query mutation deduplication; RxJS `switchMap` | Same |

### What we steal

1. **Atoms-with-string-keys is the right primitive** (Recoil model).
   We picked this independently and JS validates it: it's the smallest
   API that gives you identity, persistence across re-renders, and
   serialisable references.  `widget_slider("freq", …)` registers
   under `"freq"`, the renderer thinks in that string, the kernel
   thinks in the expression containing `signal("freq")`.  No synthetic
   IDs, no opaque tokens.

2. **Debounce / throttle on the renderer side** is mandatory, not
   nice-to-have.  Slider drag fires 60–120 events/second; our
   recompute cost is hundreds of milliseconds.  Without debouncing,
   the kernel queue grows two seconds behind the cursor.  Standard
   recipe: leading-edge fire (first event renders immediately so the
   curve moves), trailing-edge re-fire on release (final value is
   authoritative), in-between drags coalesce.  Belongs in Component
   4's renderer-side widget code, with backup at the aximar queue
   layer.

3. **Stale-while-revalidate** (TanStack Query / SWR).  While the
   kernel is recomputing after a slider event, the renderer keeps
   showing the previous figure (greyed-out, "updating…") rather than
   blanking it.  For animations specifically, our existing `animate()`
   precomputed frames *are* this cache — a reactive view can render
   the nearest cached frame instantly during drag, then refine to a
   true single eval when the user settles.  This is a real opportunity
   that doesn't exist cleanly in JS land (their "frames" aren't
   pre-sampleable from arbitrary expressions).

4. **Selector subscription, not "global re-render"** (Zustand,
   Recoil, Solid).  When only `k` changes, only views that depend on
   `k` re-eval.  We get this for free from `collect_signals`: the
   renderer doesn't track dependencies; it just sends
   `(view_id, signal_name, value)` and the kernel decides per view
   based on whether the view's expression contains the signal.  No
   shared global "store" that everyone re-renders against.

5. **`meval` read hook = MobX / Solid "reactive computation
   context"**.  Exactly the same primitive lifted into a symbolic-eval
   setting: while code runs inside view V, any signal read during
   meval is recorded as a dep of V.  Catches the `ev` / user-function
   cases that explicit `collect_signals` walking misses.  This makes
   the `meval` upstream PR more obviously the right thing — it's the
   piece every JS reactive library converged on, expressed for
   Maxima.

6. **Scope is global by default, override with explicit scope**
   (Recoil, Zustand).  Default: every cell's `widget_slider("freq", …)`
   hits the same registry slot.  Re-running a cell re-binds the signal
   at its bounds.  Explicit per-notebook / per-cell scoping is added
   when cross-leakage becomes a problem — the JS ecosystem reached
   this decision the same way (Recoil started global, added
   `RecoilScope` later).

### What we deliberately don't copy

1. **Component composition / re-render trees.**  React's whole
   architecture pivots on "parent re-rendered → children re-render
   unless memoised".  We have figures, not component trees.  The
   mental model "a view is a leaf" is correct.  Importing
   children-of-children patterns would be overhead for no benefit.

2. **Hook dependency arrays** (`useEffect([dep1, dep2])`).  Famously a
   bug factory.  We have actual expressions; we introspect them.
   Don't fake-emulate hooks.

3. **Two-way binding.**  Slider position flows renderer → kernel;
   the resulting figure flows kernel → renderer.  One-way each
   direction is correct.  Angular 1's `$watch` and Vue 2's
   `v-model` taught everyone this lesson; we don't need to relearn it.

4. **Implicit deep tracking through Proxies** (early MobX, Vue 2's
   deep-reactivity).  Lazy / identity / array-mutation bugs.  Solid
   moved to fine-grained explicit signals for the same reason.
   `collect_signals` walking the expression is sturdier.

5. **The "render is pure, side effects in `useEffect`" rule.**  Our
   "render" is a Maxima eval that may print to stdout, modify
   globals, throw `merror`, enter dbm, emit `display` envelopes.
   We can't pretend it's pure.  Embrace the side effects; make them
   observable through kernel-events envelopes.

6. **Time-travel devtools** (Redux DevTools, MobX devtools).
   Premature.  Optional later; not on the critical path.

7. **`useMemo` keyed by call site.**  React memoises by
   `(component, args)`.  We memoise by `(expression, signal-values-
   tuple)` — sturdier; the expression *is* the cache key.  Sketched
   as a future `cached(expr)` helper, not as call-site memo.

### Where we improve

1. **Symbolic substrate.**  A JS signal holds an opaque value.  Our
   signal sits inside a Maxima expression and survives `diff`,
   `integrate`, `simplify`, etc.  You can take a derivative of
   `sin(signal("k") * x)` and the derivative still tracks the
   signal.  Nothing in the JS world does this — they can't, the
   substrate is just JS values.

2. **Compile cache vs interpret pipeline.**  Solid recompiles its
   reactive dataflow on every state change.  Our compile path
   (`compile_grid`) caches a translated Lisp function per
   expression — once compiled, slider changes only re-invoke the
   cached lambda with new args.  10–100× edge for repeated evals
   of the same expression family.

3. **Cross-language evaluation boundary.**  RxJS et al. assume the
   evaluator is the same runtime that drives the UI.  Our evaluator
   is a separate process (Maxima), the UI is in another (renderer),
   transport is over a socket / pipe.  Latency cost is real (~ms per
   round-trip) but the win is multi-frontend support: the same
   `signal` / `widget` API works for the Tauri app, VS Code
   extension, and CLI replay without rewriting the reactive layer.

### A note on what JS can't help with

JS reactivity is overwhelmingly about *managing a DOM tree's
relationship to changing state*.  Our problem is *managing a Maxima
session's relationship to UI control state*.  Three differences are
load-bearing:

- We have one kernel, not millions of DOM nodes.  Granularity
  doesn't have to be ultra-fine.
- Our "renders" cost hundreds of ms, not 16 ms.  Debounce + cache
  become structural, not optimisations.
- We have stateful symbolic objects (Maxima expressions).  They're
  not pure data; they're code with eval semantics.  The framework
  layer can be smaller because the substrate is smarter.

**Primary sources:**
- Ryan Carniato, [*Building a Reactive Library from Scratch*](https://dev.to/ryansolid/building-a-reactive-library-from-scratch-1i0p) (Solid's reactive primitives)
- Jotai documentation, [*Primitives*](https://jotai.org/docs/basics/primitives)
- Recoil, [*Atoms*](https://recoiljs.org/docs/basics/atoms-selectors/) (selector-based subscription)
- Zustand, [*Slices pattern*](https://zustand.docs.pmnd.rs/guides/slices-pattern) (selector + immutable update)
- TanStack Query, [*Background Fetching Indicators*](https://tanstack.com/query/latest/docs/framework/react/guides/background-fetching-indicators) (stale-while-revalidate)
- RxJS, [*Operators*](https://rxjs.dev/guide/operators) (debounce, throttle, switchMap)

## How `animate()` fits in

The immediate work in [animate.md](animate.md) is paradigm-2
(precomputed frames) and lives entirely in `ax-plots`. This document does
not change that work. What it does is:

1. **Names the eventual desugaring.** `animate(obj, [k, lo, hi, n])` is
   sugar for `view(obj, hint=plot2d(), strategy="precompute_frames",
   signals=[k: signal(lo, hi, samples=n)])`. When `views` exists, we move
   the implementation but keep the surface.
2. **Constrains the implementation now.** Don't hardcode "animation =
   Plotly frames" anywhere outside the rendering dispatch. Specifically:
   the frame-generation logic should be reusable for non-Plotly display
   targets later, even if today it only emits Plotly JSON.
3. **Identifies the first follow-up.** Add `compile_grid` to
   `numerics`. This is independently valuable, accelerates the
   `animate()` path by 100×, and is the prerequisite for everything else.

## Open questions

1. **Strategy selection heuristics.** When should `view` choose
   precompute vs live? A simple cost-model (samples × estimated cost per
   sample) is probably enough, with user override always available. To
   be designed during Component 5. Mathematica conspicuously lacks
   this — its `Animate` is always live, even when frames would be
   vastly better — so there's no prior art to copy here. We're on our
   own.
2. **Backwards compatibility of upstream patches.** What if upstream
   rejects the `meval` read hook? We can fall back to inspecting
   expressions at view-construction time (slower, less precise), but
   it changes the reactive semantics slightly — specifically, indirect
   reads through `OwnValues` may not be tracked. Document the
   trade-off. (Mathematica's `TrackedSymbols` is the manual escape
   hatch for this exact case; we should provide an equivalent.)
4. **Widget identity across re-renders.** When a cell re-executes, do
   widgets keep their values, or reset to defaults? Marimo keeps them
   (good UX, requires identity tracking); Jupyter resets (simpler).
   Initial proposal: keep them, identified by a hash of the source
   position + name.
5. **Interaction with Maxima's `display2d` / `texput` / etc.** Signals
   in display contexts may want to render as their current value or as
   the symbol. Decide per context.

## Roadmap (rough order, not committed)

1. ~~Ship `animate()` per [animate.md](animate.md).~~ **Shipped.**  See
   `ax-plots/ax-plots.mac` `ax_draw2d`/`ax_draw3d` animation path and
   `ax-plots/examples/animations.macnb`.
2. ~~Add `compile_grid` to `numerics`.~~ **Shipped.**  See
   `numerics/lisp/core/compile_grid.lisp`.  Honest perf: 3-7×
   speedup vs `subst+float` baseline depending on grid size and
   expression complexity; design-doc 100× projection assumed a
   heavier baseline than `sin(k*x)`.
3. ~~Use `compile_grid` from `ax-plots` for `animate()` frame
   generation.~~ **Shipped.**  End-to-end ~2.7× speedup on the
   common case.  Bigger savings turned up not from the sampling
   step but from caching the x-axis JSON across frames and using a
   faster per-element stringifier for known-finite floats — see
   `ax__can_fast_sample_2d` / `ax__bulk_sample_explicit_2d` in
   `ax-plots/ax-plots.mac`.
4. **Partially shipped:** `reactive` package v0 lives at
   `reactive/` in the workspace.  Provides `widget_slider`,
   `signal_set`, `collect_signals`, `resolve_signals`, registry.
   The `meval` read hook upstream PR is **not yet** sent;
   `collect_signals` walks expressions explicitly as the v0
   substitute.  Sketch of the PR is in
   [§ Maxima core changes](#maxima-core-changes--minimal-hooks).
5. Build `widgets` integration layer: ax-plots emits `_reactive`
   metadata when an expression contains signals, aximar gains a
   `set_signal_and_replot` Tauri command + queue coalescing, Tauri
   renderer (and later vscode-extension) adds slider UI that
   debounces drag events.  ~1 week of work; this is the next concrete
   piece.
6. Build `views` abstraction; refactor `animate()` to desugar through
   it; non-breaking.  (~2 weeks)
7. Build streaming protocol + cooperative interruption upstream PR.
   The streaming **wire format** already exists as the
   `stream_begin`/`frame`/`progress`/`stream_end` envelopes shipped
   in [kernel-events](kernel-events.md); what's missing is the
   producer side in views, and the upstream `mdo` patch for
   cooperative cancel.  (~3-4 weeks plus upstream review tail)
8. Additional display targets (`ax-eqn`, `ax-tables`, `ax-3d`) as their
   use cases mature.

Total remaining: ~6-8 weeks of focused work to reach the worked
example in [§ How they compose](#how-they-compose--worked-example).
About a third of the roadmap is already done in the workspace.

## References

- [animate.md](animate.md) — immediate implementation, paradigm 2
- [kernel-events.md](kernel-events.md) — events-channel protocol
  (foundation of Components 4 and 6)
- [streaming.md](streaming.md) — first consumer of the events channel
  (Component 6 in detail)
- [numerics architecture](../../../numerics/doc/design/architecture.md) —
  the foundation `compile_grid` extends
- Mathematica:
  - [Introduction to Dynamic Interactivity](https://reference.wolfram.com/language/guide/IntroductionToDynamicInteractivity.html) — the closest prior art for the full stack
  - [ref/Manipulate](https://reference.wolfram.com/language/ref/Manipulate.html), [ref/Dynamic](https://reference.wolfram.com/language/ref/Dynamic.html), [ref/Animate](https://reference.wolfram.com/language/ref/Animate.html), [ref/Compile](https://reference.wolfram.com/language/ref/Compile.html), [ref/Locator](https://reference.wolfram.com/language/ref/Locator.html)
- [Marimo: Reactive programming model](https://docs.marimo.io/guides/reactivity/) — cell-level reactivity (departed from)
- [Pluto.jl: How reactive notebooks work](https://plutojl.org/en/docs/expressionexplorer/) — cell-level reactivity (departed from)
- [Plotly: Animations](https://plotly.com/javascript/animations/) — paradigm-2 frames
- [Desmos: Activity Builder graphing](https://www.desmos.com/calculator) — expression-level reactivity UX target
- VS Code notebook renderer messaging API (`createRendererMessaging`)
