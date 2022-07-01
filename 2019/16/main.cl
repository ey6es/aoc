
(let*
  ((line (with-open-file (stream "input.txt") (read-line stream)))
    (base-data (map 'vector (lambda (char) (parse-integer (string char))) line))
    (offset (reduce (lambda (first second) (+ (* first 10) second)) (subseq base-data 0 7)))
    (base-data-length (length base-data))
    (data-length (- (* base-data-length 10000) offset))
    (data (make-array data-length))
    (sums (make-array data-length)))
  (loop for i from 0 below data-length do
    (setf (aref data i) (aref base-data (mod (+ i offset) base-data-length))))
  (setf (aref sums (1- data-length)) (aref data (1- data-length)))
  (loop for phase from 1 to 100 do
    (loop for i from (- data-length 2) downto 0 do
      (setf (aref sums i) (+ (aref sums (1+ i)) (aref data i)))
      (setf (aref data i) (mod (aref sums i) 10))))
  (print (subseq data 0 8)))
