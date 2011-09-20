; -*- mode: lisp; package: xl-interpol; encoding: shift_jis -*-

;;; xl-interpol/unicode.l
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

;; Emulate cl-unicode variables/functions.

(defvar *try-unicode1-names-p* nil
  "Not supported in xl-interpol")

(defvar *try-abbreviations-p* nil
  "Not supported in xl-interpol")

(defvar *scripts-to-try* nil
  "Not supported in xl-interpol")

(defvar *try-hex-notation-p* nil
  "If true, name can be of the form \"U+<x>\" where <x> is a hexadecimal
number with four to six digits with the obvious meaning.")

(defvar *try-lisp-names-p* nil
  "If true, the function returns the character with the character name
(if there is one) or, if name is exactly one character, it returns this character.")

(defconstant +unicode-hex-regex+
  (ppcre:create-scanner "\\AU\\+([0-9a-f]+)\\z"
                        :case-insensitive-mode t))

(defun character-named (name)
  (flet ((try-unicode-name (name)
           (identity
            (gethash (canonicalize-name name)
                     si:*character-name-hash-table*)))
         (try-hex-notation (name)
           (when *try-hex-notation-p*
             (ed::protect-match-data
               (ppcre:register-groups-bind (hex)
                   (+unicode-hex-regex+ name)
                 (unicode-char (parse-integer hex :radix 16))))))
         (try-lisp-name (name)
           (when (and *try-lisp-names-p*
                      (char/= #\SPC (char name 0)))
             (ignore-errors
              (identity
               (read-from-string (format nil "#\\~A" name)))))))
    (or (try-unicode-name name)
        (try-hex-notation name)
        (try-lisp-name name))))

(defun canonicalize-name (name)
  (string-downcase
   (substitute-string
    (string-trim " " name)
    "[ -]+" "_")))


(provide "xl-interpol/unicode")

;;; End
