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
| `label` | `label([text, x, y], ...)` | Text at data coordinates (rotatable, Unicode) |
| `vector` | `vector([x, y], [dx, dy])` | Arrow from (x, y) to (x+dx, y+dy) |
| `polygon` | `polygon([[x1,y1],...])` or `polygon(xs, ys)` | Filled polygon (closed automatically) |
| `ax_trace` | `ax_trace(json_string)` | A raw Plotly trace, emitted verbatim (see Raw Plotly) |

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

#### Labels, Arrows and Polygons

`label`, `vector` and `polygon` take the same arguments as in the `draw`
package.  `label` and `vector` are drawn as Plotly annotations: they never
appear in the legend, and are not yet supported inside `animate(...)` or in
`ax_draw3d`.

```maxima
ax_draw2d(
  polygon([[0,0], [2,0], [1,1.5]], fill_color="rgba(100,100,230,0.2)", line_width=0),
  label(["A", 0, -0.1], ["B", 2, -0.1], ["C", 1, 1.6], font_size=16),
  label(["slope", 0.45, 0.85], label_angle=56),
  vector([1, 0.2], [0, 0.6], color="red", head_both=true),
  aspect_ratio=true
)$
```

- Label text may contain Unicode (`"i⁺"`, `"𝓘⁻"`, `"ρ"`).  Use `font_size`,
  `font_color` (defaults to `color`) and `font_family` to style it.
- `label_alignment` (`left` / `center` / `right`) and `label_valign`
  (`top` / `middle` / `bottom`) say which side of the text sits on the point.
- `label_angle` rotates the text, in degrees counterclockwise;
  `label_orientation=vertical` is the same as `label_angle=90`.
- `vector` uses `color` and `line_width` for the arrow, `head_size`
  (relative to the line width) and `head_style` (Plotly arrowhead shape 0–8)
  for the head, and `head_both=true` for heads at both ends.
- `polygon` fills with `fill_color` and outlines with `color`, `line_width`
  and `dash`; `line_width=0` hides the outline and `transparent=true` draws
  the outline only.

#### Arrowheads and Filled Areas

`lines`, `explicit` and `parametric` accept `head_end=true`,
`head_start=true` and `head_count=n` (n heads evenly spaced along the curve
by length).  Heads follow the curve's direction on screen, so they stay
correct under `aspect_ratio`; `head_size` scales them.

`explicit` accepts the draw package's `filled_func`: `filled_func=true` fills
between the curve and y = 0, and `filled_func=g(x)` fills between the curve
and g, using `fill_color`.

```maxima
ax_draw2d(
  explicit(sin(x), x, 0, %pi, filled_func=sin(x)/2, fill_color="rgba(0,0,255,0.2)"),
  parametric(cos(t), sin(t), t, 0, 3*%pi/2, head_end=true, head_count=2),
  aspect_ratio=true
)$
```

Like the draw package, `filled_func` is sticky when given at the top level:
it applies to every later `explicit` until reset with `filled_func=false`.

#### Raw Plotly

Anything not wrapped by ax-plots can be passed through as JSON:
`ax_trace("{...}")` adds a Plotly trace verbatim, and
`layout_raw="{...}"` appends keys to the layout, overriding ax-plots' own
values (annotations from `label` / `vector` still take precedence).

```maxima
ax_draw2d(
  explicit(x^2, x, -1, 1),
  ax_trace("{\"type\":\"bar\",\"x\":[-0.5,0.5],\"y\":[0.25,0.25],\"opacity\":0.4}"),
  layout_raw="{\"hovermode\":\"x unified\"}"
)$
```

#### Data Values

`lines` and `points` data may contain exact numeric constants such as
`%pi/2`, `sqrt(2)` or `atan(3)`; they are converted with `float`.  A value
that is still not a number (for example a free symbol `a`) is an error naming
the object, axis and index.  Use `false` (or `inf`, `minf`, `und`, `ind`) for
an intentional gap in a line.  Numeric constants are also accepted in
`xrange` / `yrange`, e.g. `xrange=[-%pi, %pi]`.

#### Per-object Options

Style options can be given as trailing arguments inside an object.  They apply
to that object only and do not change the options in effect for later objects:

```maxima
ax_draw2d(
  color="blue",
  lines([0, 1, 2], [0, 1, 0], color="red", dash="dot", showlegend=false),
  lines([0, 1, 2], [1, 0, 1])          /* still blue */
)$
```

`showlegend` inside an object hides (or shows) that trace's legend entry; at
the top level `showlegend` is the layout option for the whole legend.

#### Programmatic Use

To build a figure in a loop, collect objects and options in a list and pass
it with `apply`:

```maxima
objs: makelist(lines([0, 1], [0, k], color="gray", hoverinfo="skip"), k, 1, 5)$
apply(ax_draw2d, append(objs, [title="Fan", aspect_ratio=true]))$
```

#### Style Options

Options use Plotly-native naming and apply to subsequent objects until overridden
(or to a single object when given inside it, see Per-object Options):

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
| `hover_text` | none | Hover text: a string, or a list with one string per point |
| `hoverinfo` | auto | Hover content, e.g. `"skip"` (no hover, for decorations), `"none"`, `"x+y"`, `"text"` |
| `showlegend` | auto | Per-object only: `false` hides this trace's legend entry |
| `font_size` / `font_color` / `font_family` | Plotly default | Label text style; `font_color` defaults to `color` |
| `label_alignment` | auto | Label anchor: `left`, `center`, `right` |
| `label_valign` | auto | Label anchor: `top`, `middle`, `bottom` |
| `label_angle` | 0 | Label rotation, degrees counterclockwise |
| `label_orientation` | `horizontal` | `vertical` rotates labels 90° |
| `head_size` | 1 | Arrowhead scale (vector) |
| `head_style` | 1 | Arrowhead shape 0–8 (vector) |
| `head_both` | false | Arrowheads at both ends (vector) |
| `transparent` | false | Polygon outline only, no fill |
| `head_end` / `head_start` | false | Arrowhead at the end / start of a curve |
| `head_count` | 0 | Arrowheads evenly spaced along a curve |
| `filled_func` | false | `explicit` only: `true` fills to y = 0, `g(x)` fills between the curve and g |
| `legendgroup` | none | Traces with the same group toggle together in the legend |
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
| `aspect_ratio` | Lock aspect ratio: `true` (1:1), a number (y units per x unit), or `false` (off) |
| `constrain` | How `aspect_ratio` is met: `"range"` (Plotly default, widens a range) or `"domain"` (shrinks the plot area, keeps `xrange`/`yrange` exactly) |
| `margin` | Plot margins in pixels: a number for all sides, or `[l, r, t, b]` |
| `width` | Fixed plot width in pixels (`auto` to size to the container) |
| `height` | Fixed plot height in pixels (`auto` to size to the container) |
| `autosize` | `true` drops both default sizes so the plot fills its container |
| `legend_position` | `"top-right"`, `"top-left"`, `"bottom-right"`, `"bottom-left"` (inside), `"top"`, `"bottom"` (outside, horizontal), `"right"`, or `[x, y]` in paper coordinates |
| `legend_orientation` | `"h"` / `"v"` (or `horizontal` / `vertical`) |
| `xtickvals` / `ytickvals` | Tick positions, e.g. `[0, %pi/2, %pi]` |
| `xticktext` / `yticktext` | Tick labels matching `xtickvals` / `ytickvals`, e.g. `["0", "π/2", "π"]` |
| `xtickformat` / `ytickformat` | d3 number format for tick labels, e.g. `".2f"`, `".0%"` |
| `xreversed` / `yreversed` | Reverse the axis direction |
| `xzeroline` / `yzeroline` | Show / hide the zero line |
| `layout_raw` | JSON object string appended to the Plotly layout (see Raw Plotly) |
| `bar_mode` | Bar/histogram grouping: `"group"`, `"stack"`, `"overlay"` |
| `logx` / `logy` | Log-scale axes (`true`/`false`) |
| `plot_bgcolor` | Plot-area background color (default `"white"`) |
| `paper_bgcolor` | Outer figure background color (default `"white"`) |

See also: `ax_plot2d`, `ax_draw3d`, `ax_polar`, `draw2d`
