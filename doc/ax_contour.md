### Function: ax_contour (expr, xvar, xlo, xhi, yvar, ylo, yhi)

Filled contour plot of a 2D expression. Use inside `ax_draw2d`. Samples f(x,y) on a grid and renders as a Plotly contour chart with multiple filled levels.

Distinct from `implicit()` which renders a single contour line at f(x,y)=0.

#### Examples

```maxima
/* Basic contour plot */
ax_draw2d(ax_contour(x^2 + y^2, x, -3, 3, y, -3, 3))$

/* With colorscale and contour count */
ax_draw2d(
  ax_contour(sin(x)*cos(y), x, -%pi, %pi, y, -%pi, %pi),
  colorscale="Viridis", ncontours=20,
  title="sin(x)*cos(y)"
)$

/* Hide colorbar */
ax_draw2d(
  ax_contour(x*y, x, -2, 2, y, -2, 2),
  showscale=false
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `colorscale` | auto | Color scale: `"Viridis"`, `"Hot"`, `"Blues"`, etc. |
| `ncontours` | auto | Number of contour levels |
| `showscale` | auto | Show/hide the color bar |
| `nticks` | 80 | Grid sampling resolution |
| `name` | auto | Legend entry |
| `opacity` | 1.0 | Trace opacity |

See also: `ax_draw2d`, `ax_heatmap`, `implicit`
