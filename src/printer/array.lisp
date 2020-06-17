(cl:in-package #:incless)

(defmethod print-object-using-client ((client standard-client) (arr array) stream)
  (let* ((rank (array-rank arr))
         (last-dim (1- rank))
         (size (array-dimensions arr))
         (indx (make-list rank :initial-element 0)))
    (write-char #\# stream)
    (let ((*print-base* 10))
      (write-integer-digits rank stream))
    (write-char #\A stream)
    (dotimes (i rank) (write-char #\( stream))
    (block nil
      (labels ((bump (dim)
                 (when (< dim last-dim)
                   (write-char #\) stream))
                 (if (= (incf (nth dim indx) 1)
                        (nth dim size))
                     (cond ((= dim 0)
                            (write-char #\))
                            (return))
                           (t (setf (nth dim indx) 0)
                              (bump (1- dim))))
                     (write-char #\Space stream))
                 (when (< dim last-dim)
                   (write-char #\( stream))))
        (loop :for i :below (array-total-size arr)
              :for elem := (row-major-aref arr i)
              :do (write elem :stream stream)
                  (bump last-dim))))))
