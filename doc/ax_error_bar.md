### Function: ax_error_bar (xs, ys, y_errors) / ax_error_bar (xs, ys, y_errors, x_errors)

Points with error bars.  `y_errors` (and optionally `x_errors`) give the
half-length of each point's bar, in data units.  Use inside `ax_draw2d`; all
arguments are lists of numbers (or ndarrays) of the same length.

#### Examples

```maxima
ax_draw2d(
  ax_error_bar([1, 2, 3, 4], [2.0, 3.1, 3.9, 5.2], [0.2, 0.3, 0.25, 0.4]),
  explicit(x + 1, x, 0.5, 4.5, dash="dot"),
  showlegend=false
)$

/* Error bars in both directions */
ax_draw2d(ax_error_bar([1, 2, 3], [1, 4, 9], [0.5, 1, 1.5], [0.1, 0.1, 0.2]))$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `color` | auto | Marker colour |
| `marker_size` | 6 | Marker size |
| `marker_symbol` | `"circle"` | Marker shape |
| `name` | `"error bars"` | Legend entry |

See also: `points`, `ax_draw2d`
