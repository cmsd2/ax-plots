### Function: ax_streamline (Fx, Fy, xvar, xlo, xhi, yvar, ylo, yhi)

`ax_streamline(Fx, Fy, xvar, xlo, xhi, yvar, ylo, yhi)`

Streamline / phase portrait curves for a 2D ODE system dx/dt = Fx(x,y), dy/dt = Fy(x,y). Use inside `ax_draw2d`. Integrates trajectories from initial points using RK4.

Combine with `ax_vector_field` for a full phase portrait:

```maxima
ax_draw2d(
  color="#cccccc", ax_vector_field(-y, x, x, -3, 3, y, -3, 3),
  color="red", ax_streamline(-y, x, x, -3, 3, y, -3, 3),
  aspect_ratio=true, title="Phase Portrait"
)$
```

#### Examples

```maxima
/* Auto initial points */
ax_draw2d(ax_streamline(-y, x, x, -3, 3, y, -3, 3))$

/* Custom initial points and time range */
ax_draw2d(
  initial_points=[[0.5,0.5],[2,2],[3,1]],
  t_range=[0,20], dt=0.01,
  ax_streamline(x*(1-y), y*(x-1), x, 0, 4, y, 0, 4),
  title="Lotka-Volterra"
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `initial_points` | auto | List of [x0,y0] starting points |
| `t_range` | [0, 10] | Integration time span [t0, tf] |
| `dt` | 0.05 | RK4 step size |
| `color` | auto | Curve color |
| `line_width` | 1.5 | Curve thickness |
| `name` | auto | Legend entry |
| `opacity` | 1.0 | Trace opacity |

See also: `ax_draw2d`, `ax_vector_field`
