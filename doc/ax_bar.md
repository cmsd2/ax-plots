### Function: ax_bar (categories, values)

Bar chart for labeled or numeric data. Use inside `ax_draw2d`.

Calling forms:

- `ax_bar(categories, values)` — string category list + numeric value list
- `ax_bar(values)` — just values (auto-numbered 1, 2, 3, ...)

For multiple series, use different `name` options and `bar_mode` layout option.

#### Examples

```maxima
/* Basic bar chart */
ax_draw2d(
  ax_bar(["Q1","Q2","Q3","Q4"], [100,150,120,180]),
  title="Quarterly Sales"
)$

/* Colored bars */
ax_draw2d(
  color="steelblue", ax_bar(["A","B","C"], [10,20,30]),
  title="Categories"
)$

/* Grouped bars (multiple series) */
ax_draw2d(
  name="2024", ax_bar(["Q1","Q2","Q3"], [100,150,120]),
  name="2025", ax_bar(["Q1","Q2","Q3"], [110,160,140]),
  bar_mode="group", title="Year Comparison"
)$

/* Stacked bars */
ax_draw2d(
  name="Product A", ax_bar(["Jan","Feb","Mar"], [30,40,35]),
  name="Product B", ax_bar(["Jan","Feb","Mar"], [20,25,30]),
  bar_mode="stack"
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Bar fill color |
| `bar_width` | auto | Bar width (0–1 fraction) |
| `name` | auto | Legend entry / series name |
| `opacity` | 1.0 | Bar opacity |

#### Layout Options

| Option | Values | Description |
|--------|--------|-------------|
| `bar_mode` | `"group"`, `"stack"`, `"overlay"` | How multiple bar series are arranged |

See also: `ax_draw2d`, `ax_histogram`
