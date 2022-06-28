(require "asdf")

(let*
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    (original-data (apply #'vector (mapcar #'parse-integer elements))))

  (defstruct amp (data (copy-seq original-data)) (pc 0) input output halted)

  (labels
    ((run-amp (amp) (let ((data (amp-data amp)))
      (flet ((get-value (arg mode) (if (= mode 0) (aref data arg) arg)))
        (loop
          (let*
              ((pc (amp-pc amp))
                (command (aref data pc))
                (opcode (mod command 100))
                (mode0 (mod (floor command 100) 10))
                (mode1 (mod (floor command 1000) 10))
                (arg0 (aref data (1+ pc))))
              (case opcode
                (1
                  (setf (aref data (aref data (+ pc 3))) (+ (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)))
                  (setf (amp-pc amp) (+ pc 4)))
                (2
                  (setf (aref data (aref data (+ pc 3))) (* (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)))
                  (setf (amp-pc amp) (+ pc 4)))
                (3
                  (if (null (amp-input amp)) (return t))
                  (setf (aref data arg0) (pop (amp-input amp)))
                  (setf (amp-pc amp) (+ pc 2)))
                (4
                  (setf (amp-output amp) (get-value arg0 mode0))
                  (setf (amp-pc amp) (+ pc 2)))
                (5
                  (setf (amp-pc amp) (if (/= (get-value arg0 mode0) 0) (get-value (aref data (+ pc 2)) mode1) (+ pc 3))))
                (6
                  (setf (amp-pc amp) (if (= (get-value arg0 mode0) 0) (get-value (aref data (+ pc 2)) mode1) (+ pc 3))))
                (7
                  (setf (aref data (aref data (+ pc 3)))
                    (if (< (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)) 1 0))
                  (setf (amp-pc amp) (+ pc 4)))
                (8
                  (setf (aref data (aref data (+ pc 3)))
                    (if (= (get-value arg0 mode0) (get-value (aref data (+ pc 2)) mode1)) 1 0))
                  (setf (amp-pc amp) (+ pc 4)))
                (99
                  (setf (amp-halted amp) t)
                  (return))))))))
      (execute-programs (phases) (let ((amps (mapcar (lambda (phase) (make-amp :input (list phase))) phases)))
        (loop for amp in amps do (run-amp amp))
        (let ((last-output 0)) (loop named outer do
          (loop for amp in amps do
            (if (amp-halted amp) (return-from outer))
            (setf (amp-input amp) (list last-output))
            (run-amp amp)
            (setq last-output (amp-output amp)))))
        (amp-output (first (last amps)))))
      (get-max-output (phases remaining)
        (if (null remaining)
          (execute-programs phases)
          (let ((max-output 0))
            (loop for phase in remaining do
              (setq max-output (max max-output (get-max-output (append phases (list phase)) (remove phase remaining)))))
            max-output))))
    (print (get-max-output nil '(5 6 7 8 9)))))
