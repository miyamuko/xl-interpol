; -*- mode: lisp; package: xl-interpol.test.simple; encoding: shift_jis -*-

;;; some simple tests for CL-INTERPOL - entered manually and to be
;;; read in the CL-INTERPOL-TEST package; all forms except SETQ forms
;;; are expected to return a true value on success when EVALuated

(require "lisp-unit")
(require "xl-interpol")
(require "xl-interpol/test/helper")

(defpackage :xl-interpol.test.simple
  (:use :lisp :editor :lisp-unit :xl-interpol :xl-interpol.test.helper))

(in-package :xl-interpol.test.simple)

(remove-all-tests :xl-interpol.test.simple)

(enable-interpol-syntax)

(define-test read-simple
  (assert-string= #?"abc" "abc")
  (assert-string= #?'abc' "abc")
  (assert-string= #?|abc| "abc")
  (assert-string= #?/abc/ "abc")
  (assert-string= #?#abc# "abc")
  (assert-string= #?{abc} "abc")
  (assert-string= #?(abc) "abc")
  (assert-string= #?<abc> "abc")
  (assert-string= #?[abc] "abc")

  (assert-string= #?"abc\"" "abc\"")
  (assert-string= #?"abc\\" "abc\\")
  (assert-string= #?[a[b]c] "a[b]c")
  (assert-string= #?[a[[b]]c] "a[[b]]c")
  (assert-string= #?[a[[][]]b] "a[[][]]b")
  )

(define-test read-meta-chars
  (assert-string= #?"\t\n\r\f\b\a\e"
                  (coerce (list #\TAB #\LFD #\RET #\C-l #\C-h (code-char 7) (code-char 27))
                          'string))
  (assert-string= #?"\033\x1b\c[\x{1b}"
                  (make-sequence 'string 4 :initial-element (code-char 27)))
  (assert-string= #?"\x" (string (code-char 0)))
  (assert-string= #?"\x001" (format nil "~A1" (code-char 0)))
  (assert-string= #?"\0001" (format nil "~A1" (code-char 0)))

  (assert-char= (char #?"\x20" 0) #\SPC)
  (assert-eql 0 (char-code (char #?"\x" 0)))
  (assert-eql 0 (char-code (char #?"\x{}" 0)))
  (assert-string=  #?"Only\x202 digits!" "Only 2 digits!")

  ;; might in theory fail on some Lisps - see 13.1.7
  (assert-string-equal (char-name (char #?"\cH" 0)) "Backspace")
  (assert-char= (char #?"\cj" 0) #\LFD)

  ;; two spaces
  (assert-string= #?"\40\040" "  "  )
  ;; note that \377 and \777 yield the same result
  (assert-equal (map 'list #'char-code #?"\0\377\777") '(0 255 255))
  (assert-string= #?"Only\0403 digits!" "Only 3 digits!")
  (assert-equal (map 'list #'identity #?"\9") (list #\9))
  )

(define-test read-regex
  (assert-string= #?/\1/ "\\1")
  (assert-string= #?r"\1" "\\1")
  (assert-string= #?r"\k<foo>" "\\k<foo>")
  (assert-string= #?r"\p{LC}" "\\p{LC}")
  (assert-string= #?x/abc / "abc")
  (assert-string= #?x/abc
                  / "abc")
  (assert-string= #?rx"abc " "abc")
  (assert-string= #?/[\1]\1/ (format nil "[~A]\\1" (code-char 1)))
  (assert-string= #?/[(?#foo)](?#foo)/ "[(?#foo)]")
  (assert-string= #?/a#bc/ "a#bc")
  (assert-string= #?x/a#bc/ "a")
  (assert-string= #?x/\d\A[\d\A]/ "\\d\\A[\\dA]")
  )

(define-test read-convert-case
  (assert-string= #?"\Q-" "\\-")
  (assert-string= #?"\Q-\E-" "\\--")
  (assert-string= #?"\ufoo" "Foo")
  (assert-string= #?"\Ufoo" "FOO")
  (assert-string= #?"\Ufoo\Ebar" "FOObar")
  (assert-string= #?"\Ufoo\LBAR" "FOObar")
  )

(define-test read-variable
  (let ((a "foo"))
    (assert-string= #?"$" "$")
    (assert-string= #?"@ @" "@ @")
    (assert-string= #?"${a}bar" "foobar")
    (assert-string= #?/${a}bar/ "foobar")
    (assert-string= #?"$[a]bar" "foobar")
    (assert-string= #?"$(a)bar" "foobar")
    (assert-string= #?"$<a>bar" "foobar")
    (assert-string= #?/$<a>bar/ "$<a>bar")
    (assert-string= #?"$a @a " "$a @a "))

  (let ((a (list 1 2 3)))
    (assert-string= #?"${a}" "(1 2 3)")
    (assert-string= #?"@{a}" "1 2 3")
    (let ((*list-delimiter* ""))
      (assert-string= #?"@{a}" "123")))

  (let* ((a "foo")
         (b #\SPC)
         (c "bar")
         (d (list a b c))
         (x 40))
    (assert-string= #?"$ @" "$ @")
    (assert-string= #?"$(a)" "foo")
    (assert-string= #?"$<a>$[b]" "foo ")
    (assert-string= #?"\U${a}\E \u${a}" "FOO Foo")
    (assert-string= (let ((*list-delimiter* #\*))
                      #?"@{d}")
                    "foo* *bar")
    (assert-string= (let ((*list-delimiter* ""))
                      #?"@{d}")
                    "foo bar")
    (assert-string= #?"The result is ${(let ((y 2)) (+ x y))}"
                    "The result is 42")
    (assert-string= #?"${#?'${a} ${c}'} ${x}" "foo bar 40"))
  )

(define-test read-optional-delimiters
  #.(setq *optional-delimiters-p* t)
  (assert-string= (let ((% 23)) #?"$%a%b%") "23a%b%")
  (assert-string= (let ((%a 23)) #?"$%a%b%") "23%b%")
  (assert-string= (let ((%a% 23)) #?"$%a%b%") "23b%")
  (assert-string= (let ((%a%b 23)) #?"$%a%b%") "23%")
  (assert-string= (let ((%a%b% 23)) #?"$%a%b%") "23")
  #.(setq *optional-delimiters-p* nil)
  )

(disable-interpol-syntax)

;;; End
