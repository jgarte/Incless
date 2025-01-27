(in-package #:incless)

(defclass client () ())
(defclass standard-client (client) ())

(defvar *client* nil)
(defvar *default-client* (make-instance 'standard-client))
(defvar *current-depth* 0)

(defgeneric write-object (client object stream))

(defgeneric print-object-using-client (client object stream))

(defgeneric print-object (object stream)
  (:method ((object t) stream)
    (let* ((*client* (or *client* *default-client*))
           (overrides (parameter-override-list *client*))
           (symbols nil)
           (values nil))
      (loop for x in overrides
            do (loop for (sym . val) in x
                     if (not (find sym symbols))
                       do (push sym symbols)
                          (push val values)))
      (progv symbols values
         (print-object-using-client *client* object stream)))
    object))

(defun write
    (object
     &key
       (stream *standard-output*)
       ((:array *print-array*) *print-array*)
       ((:base *print-base*) *print-base*)
       ((:case *print-case*) *print-case*)
       ((:circle *print-circle*) *print-circle*)
       ((:escape *print-escape*) *print-escape*)
       ((:gensym *print-gensym*) *print-gensym*)
       ((:length *print-length*) *print-length*)
       ((:level *print-level*) *print-level*)
       ((:lines *print-lines*) *print-lines*)
       ((:miser-width *print-miser-width*) *print-miser-width*)
       ((:pprint-dispatch *print-pprint-dispatch*) *print-pprint-dispatch*)
       ((:pretty *print-pretty*) *print-pretty*)
       ((:radix *print-radix*) *print-radix*)
       ((:readably *print-readably*) *print-readably*)
       ((:right-margin *print-right-margin*) *print-right-margin*))
  (write-object (or *client* *default-client*) object stream)
  object)

(defun write-to-string
    (object
     &key
       ((:array *print-array*) *print-array*)
       ((:base *print-base*) *print-base*)
       ((:case *print-case*) *print-case*)
       ((:circle *print-circle*) *print-circle*)
       ((:escape *print-escape*) *print-escape*)
       ((:gensym *print-gensym*) *print-gensym*)
       ((:length *print-length*) *print-length*)
       ((:level *print-level*) *print-level*)
       ((:lines *print-lines*) *print-lines*)
       ((:miser-width *print-miser-width*) *print-miser-width*)
       ((:pprint-dispatch *print-pprint-dispatch*) *print-pprint-dispatch*)
       ((:pretty *print-pretty*) *print-pretty*)
       ((:radix *print-radix*) *print-radix*)
       ((:readably *print-readably*) *print-readably*)
       ((:right-margin *print-right-margin*) *print-right-margin*))
  (with-output-to-string (stream)
    (write-object (or *client* *default-client*) object stream))
  object)

(defun prin1 (object &optional (stream *standard-output*))
  (let ((*print-escape* t))
    (write-object (or *client* *default-client*) object stream))
  object)

(defun princ (object &optional (stream *standard-output*))
  (let ((*print-escape* nil)
        (*print-readably* nil))
    (write-object (or *client* *default-client*) object stream))
  object)

(defun print (object &optional (stream *standard-output*))
  (write-char #\Newline stream)
  (prin1 object stream)
  (write-char #\Space stream)
  object)

(defun pprint (object &optional (stream *standard-output*))
  (write-char #\Newline stream)
  (let ((*print-pretty* t))
    (prin1 object stream))
  (values))

(defun prin1-to-string (object)
  (with-output-to-string (stream)
    (prin1 object stream)))

(defun princ-to-string (object)
  (with-output-to-string (stream)
    (princ object stream)))
