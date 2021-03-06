;;;  -*- Package: testnamespace -*-
;;;
;;; Autogenerated by Thrift
;;; DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING

(def-package :testnamespace)


(defun test-i32 (boo) (incf boo))

(defun test-void ()
  (error 'goodbye
         :simple -1
         :complex (map '(1 . 1))
         :complexer (map (cons 0 (map (cons 1 2))))))

(defun test-me (hello wonk)
  (incf (hello-simple wonk) hello)
  wonk)

(defun test-thinger (bootz)
  (concatenate 'string bootz "." bootz))

;;; (test-server)

(thrift-test:test gen-cl/small-test
  (thrift-test:with-test-services (protocol small-service)
    (and (equal (thrift-generated-request:test-thinger protocol "12345")
                "12345.12345")
         (let ((s (thrift-generated-request:test-me
                   protocol 1 (make-instance 'hello :simple 0
                                             :complexer (map (cons 0 (map (cons 1 2))))))))
           (and (typep s 'hello)
                (eql (hello-simple s) 1)))
         (typep (nth-value 1 (ignore-errors (thrift-generated-request:test-void protocol)))
                'goodbye)
         (eql (thrift-generated-request:test-i32 protocol 1) 2)))