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
  (assert-string= "abc" #?"abc")
  (assert-string= "abc" #?'abc')
  (assert-string= "abc" #?|abc|)
  (assert-string= "abc" #?/abc/)
  (assert-string= "abc" #?#abc#)
  (assert-string= "abc" #?{abc})
  (assert-string= "abc" #?(abc))
  (assert-string= "abc" #?<abc>)
  (assert-string= "abc" #?[abc])

  (assert-string= "abc\"" #?"abc\"")
  (assert-string= "abc\\" #?"abc\\")
  (assert-string= "a[b]c" #?[a[b]c])
  (assert-string= "a[[b]]c" #?[a[[b]]c])
  (assert-string= "a[[][]]b" #?[a[[][]]b])
  )

(define-test read-meta-chars
  (assert-string= (coerce (list #\TAB #\LFD #\RET #\C-l #\C-h (code-char 7) (code-char 27))
                          'string)
                  #?"\t\n\r\f\b\a\e")
  (assert-string= (make-sequence 'string 4 :initial-element (code-char 27))
                  #?"\033\x1b\c[\x{1b}")
  (assert-string= (string (code-char 0)) #?"\x")
  (assert-string= (format nil "~A1" (code-char 0)) #?"\x001")
  (assert-string= (format nil "~A1" (code-char 0)) #?"\0001")

  (assert-char= (char #?"\x20" 0) #\SPC)
  (assert-eql 0 (char-code (char #?"\x" 0)))
  (assert-eql 0 (char-code (char #?"\x{}" 0)))
  (assert-string= #?"Only\x202 digits!" "Only 2 digits!")

  ;; might in theory fail on some Lisps - see 13.1.7
  (assert-string-equal "Backspace" (char-name (char #?"\cH" 0)))
  (assert-char= #\LFD (char #?"\cj" 0))

  ;; two spaces
  (assert-string= "  " #?"\40\040")
  ;; note that \377 and \777 yield the same result
  (assert-equal '(0 255 255) (map 'list #'char-code #?"\0\377\777"))
  (assert-string= "Only 3 digits!" #?"Only\0403 digits!")
  (assert-equal (list #\9) (map 'list #'identity #?"\9"))
  )

(define-test read-regex
  (assert-string= "\\1" #?/\1/)
  (assert-string= "\\1" #?r"\1")
  (assert-string= "\\k<foo>" #?r"\k<foo>")
  (assert-string= "\\p{LC}" #?r"\p{LC}")
  (assert-string= "abc" #?x/abc/)
  (assert-string= "abc" #?x/abc
                  /)
  (assert-string= "abc" #?rx"abc ")
  (assert-string= (format nil "[~A]\\1" (code-char 1)) #?/[\1]\1/)
  (assert-string= "[(?#foo)]" #?/[(?#foo)](?#foo)/)
  (assert-string= "a#bc" #?/a#bc/)
  (assert-string= "a" #?x/a#bc/)
  (assert-string= "\\d\\A[\\dA]" #?x/\d\A[\d\A]/)
  )

(define-test read-convert-case
  (assert-string= "\\-" #?"\Q-")
  (assert-string= "\\--" #?"\Q-\E-")
  (assert-string= "Foo" #?"\ufoo")
  (assert-string= "FOO" #?"\Ufoo")
  (assert-string= "FOObar" #?"\Ufoo\Ebar")
  (assert-string= "FOObar" #?"\Ufoo\LBAR")
  )

(define-test unicode-name
  (assert-string= "‚ " #?"\N{HIRAGANA LETTER A}")
  (assert-string= "‚ " #?"\N{hiragana letter a}")
  (assert-string= "‚ " #?{\N{HIRAGANA LETTER A}})

  ;; special CL-INTERPOL aliases
  (assert-string= #\zero_width_joiner #?"\N{ZWJ}")
  (assert-string= #\zero_width_non_joiner #?"\N{ZWNJ}")

  #.(setq *try-hex-notation-p* t)
  (assert-eql #x42 (char-code (char #?"\N{U+0042}" 0)))
  (assert-string= "‚ ‚¢‚¤" #?"\N{U+3042}\N{U+3044}\N{U+3046}")
  #.(setq *try-hex-notation-p* nil)

  #.(setq *try-lisp-names-p* t)
  (assert-char= #\LFD (char #?"\N{LFD}" 0))
  (assert-char= #\RET (char #?"\N{RET}" 0))
  (assert-char= #\a (char #?"\N{a}" 0))
  (assert-char= #\A (char #?"\N{A}" 0))
  #.(setq *try-lisp-names-p* nil)
  )

(define-test read-variable
  (let ((a "foo"))
    (assert-string= "$" #?"$")
    (assert-string= "@ @" #?"@ @")
    (assert-string= "foobar" #?"${a}bar")
    (assert-string= "foobar" #?/${a}bar/)
    (assert-string= "foobar" #?"$[a]bar")
    (assert-string= "foobar" #?"$(a)bar")
    (assert-string= "foobar" #?"$<a>bar")
    (assert-string= "$<a>bar" #?/$<a>bar/)
    (assert-string= "$a @a " #?"$a @a "))

  (let ((a (list 1 2 3)))
    (assert-string= "(1 2 3)" #?"${a}")
    (assert-string= "1 2 3" #?"@{a}")
    (let ((*list-delimiter* ""))
      (assert-string= "123" #?"@{a}")))

  (let* ((a "foo")
         (b #\SPC)
         (c "bar")
         (d (list a b c))
         (x 40))
    (assert-string= "$ @" #?"$ @")
    (assert-string= "foo" #?"$(a)")
    (assert-string= "foo " #?"$<a>$[b]")
    (assert-string= "FOO Foo" #?"\U${a}\E \u${a}")
    (assert-string= "foo* *bar"
                    (let ((*list-delimiter* #\*))
                      #?"@{d}"))
    (assert-string= "foo bar"
                    (let ((*list-delimiter* ""))
                      #?"@{d}"))
    (assert-string= "The result is 42"
                    #?"The result is ${(let ((y 2)) (+ x y))}")
    (assert-string= "foo bar 40" #?"${#?'${a} ${c}'} ${x}"))
  )

(define-test read-optional-delimiters
  #.(setq *optional-delimiters-p* t)
  (assert-string= "23a%b%" (let ((% 23)) #?"$%a%b%"))
  (assert-string= "23%b%" (let ((%a 23)) #?"$%a%b%"))
  (assert-string= "23b%" (let ((%a% 23)) #?"$%a%b%"))
  (assert-string= "23%" (let ((%a%b 23)) #?"$%a%b%"))
  (assert-string= "23" (let ((%a%b% 23)) #?"$%a%b%"))
  #.(setq *optional-delimiters-p* nil)
  )

(disable-interpol-syntax)

;;; End
