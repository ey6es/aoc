(require "asdf")

(defun parse-component (string) (let
  ((parts (uiop:split-string (string-trim " " string) :separator " ")))
  (cons (second parts) (parse-integer (first parts)))))

(let ((rules (make-hash-table :test #'equal)))
  (with-open-file (stream "input.txt")
    (loop for line = (read-line stream nil) until (null line) do
      (let*
        ((sep-index (search " => " line))
          (product (parse-component (subseq line (+ sep-index 4))))
          (components (mapcar #'parse-component (uiop:split-string (subseq line 0 sep-index) :separator ","))))
        (setf (gethash (car product) rules) (cons (cdr product) components)))))
  (flet
    ((fuel-minimum-ore (amount) (let ((extra (make-hash-table :test #'equal)))
      (labels
        ((minimum-ore (name amount) (if (or (= amount 0) (equal name "ORE")) amount
          (let*
            ((rule (gethash name rules))
              (factor (ceiling amount (first rule))))
            (incf (gethash name extra 0) (- (* factor (first rule)) amount))
            (loop for component in (rest rule) sum
              (let*
                ((base (* factor (cdr component)))
                  (from-extra (min base (gethash (car component) extra 0))))
                (decf (gethash (car component) extra 0) from-extra)
                (minimum-ore (car component) (- base from-extra))))))))
        (minimum-ore "FUEL" amount)))))
    (print (let ((lower-bound 0) (upper-bound 1000000000000)) (loop
      (if (= (- upper-bound lower-bound) 1) (return lower-bound))
      (let*
        ((test-amount (floor (+ lower-bound upper-bound) 2))
          (minimum (fuel-minimum-ore test-amount)))
        (if (< minimum 1000000000000) (setq lower-bound test-amount) (setq upper-bound test-amount))))))))
