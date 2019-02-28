; this algorithm works, but it's not particularly fast
; which makes sense, given that this is just a brute-force search

(defun bitflip (val)
  (if (= val 1)
      0
      1))

(defun is-1 (val)
  (and (not (null val))
       (= val 1)))

(defmacro def-spotfun (name &body body)
  `(defun ,name (idx cards)
     $!(card (nth idx cards))
     ,@body))

(def-spotfun flip-card
  (when (>= idx 0)
    (when (not (null card))
      (setf card (bitflip card)))))

(def-spotfun remove-card
  (when (not (is-1 card))
    (error "Can't flip this position"))
  (setf card nil)
  (flip-card (1- idx) cards)
  (flip-card (1+ idx) cards)
  cards)

(defun unsolvable-p (list)
  $(island-1 nil)
  $(in-island nil)
  $#(island-fails ()
     (if in-island
         (if island-1
             (clearf island-1 in-island)
             t)
         nil))
  (dolist (x list)
        (if (null x)
            (when (island-fails)
              (return t))
            (markf in-island))
        (when (is-1 x)
          (markf island-1)))
  (island-fails))

(defun try-removes (removes cards)
  $(my-cards (copy-list cards))
  (dolist (remove removes)
    (remove-card remove my-cards)
    (when (unsolvable-p my-cards)
      (error "Cards are now unsolvable!")))
  my-cards)

(defun brute-force-solve (cards &optional pre)
  (iter (for i from 0 to (length cards))
        $(next-pre (append (copy-list pre) (list i)))
        (handler-case
            (try-removes next-pre cards)
          (simple-error () (next-iteration)))
        (if (= (length cards) (length next-pre))
            (return-from brute-force-solve next-pre)
            $(recret (brute-force-solve cards next-pre))
            (when (not (null recret))
              (return-from brute-force-solve recret))))
  nil)
