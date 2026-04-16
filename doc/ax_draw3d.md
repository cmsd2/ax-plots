### Function: ax_draw3d ([args])

Draw 3D interactive plots using Plotly.js with WebGL rendering. Produces rotatable, zoomable 3D charts.

#### Supported Draw Objects

| Object | Syntax | Description |
|--------|--------|-------------|
| `explicit` | `explicit(expr, x, xlo, xhi, y, ylo, yhi)` | A surface z=f(x,y) |
| `points` | `points([[x1,y1,z1],[x2,y2,z2],...])` | 3D scatter points |

#### Examples

```maxima
/* 3D surface */
ax_draw3d(explicit(sin(x)*cos(y), x, -%pi, %pi, y, -%pi, %pi))$

/* 3D scatter */
ax_draw3d(points([[1,1,1],[2,2,4],[3,3,9]]), marker_size=5)$

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
