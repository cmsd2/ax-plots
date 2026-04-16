### Function: ax_vector_field (Fx, Fy, xvar, xlo, xhi, yvar, ylo, yhi)

`ax_vector_field(Fx, Fy, xvar, xlo, xhi, yvar, ylo, yhi)`

2D vector field (quiver) plot. Use inside `ax_draw2d`. Given a vector field F = (Fx(x,y), Fy(x,y)), samples on a grid and renders arrows showing the field direction and magnitude.

#### Examples

```maxima
/* Rotation field */
ax_draw2d(ax_vector_field(-y, x, x, -3, 3, y, -3, 3))$

/* Source/sink */
ax_draw2d(
  ax_vector_field(x, y, x, -2, 2, y, -2, 2),
  title="Source"
)$

/* Direction-only (normalized arrows) */
ax_draw2d(
  ax_vector_field(-y, x, x, -3, 3, y, -3, 3),
  normalize=true, ngrid=25
)$

/* Phase portrait: vector field + streamlines */
ax_draw2d(
  color="#cccccc", ax_vector_field(-y, x, x, -3, 3, y, -3, 3),
  color="red", ax_streamline(-y, x, x, -3, 3, y, -3, 3),
  aspect_ratio=true, title="Phase Portrait"
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `ngrid` | 20 | Grid resolution (ngrid x ngrid arrows) |
| `arrow_scale` | 1.0 | Multiplier for arrow length |
| `normalize` | false | Equal-length arrows (direction only) |
| `color` | auto | Arrow color |
| `name` | auto | Legend entry |
| `opacity` | 1.0 | Trace opacity |

See also: `ax_draw2d`, `ax_streamline`
