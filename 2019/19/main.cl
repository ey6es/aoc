(require "asdf")

(let
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    data pc relative-base (spans (make-array 99 :initial-element '(0 . 0))))

  (labels
    ((get-data (address) (gethash address data 0))
    (set-data (address value) (setf (gethash address data) value))
    (get-value (arg mode) (case mode (0 (get-data arg)) (1 arg) (2 (get-data (+ arg relative-base)))))
    (set-value (arg mode value) (set-data (case mode (0 arg) (2 (+ arg relative-base))) value))
    (run-tractor (input)
      (setq data (make-hash-table) pc 0 relative-base 0)
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
                  (set-value (get-data (+ pc 1)) mode0 (pop input))
                  (setq pc (+ pc 2)))
                (4
                  (return (arg0))
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
      (let*
        ((start-x (loop for x from 0 do (if (= (run-tractor (list x 99)) 1) (return x))))
          (end-x (loop for x from start-x do (if (= (run-tractor (list x 99)) 0) (return (1- x))))))
        (setf (aref spans 0) (cons start-x end-x))
        (print (loop for y from 100 do (let*
          ((index (mod y 99))
            (top (aref spans index))
            (start-top (car top))
            (end-top (cdr top))
            (previous (aref spans (mod (+ y 98) 99)))
            (start-x (loop for x from (car previous) do (if (= (run-tractor (list x y)) 1) (return x))))
            (end-x (loop for x from (cdr previous) do (if (= (run-tractor (list x y)) 0) (return (1- x))))))
          (if (<= (+ start-x 99) end-top) (return (+ (* start-x 10000) (- y 99))))
          (setf (aref spans index) (cons start-x end-x))))))))
