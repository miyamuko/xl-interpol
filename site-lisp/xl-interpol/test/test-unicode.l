; -*- mode: lisp; package: xl-interpol.test.unicode; encoding: shift_jis -*-

;;; xl-interpol/test/test-unicode.l
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

(require "lisp-unit")
(require "xl-interpol")
(require "xl-interpol/test/helper")

(defpackage :xl-interpol.test.unicode
  (:use :lisp :editor :lisp-unit :xl-interpol :xl-interpol.test.helper))

(in-package :xl-interpol.test.unicode)

(remove-all-tests :xl-interpol.test.unicode)

(define-test unicode/invalid-unicode-name
  (assert-error 'interpol::simple-reader-error
      (read-interpol "\"\\N{a}\""))
  (assert-error 'interpol::simple-reader-error
      (read-interpol "\"\\N{A}\""))

  (assert-string= "a" (read-interpol "\"\\N{latin_small_letter_a}\""))
  (assert-string= "a" (read-interpol "\"\\N{LATIN_SMALL_LETTER_A}\""))
  (assert-string= "a" (read-interpol "\"\\N{LATIN SMALL LETTER A}\""))
  )

(define-test unicode/resolve-unicode-name
  (assert-eq nil (interpol::resolve-unicode-name "a"))
  (assert-eq nil (interpol::resolve-unicode-name "A"))

  ;; alias.l
  (assert-char= #\zero_width_joiner (interpol::resolve-unicode-name "ZWJ"))
  (assert-char= #\zero_width_non_joiner (interpol::resolve-unicode-name "ZWNJ"))

  (assert-char= #\a (interpol::resolve-unicode-name "latin_small_letter_a"))
  (assert-char= #\a (interpol::resolve-unicode-name "LATIN_SMALL_LETTER_A"))
  (assert-char= #\a (interpol::resolve-unicode-name "LATIN SMALL LETTER A"))
  )

(define-test unicode/character-named
  (assert-eq nil (interpol::character-named "a"))
  (assert-eq nil (interpol::character-named "A"))

  (assert-eq nil (interpol::character-named "ZWJ"))
  (assert-eq nil (interpol::character-named "ZWNJ"))

  (assert-char= #\a (interpol::character-named "latin_small_letter_a"))
  (assert-char= #\a (interpol::character-named "LATIN_SMALL_LETTER_A"))
  (assert-char= #\a (interpol::character-named "LATIN SMALL LETTER A"))

  (assert-char= #\A (interpol::character-named "latin_capital_letter_a"))
  (assert-char= #\A (interpol::character-named "LATIN_CAPITAL_LETTER_A"))
  (assert-char= #\A (interpol::character-named "LATIN CAPITAL LETTER A"))

  (assert-char= #\Ç† (interpol::character-named "HIRAGANA LETTER A"))
  (assert-char= #\ÉA (interpol::character-named "KATAKANA LETTER A"))

  (assert-char= #\Ç† (interpol::character-named "HIRAGANA LETTER A   "))
  (assert-char= #\ÉA (interpol::character-named "   KATAKANA      LETTER    A   "))
  )

(define-test unicode/lisp-name
  (let ((*try-lisp-names-p* t))
    (assert-char= #\a (interpol::character-named "a"))
    (assert-char= #\A (interpol::character-named "A"))

    (assert-char= #\SPC (interpol::character-named "SPC"))
    (assert-char= #\RET (interpol::character-named "RET"))
    (assert-char= #\TAB (interpol::character-named "TAB"))

    (assert-eq nil (interpol::character-named "    TAB  "))
    ))

(define-test unicode/hex-notation
  (let ((*try-hex-notation-p* t))
    (assert-char= #\SPC (interpol::character-named "U+20"))
    (assert-char= #\a (interpol::character-named "U+61"))
    (assert-char= #\A (interpol::character-named "U+0041"))

    (assert-char= #\Ç† (interpol::character-named "U+3042"))
    (assert-char= #\ÉA (interpol::character-named "U+30a2"))
    (assert-char= #\àü (interpol::character-named "u+4e9c"))

    (assert-eq nil (interpol::character-named "U+3042   "))
    (assert-eq nil (interpol::character-named "   U+30a2"))
    (assert-eq nil (interpol::character-named "   u+4e9c   "))

    (assert-eq nil (interpol::character-named "hoge U+3042"))
    (assert-eq nil (interpol::character-named "U+30a2 fuga"))
    (assert-eq nil (interpol::character-named "hoge u+4e9c fuga"))
    ))

;;; End
