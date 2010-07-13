;;;  -*- Package: thrift-generated -*-
;;;
;;; Autogenerated by Thrift
;;; DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING

(def-package :thrift-generated)

(thrift:def-enum "Numberz"
  (("ONE" . 1)
   ("TWO" . 2)
   ("THREE" . 3)
   ("FIVE" . 5)
   ("SIX" . 6)
   ("EIGHT" . 8)))

(thrift:def-struct "bonk"
  (("message" nil :type string :id 1)
   ("type" nil :type i32 :id 2)))

(thrift:def-struct "bools"
  (("im_true" nil :type bool :id 1)
   ("im_false" nil :type bool :id 2)))

(thrift:def-struct "xtruct"
  (("string_thing" nil :type string :id 1)
   ("byte_thing" nil :type byte :id 4)
   ("i32_thing" nil :type i32 :id 9)
   ("i64_thing" nil :type i64 :id 11)))

(thrift:def-struct "xtruct2"
  (("byte_thing" nil :type byte :id 1)
   ("struct_thing" nil :type (struct "xtruct") :id 2)
   ("i32_thing" nil :type i32 :id 3)))

(thrift:def-struct "xtruct3"
  (("string_thing" nil :type string :id 1)
   ("changed" nil :type i32 :id 4)
   ("i32_thing" nil :type i32 :id 9)
   ("i64_thing" nil :type i64 :id 11)))

(thrift:def-struct "insanity"
  (("userMap" nil :type (map (enum "Numberz") i64) :id 1)
   ("xtructs" nil :type (list (struct "xtruct")) :id 2)))

(thrift:def-struct "crazynesting"
  (("string_field" nil :type string :id 1)
   ("set_field" nil :type (set (struct "insanity")) :id 2)
   ("list_field" nil :type (list (map (set i32) (map i32 (set (list (map (struct "insanity") string)))))) :id 3)))

(thrift:def-exception "xception"
  (("errorCode" nil :type i32 :id 1)
   ("message" nil :type string :id 2)))

(thrift:def-exception "xception2"
  (("errorCode" nil :type i32 :id 1)
   ("struct_thing" nil :type (struct "xtruct") :id 2)))

(thrift:def-struct "emptystruct"
  ())

(thrift:def-struct "onefield"
  (("field" nil :type (struct "emptystruct") :id 1)))

(thrift:def-struct "versioningtestv1"
  (("begin_in_both" nil :type i32 :id 1)
   ("old_string" nil :type string :id 3)
   ("end_in_both" nil :type i32 :id 12)))

(thrift:def-struct "versioningtestv2"
  (("begin_in_both" nil :type i32 :id 1)
   ("newint" nil :type i32 :id 2)
   ("newbyte" nil :type byte :id 3)
   ("newshort" nil :type i16 :id 4)
   ("newlong" nil :type i64 :id 5)
   ("newdouble" nil :type double :id 6)
   ("newstruct" nil :type (struct "bonk") :id 7)
   ("newlist" nil :type (list i32) :id 8)
   ("newset" nil :type (set i32) :id 9)
   ("newmap" nil :type (map i32 i32) :id 10)
   ("newstring" nil :type string :id 11)
   ("end_in_both" nil :type i32 :id 12)))

(thrift:def-struct "listtypeversioningv1"
  (("myints" nil :type (list i32) :id 1)
   ("hello" nil :type string :id 2)))

(thrift:def-struct "listtypeversioningv2"
  (("strings" nil :type (list string) :id 1)
   ("hello" nil :type string :id 2)))

(thrift:def-service "ThriftTest" nil
  (:method "testVoid" (() void))
  (:method "testString" ((("thing" string 1)) string))
  (:method "testByte" ((("thing" byte 1)) byte))
  (:method "testI32" ((("thing" i32 1)) i32))
  (:method "testI64" ((("thing" i64 1)) i64))
  (:method "testDouble" ((("thing" double 1)) double))
  (:method "testStruct" ((("thing" (struct "xtruct") 1)) (struct "xtruct")))
  (:method "testNest" ((("thing" (struct "xtruct2") 1)) (struct "xtruct2")))
  (:method "testMap" ((("thing" (map i32 i32) 1)) (map i32 i32)))
  (:method "testSet" ((("thing" (set i32) 1)) (set i32)))
  (:method "testList" ((("thing" (list i32) 1)) (list i32)))
  (:method "testEnum" ((("thing" (enum "Numberz") 1)) (enum "Numberz")))
  (:method "testTypedef" ((("thing" i64 1)) i64))
  (:method "testMapMap" ((("hello" i32 1)) (map i32 (map i32 i32))))
  (:method "testInsanity" ((("argument" (struct "insanity") 1)) (map i64 (map (enum "Numberz") (struct "insanity")))))
  (:method "testMulti" ((("arg0" byte 1) ("arg1" i32 2) ("arg2" i64 3) ("arg3" (map i16 string) 4) ("arg4" (enum "Numberz") 5) ("arg5" i64 6)) (struct "xtruct")))
  (:method "testException" ((("arg" string 1)) void)
   :exceptions (("err1" nil :type (struct "xception") :id 1)))
  (:method "testMultiException" ((("arg0" string 1) ("arg1" string 2)) (struct "xtruct"))
   :exceptions (("err1" nil :type (struct "xception") :id 1)
   ("err2" nil :type (struct "xception2") :id 2)))
  (:method "testOneway" ((("secondsToSleep" i32 1)) void)
   :oneway t))
(thrift:def-service "SecondService" nil
  (:method "blahBlah" (() void)))