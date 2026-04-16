### Function: ax_histogram (data)

Histogram of numeric data. Use inside `ax_draw2d`. Takes a flat list of numbers; Plotly handles binning automatically.

#### Examples

```maxima
/* Basic histogram */
data: makelist(random(100)/10.0, i, 1, 500)$
ax_draw2d(ax_histogram(data), title="Distribution")$

/* Control bin count */
ax_draw2d(ax_histogram(data), nbins=30)$

/* Overlaid histograms */
data1: makelist(random_normal(0, 1), i, 1, 500)$
data2: makelist(random_normal(2, 1.5), i, 1, 500)$
ax_draw2d(
  color="blue", opacity=0.5, name="Group A", ax_histogram(data1),
  color="red", opacity=0.5, name="Group B", ax_histogram(data2),
  bar_mode="overlay", title="Comparing Distributions"
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `nbins` | auto | Number of bins |
| `color` | auto | Bar fill color |
| `name` | auto | Legend entry |
| `opacity` | 1.0 | Bar opacity |

#### Layout Options

| Option | Values | Description |
|--------|--------|-------------|
| `bar_mode` | `"group"`, `"stack"`, `"overlay"` | How overlapping histograms are displayed |

See also: `ax_draw2d`, `ax_bar`
