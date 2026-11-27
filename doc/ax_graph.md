### Function: ax_graph (positions, edges)

A graph: points joined by edges. Use inside `ax_draw2d` or `ax_draw3d`.

Calling forms:

- `ax_graph(positions, edges)`: points and the edges between them
- `ax_graph(g)`: a graph or digraph from Maxima's `graphs` package, at its stored positions, or at a spring embedding when it has none (in 3D, always a spring embedding)
- `ax_graph(g, positions)`: a `graphs` graph at the positions given, either the package's own `[[v, [x, y]], ...]` (as `circular_positions` or `spring_embedding` return) or a list of points in increasing vertex order

`positions` is a list of points, `[x, y]` in 2D or `[x, y, z]` in 3D; vertex i sits at `positions[i]`. `edges` is a list of `[i, j]` or `[i, j, k]`, where k is the edge's class: the edges of each class form one trace, so they share a colour and a legend entry. For a Cayley graph the class is the generator. `edges` may also be `[n, edges]`, the form the permutations package's `pgrp_cayley_graph` returns.

For a `graphs` graph, the vertices keep their own numbers when hovered, and a digraph's arcs are drawn without arrows. ax-plots doesn't load the `graphs` package; load it yourself to build such graphs.

The vertices form one more trace, grey unless `vertex_color` is given. Hovering a vertex shows its number, or its label from `vertex_labels`. Set `marker_size = 0` to draw the edges alone.

A plot that holds only `ax_graph` objects shows only the graph's arrangement. In 3D it defaults to `diagram=true`: no axes, grid or legend, and equal scales. In 2D it hides the axes, grid and legend and keeps equal scales. Options given explicitly win: `diagram=false` brings everything back, and `xaxis=true` or `showlegend=true` brings back one thing.

#### Examples

```maxima
/* A square with labelled corners */
ax_draw2d(
  ax_graph([[0, 0], [1, 0], [1, 1], [0, 1]], [[1, 2], [2, 3], [3, 4], [4, 1]],
           vertex_labels = ["A", "B", "C", "D"])
)$

/* A tetrahedron */
ax_draw3d(
  ax_graph([[1, 1, 1], [1, -1, -1], [-1, 1, -1], [-1, -1, 1]],
           [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]])
)$

/* Graphs from the graphs package, including one built from an adjacency matrix */
load(graphs)$
ax_draw2d(ax_graph(petersen_graph()))$
ax_draw3d(ax_graph(dodecahedron_graph()))$
ax_draw2d(ax_graph(from_adjacency_matrix(matrix([0,1,1,0], [1,0,1,1], [1,1,0,1], [0,1,1,0]))))$

/* The Cayley graph of A5, laid out from the group alone: a football */
load("permutations")$
C : pgrp_cayley_graph(pgrp([2, 3, 4, 5, 1], [2, 1, 4, 3, 5]))$
ax_draw3d(
  ax_graph(pgrp_spectral_layout(C), C,
           edge_colors = ["#1f2440", "#e0452b"], marker_size = 4)
)$
```

#### Relevant Options

| Option | Default | Description |
|--------|---------|-------------|
| `edge_colors` | auto | A list of colours, one per edge class in order of class, cycled |
| `edge_names` | `edges k` | A list of legend names, one per edge class |
| `color` | auto | The edges' colour when there is one class and no `edge_colors` |
| `line_width` | 2 | Edge width |
| `vertex_color` | grey | The vertices' colour |
| `marker_size` | 6 | Vertex size; 0 draws no vertices |
| `vertex_labels` | none | A list with a label per vertex, drawn above it |
| `opacity` | 1.0 | Trace opacity |

See also: `ax_draw2d`, `ax_draw3d`
