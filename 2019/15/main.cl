(require "asdf")

(defun direction-offset (direction) (case direction (1 '(0 . -1)) (2 '(0 . 1)) (3 '(-1 . 0)) (4 '(1 . 0))))
(defun direction-opposite (direction) (case direction (1 2) (2 1) (3 4) (4 3)))
(defun add-pos (pos offset) (cons (+ (car pos) (car offset)) (+ (cdr pos) (cdr offset))))

(let
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    (data (make-hash-table))
    (pc 0)
    (relative-base 0)
    (map (make-hash-table :test #'equal))
    (position '(0 . 0))
    (boundary (list '(0 . 0)))
    oxygen-system)

  (setf (gethash position map) '(0 . 0))

  (labels
    ((get-data (address) (gethash address data 0))
    (set-data (address value) (setf (gethash address data) value))
    (get-value (arg mode) (case mode (0 (get-data arg)) (1 arg) (2 (get-data (+ arg relative-base)))))
    (set-value (arg mode value) (set-data (case mode (0 arg) (2 (+ arg relative-base))) value))
    (move-droid (direction) (loop
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
                (set-value (get-data (+ pc 1)) mode0 direction)
                (setq pc (+ pc 2)))
              (4
                (let ((status (arg0))) (setq pc (+ pc 2)) (return status)))
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
    (remove-min-pos () (let*
      ((min-pos (first boundary))
        (min-dist (car (gethash min-pos map))))
      (loop for pos in (rest boundary) do
        (let ((dist (car (gethash pos map)))) (if (< dist min-dist) (setq min-pos pos min-dist dist))))
      (setq boundary (delete min-pos boundary :test #'equal))
      min-pos))
    (get-path (end-pos) (loop with pos = end-pos until (equal pos '(0 . 0)) collect
      (let ((dir (cdr (gethash pos map)))) (setq pos (add-pos pos (direction-offset dir))) dir)))
    (reverse-path (path) (reverse (mapcar #'direction-opposite path)))
    (return-from-pos (pos) (mapc #'move-droid (get-path pos)))
    (move-to-pos (pos) (mapc #'move-droid (reverse-path (get-path pos)))))

    (loop for value in elements for address from 0 do (set-data address (parse-integer value)))

    (loop until (null boundary) do
      (let* ((min-pos (remove-min-pos)) (min-dist (car (gethash min-pos map))))
        (move-to-pos min-pos)
        (loop for dir from 1 to 4 do
          (let ((status (move-droid dir)))
            (if (/= status 0)
              (let ((pos (add-pos min-pos (direction-offset dir))))
                (if (null (gethash pos map)) (progn
                  (if (= status 2) (setq oxygen-system pos))
                  (setf (gethash pos map) (cons (1+ min-dist) (direction-opposite dir)))
                  (push pos boundary)))
                (move-droid (direction-opposite dir))))))
        (return-from-pos min-pos)))

    (remhash oxygen-system map)

    (print (loop for minutes from 0 with pending = (list oxygen-system) until (null pending) do
      (let (next-pending)
        (loop for pending-pos in pending do
          (loop for dir from 1 to 4 do
            (let ((pos (add-pos pending-pos (direction-offset dir))))
              (if (gethash pos map) (progn
                (remhash pos map)
                (push pos next-pending))))))
        (setq pending next-pending))
      finally (return (1- minutes))))))
