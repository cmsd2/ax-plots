# ax-plots

[![Docs](https://img.shields.io/badge/docs-online-blue)](https://cmsd2.github.io/ax-plots/)

Interactive [Plotly.js](https://plotly.com/javascript/) plotting for
[Maxima](https://maxima.sourceforge.io/). Each plot function emits a Plotly JSON
spec, which [Aximar](https://github.com/cmsd2/aximar) (or any Plotly.js-capable
frontend) renders as an interactive chart with pan, zoom, hover tooltips, and
WebGL-accelerated 3D surfaces.

Reuses Maxima's familiar `draw` package object syntax (`explicit`, `parametric`,
`points`, `implicit`, `label`, `vector`, `polygon`, `rectangle`, `ellipse`) and
adds:

- data plots (`lines`), contour plots, heatmaps, bar charts, histograms, box,
  violin and pie charts, error bars, vector fields and streamlines;
- arrowheads on curves, snake and zigzag decorations, and diagram helpers
  (`diagram=true`, `theme="dark"`, `group(...)`);
- animation with `animate(...)`, and interactive parameters from the
  [reactive](https://github.com/cmsd2/maxima-reactive) package.

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

/* Labels, arrows and an animation */
ax_draw2d(
  parametric(cos(s), sin(s), s, 0, 2*%pi, color="gray"),
  animate(vector([0, 0], [cos(t), sin(t)], color="red"), [t, 0, 2*%pi, 48]),
  animate(label([t, 1.25*cos(t), 1.25*sin(t)]), [t, 0, 2*%pi, 48]),
  aspect_ratio=true, xrange=[-1.6, 1.6], yrange=[-1.6, 1.6]
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
| `ax_box` / `ax_violin` | Box and violin plots |
| `ax_pie` | Pie and donut charts |
| `ax_error_bar` | Points with error bars |
| `ax_vector_field` | 2D quiver plots |
| `ax_streamline` | ODE streamlines / phase portraits (RK4) |
| `animate` | Animate any object over a parameter, with play button and slider |

See the [full documentation](https://cmsd2.github.io/ax-plots/) for options,
examples, and layout customisation, and the [changelog](CHANGELOG.md) for
what's new.

## Install

Requires [mxpm](https://github.com/cmsd2/maxima-mxpm).
[Aximar](https://github.com/cmsd2/aximar) is needed to display the plots.
Playing animations and showing `reactive` controls need an Aximar newer
than release v0.14.0 (built from `master`).

Optional packages: `numerics` (ndarray input and faster animations) and
`reactive` (interactive parameters), both installable with `mxpm`.

```
mxpm install ax-plots
```

For development:

```
mxpm install --path . --editable
```

## License

MIT
