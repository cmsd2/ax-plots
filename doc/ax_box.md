### Function: ax_box (data) / ax_box (data, category)

Box plot of a list of numbers (or an ndarray).  Use inside `ax_draw2d`.  With
a `category` string, the box is placed at that position on the x-axis, so
several `ax_box` objects with different categories sit side by side.

#### Examples

```maxima
ax_draw2d(ax_box([2.1, 2.5, 2.8, 3.0, 3.2, 3.9, 5.6]))$

/* Two groups, with every point shown and the mean marked */
ax_draw2d(
  ax_box([5, 7, 8, 9, 12, 15], "control"),
  ax_box([8, 10, 11, 13, 14, 21], "treated"),
  boxpoints=all, boxmean=true, showlegend=false
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Box colour |
| `boxpoints` | outliers | Points drawn beside the box: `all`, `outliers` (or a Plotly value as a string) |
| `boxmean` | false | `true` marks the mean; `sd` also shows the standard deviation |
| `name` | `"box"` | Legend entry |

See also: `ax_violin`, `ax_histogram`, `ax_draw2d`
