### Function: ax_plot2d (expr, [var, min, max])

`ax_plot2d(expr, [var, min, max], options)`
`ax_plot2d([expr_1, ..., expr_n], [var, min, max], options)`

Plot one or more expressions as interactive Plotly.js charts. This is a convenience wrapper around `ax_draw2d` that automatically creates `explicit()` objects from expressions.

#### Examples

```maxima
/* Single expression */
ax_plot2d(sin(x), [x, -%pi, %pi])$

/* Multiple expressions */
ax_plot2d([sin(x), cos(x)], [x, -5, 5])$

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
