(require "asdf")

(let ((orbits (make-hash-table :test #'equal)) (distances (make-hash-table :test #'equal)))
  (with-open-file (stream "input.txt")
    (loop for line = (read-line stream nil) until (null line) do
      (let ((elements (uiop:split-string line :separator ")")))
        (push (second elements) (gethash (first elements) orbits))
        (push (first elements) (gethash (second elements) orbits)))))

  (loop for node being the hash-key of orbits do (setf (gethash node distances) 9999999))
  (setf (gethash "YOU" distances) 0)
  (loop named outer do (let (min-node (min-distance 9999999))
    (loop for node being the hash-key using (hash-value distance) of distances do
      (if (< distance min-distance) (setq min-node node min-distance distance)))
    (cond ((equal min-node "SAN") (print (- min-distance 2)) (return-from outer)))
    (remhash min-node distances)
    (loop for neighbor in (gethash min-node orbits) do
      (let ((current-distance (gethash neighbor distances)) (new-distance (1+ min-distance)))
        (if (and current-distance (< new-distance current-distance)) (setf (gethash neighbor distances) new-distance)))))))
