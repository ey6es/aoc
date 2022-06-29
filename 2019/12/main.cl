(defun parse-vector (line)
  (let*
    ((first-start (1+ (position #\= line)))
      (first-end (position #\, line :start first-start))
      (second-start (1+ (position #\= line :start first-end)))
      (second-end (position #\, line :start second-start))
      (third-start (1+ (position #\= line :start second-end)))
      (third-end (position #\> line :start third-start)))
    (list
      (parse-integer (subseq line first-start first-end))
      (parse-integer (subseq line second-start second-end))
      (parse-integer (subseq line third-start third-end)))))

(let*
  ((positions (with-open-file (stream "input.txt")
    (loop for line = (read-line stream nil) until (null line) collect (parse-vector line))))
  (velocities (loop repeat (length positions) collect (list 0 0 0))))

  (let ((periods (loop for axis from 0 to 2 collect
    (let
      ((pcomps (map 'vector (lambda (pos) (nth axis pos)) positions))
        (vcomps (map 'vector (lambda (vel) (nth axis vel)) velocities))
        (states (make-hash-table :test #'equalp)))
      (loop for step from 0 do
        (let ((state (concatenate 'vector pcomps vcomps)))
          (if (gethash state states) (return step))
          (setf (gethash state states) t)
          (loop for i from 0 below (length pcomps) do
            (loop for j from 0 below (length pcomps) do
              (let ((delta (- (aref pcomps j) (aref pcomps i))))
                (cond ((> delta 0) (incf (aref vcomps i))) ((< delta 0) (decf (aref vcomps i)))))))
          (loop for i from 0 below (length pcomps) do (incf (aref pcomps i) (aref vcomps i)))))))))
    (print (apply #'lcm periods))))
