;;; -*- Mode: Common-lisp; Package: clim-internals -*-

(in-package :clim-internals)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Some facilities for Pixmaps and Patterns
;;; and dealing with file formats
;;;
;;; There's a version of each of these for pixmaps and patterns
;;; They are identical other than which type of object they deal with
;;;
;;; It's not clear we need both of these, but when to use patterns, vs pixmaps
;;; isn't clear to me.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Since Clim-internals uses Clim, this will have the effect
;;; of making these exported from CLIM but defined in clim-internals

(eval-when (:compile-toplevel :load-toplevel :execute)
  (loop for string in '("make-pixmap-and-pattern-from-file"
			"display-sub-pixmap"
			"display-clipped-pixmap"
			"display-sub-pattern"
			"display-clipped-pattern")
      for symbol = (intern (string-upcase string) 'clim)
      do (export symbol 'clim)))

(defun make-pixmap-and-pattern-from-file 
    (&key 
     (pathname #P"/research-projects/nicecap/stata-image.tiff")
     (format :tiff)
     (stream *standard-output*))
  (let* ((pattern (clim:make-pattern-from-bitmap-file pathname :format format))
	 (pixmap (clim:with-output-to-pixmap (stream stream)
		   (clim:draw-pattern* stream pattern 0 0))))
    (values pixmap pattern)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Pixmap Version
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun display-sub-pixmap (pixmap pixmap-x pixmap-y width height stream stream-x stream-y)
  (let ((region (clim:make-bounding-rectangle stream-x stream-y
					      (+ stream-x width) (+ stream-y height))))
    (clim:draw-pixmap* stream pixmap (- stream-x pixmap-x) (- stream-y pixmap-y)
		       :clipping-region region)))

(defun display-clipped-pixmap (pixmap pixmap-x pixmap-y 
			       &key
			       window-x window-y
			       (width (- (clim:pixmap-width pixmap) pixmap-x))
			       (height (-(clim:pixmap-height pixmap) pixmap-y))
			       (stream *standard-output*)
			       (move-cursor? nil))  
  (unless (and window-x window-y)
    (multiple-value-bind (current-window-x current-window-y)
	(clim:stream-cursor-position stream)
      (unless window-x (setq window-x current-window-x))
      (unless window-y (setq window-y current-window-y))
      ))
  (clim:with-bounding-rectangle* (vx1 vy1 vx2 vy2) 
      (clim:pane-viewport-region stream)
    (declare (ignore vx1 vy1 vx2))
    (when (> (+ window-y height) vy2)
      (clim:window-set-viewport-position stream 0 (- window-y 10))))
  (display-sub-pixmap pixmap pixmap-x pixmap-y width height stream window-x window-y)
  (when move-cursor?
    (clim:stream-set-cursor-position stream 0 (+ window-y height)))
  (values window-x window-y width height)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Pattern Version
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun display-sub-pattern (pattern pattern-x pattern-y width height stream stream-x stream-y)
  (let ((region (clim:make-bounding-rectangle stream-x stream-y
					      (+ stream-x width) (+ stream-y height))))
    (clim:draw-pattern* stream pattern (- stream-x pattern-x) (- stream-y pattern-y)
		       :clipping-region region)))

(defun display-clipped-pattern (pattern pattern-x pattern-y 
			       &key
			       window-x window-y
			       (width (- (clim:pattern-width pattern) pattern-x))
			       (height (-(clim:pattern-height pattern) pattern-y))
			       (stream *standard-output*)
			       (move-cursor? nil))  
  (unless (and window-x window-y)
    (multiple-value-bind (current-window-x current-window-y)
	(clim:stream-cursor-position stream)
      (unless window-x (setq window-x current-window-x))
      (unless window-y (setq window-y current-window-y))
      ))
  (clim:with-bounding-rectangle* (vx1 vy1 vx2 vy2) 
      (clim:pane-viewport-region *standard-output*)
    (declare (ignore vx1 vy1 vx2))
    (when (> (+ window-y height) vy2)
      (clim:window-set-viewport-position *standard-output* 0 (- window-y 10))))
  (display-sub-pattern pattern pattern-x pattern-y width height stream window-x window-y)
  (when move-cursor?
    (clim:stream-set-cursor-position stream 0 (+ window-y height)))
  (values window-x window-y width height)
  )


