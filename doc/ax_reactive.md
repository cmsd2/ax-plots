### Reactive plots

With the [reactive](https://github.com/cmsd2/maxima-reactive) package
(`mxpm install reactive`), a plot can depend on named parameters, called
*signals*, that the reader changes with a slider or other control.  The host
shows a control for every signal in the plot and redraws the plot when one
changes.

A signal is created by a widget function and stays symbolic, so it can be
used anywhere in an expression, including inside `diff` or `integrate`:

| Function | Control | Value |
|----------|---------|-------|
| `widget_slider(name, lo, hi)` | slider | a number in `[lo, hi]`, initially `lo` |
| `widget_number(name, lo, hi, initial)` | number box | a number in `[lo, hi]` |
| `widget_checkbox(name, initial)` | checkbox | `0.0` or `1.0` |
| `widget_dropdown(name, [c1, c2, ...])` | drop-down list | one of the choices |

`signal(name)` refers to an existing signal by name, and
`reactive_reset()` clears them all.  See the `reactive` documentation for
the rest of its API.

#### Examples

```maxima
load("ax-plots")$
load("reactive")$

/* One slider */
ax_draw2d(explicit(sin(widget_slider("freq", 0.1, 5) * x), x, -%pi, %pi),
          yrange=[-1.2, 1.2])$

/* A signal bound to a variable can be used more than once */
d : widget_slider("damping", 0.05, 1.5)$
ax_draw2d(explicit(exp(-d*x) * cos(6*x), x, 0, 6),
          explicit(exp(-d*x), x, 0, 6, dash="dot"))$

/* 3D works the same way */
ax_draw3d(explicit(sin(widget_slider("kx", 0.2, 3) * x) * cos(y),
                   x, -%pi, %pi, y, -%pi, %pi))$
```

The `examples/reactive-sliders.macnb` notebook has more.

#### How it works

A plot whose objects contain signals carries a `_reactive` block listing
them (name, kind, range, current value), and is registered under a view id.
When a control changes, the host sets the signal and asks ax-plots to draw
the view again with the new value.  Plots without signals are unaffected,
and nothing changes when `reactive` isn't loaded.

This needs ax-plots 0.2.0 or later with `reactive` at commit `897a88b` or
later, and a host that renders the controls: Aximar built from its June 2026
`master` onwards.  `animate` and signals can't be combined in one plot.

See also: `ax_draw2d`, `ax_draw3d`, `animate`
