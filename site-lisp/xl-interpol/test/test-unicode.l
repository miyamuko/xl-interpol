; -*- mode: lisp; package: xl-interpol.test.unicode; encoding: shift_jis -*-

;;; xl-interpol/test/test-unicode.l
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
