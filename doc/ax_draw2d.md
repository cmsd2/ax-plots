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
| `rectangle` | `rectangle([x1,y1], [x2,y2])` | Rectangle from opposite corners (see Shapes) |
| `ellipse` | `ellipse(xc, yc, a, b)` or `ellipse(xc, yc, a, b, ang1, ang2)` | Ellipse, or sector from `ang1` sweeping `ang2` degrees |
| `hline` / `vline` | `hline(y1, ...)` / `vline(x1, ...)` | Horizontal / vertical lines across the whole plot |
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
- `label_offset=[dx, dy]` shifts the text by pixels (dy up), so it stays the
  same distance from its point whatever the axis ranges.  With
  `label_valign=bottom` and `label_offset=[0, 4]` the text sits just above
  the point.
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

By default each head follows the curve's local direction
(`head_direction="tangent"`), as in most plotting libraries.  For wavy or
noisy curves, `head_direction="chord"` points each head along the curve's
overall direction instead: from the point one head-spacing of length back
(the start of the curve, for a single `head_end`).

A head's tip sits on its data point and the head extends back over the
curve (Plotly can only offset markers backwards).  For a wavy line such as a
photon, use a decoration (below): with `head_end=true` it leaves a straight
run at the end, so the head points along the line and the wiggle stops near
where the head begins.

#### Decorations

`decoration="snake"` (a sine wave) or `decoration="zigzag"` on `lines`,
`explicit` or `parametric` draws a wave that follows the curve, like TikZ's
decorations, so a wavy photon or a zigzag singularity is just a straight
line with a decoration:

```maxima
ax_draw2d(
  lines([[0, 0], [1, 1]], decoration="snake", decoration_wavelength=0.12,
        decoration_amplitude=0.03, head_end=true, head_size=1.2),
  lines([[-1, 1.2], [1, 1.2]], decoration="zigzag", decoration_wavelength=0.09,
        decoration_amplitude=0.025, color="red"),
  aspect_ratio=true
)$
```

- `decoration_wavelength` (default: the curve's length / 10) and
  `decoration_amplitude` (default: wavelength / 4) are in data units, and the
  wave is offset along the curve's normal in data space, so it looks right
  with `aspect_ratio=true`.  The wavelength is adjusted slightly so that a
  whole number of waves fits and the wave ends back on the curve.
- `decoration_pre` and `decoration_post` leave the first and last stretch of
  the curve straight.  They default to 0, except that `head_start=true` /
  `head_end=true` make them half a wavelength, so end heads point along the
  curve rather than along the last wiggle.
- Heads placed along the curve with `head_count` follow the wave; add
  `head_direction="chord"` to point them along the curve instead.
- A line with gaps is decorated piece by piece.

The algorithm is specified independently of ax-plots, with a plain-Maxima
reference implementation that draws with `plot2d`/gnuplot, in
[this gist](https://gist.github.com/cmsd2/b19d20316b62719e10cd9e3840cdf2d2).

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

#### Diagrams

`diagram=true` sets up a figure that is a picture rather than a graph: axes,
grid, legend and hover off, equal x and y scales (`aspect_ratio=true`) and
`height=fit`.  Options given explicitly win, e.g. `diagram=true, xaxis=true`.

`height=fit` computes the height at which the plot area shows `xrange` and
`yrange` at the aspect ratio (1, or `aspect_ratio` if it is a number) with no
space left over, for the `width` (700 by default) and margins.  It needs both
ranges.  Without a `margin` option it assumes Aximar's fixed margins
(left 50, right 30, top 40, bottom 50 pixels) and sets them explicitly, so
other hosts lay the plot out the same way.  With `diagram=true` and automatic
ranges, the height falls back to the default square plot.

`theme="dark"` uses dark backgrounds, light text and grid colours suited to a
dark host, and makes uncoloured `vector` arrows and shape outlines light too.
`plot_bgcolor` / `paper_bgcolor` still override the background.  Aximar makes
plot backgrounds transparent, so there the theme mostly sets the text and
line colours.

```maxima
ax_draw2d(
  polygon([[0,0], [1,1], [2,0], [1,-1]], fill_color="rgba(150,150,230,0.3)"),
  label(["I", 1, 0], font_size=20),
  diagram=true, theme="dark", xrange=[-0.2, 2.2], yrange=[-1.2, 1.2]
)$
```

#### Shapes

`rectangle`, `ellipse`, `hline` and `vline` are drawn as Plotly layout
shapes: they never appear in the legend or take hover.  `rectangle` and
`ellipse` take the draw package's arguments.  The outline uses `color`,
`line_width` and `dash`; `rectangle` and `ellipse` are filled only when
`fill_color` is set.  `layer="below"` draws a shape underneath the data.
Like `label`, shapes are not yet supported inside `animate(...)`.

```maxima
ax_draw2d(
  rectangle([0, 0], [1, 1], fill_color="rgba(0,150,0,0.15)", layer="below"),
  ellipse(0.5, 0.5, 0.5, 0.25, color="blue"),
  ellipse(0, 0, 0.3, 0.3, 0, 90, fill_color="orange"),
  hline(0.5, dash="dot"), vline(0.5, dash="dot"),
  explicit(x^2, x, 0, 1),
  aspect_ratio=true
)$
```

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

#### Lists and Groups

Any argument may be a list of objects (and options); lists are spliced in
place, at any depth, so a figure built in a loop can be passed directly:

```maxima
objs: makelist(lines([0, 1], [0, k]), k, 1, 5)$
ax_draw2d(objs, title="Fan", aspect_ratio=true)$
```

`group(obj, ..., opt=val, ...)` gives every object in it the group's
options, as if each were written inside the object.  The options apply to
the group only, and an object's own options still win.  Groups may contain
lists and other groups:

```maxima
ax_draw2d(
  group(objs, color="gray", line_width=1, hoverinfo="skip"),
  group(lines([0, 1], [0, 2.5], color="red"), lines([0, 1], [0, 5.5]), dash="dot"),
  title="Fan"
)$
```

Layout options such as `title` can't go in a group.  `ax_draw3d` accepts
lists and groups the same way.

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
| `label_offset` | none | Label shift `[dx, dy]` in pixels, dy up |
| `head_size` | 1 | Arrowhead scale (vector) |
| `head_style` | 1 | Arrowhead shape 0–8 (vector) |
| `head_both` | false | Arrowheads at both ends (vector) |
| `transparent` | false | Polygon outline only, no fill |
| `head_end` / `head_start` | false | Arrowhead at the end / start of a curve |
| `head_count` | 0 | Arrowheads evenly spaced along a curve |
| `head_direction` | `"tangent"` | Curve arrowheads follow the local direction (`"tangent"`) or the overall direction (`"chord"`) |
| `decoration` | none | `"snake"` or `"zigzag"` wave along a curve (see Decorations) |
| `decoration_wavelength` / `decoration_amplitude` | length / 10, wavelength / 4 | Wave size, in data units |
| `decoration_pre` / `decoration_post` | 0 (half a wavelength with an end head) | Straight length left at the start / end |
| `line_shape` | `"linear"` | Line interpolation: `"linear"`, `"spline"`, or steps `"hv"`, `"vh"`, `"hvh"`, `"vhv"` |
| `layer` | `"above"` | Shapes: draw `"above"` or `"below"` the data |
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
| `height` | Fixed plot height in pixels (`auto` to size to the container, `fit` to match the ranges; see Diagrams) |
| `autosize` | `true` drops both default sizes so the plot fills its container |
| `legend_position` | `"top-right"`, `"top-left"`, `"bottom-right"`, `"bottom-left"` (inside), `"top"`, `"bottom"` (outside, horizontal), `"right"`, or `[x, y]` in paper coordinates |
| `legend_orientation` | `"h"` / `"v"` (or `horizontal` / `vertical`) |
| `legend_title` | Legend heading |
| `title_font_size` / `title_x` / `title_align` | Title size; horizontal position (0–1 across the figure); which side of the title sits at `title_x` (`"left"`, `"center"`, `"right"`) |
| `colorway` | Colour sequence for traces without an explicit `color`, e.g. `[red, "#1f77b4", "green"]` |
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
| `theme` | `"light"` (default) or `"dark"`: background, grid, axis and text colours (see Diagrams) |
| `diagram` | `true`: no axes, grid, legend or hover; equal scales; `height=fit` (see Diagrams) |

See also: `ax_plot2d`, `ax_draw3d`, `ax_polar`, `draw2d`
