### Function: animate (object, [param, lo, hi]) / animate (object, [param, lo, hi, n])

Animates a draw object over a parameter.  Use it inside `ax_draw2d` or
`ax_draw3d` in place of the object: `object` is drawn at `n` values of
`param`, evenly spaced from `lo` to `hi` inclusive (60 by default), and the
plot gets a play button and a slider to scrub through them.

`param` must be a symbol that `object` depends on, such as `k` in
`explicit(sin(k*x), x, -%pi, %pi)`.  Every `animate` in one plot must use
the same `[param, lo, hi, n]`; objects outside `animate` stay fixed.

#### Examples

```maxima
/* A wave changing frequency */
ax_draw2d(animate(explicit(sin(k*x), x, -%pi, %pi), [k, 0.5, 3, 40]))$

/* Several animated objects share one parameter; the circle stays fixed */
ax_draw2d(
  parametric(cos(s), sin(s), s, 0, 2*%pi, color="gray"),
  animate(vector([0, 0], [cos(t), sin(t)], color="red"), [t, 0, 2*%pi, 48]),
  animate(label([t, 1.25*cos(t), 1.25*sin(t)]), [t, 0, 2*%pi, 48]),
  aspect_ratio=true, xrange=[-1.6, 1.6], yrange=[-1.6, 1.6], slider_label="t"
)$

/* A surface in 3D */
ax_draw3d(animate(
  explicit(sin(k*x)*cos(y), x, -%pi, %pi, y, -%pi, %pi), [k, 0.5, 2.0]),
  colorscale="Viridis")$
```

#### What can be animated

- Curves, points, surfaces and the other trace objects, in 2D and 3D.  The
  object must produce the same number of traces at every frame.
- In 2D, also `label`, `vector` and shapes (`rectangle`, `ellipse`, `hline`,
  `vline`).  They are rebuilt for each frame and jump between frames rather
  than tweening.  A label whose text is a float, such as `label([t, x, y])`,
  shows it to 3 significant figures.
- `animate` and `reactive` signals can't be combined in one plot.

With the `numerics` package loaded, an animated 2D `explicit` is sampled
for all frames at once by `numerics`' `compile_grid`, which is several times
faster for long animations.  This needs a `numerics` with `compile_grid`
(published to the mxpm index on 2026-10-19).

#### Playback options

These are plot options, given alongside `title` or `xrange`:

| Option | Default | Description |
|--------|---------|-------------|
| `fps` | 12 | Frames per second when playing |
| `transition_duration` | 1000 / `fps` ms | Tween between frames; `0` steps without tweening |
| `slider_label` | the parameter's name | Text before the value on the slider |

An animation plays once per press of the play button.  `loop` is not
implemented, and giving it is an error.

Playing an animation needs a host that registers Plotly frames.  Aximar
does from its June 2026 `master` onwards; release v0.14.0 shows the controls
but they do nothing.

See also: `ax_draw2d`, `ax_draw3d`
