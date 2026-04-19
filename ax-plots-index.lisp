(in-package :cl-info)
(let (
(deffn-defvr-pairs '(
; CONTENT: (<INDEX TOPIC> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS> <NODE NAME>))
("ax_bar" . ("ax-plots.info" 16124 686 "Function ax_bar categories values"))
("ax_contour" . ("ax-plots.info" 22321 558 "Function ax_contour expr xvar xlo xhi yvar ylo yhi"))
("ax_draw3d" . ("ax-plots.info" 13180 300 "Function ax_draw3d [args]"))
("ax_plot2d" . ("ax-plots.info" 1168 775 "Function ax_plot2d expr [var min max]"))
))
(section-pairs '(
; CONTENT: (<NODE NAME> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS>))
("2D Plotting" . ("ax-plots.info" 997 85))
("3D Plotting" . ("ax-plots.info" 13033 73))
("Field Plots" . ("ax-plots.info" 22124 98))
("Introduction to ax-plots" . ("ax-plots.info" 543 315))
("Statistical Charts" . ("ax-plots.info" 15940 95))
)))
(load-info-hashtables (maxima::maxima-load-pathname-directory) deffn-defvr-pairs section-pairs))
