# ax-plots

[![Docs](https://img.shields.io/badge/docs-online-blue)](https://cmsd2.github.io/ax-plots/)

Interactive Plotly.js plotting for Maxima via [Aximar](https://github.com/cmsd2/aximar).

Provides `ax_plot2d`, `ax_draw2d`, and `ax_draw3d` which produce Plotly.js JSON
specs. These functions reuse Maxima's `draw` package object syntax (`explicit`,
`parametric`, `points`, `implicit`) but render with Plotly instead of gnuplot.

## Install

Install locally during development:

```
mxpm install --path . --editable
```

Or copy-install:

```
mxpm install --path .
```

## Usage

```maxima
load("ax-plots");
ax_plot2d(sin(x), [x, -5, 5]);
ax_draw2d(explicit(sin(x), x, -5, 5));
```

## Documentation

Build documentation artifacts (`.info` and help index):

```
mxpm doc build
```

Live preview with mdBook:

```
mxpm doc serve
```

## License

MIT
