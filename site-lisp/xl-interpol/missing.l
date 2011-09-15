; -*- mode: lisp; package: xl-interpol; encoding: shift_jis -*-

;;; xl-interpol/missing.l
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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xl-interpol/packages")
  )

(in-package :xl-interpol)

(defmacro ecase (keyform &rest forms)
  `(case ,keyform
     ,@forms
     (t
      (error 'type-error
             :datum ',keyform
             :expected-type ',(if (cdr forms)
                                  `(or ,@(mapcar #'car forms))
                                (caar forms)))
      )))
(setf (get 'ecase 'lisp-indent-hook) 1)

(defun write-string (string &optional (stream *standard-output*) &key (start 0) end)
  (format stream "~A" (substring string start end)))


(provide "xl-interpol/missing")

;;; End
