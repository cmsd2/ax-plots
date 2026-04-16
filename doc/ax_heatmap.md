### Function: ax_heatmap (z_matrix)

`ax_heatmap(z_matrix)`
`ax_heatmap(z_matrix, x_labels, y_labels)`
`ax_heatmap(expr, xvar, xlo, xhi, yvar, ylo, yhi)`

Heatmap visualization. Use inside `ax_draw2d`. Three forms:

1. **Matrix only**: pass a Maxima `matrix(...)` directly
2. **Matrix + labels**: matrix with string lists for axis labels
3. **Expression**: symbolic expression sampled on a grid

#### Examples

```maxima
/* From a matrix */
ax_draw2d(ax_heatmap(matrix([1,2,3],[4,5,6],[7,8,9])))$

/* With axis labels */
M: matrix([85,90,78],[92,88,95])$
ax_draw2d(
  ax_heatmap(M, ["Math","Science","English"], ["Alice","Bob"]),
  colorscale="Blues", title="Scores"
)$

/* From an expression */
ax_draw2d(
  ax_heatmap(sin(x)*cos(y), x, -%pi, %pi, y, -%pi, %pi),
  colorscale="Hot"
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `colorscale` | auto | Color scale: `"Viridis"`, `"Hot"`, `"Blues"`, etc. |
| `showscale` | auto | Show/hide the color bar |
| `nticks` | 50 | Grid resolution (expression form only) |
| `name` | auto | Legend entry |
| `opacity` | 1.0 | Trace opacity |

See also: `ax_draw2d`, `ax_contour`
