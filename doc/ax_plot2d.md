### Function: ax_plot2d (y1, x1, y2, x2, ..., options)

Plot expressions and/or data as interactive Plotly.js line charts. Arguments are consumed as (y, x) pairs, where y is what to plot and x is the domain.

Each pair can be:

- **Expression + range**: y is an expression (or list of expressions), x is `[var, min, max]`
- **Data + data**: y is a list or ndarray of values, x is a list or ndarray of coordinates

Calling forms:

- `ax_plot2d(expr, [var, min, max])` — single expression
- `ax_plot2d([expr_1, ..., expr_n], [var, min, max])` — multiple expressions sharing a range
- `ax_plot2d(ys, xs)` — data pair (lists or ndarrays), plotted as lines
- `ax_plot2d([ys_1, ..., ys_n], xs)` — multiple y series sharing one x
- `ax_plot2d(expr, [var, lo, hi], ys, xs, ...)` — mixed expressions and data

#### Examples

```maxima
/* Single expression */
ax_plot2d(sin(x), [x, -%pi, %pi])$

/* Multiple expressions */
ax_plot2d([sin(x), cos(x)], [x, -5, 5])$

/* Data from lists */
ax_plot2d([1,4,9,16], [1,2,3,4])$

/* Data from ndarrays (requires numerics package) */
xs : np_linspace(-3, 3, 50)$
ax_plot2d(np_mul(xs, xs), xs)$

/* Apply a custom function with np_map */
f(x) := x^3 - x$
ax_plot2d(np_map(f, xs), xs)$

/* Or use a lambda for quick one-off transforms */
ax_plot2d(np_map(lambda([x], x^3 - x), xs), xs)$

/* Multiple y series sharing x */
ax_plot2d([np_pow(xs, 2), np_sin(xs)], xs)$

/* Mixed expressions and data */
ax_plot2d(sin(x), [x, -3, 3], np_pow(xs, 2), xs, title="Mixed")$

/* With options */
ax_plot2d(x^2, [x, -3, 3], title="Parabola", color="red")$
```

#### Style Options

Style options apply to subsequent traces until overridden:

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Line/marker color (atom like `red` or CSS string) |
| `line_width` | 2 | Line width in pixels |
| `dash` | `"solid"` | Line style: `"solid"`, `"dot"`, `"dash"`, `"dashdot"` |
| `opacity` | 1.0 | Trace opacity (0–1) |
| `name` | auto | Legend entry name |
| `nticks` | 500 | Sampling resolution |

#### Layout Options

| Option | Description |
|--------|-------------|
| `title` | Plot title |
| `xlabel` / `ylabel` | Axis labels |
| `xrange` / `yrange` | Axis ranges, e.g. `xrange=[-5,5]` |
| `grid` | Show grid lines (`true`/`false`) |
| `showlegend` | Show legend (`true`/`false`) |
| `aspect_ratio` | Lock aspect ratio (`true`/`false`) |
| `width` | Fixed plot width in pixels |
| `height` | Fixed plot height in pixels |

See also: `ax_draw2d`, `ax_draw3d`, `ax_polar`, `plot2d`
