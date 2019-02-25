(defun count-chars (string)
  (let ((plist nil))
    (loop
       for c across string
       do (incf (getf plist c 0)))
    plist))

(defun balanced (string)
  (let ((plist (count-chars string)))
    (= (getf plist #\x)
       (getf plist #\y))))

(defun balanced-bonus (string)
  (if (zerop (length string))
      t
      (let ((plist (count-chars string)))
        (apply #'= (loop
                      for (char count) on plist by (function cddr)
                      collect count)))))
