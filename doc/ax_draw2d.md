### Function: ax_draw2d ([args])

Draw 2D interactive plots using Plotly.js. Accepts Maxima draw package objects and Aximar-specific objects, rendering them as interactive charts with pan, zoom, and hover.

#### Supported Objects

**Draw package objects:**

| Object | Syntax | Description |
|--------|--------|-------------|
| `explicit` | `explicit(expr, var, lo, hi)` | A curve y=f(x) |
| `parametric` | `parametric(x(t), y(t), t, tlo, thi)` | A parametric curve |
| `points` | `points([[x1,y1],...])` or `points(xs, ys)` | Scatter points |
| `lines` | `lines([[x1,y1],...])` or `lines(xs, ys)` | Line plot from data |
| `implicit` | `implicit(eqn, x, xlo, xhi, y, ylo, yhi)` | An implicit curve f(x,y)=0 |

**Aximar objects:**

| Object | Syntax | Description |
|--------|--------|-------------|
| `ax_contour` | `ax_contour(expr, x, xlo, xhi, y, ylo, yhi)` | Filled contour plot |
| `ax_heatmap` | `ax_heatmap(matrix)` or `ax_heatmap(expr, x, xlo, xhi, y, ylo, yhi)` | Heatmap |
| `ax_bar` | `ax_bar(categories, values)` or `ax_bar(values)` | Bar chart |
| `ax_histogram` | `ax_histogram(data)` | Histogram |
| `ax_vector_field` | `ax_vector_field(Fx, Fy, x, xlo, xhi, y, ylo, yhi)` | 2D vector field |
| `ax_streamline` | `ax_streamline(Fx, Fy, x, xlo, xhi, y, ylo, yhi)` | Streamline / phase portrait curves |

#### Examples

```maxima
/* Explicit curves with styling */
ax_draw2d(
  color="red", explicit(x^2, x, -3, 3),
  color="blue", explicit(x^3, x, -2, 2)
)$

/* Filled contour */
ax_draw2d(
  ax_contour(sin(x)*cos(y), x, -%pi, %pi, y, -%pi, %pi),
  colorscale="Viridis", title="Contour Plot"
)$

/* Bar chart */
ax_draw2d(
  ax_bar(["Q1","Q2","Q3","Q4"], [100,150,120,180]),
  title="Quarterly Sales"
)$

/* Histogram */
ax_draw2d(
  ax_histogram(makelist(random(100)/10.0, i, 1, 500)),
  nbins=20, title="Distribution"
)$

/* Line plot from data */
ax_draw2d(lines([1,2,3,4,5], [1,4,9,16,25]))$

/* Scatter with separate x/y lists */
ax_draw2d(points([1,2,3,4,5], [1,4,9,16,25]))$

/* Lines and points accept ndarrays (requires numerics package) */
xs : np_linspace(-3, 3, 50)$
ax_draw2d(
  lines(xs, np_mul(xs, xs)),
  points(xs, np_sin(xs))
)$

/* Use np_map with a lambda for custom transforms */
ax_draw2d(lines(xs, np_map(lambda([x], x^3 - x), xs)))$

/* Phase portrait: vector field + streamlines */
ax_draw2d(
  color="#cccccc", ax_vector_field(-y, x, x, -3, 3, y, -3, 3),
  color="red", ax_streamline(-y, x, x, -3, 3, y, -3, 3),
  aspect_ratio=true, title="Phase Portrait"
)$

/* Streamlines with custom initial conditions */
ax_draw2d(
  initial_points=[[1,0],[0,1],[-1,0],[0,-1]],
  t_range=[0,8],
  ax_streamline(-y, x, x, -3, 3, y, -3, 3),
  aspect_ratio=true
)$
```

#### Style Options

Options use Plotly-native naming and apply to subsequent objects until overridden:

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Line/marker color (atom like `red` or CSS string) |
| `fill_color` | none | Fill color |
| `opacity` | 1.0 | Trace opacity (0–1) |
| `line_width` | 2 | Line width in pixels |
| `dash` | `"solid"` | Line style: `"solid"`, `"dot"`, `"dash"`, `"dashdot"` |
| `marker_symbol` | `"circle"` | Marker shape |
| `marker_size` | 6 | Marker size |
| `name` | auto | Legend entry |
| `fill` | none | Fill region: `"tozeroy"`, `"toself"`, etc. |
| `colorscale` | none | Color scale for contour/heatmap (e.g. `"Viridis"`, `"Hot"`) |
| `showscale` | auto | Show/hide colorbar for contour/heatmap |
| `ncontours` | auto | Number of contour levels (ax_contour) |
| `nbins` | auto | Number of bins (ax_histogram) |
| `bar_width` | auto | Bar width fraction (ax_bar) |
| `nticks` | 500 | Sampling resolution |
| `ngrid` | 20 | Vector field grid resolution (ngrid x ngrid) |
| `arrow_scale` | 1.0 | Arrow length multiplier (ax_vector_field) |
| `normalize` | false | Equal-length arrows, direction only (ax_vector_field) |
| `initial_points` | auto | Streamline start points `[[x0,y0],...]` (ax_streamline) |
| `t_range` | [0, 10] | Integration time span `[t0, tf]` (ax_streamline) |
| `dt` | 0.05 | RK4 step size (ax_streamline) |

#### Layout Options

| Option | Description |
|--------|-------------|
| `title` | Plot title |
| `xlabel` / `ylabel` | Axis labels |
| `xrange` / `yrange` | Axis ranges |
| `grid` | Show grid lines |
| `xaxis` / `yaxis` | Show/hide axes |
| `showlegend` | Show legend |
| `aspect_ratio` | Lock aspect ratio |
| `width` | Fixed plot width in pixels |
| `height` | Fixed plot height in pixels |
| `bar_mode` | Bar/histogram grouping: `"group"`, `"stack"`, `"overlay"` |

See also: `ax_plot2d`, `ax_draw3d`, `ax_polar`, `draw2d`
