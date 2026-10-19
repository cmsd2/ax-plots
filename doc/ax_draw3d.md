### Function: ax_draw3d ([args])

Draw 3D interactive plots using Plotly.js with WebGL rendering. Produces rotatable, zoomable 3D charts.

#### Supported Draw Objects

| Object | Syntax | Description |
|--------|--------|-------------|
| `explicit` | `explicit(expr, x, xlo, xhi, y, ylo, yhi)` | A surface z=f(x,y) |
| `points` | `points([[x1,y1,z1],...])` or `points(xs, ys, zs)` | 3D scatter points |
| `lines` | `lines([[x1,y1,z1],...])` or `lines(xs, ys, zs)` | 3D line plot from data |
| `parametric` | `parametric(x(t), y(t), z(t), t, t0, t1)` | A space curve |
| `parametric_surface` | `parametric_surface(x(u,v), y(u,v), z(u,v), u, u0, u1, v, v0, v1)` | A parametric surface |
| `implicit` | `implicit(f(x,y,z) = c, x, x0, x1, y, y0, y1, z, z0, z1)` | The surface where the equation holds (an isosurface) |
| `ax_contour3d` | `ax_contour3d(expr, x, x0, x1, y, y0, y1)` | A surface z = f(x,y) with contour lines, projected onto the floor |
| `ax_vector_field3d` | `ax_vector_field3d(Fx, Fy, Fz, x, x0, x1, y, y0, y1, z, z0, z1)` | Cones showing a vector field on a grid |
| `animate` | `animate(object, [param, lo, hi])` | Any of the above over a parameter (see `animate`) |
| `ax_trace` | `ax_trace(json_string)` | A raw Plotly trace, emitted verbatim |

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

/* Space curve and parametric surface (a torus) */
ax_draw3d(parametric(cos(t), sin(t), t/5, t, 0, 6*%pi))$
ax_draw3d(parametric_surface((2 + cos(v))*cos(u), (2 + cos(v))*sin(u), sin(v),
                             u, 0, 2*%pi, v, 0, 2*%pi))$

/* Implicit surface: a sphere */
ax_draw3d(implicit(x^2 + y^2 + z^2 = 1, x, -1.2, 1.2, y, -1.2, 1.2, z, -1.2, 1.2))$

/* Contour lines on a surface, and a 3D vector field */
ax_draw3d(ax_contour3d(sin(x)*cos(y), x, -%pi, %pi, y, -%pi, %pi))$
ax_draw3d(ax_vector_field3d(-y, x, z/2, x, -1, 1, y, -1, 1, z, -1, 1))$
```

Grid sizes are limited to keep the plots responsive; a value above the
limit falls back to the default.  `nticks` is at most 200 for surfaces
(default 50) and at most 50 for `implicit` (default 20); `ngrid` is at most
15 for `ax_vector_field3d` (default 8, so 512 cones).  `normalize=true` draws
all cones the same size.

As in `ax_draw2d`, arguments may be lists of objects, and
`group(obj, ..., opt=val, ...)` applies options to the objects in it only.

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
| `autosize` | `true` drops the default size so the plot fills its container |
| `margin` | Plot margins in pixels: a number, or `[l, r, t, b]` |
| `legend_position` / `legend_orientation` / `legend_title` | Legend placement and heading; see `ax_draw2d` |
| `title_font_size` / `title_x` / `title_align` | Title styling; see `ax_draw2d` |
| `colorway` | Colour sequence for traces without an explicit `color` |
| `layout_raw` | JSON object string merged into the Plotly layout; see `ax_draw2d` |
| `logx` / `logy` / `logz` | Log-scale axes (`true`/`false`) |
| `plot_bgcolor` | Scene background color (default `"white"`; maps to `scene.bgcolor`) |
| `paper_bgcolor` | Outer figure background color (default `"white"`) |
| `theme` | `"light"` (default) or `"dark"`: background, grid, axis and text colours |

See also: `ax_plot2d`, `ax_draw2d`, `ax_polar`, `draw3d`
