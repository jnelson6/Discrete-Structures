#lang eopl
; Julia Nelson
; 4/24/2018
; 'I pledge my honor that I have abided by the Stevens honor system' -Julia Nelson
;     jnelson6

;;Define composite
;; Composite takes an inner relation and an outer relation and returns a relation
;; For every (a b) tuple in the inner relation if b equals an A in a (A B) tuple in the outer relation
;; then add the duple (a B) to the relation you will be returning
;; order doesn't matter

;; Examples:
;; (composite '((2 4) (3 5) (4 6) (5 7)) '((1 2) (2 3) (3 4) (4 5)) ) -> '((1 4) (2 5) (3 6) (4 7))
;; (composite '((2 4) (5 8) (3 4)) '((2 4) (5 8) (3 4))) -> '()
;; (composite '((1 1) (2 2) (3 3)) '((1 1) (2 2) (3 3))) -> '((1 1) (2 2) (3 3))

;; Type Signature: (composite relation relation) -> relation

(define (composite  relationOuter relationInner)
  (if (null? relationInner)
      '()
      (union (composite-helper relationOuter (car relationInner)) (composite relationOuter (cdr relationInner)))))

(define (composite-helper relationOuter tuple)
  (if (null? relationOuter)
      '()
      (if (equal? (car (cdr tuple)) (car (car relationOuter)))
          (union (list (list (car tuple) (car (cdr (car relationOuter))))) (composite-helper (cdr relationOuter) tuple))
          (composite-helper (cdr relationOuter) tuple))))

;; Define power
;; power takes a relation and applies composite to itself k times
;; You will need to use a helper to store the initial relation
;; when k is zero it should return '()
;; order doesn't matter

;; Examples:
;; (power '((1 2) (2 3) (3 4) (4 1)) 0) -> '()
;; (power '((1 2) (2 3) (3 4) (4 1)) 1) -> '((1 2) (2 3) (3 4) (4 1))
;; (power '((1 2) (2 3) (3 4) (4 1)) 2) -> '((1 3) (2 4) (3 5) (4 2))

;; Type Signature: (power relation int) -> relation

(define (power relation k)
  (power-help relation relation k))

(define (power-help relation initial k)
  (if (= k 0)
      '()
      (if (= k 1)
          relation
          (power-help (composite relation initial) initial (- k 1)))))


;; Define transitive-closure
;; transitive-closure should compute the transitive-closure of a relation
;; Transitive-closure is the union of all possible powers of the relation
;; order doesn't matter

;; Examples:
;; (transitive-closure '((1 2) (2 3) (3 1))) -> '((1 1) (1 2) (1 3) (2 1) (2 2) (2 3) (3 1) (3 2) (3 3))
;; (transitive-closure '((1 3) (3 5) (2 4) (5 6) (2 3))) -> '((1 3) (3 5) (2 4) (5 6) (2 3) (1 5) (1 6) (3 6) (2 5) (2 6))

;; Type Signature: (transitive-closure relation) -> relation

(define (transitive-closure relation)
  (TC-helper relation (cardinality relation)))

(define (TC-helper relation k)
  (if (= k 0)
      '()
      (union (power relation k) (TC-helper relation (- k 1)))))

;; Define transitive?
;; returns if a given relation is transitive

;; Examples:
;; (transitive? '((1 1) (1 2) (1 3) (2 1) (2 2) (2 3) (3 1) (3 2) (3 3))) -> #t
;; (transitive? '((1 2) (2 3) (3 1))) -> #f

;; Type Signature: (transitive? relation) -> boolean

(define (transitive? relation)
   (set-equal? relation (transitive-closure relation)))


;; Define EQ-relation?
;; returns if a given relation is an EQ-relation
;; A relation is an EQ-relation if it is symmetric, reflexive, and transitive

;; Examples:
;; (EQ-relation? '((1 1) (1 2) (1 3) (2 1) (2 2) (2 3) (3 1) (3 2) (3 3)) 3) -> #t
;; (EQ-relation? '((1 1) (1 2) (2 1)) 2) -> #f

(define (EQ-relation? relation n)
  (if (and (reflexive? relation n) (symmetric? relation) (transitive? relation))
              #t
              #f ))


;;_________________________________________________________________
(define (element? item list-of-items)
  (if (null? list-of-items)                  ;Is our "set" empty?
      #f                                     ;If empty, not an element!
      (if (equal? item (car list-of-items))  ;Is our item first in list?
          #t                                 ;Yes?  Then it's an element!
          (element? item (cdr list-of-items)))));No? Check the rest.

(define (make-set list-of-items)
  (if (null? list-of-items) ;An empty list can have no duplicates,
      '()                   ;so just return an empty list.
      (if (element? (car list-of-items) (cdr list-of-items))
          (make-set (cdr list-of-items))
          (cons (car list-of-items) (make-set (cdr list-of-items))))))
         
(define (union setA setB)
  (make-set (append setA setB))) 

(define (intersection setA setB)
  (make-set (Intersection (make-set setA) (make-set setB))))

(define (Intersection setA setB)
  (if (null? setA) 
      '()
      (if (element? (car setA) setB)
          (cons (car setA) (intersection (cdr setA) setB))
          (intersection (cdr setA) setB))))

(define (subset? setA setB)
  (if (null? setA)
      #t
      (if (element? (car setA) setB)
          (subset? (cdr setA)  setB)
          #f)))

(define (set-equal? setA setB)
   (and (subset? setA setB) (subset? setB setA)))

(define (proper-subset? setA setB)
  (and (subset? setA setB) (not (set-equal? setA setB))))

(define (set-difference setA setB)
  (make-set (Set-Difference setA setB)))

(define (Set-Difference setA setB)
  (if (null? setA)
      '()
      (if (element? (car setA) setB)
          (Set-Difference (cdr setA) setB)
          (cons (car setA) (Set-Difference (cdr setA) setB)))))

(define (sym-diff setA setB)
  (union (set-difference setA setB) (set-difference setB setA)))

(define (cardinality set)
  (length (make-set set)))

(define (disjoint? setA setB)
  (null? (intersection setA setB)))

(define (superset? setA setB)
  (subset? setB setA))

(define (insert element set)
  (make-set (cons element set)))

(define (remove element set)
  (set-difference set (list element)))

(define (id n)
    (if (zero? n)
        '()
        (cons (list n n) (id (- n 1)))))

(define (reflexive? relation n)  
    (subset? (id n) relation))

(define (reflexive-closure relation n)
    (union relation (id n)))

(define (flip-pairs relation)
    (if (null? relation)
        '()
        (cons (reverse (car relation)) (flip-pairs (cdr relation)))))

(define (symmetric? relation)
   (set-equal? relation (flip-pairs relation)))

(define (symmetric-closure relation) 
   (union relation (flip-pairs relation)))

(define (related-to element relation)
   (if (null? relation)
      '()
      (if (equal? element (caar relation))
          (cons (cadar relation) (related-to element (cdr relation)))
          (related-to element (cdr relation)))))
