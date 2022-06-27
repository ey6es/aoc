(defun digit (number index) (mod (floor (/ number (expt 10 (- 5 index)))) 10))

(defun two-digits-same (number)
  (loop for i from 0 to 4 thereis
      (let ((value (digit number i)))
        (and
          (= value (digit number (1+ i)))
          (or (= i 0) (/= value (digit number (1- i))))
          (or (= i 4) (/= value (digit number (+ i 2))))))))

(defun digits-never-decrease (number)
  (loop for i from 0 to 4 never (< (digit number i) (digit number (1+ i)))))

(print (loop for i from 231832 to 767346 count (and (two-digits-same i) (digits-never-decrease i))))
