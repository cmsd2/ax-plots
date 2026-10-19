# Changelog

Notable changes to ax-plots.  The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/) (in 0.x, a minor bump can break
compatibility).

## [Unreleased]

## [0.2.0] - 2026-10-19

### Added

- **Labels, arrows and polygons** (2D), with the draw package's calling
  forms: `label([text, x, y], ...)`, `vector([x, y], [dx, dy])` and
  `polygon([[x, y], ...])`.  Label options: `font_size`, `font_color`,
  `font_family`, `label_alignment`, `label_valign`, `label_angle`,
  `label_orientation` and `label_offset` (pixel offset).
- **Shapes** (2D): `rectangle`, `ellipse` (including sectors), `hline` and
  `vline`, drawn above or below the data with `layer`.
- **Arrowheads on curves**: `head_end`, `head_start` and `head_count` on
  `lines`, `explicit` and `parametric`, sized with `head_size`, pointing
  along the curve (`head_direction="tangent"`) or its overall direction
  (`"chord"`).
- **Snake and zigzag decorations** on curves: `decoration`, with
  `decoration_wavelength`, `decoration_amplitude`, `decoration_pre` and
  `decoration_post`.
- **Per-object options**: style options given inside an object apply to it
  only, e.g. `lines(xs, ys, color="red")`.  Per-object `showlegend`,
  `hoverinfo`, `hover_text` and `legendgroup`.
- **Lists and `group()`**: arguments can be lists of objects, so
  `ax_draw2d(objs, ...)` replaces `apply(ax_draw2d, ...)`;
  `group(obj, ..., opt=val)` applies options to the objects in it.
- **`animate()` for labels, arrows and shapes** (2D).  A label whose text
  is a float, such as the animation parameter, shows 3 significant figures.
- **Diagrams**: `diagram=true` (no axes, grid, legend or hover; equal
  scales; fitted height) and `height=fit`.
- **`theme="dark"`** (2D, 3D, polar).
- **`filled_func`** on `explicit`: fill to y = 0 or between two curves.
- **Layout options**: `margin`, numeric `aspect_ratio`, `constrain`,
  `autosize`, `legend_position`, `legend_orientation`, `legend_title`,
  `title_font_size`, `title_x`, `title_align`, `colorway`, `line_shape`,
  tick values / text / format, reversed axes and zero lines.
- **Raw Plotly**: `ax_trace(json)` adds a trace and `layout_raw=json`
  merges into the layout, for anything not wrapped yet.
- **CI** runs the tests with and without `numerics` and `reactive`.

### Changed

- **Reactive signal metadata is read by key**, so ax-plots needs `reactive`
  at commit `897a88b` or later (keyed `signal_meta`).
- **Non-numeric data values** in `lines` and `points` are an error naming
  the object, axis and index, instead of a silent gap.  `false`, `inf`,
  `minf`, `und` and `ind` still mark intentional gaps.
- **Polar plots**: the plot area's background follows `plot_bgcolor`.

### Fixed

- Exact numeric constants such as `%pi/2` or `atan(3)` were written as
  `null` (a gap), in data and in `xrange` / `yrange`.
- `colorscale` (and any option not in the default style) was ignored.
- Quotes and backslashes in strings were not escaped in the JSON output.
- `aspect_ratio=false` still locked the aspect ratio.
- Curve arrowheads: a light rim around heads, heads drawn faded, and gaps
  in lines that carry heads.
- Slider labels showed 0 as `0.000e+0`.

## [0.1.0] - 2026-04-16 to 2026-06-04

The first version, unchanged in number while these were added:

- `ax_draw2d` and `ax_draw3d` with `explicit`, `parametric`, `points`,
  `lines` and `implicit`; `ax_plot2d`; `ax_polar`; `ax_contour`,
  `ax_heatmap`, `ax_bar`, `ax_histogram`, `ax_box`, `ax_violin`, `ax_pie`,
  `ax_error_bar`, `ax_vector_field` and `ax_streamline`.
- Help-system index for `?` and `??`.
- `numerics` ndarrays accepted wherever lists are.
- Log-scale axes and background colour options.
- `animate()` for curves and surfaces, with a fast path through
  `numerics`' `compile_grid` when it is installed.
- Reactive views: plots containing `reactive` signals carry `_reactive`
  metadata, so a host can show widgets and redraw the plot.

[Unreleased]: https://github.com/cmsd2/ax-plots/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/cmsd2/ax-plots/compare/a721119...v0.2.0
[0.1.0]: https://github.com/cmsd2/ax-plots/commits/a721119
