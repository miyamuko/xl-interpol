; -*- mode: lisp; package: xl-interpol.test.helper; encoding: shift_jis -*-

;;; xl-interpol/test/helper.l
;;
;; Copyright (c) 2011 MIYAMUKO Katsuyuki.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;; 
;;   * Redistributions of source code must retain the above copyright
;;     notice, this list of conditions and the following disclaimer.
;; 
;;   * Redistributions in binary form must reproduce the above
;;     copyright notice, this list of conditions and the following
;;     disclaimer in the documentation and/or other materials
;;     provided with the distribution.
;; 
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS' AND ANY EXPRESSED
;; OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
;; GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Code:

(defpackage :xl-interpol.test.helper
  (:use :lisp :editor :lisp-unit :xl-interpol))

(in-package :xl-interpol.test.helper)

(export '(assert-string=
          assert-string-equal
          assert-char=

          read-interpol
          ))

(defmacro assert-string= (expected form &rest extras)
  (lisp-unit::expand-assert :equal form form expected extras :test #'string=))

(defmacro assert-string-equal (expected form &rest extras)
  (lisp-unit::expand-assert :equal form form expected extras :test #'string-equal))

(defmacro assert-char= (expected form &rest extras)
  (lisp-unit::expand-assert :equal form form expected extras :test #'char=))


(defun read-interpol (str)
  (with-input-from-string (stream str)
    (interpol::interpol-reader stream nil nil)))


(provide "xl-interpol/test/helper")

;;; End
