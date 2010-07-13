;;;  -*- Package: thrift-generated -*-
;;;
;;; Autogenerated by Thrift
;;; DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING

(def-package :thrift-generated)

(thrift:def-struct "oneofeachbeans"
  (("boolean_field" nil :type bool :id 1)
   ("a_bite" nil :type byte :id 2)
   ("integer16" nil :type i16 :id 3)
   ("integer32" nil :type i32 :id 4)
   ("integer64" nil :type i64 :id 5)
   ("double_precision" nil :type double :id 6)
   ("some_characters" nil :type string :id 7)
   ("base64" nil :type string :id 8)
   ("byte_list" nil :type (list byte) :id 9)
   ("i16_list" nil :type (list i16) :id 10)
   ("i64_list" nil :type (list i64) :id 11)))

(thrift:def-service "Service" nil
  (:method "mymethod" ((("blah" i64 -1)) i64)))