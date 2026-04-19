(in-package :cl-info)
(let (
(deffn-defvr-pairs '(
; CONTENT: (<INDEX TOPIC> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS> <NODE NAME>))
("ax_bar" . ("ax-plots.info" 17192 580 "Function ax_bar categories values"))
("ax_contour" . ("ax-plots.info" 22434 466 "Function ax_contour expr xvar xlo xhi yvar ylo yhi"))
("ax_draw3d" . ("ax-plots.info" 14148 256 "Function ax_draw3d [args]"))
))
(section-pairs '(
; CONTENT: (<NODE NAME> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS>))
("2D Plotting" . ("ax-plots.info" 1130 90))
("3D Plotting" . ("ax-plots.info" 14001 73))
("Field Plots" . ("ax-plots.info" 22237 98))
("Introduction to ax-plots" . ("ax-plots.info" 543 440))
("Statistical Charts" . ("ax-plots.info" 17008 95))
)))
(load-info-hashtables (maxima::maxima-load-pathname-directory) deffn-defvr-pairs section-pairs))
