(defun num-digits (num)
  (do ((digit)
       (digits '() (cons digit digits)))
      ((= num 0) digits)
    (multiple-value-setq (num digit) (floor num 10))))

(defun add-one-and-string (digit)
  (write-to-string (+ 1 digit)))

(defun add-to-digits (num)
  (apply #'concatenate
         (cons 'string (mapcar #'add-one-and-string
                               (num-digits num)))))
