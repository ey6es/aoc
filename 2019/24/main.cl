(defun get-edges (dir) (case dir
  (0 '((4 . 0) (4 . 1) (4 . 2) (4 . 3) (4 . 4)))
  (1 '((0 . 4) (1 . 4) (2 . 4) (3 . 4) (4 . 4)))
  (2 '((0 . 0) (1 . 0) (2 . 0) (3 . 0) (4 . 0)))
  (3 '((0 . 0) (0 . 1) (0 . 2) (0 . 3) (0 . 4)))))

(let ((initial-state 0) (levels (make-hash-table)))
  (with-open-file (stream "input.txt")
    (loop for line = (read-line stream nil) with power = 1 until (null line) do
      (loop for ch across line do
        (setq initial-state (logior initial-state (if (char= ch #\.) 0 power)) power (ash power 1)))))
  (setf (gethash 0 levels) initial-state)

  (labels
    ((get-value (level row col &optional dir) (cond
      ((= row -1) (get-value (1- level) 1 2))
      ((= col -1) (get-value (1- level) 2 1))
      ((= row 5) (get-value (1- level) 3 2))
      ((= col 5) (get-value (1- level) 2 3))
      ((and (= row 2) (= col 2)) (loop for pos in (get-edges dir) sum
        (get-value (1+ level) (car pos) (cdr pos))))
      (t (logand (ash (gethash level levels 0) (- (* row -5) col)) 1)))))
    (loop for minute from 1 to 200 do (let ((next-levels (make-hash-table)))
      (loop for level from (- minute) to minute do (let ((next-state 0))
        (loop for row from 0 to 4 with power = 1 do
          (loop for col from 0 to 4 do (let
            ((neighbors (+
              (get-value level (1- row) col 0)
              (get-value level row (1- col) 1)
              (get-value level row (1+ col) 2)
              (get-value level (1+ row) col 3))))
            (if (and
              (or (/= row 2) (/= col 2))
              (or (= neighbors 1) (and (zerop (get-value level row col)) (= neighbors 2))))
                (setq next-state (logior next-state power)))
            (setq power (ash power 1)))))
        (setf (gethash level next-levels) next-state)))
      (setq levels next-levels))))

  (print (loop for level from -201 to 201 sum
    (loop for row from 0 to 4 with state = (gethash level levels 0) sum
      (loop for col from 0 to 4 sum (let ((value (logand state 1)))
        (setq state (ash state -1))
        value))))))
