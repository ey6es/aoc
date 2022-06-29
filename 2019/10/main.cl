(let*
  ((lines (with-open-file (stream "input.txt") (loop for line = (read-line stream nil) until (null line) collect line)))
    (width (length (first lines)))
    (height (length lines))
    (data (make-array (list height width)))
    (max-total 0) max-row max-col)
  (loop for line in lines for row from 0 do
    (loop for char across line for col from 0 do
      (setf (aref data row col) char)))
  (loop for src-row from 0 below height do
    (loop for src-col from 0 below width do
      (let ((total (if (equal (aref data src-row src-col) #\.) 0
        (loop for dest-row from 0 below height sum
          (loop for dest-col from 0 below width sum
            (if (or (and (= src-row dest-row) (= src-col dest-col)) (equal (aref data dest-row dest-col) #\.)) 0
              (let*
                ((row-delta (- dest-row src-row))
                  (col-delta (- dest-col src-col))
                  (delta-gcd (gcd row-delta col-delta))
                  (row-inc (/ row-delta delta-gcd))
                  (col-inc (/ col-delta delta-gcd))
                  (row src-row)
                  (col src-col))
                (loop
                  (setq row (+ row row-inc) col (+ col col-inc))
                  (if (and (= row dest-row) (= col dest-col)) (return 1))
                  (if (equal (aref data row col) #\#) (return 0))))))))))
        (if (> total max-total) (setq max-total total max-row src-row max-col src-col)))))
  (loop for i from 1 to 200 with current-angle = -0.000001 do
    (let (greater-angle greater-dist greater-row greater-col smallest-angle smallest-dist smallest-row smallest-col)
      (loop for row from 0 below height do
        (loop for col from 0 below width do
          (if (and (or (/= row max-row) (/= col max-col)) (equal (aref data row col) #\#))
            (let*
              ((row-delta (- row max-row))
                (col-delta (- col max-col))
                (angle (atan col-delta (- row-delta)))
                (dist (+ (* row-delta row-delta) (* col-delta col-delta))))
              (if (and (> angle current-angle)
                (or (null greater-angle) (< angle greater-angle) (and (= angle greater-angle) (< dist greater-dist))))
                (setq greater-angle angle greater-dist dist greater-row row greater-col col))
              (if (or (null smallest-angle) (< angle smallest-angle) (and (= angle smallest-angle) (< dist smallest-dist)))
                (setq smallest-angle angle smallest-dist dist smallest-row row smallest-col col))))))
      (let (target-row target-col)
        (if (null greater-angle)
          (setq current-angle smallest-angle target-row smallest-row target-col smallest-col)
          (setq current-angle greater-angle target-row greater-row target-col greater-col))
        (setf (aref data target-row target-col) #\.)
        (if (= i 200) (print (+ (* target-col 100) target-row)))))))
