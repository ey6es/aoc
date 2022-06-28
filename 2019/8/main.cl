

(let*
  ((layer-size (* 25 6))
  (data (with-open-file (stream "input.txt") (read-line stream)))
  (layers (loop for offset from 0 by layer-size below (length data) collect (subseq data offset (+ offset layer-size))))
  (combined (reduce (lambda (first-layer second-layer)
    (map 'string (lambda (first-char second-char) (if (equal first-char #\2) second-char first-char)) first-layer second-layer))
    layers)))
  (setq combined (map 'string (lambda (char) (if (equal char #\1) #\X #\Space)) combined))
  (loop for offset from 0 by 25 below (length combined) do (print (subseq combined offset (+ offset 25)))))
