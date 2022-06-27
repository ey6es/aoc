(require "asdf")

(let*
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    (data (apply #'vector (mapcar #'parse-integer elements))))

  (flet
    ((get-value (arg mode) (if (= mode 0) (aref data arg) arg)))

    (let ((pc 0)) (loop
      (let*
          ((command (aref data pc))
            (opcode (mod command 100))
            (mode0 (mod (floor command 100) 10))
            (mode1 (mod (floor command 1000) 10))
            (arg0 (aref data (1+ pc))))
          (case opcode
            (1
              (setf (aref data (aref data (+ pc 3))) (+ (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)))
              (setq pc (+ pc 4)))
            (2
              (setf (aref data (aref data (+ pc 3))) (* (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)))
              (setq pc (+ pc 4)))
            (3
              (setf (aref data arg0) 5)
              (setq pc (+ pc 2)))
            (4
              (print (get-value arg0 mode0))
              (setq pc (+ pc 2)))
            (5
              (setq pc (if (/= (get-value arg0 mode0) 0) (get-value (aref data (+ pc 2)) mode1) (+ pc 3))))
            (6
              (setq pc (if (= (get-value arg0 mode0) 0) (get-value (aref data (+ pc 2)) mode1) (+ pc 3))))
            (7
              (setf (aref data (aref data (+ pc 3))) (if (< (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)) 1 0))
              (setq pc (+ pc 4)))
            (8
              (setf (aref data (aref data (+ pc 3))) (if (= (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)) 1 0))
              (setq pc (+ pc 4)))
            (99 (return))))))))
