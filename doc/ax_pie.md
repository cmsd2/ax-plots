### Function: ax_pie (values) / ax_pie (values, labels)

Pie chart of a list of non-negative numbers, with an optional list of label
strings.  Use inside `ax_draw2d`.  `hole` turns it into a donut chart.

#### Examples

```maxima
ax_draw2d(ax_pie([45, 30, 25], ["Maxima", "Lisp", "Other"]))$

/* Donut */
ax_draw2d(ax_pie([45, 30, 25], ["Maxima", "Lisp", "Other"], hole=0.4))$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `hole` | 0 | Size of the hole in the middle, as a fraction of the radius (0–1) |
| `name` | `"pie"` | Name shown on hover |

See also: `ax_bar`, `ax_draw2d`
