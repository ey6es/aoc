(require "asdf")

(defconstant DIRECTION_OFFSETS '#((0 . -1) (1 . 0) (0 . 1) (-1 . 0)))

(defun move (position direction) (let ((offset (aref DIRECTION_OFFSETS direction)))
  (cons (+ (car position) (car offset)) (+ (cdr position) (cdr offset)))))

(let
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    (data (make-hash-table))
    (pc 0)
    (relative-base 0)
    (image (make-hash-table :test #'equal))
    (position '(0 . 0))
    (min-position '(0 . 0))
    (max-position '(0 . 0))
    (direction 0)
    (output-color t))

  (setf (gethash position image) 1)

  (labels
    ((get-data (address) (gethash address data 0))
    (set-data (address value) (setf (gethash address data) value))
    (get-value (arg mode) (case mode (0 (get-data arg)) (1 arg) (2 (get-data (+ arg relative-base)))))
    (set-value (arg mode value) (set-data (case mode (0 arg) (2 (+ arg relative-base))) value)))

    (loop for value in elements for address from 0 do (set-data address (parse-integer value)))

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
                (set-value (get-data (+ pc 1)) mode0 (gethash position image 0))
                (setq pc (+ pc 2)))
              (4
                (if output-color
                  (setf (gethash position image) (arg0))
                  (setq
                    direction (mod (+ direction (if (= (arg0) 0) 3 1)) 4)
                    position (move position direction)
                    min-position (cons (min (car min-position) (car position)) (min (cdr min-position) (cdr position)))
                    max-position (cons (max (car max-position) (car position)) (max (cdr max-position) (cdr position)))))
                (setq output-color (not output-color))
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
              (99 (return)))))))
  (loop for y from (cdr min-position) to (cdr max-position) do
    (loop for x from (car min-position) to (car max-position) do
      (princ (if (equal (gethash (cons x y) image) 1) #\X #\Space)))
    (princ #\Newline)))
