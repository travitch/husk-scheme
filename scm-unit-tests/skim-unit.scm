(load "../stdlib.scm")

(define pass-count 0)
(define fail-count 0)

(define (unit-test-handler expected actual) 
  (if (not (eqv? expected actual))
    (begin (write (list "Test failed; expected value:" expected ", actual value:" actual))
           (set! fail-count (+ fail-count 1)))
    (set! pass-count (+ pass-count 1))))

(define (assert proc) (unit-test-handler #t (proc)))

(define (assert-equal proc value) (unit-test-handler value (proc)))

; TODO:
(define-syntax assert/equal
  (syntax-rules ()
    ((_ test expected)
     (unit-test-handler expected ((lambda () test))))))

(define (unit-test-handler-results)
  (write `("Test Complete" Passed: ,pass-count Failed: ,fail-count)))
