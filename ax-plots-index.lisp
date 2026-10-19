(in-package :cl-info)
(let (
(deffn-defvr-pairs '(
; CONTENT: (<INDEX TOPIC> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS> <NODE NAME>))
("ax_bar" . ("ax-plots.info" 40349 686 "Function ax_bar categories values"))
("ax_contour" . ("ax-plots.info" 46546 558 "Function ax_contour expr xvar xlo xhi yvar ylo yhi"))
("ax_draw3d" . ("ax-plots.info" 35425 300 "Function ax_draw3d [args]"))
))
(section-pairs '(
; CONTENT: (<NODE NAME> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS>))
("2D Plotting" . ("ax-plots.info" 1172 90))
("3D Plotting" . ("ax-plots.info" 35278 73))
("Field Plots" . ("ax-plots.info" 46349 98))
("Introduction to ax-plots" . ("ax-plots.info" 543 470))
("Statistical Charts" . ("ax-plots.info" 40165 95))
)))
(load-info-hashtables (maxima::maxima-load-pathname-directory) deffn-defvr-pairs section-pairs))
