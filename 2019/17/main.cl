(require "asdf")

(defun dir-offset (dir) (case dir (0 '(0 . -1)) (1 '(1 . 0)) (2 '(0 . 1)) (3 '(-1 . 0))))

(defun add-pos (pos offset) (cons (+ (car pos) (car offset)) (+ (cdr pos) (cdr offset))))

(defun replace-seq (from to seq)
  (if (zerop (length from)) seq
    (let ((index (search from seq :test #'equal)))
      (if (null index) seq
        (append (subseq seq 0 index) to (replace-seq from to (subseq seq (+ index (length from)))))))))

(let
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    data pc relative-base
    (line (make-array 0 :fill-pointer t))
    (lines (make-array 0 :fill-pointer t))
    map-height map-width map pos (dir 0) path
    (remaining (make-hash-table :test #'equal)))

  (labels
    ((get-data (address) (gethash address data 0))
    (set-data (address value) (setf (gethash address data) value))
    (get-value (arg mode) (case mode (0 (get-data arg)) (1 arg) (2 (get-data (+ arg relative-base)))))
    (set-value (arg mode value) (set-data (case mode (0 arg) (2 (+ arg relative-base))) value))
    (get-map-char (pos) (let ((col (car pos)) (row (cdr pos)))
      (if (or (< col 0) (< row 0) (>= col map-width) (>= row map-height)) #\Space (aref map row col))))
    (run-ascii (mode input output)
      (setq data (make-hash-table) pc 0 relative-base 0)
      (loop for value in elements for address from 0 do (set-data address (parse-integer value)))

      (set-data 0 mode)

      (loop
        (let*
            ((command (get-data pc))
              (opcode (mod command 100))
              (mode0 (mod (floor command 100) 10))
              (mode1 (mod (floor command 1000) 10))
              (mode2 (mod (floor command 10000) 10)))
            (flet
              ((arg0 () (get-value (get-data (+ pc 1)) mode0))
                (arg1 () (get-value (get-data (+ pc 2)) mode1))
                (arg2 () (get-value (get-data (+ pc 3)) mode2)))
              (case opcode
                (1
                  (set-value (get-data (+ pc 3)) mode2 (+ (arg0) (arg1)))
                  (setq pc (+ pc 4)))
                (2
                  (set-value (get-data (+ pc 3)) mode2 (* (arg0) (arg1)))
                  (setq pc (+ pc 4)))
                (3
                  (set-value (get-data (+ pc 1)) mode0 (funcall input))
                  (setq pc (+ pc 2)))
                (4
                  (funcall output (arg0))
                  (setq pc (+ pc 2)))
                (5
                  (setq pc (if (/= (arg0) 0) (arg1) (+ pc 3))))
                (6
                  (setq pc (if (= (arg0) 0) (arg1) (+ pc 3))))
                (7
                  (set-value (get-data (+ pc 3)) mode2 (if (< (arg0) (arg1)) 1 0))
                  (setq pc (+ pc 4)))
                (8
                  (set-value (get-data (+ pc 3)) mode2 (if (= (arg0) (arg1)) 1 0))
                  (setq pc (+ pc 4)))
                (9
                  (setq relative-base (+ relative-base (arg0)))
                  (setq pc (+ pc 2)))
                (99 (return))))))))
    (run-ascii 1
      (lambda () 0)
      (lambda (code) (let ((char (code-char code)))
        (if (char= char #\Newline)
          (progn
            (if (/= 0 (length line)) (vector-push-extend line lines))
            (setq line (make-array 0 :fill-pointer t)))
          (vector-push-extend char line)))))
    (setq map-height (length lines) map-width (length (aref lines 0)) map (make-array (list map-height map-width)))
    (loop for row from 0 below map-height do (let ((line (aref lines row)))
      (loop for col from 0 below map-width do
        (setf (aref map row col) (aref line col))
        (case (aref line col)
          (#\^ (setq pos (cons col row)))
          (#\# (setf (gethash (cons col row) remaining) t))))))

    (loop until (zerop (hash-table-count remaining)) do
      (let*
        ((right (mod (+ dir 1) 4))
          (left (mod (+ dir 3) 4))
          (dir-pos (add-pos pos (dir-offset dir)))
          (right-pos (add-pos pos (dir-offset right)))
          (left-pos (add-pos pos (dir-offset left))))
        (cond
          ((char= (get-map-char dir-pos) #\#)
            (setq pos dir-pos)
            (remhash dir-pos remaining)
            (if (numberp (car path)) (incf (car path)) (push 1 path)))
          ((char= (get-map-char right-pos) #\#)
            (setq dir right)
            (push "R" path))
          ((char= (get-map-char left-pos) #\#)
            (setq dir left)
            (push "L" path))
          (t (return)))))

      (setq path (mapcar (lambda (element) (format nil "~A" element)) (reverse path)))

      (setq path (loop named outer for a-length from (/ (length path) 2) downto 1 do (let*
        ((a (subseq path 0 a-length))
          (a-replaced (replace-seq a '(#\A) path))
          (first-non-char (position-if-not #'characterp a-replaced))
          (start-b-index (if (null first-non-char) (length a-replaced) first-non-char))
          (end-b-index (position-if #'characterp a-replaced :start start-b-index)))
        (if (null end-b-index) (setq end-b-index (length a-replaced)))
        (loop for b-length from (- end-b-index start-b-index) downto 1 do (let*
          ((b (subseq a-replaced start-b-index (+ start-b-index b-length)))
            (b-replaced (replace-seq b '(#\B) a-replaced))
            (first-non-char (position-if-not #'characterp b-replaced))
            (start-c-index (if (null first-non-char) (length b-replaced) first-non-char))
            (end-c-index (position-if #'characterp b-replaced :start start-c-index)))
          (if (null end-c-index) (setq end-c-index (length b-replaced)))
          (let*
            ((c (subseq b-replaced start-c-index end-c-index))
              (c-replaced (replace-seq c '(#\C) b-replaced)))
            (if (null (position-if-not #'characterp c-replaced)) (let*
              ((formatted (format nil "~{~A~^,~}" c-replaced))
                (a-formatted (format nil "~{~A~^,~}" a))
                (b-formatted (format nil "~{~A~^,~}" b))
                (c-formatted (format nil "~{~A~^,~}" c)))
              (if (and
                (<= (length formatted) 20)
                (<= (length a-formatted) 20)
                (<= (length b-formatted) 20)
                (<= (length c-formatted) 20))
                  (return-from outer (format nil "~A~%~A~%~A~%~A~%n~%" formatted a-formatted b-formatted c-formatted)))))))))))

      (let ((path-index 0))
        (run-ascii 2
          (lambda () (let ((ch (char path path-index))) (incf path-index) (char-code ch)))
          (lambda (output) (if (< output 128) (princ (code-char output)) (print output)))))))
