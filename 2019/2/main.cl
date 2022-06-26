(require "asdf")

(let*
  ((elements (uiop:split-string (with-open-file (stream "input.txt") (read-line stream)) :separator ","))
    (data-original (apply #'vector (mapcar #'parse-integer elements))))

  (loop for noun from 0 to 100 do
    (loop for verb from 0 to 100 do
      (let ((data (copy-seq data-original)))
        (setf (aref data 1) noun)
        (setf (aref data 2) verb)

        (loop for i from 0 by 4 do
          (let*
            ((opcode (aref data i))
              (fn (case opcode (1 #'+) (2 #'*) (99 (return))))
              (first (aref data (+ i 1)))
              (second (aref data (+ i 2)))
              (dest (aref data (+ i 3))))

              (setf (aref data dest) (funcall fn (aref data first) (aref data second)))
            ))

          (if (= (aref data 0) 19690720) (print (+ (* 100 noun) verb)))))))
