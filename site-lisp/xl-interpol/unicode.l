; -*- mode: lisp; package: xl-interpol; encoding: shift_jis -*-

;;; xl-interpol/unicode.l
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
