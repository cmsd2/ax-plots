# Package ax-plots

## Introduction to ax-plots

Interactive Plotly.js plotting for Maxima via Aximar. Provides functions that
reuse Maxima's `draw` package object syntax (`explicit`, `parametric`, `points`,
`implicit`) and add new objects (`lines`) for data plotting. Renders with Plotly
instead of gnuplot. Lists and ndarrays (from the `numerics` package) are accepted
transparently.

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

## Statistical Charts

<!-- include: ax_bar.md -->
<!-- include: ax_histogram.md -->
<!-- include: ax_heatmap.md -->

## Field Plots

<!-- include: ax_contour.md -->
<!-- include: ax_vector_field.md -->
<!-- include: ax_streamline.md -->
