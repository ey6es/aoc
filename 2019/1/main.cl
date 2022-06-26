(defun compute-fuel (mass)
  (let ((base-fuel (- (floor (/ mass 3)) 2)))
    (if (<= base-fuel 0) 0 (+ base-fuel (compute-fuel base-fuel)))))

(print (with-open-file (stream "input.txt")
  (loop for line = (read-line stream nil)
    until (null line)
    sum (compute-fuel (parse-integer line)))))
