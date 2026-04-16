# ax-plots

[![Docs](https://img.shields.io/badge/docs-online-blue)](https://cmsd2.github.io/ax-plots/)

Interactive [Plotly.js](https://plotly.com/javascript/) plotting for
[Maxima](https://maxima.sourceforge.io/). Each plot function emits a Plotly JSON
spec, which [Aximar](https://github.com/cmsd2/aximar) (or any Plotly.js-capable
frontend) renders as an interactive chart with pan, zoom, hover tooltips, and
WebGL-accelerated 3D surfaces.

Reuses Maxima's familiar `draw` package object syntax (`explicit`, `parametric`,
`points`, `implicit`) and adds specialised objects for contour plots, heatmaps,
bar charts, histograms, vector fields, and streamlines.

## Quick start

```maxima
load("ax-plots");

/* Simple 2D plot */
ax_plot2d(sin(x), [x, -%pi, %pi]);

/* Multiple curves with styling */
ax_draw2d(
  color="red",  explicit(sin(x), x, -5, 5),
  color="blue", explicit(cos(x), x, -5, 5),
  title="Trig functions"
);

/* 3D surface */
ax_draw3d(
  explicit(sin(x)*cos(y), x, -%pi, %pi, y, -%pi, %pi),
  colorscale="Viridis"
);

/* Polar */
ax_polar(1 + cos(t), [t, 0, 2*%pi]);

/* Phase portrait */
ax_draw2d(
  color="#ccc", ax_vector_field(-y, x, x, -3, 3, y, -3, 3),
  color="red", ax_streamline(-y, x, x, -3, 3, y, -3, 3),
  aspect_ratio=true
);
```

## Functions

| Function | Description |
|----------|-------------|
| `ax_plot2d` | Quick 2D plot from expressions (like `plot2d`) |
| `ax_draw2d` | 2D plotting with draw-style objects and Aximar extras |
| `ax_draw3d` | 3D surfaces and scatter with WebGL rendering |
| `ax_polar` | Polar coordinate plots |
| `ax_bar` | Bar charts (labeled or simple) |
| `ax_contour` | Filled contour plots |
| `ax_heatmap` | Heatmaps from matrices or expressions |
| `ax_histogram` | Histograms with automatic binning |
| `ax_vector_field` | 2D quiver plots |
| `ax_streamline` | ODE streamlines / phase portraits (RK4) |

See the [full documentation](https://cmsd2.github.io/ax-plots/) for options,
examples, and layout customisation.

## Install

Requires [mxpm](https://github.com/cmsd2/maxima-mxpm).
[Aximar](https://github.com/cmsd2/aximar) is needed to display the plots.

```
mxpm install ax-plots
```

For development:

```
mxpm install --path . --editable
```

## License

MIT
