;;; -*- Mode: lisp; Syntax: ansi-common-lisp; Base: 10; Package: thrift-test; -*-

(in-package :thrift-test)

;;; (run-tests "setup/.*")
;;; (run-tests)

(defparameter *test-root-pathname*
  (make-pathname :name nil :type nil :defaults (or *compile-file-pathname* *load-pathname*)))

(defvar *tests* (make-hash-table))

(defvar *test-location* #u"thrift://127.0.0.1:9091")

(defvar *test-service* (make-instance 'service :name "Test Root"))

(defvar *test-server-process* nil)


(defun find-test (name) (gethash name *tests*))

(defun (setf find-test) (test-function name)
  (if (null test-function)
    (remhash name *tests*)
    (setf (gethash name *tests*) test-function)))

(defgeneric run-test (test)
  (:method ((name symbol))
    (let ((test-function (find-test name)))
      (if test-function
        (run-test test-function)
        (warn "test not found: ~s." name))))
  (:method ((test-function function))
    ))

(defun run-tests (&rest test-names)
  (let ((succeeded 0)
        (failed ())
        (errored ()))
    (flet ((run-test (test-function)
             (multiple-value-bind (result condition name form)
                                  (funcall test-function)
               (cond (result
                      (incf succeeded))
                     (condition
                      (format *trace-output* "~%test (~a) signaled:~%~:w~%~a" name form condition)
                      (push name errored))
                     (t
                      (format *trace-output* "~%test (~a) failed:~%~:w" name form)
                      (push name failed))))))
      (if test-names
        (dolist (pattern test-names)
          (etypecase pattern
            (symbol
             (run-test (or (find-test pattern) (error "test not found: ~s." pattern))))
            (string
             (let ((scanner (ppcre:create-scanner (string-upcase pattern))))
               (flet ((run-if-matched (name function)
                        (let* ((namestring (string name))
                               (matched-string (cl-ppcre:scan-to-strings scanner namestring)))
                          (when (string-equal namestring matched-string)
                            (run-test function)))))
                 (maphash #'run-if-matched *tests*))))))
        (loop for test being each hash-value of *tests* do (run-test test))))
    `(,(or test-names ".*")
      :succeeded ,(+ succeeded (length failed) (length errored))
      ,@(when failed `(:failed (,(length failed) ,@failed)))
      ,@(when errored `(:errored (,(length errored) ,@errored))))))

(defmacro test (name form)
  `(progn (setf (find-test ',name)
                #'(lambda (&aux (name ',name) (form ',form))
                    (multiple-value-bind (result error)
                                         (ignore-errors ,form)
                      (cond (error
                             (values nil error name form))
                            (result
                             (values result nil name form))
                            (t
                             (values nil nil name form))))))
          ',name))

#+digitool
(setf (ccl:assq 'test ccl:*fred-special-indent-alist*) 1)



;;;
;;;

(defclass test-struct ()
  ((field1 :type string :initarg :field1 :accessor test-struct-field1
           :identifier-number 1 :identifier "fieldOne")
   (field2 :type i16 :initarg :field2 :accessor test-struct-field2
           :identifier-number 2 :identifier "fieldTwo"))
  (:metaclass thrift-class)
  (:identifier "TestStruct"))



(defun make-test-transport (&rest initargs)
  (apply #'make-instance 'vector-stream-transport initargs))

(defun make-test-protocol (&rest initargs &key
                                 (direction :io)
                                 (input-transport (make-test-transport))
                                 (output-transport input-transport))
  (apply #'make-instance 'binary-protocol
         :direction direction 
         :input-transport input-transport
         :output-transport output-transport
         initargs))

(defun make-test-protocol-peers (&key (request-hook 'rewind) (response-hook 'rewind))
  (let ((request-transport (make-test-transport :force-output-hook request-hook))
        (response-transport (make-test-transport :force-output-hook response-hook)))
    (values (make-test-protocol :output-transport request-transport
                                :input-transport response-transport)
            (make-test-protocol :output-transport response-transport
                                :input-transport request-transport))))

(defgeneric rewind (stream)
  (:method ((protocol protocol))
    (rewind (protocol-input-transport protocol))
    (rewind (protocol-output-transport protocol))
    protocol)
  
  (:method ((stream vector-stream))
    (stream-position stream 0)
    stream))

(defgeneric reset (stream)
  (:method ((protocol protocol))
    (rewind protocol)
    (reset (protocol-output-transport protocol))
    protocol)

  (:method ((stream vector-stream))
    (fill (get-vector-stream-vector stream) 0)
    stream))


(defun test-server (&optional (location *test-location*))
  (setq *test-location* location)
  (or *test-server-process*
      (setq *test-server-process* (bt:make-thread #'(lambda () (serve location *test-service*))))))

(defun stop-test-server ()
  (when (typep *test-server-process* 'bt:thread)
    (bt:destroy-thread *test-server-process*)
    (setq *test-server-process* nil)))
;;; (stop-test-server)

(defun call-with-test-services (function &rest services)
  (declare (dynamic-extent function))
  (unwind-protect (progn (setf (thrift::service-base-services *test-service*)
                               (union (thrift::service-base-services *test-service*)
                                      services))
                         (funcall function))
    (setf (thrift::service-base-services *test-service*)
          (set-difference (thrift::service-base-services *test-service*)
                          services))))

(defmacro with-test-services ((protocol &rest services) &body body)
  (let ((op (gensym)))
    `(flet ((,op () (with-client (,protocol *test-location*) ,@body)))
       ;; (test-server) doesn't work as the connect beats the accept and the client hangs
       (call-with-test-services #',op ,@services))))

  

;;;

(test setup/thrift-class
      (let ((class (find-class 'test-struct)))
        (and (equal (thrift::class-identifier class) "TestStruct")
             (every #'(lambda (id name)
                        (equal (thrift::field-definition-identifier
                                (find id (thrift::class-field-definitions class)
                                      :key #'thrift::field-definition-identifier-number))
                               name))
                    '(1 2)
                    '("fieldOne" "fieldTwo")))))

(test setup/test-transport
      (typep (make-test-transport) 'binary-transport))

(test setup/test-protocol
      (typep (make-test-protocol) 'binary-protocol))

