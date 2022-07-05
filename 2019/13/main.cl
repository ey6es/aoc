(require "asdf")

(let
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    (data (make-hash-table))
    (pc 0)
    (relative-base 0)
    (image (make-hash-table :test #'equal))
    output score ball-x paddle-x)

  (labels
    ((get-data (address) (gethash address data 0))
    (set-data (address value) (setf (gethash address data) value))
    (get-value (arg mode) (case mode (0 (get-data arg)) (1 arg) (2 (get-data (+ arg relative-base)))))
    (set-value (arg mode value) (set-data (case mode (0 arg) (2 (+ arg relative-base))) value)))

    (loop for value in elements for address from 0 do (set-data address (parse-integer value)))

    (set-data 0 2)

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
                (set-value (get-data (+ pc 1)) mode0 (if (> ball-x paddle-x) 1 (if (< ball-x paddle-x) -1 0)))
                (setq pc (+ pc 2)))
              (4
                (push (arg0) output)
                (if (= (length output) 3) (let
                  ((tile-id-score (pop output))
                    (y (pop output))
                    (x (pop output)))
                  (if (and (= x -1) (= y 0))
                    (setq score tile-id-score)
                    (progn
                      (setf (gethash (cons x y) image) tile-id-score)
                      (case tile-id-score (3 (setq paddle-x x)) (4 (setq ball-x x)))))))
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
  (print score))