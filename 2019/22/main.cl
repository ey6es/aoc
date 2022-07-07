(defun fract (value) (- value (floor value)))

; https://www.geeksforgeeks.org/modular-division/
(defun gcd-extended (a b)
  (if (zerop a) (list b 0 1)
    (let*
      ((gcd (gcd-extended (mod b a) a)))
      (list (first gcd) (- (third gcd) (* (floor b a) (second gcd))) (second gcd)))))

(let
  ((length 119315717514047)
    (reps 101741582076661)
    (index 2020)
    (lines (with-open-file (stream "input.txt") (loop for line = (read-line stream nil) until (null line) collect line)))
    (scale 1) (offset 0) (rep-scale 1) (rep-offset 0))
  (loop for line in lines do (let
    ((cut-index (search "cut " line))
      (increment-index (search "increment " line))
      a b)
    (cond
      ((numberp cut-index) (setq a 1 b (- (parse-integer (subseq line (+ cut-index 4))))))
      ((numberp increment-index) (setq a (parse-integer (subseq line (+ increment-index 10))) b 0))
      (t (setq a -1 b -1)))
    (setq offset (mod (+ (* offset a) b) length) scale (mod (* scale a) length))))
  (loop while (> reps 0) do
    (loop with sub-reps = 1 with a = scale with b = offset do (let
      ((next-sub-reps (* sub-reps 2)))
      (if (> next-sub-reps reps) (progn
        (setq rep-offset (mod (+ (* rep-offset a) b) length) rep-scale (mod (* rep-scale a) length) reps (- reps sub-reps))
        (return)))
      (setq b (mod (+ (* b a) b) length) a (mod (* a a) length) sub-reps next-sub-reps))))
  (let*
    ((m (mod (- index rep-offset) length))
      (gcd (gcd-extended rep-scale length))
      (inverse (second gcd))
      (result (mod (* inverse m) length)))
    (print result)
    (print (mod (+ (* result rep-scale) rep-offset) length))))
