### Function: ax_polar (expr, [var, min, max])

`ax_polar(expr, [θ, min, max], options)`
`ax_polar([expr_1, ..., expr_n], [θ, min, max], options)`

Plot r(θ) curves in polar coordinates as interactive Plotly.js charts. Standalone function (like `ax_plot2d`).

#### Examples

```maxima
/* Cardioid */
ax_polar(1 + cos(θ), [θ, 0, 2*%pi])$

/* Rose curve */
ax_polar(sin(3*θ), [θ, 0, 2*%pi], color="red", title="Rose Curve")$

/* Multiple curves */
ax_polar(
  [1 + cos(θ), 1 - cos(θ)],
  [θ, 0, 2*%pi],
  title="Cardioids"
)$

/* Spiral */
ax_polar(θ/10, [θ, 0, 6*%pi], title="Archimedean Spiral")$
```

#### Style Options

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Line color |
| `line_width` | 2 | Line width in pixels |
| `dash` | `"solid"` | Line style: `"solid"`, `"dot"`, `"dash"`, `"dashdot"` |
| `name` | auto | Legend entry |
| `opacity` | 1.0 | Trace opacity |
| `nticks` | 500 | Sampling resolution |

#### Layout Options

| Option | Description |
|--------|-------------|
| `title` | Plot title |
| `showlegend` | Show legend (`true`/`false`) |
| `width` | Fixed plot width in pixels |
| `height` | Fixed plot height in pixels |

See also: `ax_plot2d`, `ax_draw2d`
