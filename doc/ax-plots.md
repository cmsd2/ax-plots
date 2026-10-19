# Package ax-plots

## Introduction to ax-plots

Interactive Plotly.js plotting for Maxima via Aximar. Provides functions that
reuse Maxima's `draw` package object syntax (`explicit`, `parametric`, `points`,
`implicit`, `label`, `vector`, `polygon`, `rectangle`, `ellipse`) and add new
objects (`lines`, shapes, charts and fields) for data plotting.  Plots can be
animated with `animate`, and can depend on interactive parameters from the
`reactive` package.  Renders with Plotly instead of gnuplot.  Lists and ndarrays
(from the `numerics` package) are accepted transparently.

To use the package:

```
load("ax-plots");
```

## 2D Plotting

<!-- include: ax_plot2d.md -->
<!-- include: ax_draw2d.md -->
<!-- include: ax_polar.md -->

## 3D Plotting

<!-- include: ax_draw3d.md -->

## Animation and Interaction

<!-- include: ax_animate.md -->
<!-- include: ax_reactive.md -->

## Statistical Charts

<!-- include: ax_bar.md -->
<!-- include: ax_histogram.md -->
<!-- include: ax_heatmap.md -->
<!-- include: ax_box.md -->
<!-- include: ax_violin.md -->
<!-- include: ax_pie.md -->
<!-- include: ax_error_bar.md -->

## Field Plots

<!-- include: ax_contour.md -->
<!-- include: ax_vector_field.md -->
<!-- include: ax_streamline.md -->
