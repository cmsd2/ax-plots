### Function: ax_draw3d ([args])

Draw 3D interactive plots using Plotly.js with WebGL rendering. Produces rotatable, zoomable 3D charts.

#### Supported Draw Objects

| Object | Syntax | Description |
|--------|--------|-------------|
| `explicit` | `explicit(expr, x, xlo, xhi, y, ylo, yhi)` | A surface z=f(x,y) |
| `points` | `points([[x1,y1,z1],...])` or `points(xs, ys, zs)` | 3D scatter points |
| `lines` | `lines([[x1,y1,z1],...])` or `lines(xs, ys, zs)` | 3D line plot from data |

#### Examples

```maxima
/* 3D surface */
ax_draw3d(explicit(sin(x)*cos(y), x, -%pi, %pi, y, -%pi, %pi))$

/* 3D scatter */
ax_draw3d(points([[1,1,1],[2,2,4],[3,3,9]]), marker_size=5)$

/* 3D scatter with separate coordinate arrays */
ax_draw3d(points([1,2,3], [4,5,6], [7,8,9]))$

/* 3D line plot from data */
ax_draw3d(lines([[0,0,0],[1,1,1],[2,0,2]]))$

/* 3D line from separate arrays (e.g. ndarrays) */
t : np_linspace(0, 6.28, 200)$
ax_draw3d(lines(np_cos(t), np_sin(t), np_scale(0.1, t)))$

/* With options */
ax_draw3d(
  explicit(x^2 - y^2, x, -2, 2, y, -2, 2),
  title="Saddle Surface",
  colorscale="Viridis"
)$
```

#### Style Options

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Trace color |
| `opacity` | 1.0 | Trace opacity |
| `colorscale` | none | Surface colorscale (e.g. `"Viridis"`, `"Hot"`) |
| `marker_size` | 6 | Marker size for scatter points |
| `marker_symbol` | `"circle"` | Marker shape |
| `name` | auto | Legend entry |
| `nticks` | 50 | Grid resolution (nticks x nticks) |

#### Layout Options

| Option | Description |
|--------|-------------|
| `title` | Plot title |
| `xlabel` / `ylabel` / `zlabel` | Axis labels |
| `xrange` / `yrange` / `zrange` | Axis ranges |
| `showlegend` | Show legend |
| `width` | Fixed plot width in pixels |
| `height` | Fixed plot height in pixels |

See also: `ax_plot2d`, `ax_draw2d`, `ax_polar`, `draw3d`
