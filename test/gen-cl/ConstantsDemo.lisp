;;;  -*- Package: thrift-generated -*-
;;;
;;; Autogenerated by Thrift
;;; DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING

(def-package :thrift-generated)

(thrift:def-enum "enumconstants"
  (("ONE" . 1)
   ("TWO" . 2)))

(thrift:def-struct "thing"
  (("hello" nil :type i32 :id 1)
   ("goodbye" nil :type i32 :id 2)))

(thrift:def-struct "thing2"
  (("val"   2 :type (enum "enumconstants") :id 1)))

(thrift:def-exception "blah"
  (("bing" nil :type i32 :id 1)))

(thrift:def-exception "gak"
  ())

(thrift:def-service "yowza" nil
  (:method "blingity" (() void))
  (:method "blangity" (() i32)
   :exceptions (("hoot" nil :type (struct "blah") :id 1))))
