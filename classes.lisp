;;; -*- Mode: lisp; Syntax: ansi-common-lisp; Base: 10; Package: org.apache.thrift.implementation; -*-

(in-package :org.apache.thrift.implementation)

;;; This file defines the abstract and metaclass definitions for the `org.apache.thrift` library.
;;;
;;; copyright 2010 [james anderson](james.anderson@setf.de)
;;;
;;; Licensed to the Apache Software Foundation (ASF) under one
;;; or more contributor license agreements. See the NOTICE file
;;; distributed with this work for additional information
;;; regarding copyright ownership. The ASF licenses this file
;;; to you under the Apache License, Version 2.0 (the
;;; "License"); you may not use this file except in compliance
;;; with the License. You may obtain a copy of the License at
;;; 
;;;   http://www.apache.org/licenses/LICENSE-2.0
;;; 
;;; Unless required by applicable law or agreed to in writing,
;;; software distributed under the License is distributed on an
;;; "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
;;; KIND, either express or implied. See the License for the
;;; specific language governing permissions and limitations
;;; under the License.


;;; The thrift-class metaclass manages struct field definitions, which are used to generate
;;; structure encoding/decoding aspects of request and response operators. The classes
;;; are associated with an external identifier in a mechanism which parallels find-class,
;;; and each field slot definition includes its name and number identifiers.
;;;
;;; The abstract metaclass is specialized as thrift-struct-class and thrift-exception-class
;;; to allow for different instantiation protocols for standard  objects and conditions.


(defclass thrift-class (standard-class)
  ((identifier
    :reader class-identifier
    :type string
    :documentation "The external name used to encode/decode an instance as a struct."))
  (:documentation "The thrift-class metaclass records its external identifier and
 uses extended slot definitions to record thrift field definitions. It is specialized as
 thrift-struct-class and thrift-exception-class.

 The initialization protocol includes a step to bind/rebind class identifiers in the global
 *thrift-classes* for use with the find-thrift-class operator."))

(defclass thrift-struct-class (thrift-class)
  ()
  (:documentation "Each struct declaration creates a thrift-struct-class, which is used directly
 to instantiate structs."))

(defclass thrift-exception-class (thrift-class)
  ((condition-class
    :initarg :condition-class :initform (error "A condition-class is required.")
    :reader class-condition-class
    :documentation "The respective standard condition class of which to make condition,"))
  (:documentation "Each exception declaration yields a thrift-exception-class definition _and_
 a standard exception class. The former sesrves to model the extended slot descrition, and the
 latter to make conditions."))



(defclass thrift-object ()
  ()
  (:documentation "The abstract root class of all struct instances."))


(defclass field-definition ()
  ((identifier
    :initarg :identifier
    :reader field-definition-identifier)
   (identifier-number
    :initarg :identifier-number
    :reader field-definition-identifier-number)))
   

(defclass direct-field-definition (field-definition c2mop:standard-direct-slot-definition)
  ((identifier-number  :initform (error "identifier-number is required."))
   (identifier  :initform (error "identifier is required."))))


(defclass effective-field-definition (field-definition c2mop:standard-effective-slot-definition)
  ((reader
    :reader field-definition-reader)))


;;; the specialized generic function classes
;;; now serve just to document the relation between the external identifier and the function
;;; all information is compiled statically into the request/response function definitions.

(defclass thrift-generic-function (standard-generic-function)
  ((identifier
    :initarg :identifier
    :reader generic-function-identifier))
  (:metaclass c2mop:funcallable-standard-class)
  (:documentation "The abstract mixin for thrift interface operators which binds the external name."))


(defclass thrift-request-function (thrift-generic-function)
  ()
  (:metaclass c2mop:funcallable-standard-class)
  (:documentation "The class of thrift request operators. Each acts as a proxy for an external
 operator, encodes and manages the request/response exchange and returns the result value or signals
 an exception - as per the response message."))


(defclass thrift-response-function (thrift-generic-function)
  ((implementation-function
    :initarg :implementation-function
    :reader generic-function-implementation-function))
  (:metaclass c2mop:funcallable-standard-class)
  (:documentation "The class of thrift response operators. Each wraps the invocation of a base
 implemntation operator with a mechanism to decode the arguments for application, to encode
 the results as a 'reply' response message, and to catch exceptions and encode them as an
 'exception' response message."))


;;;
;;; thrift-class operators

(defmethod c2mop:validate-superclass ((c1 standard-class) (c2 thrift-class))
  t)

(defmethod c2mop:validate-superclass ((c2 thrift-class) (c1 standard-class))
  t)


(defmethod make-instance ((class thrift-exception-class) &rest initargs)
  (declare (dynamic-extent initargs))
  (apply #'make-condition (class-condition-class class) initargs))


(defgeneric find-thrift-class (name &optional errorp)
  (:documentation "Return a class registered by identifier name. If none is registered, if
 signal an error if errorp is true. Otherwise return nil.")

  (:method ((name string) &optional (errorp t))
    (cond ((gethash name *thrift-classes*))
          (errorp
           (error "thrift-class not found: ~s" name)))))


(defgeneric (setf find-thrift-class) (class name)
  (:documentation "Register a classe according to identifier string. Given nil, delete the entry.")

  (:method ((class thrift-class) (name string))
    (setf (gethash name *thrift-classes*) class))

  (:method ((class null) (name string))
    (remhash name *thrift-classes*)))


(defmethod initialize-instance :after ((class thrift-class) &key (identifier (class-name class)))
  (initialize-thrift-class class :identifier identifier))


(defmethod reinitialize-instance :after ((class thrift-class) &key identifier )
  (when identifier
    (initialize-thrift-class class :identifier identifier)))


(defgeneric initialize-thrift-class (class &rest initargs)
  (declare (dynamic-extent initargs))
  (:method ((class thrift-class) &rest initargs)
    (declare (dynamic-extent initargs))
    ;; nb. dont bind the class here - symmetry to exceptions argues that it be
    ;; bound in the definition form
    (destructuring-bind (&key identifier &allow-other-keys) initargs
      (loop (etypecase identifier
              ;; initialize instance asserts a value, reinitial does not
              (null (return))
              ((or string symbol)
               (setf (slot-value class 'identifier) (string identifier))
               (return))
              (cons
               (setf identifier (first identifier))))))))


(defgeneric class-identifier (class)
  (:documentation "Return the external name for the given class. Given a designator (the class name
 of an instance), delegate to the class. Given an external name (a string) return it.")

  (:method ((class class))
    (string (class-name class)))
  (:method ((object structure-object))
    (class-identifier (class-of object)))
  (:method ((object standard-object))
    (class-identifier (class-of object)))

  (:method ((class-name symbol))
    (class-identifier (find-class class-name)))
  (:method ((identifier string))
    identifier))
  

(defmethod c2mop:direct-slot-definition-class ((class thrift-class) &key identifier)
  "If an id is present in the definition, the slot is included to pr included when de/serializing"
  (cond (identifier
         (find-class 'direct-field-definition))
        (t
         (call-next-method))))

(defmethod c2mop:effective-slot-definition-class ((class thrift-class) &key name)
  "If some direct lost definition indicates thrift support, them carry that over to the effective definition"
  (if (some #'(lambda (class)
                (typep (find name (c2mop:class-direct-slots class) :key #'field-definition-name)
                       'direct-field-definition))
            (c2mop:class-precedence-list class))
    (find-class 'effective-field-definition)
    (call-next-method)))

(defmethod c2mop:compute-effective-slot-definition ((class thrift-class) name direct-slots)
  (let ((sd (call-next-method)))
    (typecase sd
      (effective-field-definition
       (setf (slot-value sd 'identifier) (or (some #'field-definition-identifier direct-slots)
                                             (error "No direct slot specified an identifier: ~s." name)))
       (setf (slot-value sd 'identifier-number) (or (some #'field-definition-identifier-number direct-slots)
                                                (error "No direct slot specified an id number: ~s." name)))
       (setf (slot-value sd 'reader) (or (some #'field-definition-reader direct-slots)
                                         (error "No direct slot specified a reader: ~s." name)))))
    sd))

(defgeneric field-definition-identifier (slot-definition)
  (:method ((sd c2mop:slot-definition))
    "Provide a base method which returns nil to permit filtering all definitions."
    nil))

(defgeneric field-definition-identifier (field-definition)
  (:method ((fd cl:list))
    ;; for use in macros
    (first fd)))

(defgeneric field-definition-name (field-definition)
  (:method ((fd cl:list))
    ;; for use in macros
    (let ((identifier (first fd)))
      (etypecase identifier
        (string (str-sym identifier))
        ;; allow for the gensym in the interposed result field
        (symbol identifier)))))

(defgeneric field-definition-identifier-number (field-definition)
  (:method ((fd cl:list))
    ;; for use in macros
    (getf (cddr fd) :id)))

(defgeneric field-definition-type (field-definition)
  (:method ((fd cl:list))
    ;; for use in macros
    (getf (cddr fd) :type))
  (:method ((sd c2mop:slot-definition))
    (c2mop:slot-definition-type sd)))

(defgeneric field-definition-name (field-definition)
  (:method ((sd c2mop:slot-definition))
    (c2mop:slot-definition-name sd)))

(defgeneric field-definition-initarg (field-definition)
  (:method ((sd c2mop:slot-definition))
    (first (c2mop:slot-definition-initargs sd))))

(defgeneric field-definition-reader (field-definition)
  (:method ((sd c2mop:direct-slot-definition))
    (first (c2mop:slot-definition-readers sd))))


(defgeneric class-field-definitions (class)
  (:method ((class symbol))
    (class-field-definitions (find-class class)))
  
  (:method ((class thrift-class))
    (unless (c2mop:class-finalized-p class)
      (c2mop:finalize-inheritance class))
    (remove-if-not #'(lambda (sd) (typep sd 'effective-field-definition)) (c2mop:class-slots class)))

  (:method ((object standard-object))
    (class-field-definitions (class-of object)))

  (:method ((object structure-object))
    (class-field-definitions (class-of object)))

  (:method ((object condition))
    (class-field-definitions (class-of object)))

  (:method ((identifier string))
    (class-field-definitions (str-sym identifier)))

  (:method ((class class))
    (if (subtypep class 'condition)
      (class-field-definitions (cons-symbol (symbol-package (class-name class)) (class-name class) :-thrift-class))
      nil)))


(defmethod unknown-field ((class thrift-class) (name t) (id t) (type t) (value t))
  "The default method for thrift classes does nothing, which is intended to leave the final
 disposition to the protocol."

  nil)
