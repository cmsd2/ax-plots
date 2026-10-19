### Function: ax_violin (data) / ax_violin (data, category)

Violin plot of a list of numbers (or an ndarray): the distribution's density,
with a box plot and the mean drawn inside.  Use inside `ax_draw2d`.  With a
`category` string, the violin is placed at that position on the x-axis.

#### Examples

```maxima
ax_draw2d(ax_violin([2.1, 2.5, 2.8, 3.0, 3.2, 3.9, 5.6]))$

ax_draw2d(
  ax_violin([5, 7, 8, 9, 12, 15], "control"),
  ax_violin([8, 10, 11, 13, 14, 21], "treated"),
  boxpoints=all, showlegend=false
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Violin colour |
| `boxpoints` | Plotly's default | Points drawn beside the violin: `all`, `outliers` (or a Plotly value as a string) |
| `name` | `"violin"` | Legend entry |

See also: `ax_box`, `ax_histogram`, `ax_draw2d`
