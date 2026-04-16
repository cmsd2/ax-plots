### Function: ax_heatmap (z_matrix)

Heatmap visualization. Use inside `ax_draw2d`.

Calling forms:

- `ax_heatmap(z_matrix)` — pass a Maxima `matrix(...)` directly
- `ax_heatmap(z_matrix, x_labels, y_labels)` — matrix with string lists for axis labels
- `ax_heatmap(expr, xvar, xlo, xhi, yvar, ylo, yhi)` — symbolic expression sampled on a grid

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
