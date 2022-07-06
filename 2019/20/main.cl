(defun dir-offset (dir) (case dir (0 '(0 . -1)) (1 '(1 . 0)) (2 '(0 . 1)) (3 '(-1 . 0))))

(defun add-pos (pos offset) (cons (+ (car pos) (car offset)) (+ (cdr pos) (cdr offset))))

(defstruct heap (values (make-array 0 :adjustable t :fill-pointer t)) (items (make-hash-table :test #'equal)))

(defun bubble-heap (start-index heap) (let
  ((values (heap-values heap))
    (items (heap-items heap)))
  (loop with index = start-index until (zerop index) do
    (let*
      ((parent-index (floor (1- index) 2))
        (value (aref values index))
        (parent-value (aref values parent-index)))
      (if (< (cdr value) (cdr parent-value))
        (setf
          (aref values index) parent-value
          (gethash (car parent-value) items) index
          (aref values parent-index) value
          (gethash (car value) items) parent-index
          index parent-index)
        (return))))))

(defun push-replace-heap (item dist heap) (let*
  ((values (heap-values heap))
    (items (heap-items heap))
    (index (gethash item items)))
  (if (null index) (push-heap item dist heap)
    (if (< dist (cdr (aref values index))) (progn
      (setf (aref values index) (cons item dist))
      (bubble-heap index heap))))))

(defun push-heap (item dist heap) (let*
  ((values (heap-values heap))
    (items (heap-items heap))
    (last-index (fill-pointer values)))
  (vector-push-extend (cons item dist) values)
  (setf (gethash item items) last-index)
  (bubble-heap last-index heap)))

(defun pop-heap (heap) (let*
  ((values (heap-values heap))
    (items (heap-items heap))
    (top-value (aref values 0))
    (last-value (vector-pop values))
    (value-length (fill-pointer values)))
  (remhash (car top-value) items)
  (if (> value-length 0) (progn
    (setf (aref values 0) last-value (gethash (car last-value) items) 0)
    (loop with index = 0 until (>= index value-length) do (let ((left-index (1+ (* index 2))))
      (if (>= left-index value-length) (return))
      (let ((value (aref values index)) (left-value (aref values left-index)) (right-index (1+ left-index)))
        (if (>= right-index value-length) (progn
          (if (< (cdr left-value) (cdr value)) (setf
            (aref values index) left-value
            (gethash (car left-value) items) index
            (aref values left-index) value
            (gethash (car value) items) left-index))
          (return)))
        (let ((right-value (aref values right-index)))
          (if (< (cdr left-value) (cdr right-value))
            (if (< (cdr left-value) (cdr value))
              (setf
                (aref values index) left-value
                (gethash (car left-value) items) index
                (aref values left-index) value
                (gethash (car value) items) left-index
                index left-index)
              (return))
            (if (< (cdr right-value) (cdr value))
              (setf
                (aref values index) right-value
                (gethash (car right-value) items) index
                (aref values right-index) value
                (gethash (car value) items) right-index
                index right-index)
              (return)))))))))
  top-value))

(let*
  ((lines (with-open-file (stream "input.txt")
      (loop for line = (read-line stream nil) until (null line) collect line)))
    (height (length lines))
    (width (loop for line in lines maximize (length line)))
    (data (make-array (list height width)))
    (portal-positions (make-hash-table :test #'equal))
    (portal-labels (make-hash-table :test #'equal)))

  (loop for row from 0 below height for line in lines do
    (loop for col from 0 below width do (setf (aref data row col) (if (< col (length line)) (char line col) #\Space))))

  (loop for row from 0 below (1- height) do
    (loop for col from 0 below (1- width) do (let
      ((ch (aref data row col))
        (right (aref data row (1+ col)))
        (below (aref data (1+ row) col)))
      (cond
        ((and (alpha-char-p ch) (alpha-char-p right)) (let
          ((label (format nil "~A~A" ch right))
            (pos (if (and (> col 0) (char= (aref data row (1- col)) #\.)) (cons row (1- col)) (cons row (+ 2 col)))))
          (push (cons pos (or (= col 0) (= col (- width 2)))) (gethash label portal-positions))
          (setf (gethash pos portal-labels) label)))
        ((and (alpha-char-p ch) (alpha-char-p below)) (let
          ((label (format nil "~A~A" ch below))
            (pos (if (and (> row 0) (char= (aref data (1- row) col) #\.)) (cons (1- row) col) (cons (+ 2 row) col))))
          (push (cons pos (or (= row 0) (= row (- height 2)))) (gethash label portal-positions))
          (setf (gethash pos portal-labels) label)))))))

  (flet
    ((get-distance (start end &aux (dists (make-heap)) (loop-counter 0))
      (push-heap (cons start 0) 0 dists)
      (loop (let*
        ((min-value (pop-heap dists))
          (min-item (car min-value))
          (min-dist (cdr min-value))
          (min-pos (car min-item))
          (min-layer (cdr min-item))
          (label (gethash min-pos portal-labels))
          (portals (gethash label portal-positions))
          (dist (1+ min-dist)))
        (if (and (equal min-pos end) (= min-layer 0)) (return min-dist))
        (if (zerop (mod (incf loop-counter) 100000)) (print min-dist))
        (loop for portal in portals do (let ((pos (car portal)) (outer (not (cdr portal))))
          (if (not (equal pos min-pos))
            (if outer
              (if (> min-layer 0) (push-replace-heap (cons pos (1- min-layer)) dist dists))
              (push-replace-heap (cons pos (1+ min-layer)) dist dists)))))
        (loop for dir from 0 to 3 do (let ((pos (add-pos min-pos (dir-offset dir))))
          (if (char= (aref data (car pos) (cdr pos)) #\.) (push-replace-heap (cons pos min-layer) dist dists))))))))

    (print (get-distance (car (car (gethash "AA" portal-positions))) (car (car (gethash "ZZ" portal-positions)))))))
