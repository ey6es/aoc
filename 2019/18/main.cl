(defun manhattan-dist (start end) (+ (abs (- (car end) (car start))) (abs (- (cdr end) (cdr start)))))

(defun dir-offset (dir) (case dir (0 '(0 . -1)) (1 '(1 . 0)) (2 '(0 . 1)) (3 '(-1 . 0))))

(defun add-pos (pos offset) (cons (+ (car pos) (car offset)) (+ (cdr pos) (cdr offset))))

(defstruct heap (values (make-array 0 :adjustable t :fill-pointer t)) (pred (lambda (a b) (< (third a) (third b)))))

(defun push-heap (item heap) (let* ((values (heap-values heap)) (pred (heap-pred heap)))
  (vector-push-extend item values)
  (loop with index = (1- (fill-pointer values)) until (zerop index) do
    (let*
      ((parent-index (floor (1- index) 2))
        (value (aref values index))
        (parent-value (aref values parent-index)))
      (if (funcall pred value parent-value)
        (setf (aref values index) parent-value (aref values parent-index) value index parent-index)
        (return))))))

(defun pop-heap (heap) (let* ((values (heap-values heap)) (top (aref values 0)) (pred (heap-pred heap)) value-length)
  (setf (aref values 0) (vector-pop values) value-length (fill-pointer values))
  (loop with index = 0 until (>= index value-length) do (let ((left-index (1+ (* index 2))))
    (if (>= left-index value-length) (return))
    (let ((value (aref values index)) (left-value (aref values left-index)) (right-index (1+ left-index)))
      (if (>= right-index value-length) (progn
        (if (funcall pred left-value value) (setf (aref values index) left-value (aref values left-index) value))
        (return)))
      (let ((right-value (aref values right-index)))
        (if (funcall pred left-value right-value)
          (if (funcall pred left-value value)
            (setf (aref values index) left-value (aref values left-index) value index left-index)
            (return))
          (if (funcall pred right-value value)
            (setf (aref values index) right-value (aref values right-index) value index right-index)
            (return)))))))
  top))

(let*
  ((lines (with-open-file (stream "input.txt")
      (loop for line = (read-line stream nil) until (null line) collect line)))
    (height (length lines))
    (width (length (first lines)))
    (data (make-array (list height width)))
    (visited (make-array (list height width) :initial-element nil))
    start-pos start-row start-col (key-count 0) dependencies positions all-keys (states (make-hash-table :test #'equal)))
  (loop for row from 0 below height for line in lines do
    (loop for col from 0 below width do (let ((ch (char line col)))
      (if (char= ch #\@) (setq start-pos (cons row col)))
      (if (and (char>= ch #\a) (char<= ch #\z)) (setq key-count (max key-count (- (1+ (char-code ch)) (char-code #\a)))))
      (setf (aref data row col) ch))))

  (setq start-row (car start-pos) start-col (cdr start-pos))
  (setf
    (aref data (1- start-row) (1- start-col)) #\@
    (aref data (1- start-row) start-col) #\#
    (aref data (1- start-row) (1+ start-col)) #\@
    (aref data start-row (1- start-col)) #\#
    (aref data start-row start-col) #\#
    (aref data start-row (1+ start-col)) #\#
    (aref data (1+ start-row) (1- start-col)) #\@
    (aref data (1+ start-row) start-col) #\#
    (aref data (1+ start-row) (1+ start-col)) #\@)
  (setq start-pos (list
    (cons (1- start-row) (1- start-col))
    (cons (1- start-row) (1+ start-col))
    (cons (1+ start-row) (1- start-col))
    (cons (1+ start-row) (1+ start-col))))

  (setq dependencies (make-array key-count) positions (make-array key-count) all-keys (1- (ash 1 key-count)))

  (loop for row from 0 below height for line in lines do
    (loop for col from 0 below width do (let ((ch (char line col)))
      (if (and (char>= ch #\a) (char<= ch #\z)) (setf (aref positions (- (char-code ch) (char-code #\a))) (cons row col))))))

  (labels ((explore (pos &optional (deps 0)) (let* ((row (car pos)) (col (cdr pos)))
    (if (null (aref visited row col)) (let ((ch (aref data row col)))
      (if (char/= ch #\#) (let
          ((next-deps (if (alpha-char-p ch) (logior deps (ash 1 (- (char-code (char-downcase ch)) (char-code #\a)))) deps)))
        (setf (aref visited row col) t)
        (if (and (char>= ch #\a) (char<= ch #\z)) (setf (aref dependencies (- (char-code ch) (char-code #\a))) deps))
        (explore (cons (1- row) col) next-deps)
        (explore (cons row (1- col)) next-deps)
        (explore (cons row (1+ col)) next-deps)
        (explore (cons (1+ row) col) next-deps)
        (setf (aref visited row col) nil))))))))
    (loop for pos in start-pos do (explore pos)))

  (flet
    ((get-distance (start end &aux (fringe (make-heap)) (visited (make-hash-table :test #'equal)))
      (push-heap (list start 0 (manhattan-dist start end)) fringe)
      (loop (let*
        ((min-value (pop-heap fringe))
          (min-pos (first min-value))
          (min-dist (second min-value)))
        (if (equal min-pos end) (return min-dist))
        (loop for dir from 0 to 3 do (let* ((pos (add-pos min-pos (dir-offset dir))))
          (if (and (not (gethash pos visited)) (char/= (aref data (car pos) (cdr pos)) #\#)) (progn
            (setf (gethash pos visited) t)
            (push-heap (list pos (1+ min-dist) (+ min-dist 1 (manhattan-dist pos end))) fringe)))))))))

    (setf (gethash (cons 0 start-pos) states) 0)
    (print (loop (let ((min-dist 99999999) min-value)
      (loop for value being the hash-key using (hash-value dist) of states do
        (if (< dist min-dist) (setq min-dist dist min-value value)))
      (remhash min-value states)
      (let ((min-state (car min-value)) (min-pos (cdr min-value)))
        (if (= all-keys min-state) (return min-dist))
        (loop for key from 0 below key-count do
          (let ((key-bit (ash 1 key)) (deps (aref dependencies key)))
            (if (and (zerop (logand min-state key-bit)) (= (logand min-state deps) deps)) (let*
              ((key-pos (aref positions key))
                (quadrant
                  (if (< (car key-pos) start-row) (if (< (cdr key-pos) start-col) 0 1) (if (< (cdr key-pos) start-col) 2 3)))
                (pos (copy-list min-pos)))
              (setf (nth quadrant pos) key-pos)
              (let*
                ((value (cons (logior min-state key-bit) pos))
                  (dist (+ min-dist (get-distance (nth quadrant min-pos) key-pos)))
                  (current-dist (gethash value states)))
              (if (or (null current-dist) (< dist current-dist)) (setf (gethash value states) dist)))))))))))))
