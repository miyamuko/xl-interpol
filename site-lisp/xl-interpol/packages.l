; -*- mode: lisp; package: xl-interpol; encoding: shift_jis -*-

;;; Copyright (c) 2003-2008, Dr. Edmund Weitz. All rights reserved.

;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:

;;;   * Redistributions of source code must retain the above copyright
;;;     notice, this list of conditions and the following disclaimer.

;;;   * Redistributions in binary form must reproduce the above
;;;     copyright notice, this list of conditions and the following
;;;     disclaimer in the documentation and/or other materials
;;;     provided with the distribution.

;;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS' AND ANY EXPRESSED
;;; OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
;;; GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :xl-interpol)
    (require "ansify")
    (require "ansi-loop")
    (require "xl-ppcre")

    (defpackage :xl-interpol
      (:nicknames :interpol)
      (:use :lisp :editor :ppcre)
      ;; xyzzy 標準で lisp::ecase などが将来的に提供された場合でも、
      ;; シンボルが衝突してエラーにならないように shadowing-import にする
      (:shadowing-import-from :ansify
       :ecase
       )
      (:shadowing-import-from :ansi-loop
       :loop
       :loop-finish
       )
      )))

(in-package :xl-interpol)

(export '(enable-interpol-syntax
          disable-interpol-syntax
          *list-delimiter*
          *outer-delimiters*
          *inner-delimiters*
          *optional-delimiters-p*
          *try-unicode1-names-p*
          *try-abbreviations-p*
          *scripts-to-try*
          *try-hex-notation-p*
          *try-lisp-names-p*
          ))

(provide "xl-interpol/packages")

;;; End
