; -*- mode: lisp; package: xl-interpol.test.helper; encoding: shift_jis -*-

;;; xl-interpol/test/helper.l
;;
;; Copyright (c) 2011 MIYAMUKO Katsuyuki.
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
