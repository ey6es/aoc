(require "asdf")

(defstruct queue head tail)

(defun queue-push (item queue) (let ((old-tail (queue-tail queue)) (new-tail (cons item nil)))
  (if (null old-tail)
    (setf (queue-head queue) new-tail)
    (setf (cdr old-tail) new-tail))
  (setf (queue-tail queue) new-tail)))

(defun queue-pop (queue) (let ((item (pop (queue-head queue))))
  (if (null (queue-head queue)) (setf (queue-tail queue) nil))
  item))

(defun queue-empty (queue) (null (queue-head queue)))

(defstruct computer (input (make-queue)) run)

(let
  ((elements (mapcar #'parse-integer (uiop:split-string
    (with-open-file (stream "input.txt") (read-line stream)) :separator ",")))
    (computers (make-array 50))
    nat-x nat-y (nat-y-values (make-hash-table)))

  (flet
    ((create-computer (address) (let*
      ((computer (make-computer))
        (input (computer-input computer))
        (data (make-hash-table))
        (pc 0)
        (relative-base 0)
        output
        (empty-inputs 0))
      (labels
        ((get-data (address) (gethash address data 0))
          (set-data (address value) (setf (gethash address data) value))
          (get-value (arg mode) (case mode (0 (get-data arg)) (1 arg) (2 (get-data (+ arg relative-base)))))
          (set-value (arg mode value) (set-data (case mode (0 arg) (2 (+ arg relative-base))) value))
          (run ()
            (let*
                ((command (get-data pc))
                  (opcode (mod command 100))
                  (mode0 (mod (floor command 100) 10))
                  (mode1 (mod (floor command 1000) 10))
                  (mode2 (mod (floor command 10000) 10)))
                (flet
                  ((arg0 () (get-value (get-data (+ pc 1)) mode0))
                    (arg1 () (get-value (get-data (+ pc 2)) mode1))
                    (arg2 () (get-value (get-data (+ pc 3)) mode2)))
                  (case opcode
                    (1
                      (set-value (get-data (+ pc 3)) mode2 (+ (arg0) (arg1)))
                      (setq pc (+ pc 4)))
                    (2
                      (set-value (get-data (+ pc 3)) mode2 (* (arg0) (arg1)))
                      (setq pc (+ pc 4)))
                    (3
                      (let ((next-input (queue-pop input)))
                        (set-value (get-data (+ pc 1)) mode0
                          (if (null next-input) (progn (incf empty-inputs) -1) (progn (setq empty-inputs 0) next-input))))
                      (setq pc (+ pc 2)))
                    (4
                      (setq empty-inputs 0)
                      (push (arg0) output)
                      (if (= (length output) 3) (let ((y (pop output)) (x (pop output)) (target (pop output)))
                        (if (= target 255)
                          (setq nat-x x nat-y y)
                          (let ((target-input (computer-input (aref computers target))))
                            (queue-push x target-input)
                            (queue-push y target-input)))))
                      (setq pc (+ pc 2)))
                    (5
                      (setq pc (if (/= (arg0) 0) (arg1) (+ pc 3))))
                    (6
                      (setq pc (if (= (arg0) 0) (arg1) (+ pc 3))))
                    (7
                      (set-value (get-data (+ pc 3)) mode2 (if (< (arg0) (arg1)) 1 0))
                      (setq pc (+ pc 4)))
                    (8
                      (set-value (get-data (+ pc 3)) mode2 (if (= (arg0) (arg1)) 1 0))
                      (setq pc (+ pc 4)))
                    (9
                      (setq relative-base (+ relative-base (arg0)))
                      (setq pc (+ pc 2))))))
            (and (queue-empty input) (> empty-inputs 0))))
      (loop for value in elements for address from 0 do (set-data address value))
      (queue-push address input)
      (setf (computer-run computer) #'run)
      (setf (aref computers address) computer)
      computer))))
  (loop for address from 0 to 49 do (create-computer address))
  (loop do (let ((all-idle t))
    (loop for computer across computers do
      (setq all-idle (and (funcall (computer-run computer)) all-idle)))
    (if (and all-idle (numberp nat-x) (numberp nat-y)) (let ((target-input (computer-input (aref computers 0))))
      (if (gethash nat-y nat-y-values) (progn
        (print nat-y)
        (quit)))
      (setf (gethash nat-y nat-y-values) t)
      (queue-push nat-x target-input)
      (queue-push nat-y target-input)))))))
