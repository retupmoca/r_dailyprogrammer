(defun num-digits (num)
  (do ((digit)
       (digits '() (cons digit digits)))
      ((= num 0) digits)
    (multiple-value-setq (num digit) (floor num 10))))

(defun sum-digits (num)
  (apply #'+ (num-digits num)))

(defun additive-persistence (num)
  (do ((count 0 (+ 1 count)))
      ((< num 10) count)
    (setq num (sum-digits num))))
