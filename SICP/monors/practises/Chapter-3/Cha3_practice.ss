;; 3.1
#lang racket
(define (make-accumulater init)
  (lambda (x)
    (set! init (+ x init))
    init)
  )

(define A (make-accumulater 5))

(A 10)
(A 10)

;; 3.2
#lang racket
(define (make-moniterd f)
  (let ((counter 0))
    (define show-count counter)
    (define (executer x)
      (begin
        (set! counter (+ counter 1))
        (f x)))
    (define (disptch m)
      (if (eq? m 'how-many-calls?)
          show-count
          (executer m)))
    disptch))

(define s (make-moniterd sqrt))
(s 100)
(s 'how-many-calls?)

;;3.3 
#lang racket
(define (make-account balance pass)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount ))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount ))
    balance)
  (define (dispatch m)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request: MAKE-ACCOUNT"
                       m))))
  (define (authenticate p m)
    (if (eq? p pass)
        (dispatch m)
        (lambda (m) "Incorrect password")))
  authenticate)

(define acc (make-account 100 'secret-password ))
((acc 'secret-password 'withdraw) 40)
((acc 'some-other-password 'deposit) 50)

;;3.4
#lang racket
(define (make-account balance pass)
  (define rest-attempt 7)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount ))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount ))
    balance)
  (define (dispatch m)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request: MAKE-ACCOUNT"
                       m))))
  (define (call-the-cops m) "call-the-cops")
  
  (define (authenticate p m)
    (let ((reduce-attempt (- rest-attempt 1)))
      (if (eq? p pass)
          (begin (set! rest-attempt 7)
                 (dispatch m))
          (begin
            (set! rest-attempt reduce-attempt)
            (if (= rest-attempt 0)
                (lambda (m) (call-the-cops m))
                (lambda (m) "Incorrect password"))))))
  authenticate)

(define acc (make-account 100 'secret-password ))
((acc 'some-other-password 'deposit) 50)
((acc 'some-other-password 'deposit) 50)
((acc 'some-other-password 'deposit) 50)
((acc 'some-other-password 'deposit) 50)
((acc 'some-other-password 'deposit) 50)
((acc 'some-other-password 'deposit) 50)
((acc 'some-other-password 'deposit) 50)
((acc 'secret-password 'withdraw) 40)
((acc 'some-other-password 'deposit) 50)

;; 3.5
#lang racket
(define (monte-carlo trials experiment) 
  (define (iter trials-remaining trials-passed) 
    (cond ((= trials-remaining 0) 
           (/ trials-passed trials)) 
          ((experiment) 
           (iter (- trials-remaining 1) (+ trials-passed 1))) 
          (else 
           (iter (- trials-remaining 1) trials-passed)))) 
  (iter trials 0)) 
(define (random-in-range low high) 
  (let ((range (- high low))) 
    (+ low (random range)))) 

(define (P x y) 
  (< (+ (expt (- x 5) 2) 
        (expt (- y 7) 2)) 
     (expt 3 2)))

(define (estimate-integral P x1 x2 y1 y2 trials) 
  (define (experiment) 
    (P (random-in-range x1 x2) 
       (random-in-range y1 y2))) 
  (monte-carlo trials experiment))

(estimate-integral P 2 8 4 10 100)

;;3.6
#lang racket
(define (rand signal)
  (let ((x 10))
    (cond ((eq? signal 'generate)
           (lambda () (set! x (random x)) x))
          ((eq? signal 'reset)
           (lambda (new)
             (set! x new)))
          (else (error signal "is not define")))))

((rand 'reset) 0)
((rand 'generate))

;; 3.7
#lang racket
(define (make-account balance pass)
  (define p-list (cons pass '()))
  
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount ))
               balance)
        "Insufficient funds"))

  (define (deposit amount)
    (set! balance (+ balance amount ))
    balance)

  (define (join n-p)
    (set! p-list (cons n-p p-list))
    authenticate)

  (define (dispatch m)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          ((eq? m 'join) join)
          (else (error "Unknown request: MAKE-ACCOUNT"
                       m))))

  (define (match-pass lt p)
    (cond ((null? lt) #f)
          ((eq? (car lt) p) #t)
          (else (match-pass (cdr lt) p))))

  (define (authenticate p m)
    (if (match-pass p-list p)
        (dispatch m)
        (lambda (m) "Incorrect password")))

  authenticate)

(define acc (make-account 100 'secret-password ))
;;((acc 'secret-password 'withdraw) 10)

(define (make-join acc p n-p)
  ((acc p 'join) n-p))

;; 統合号座の作成
(define new-acc
  (make-join acc 'secret-password 'hoge))

((new-acc 'hoge 'withdraw) 10)
((new-acc 'secret-password 'withdraw) 10)

;; 3.8
#lang racket
(define f
  (let ((count -1))
    (lambda (n)
      (begin
        (set! count (+ count 1))
        (if (= count n)
            n
            0)))))

(+ (f 1) (f 0)) ; 0

(define g
  (let ((count -1))
    (lambda (n)
      (begin
        (set! count (+ count 1))
        (if (= count n)
            n
            0)))))


(+ (g 0) (g 1)) ; 1

;; 3.9
;; 図のため省略

;; 3.10
;; 図なため省略

;; 3.11
;; まず、set!されるとbalanceの値が変化するので異なる環境が作成される。
;; 例えば、(make-account 40)ののちにdeposit処理で50振り込む処理が呼ばれた場合、
;; balanceは40 + 50となり新たな変数として作成される。imutableにおけるNewのような感じ。
;; http://community.schemewiki.org/?sicp-ex-3.11

;; 1. accの局所状態は各局所定義上に作成される。
;; 2. global環境の状態のみが共有される。

;; 3.12
;; (append x y)
;; (cdr x) -> (b, nil)

;; (append! x y)
;; (cdr x) -> (d, nil)

;; 3.13
;; <1> -> |a| |
;;           -> |b| |
;;                 -> |c| | -> <1>
;;(last-pair z)はStack Orver Flowになる。

;; 3.14
;; 1. mysteryが何をするかを答えよ。
;; 配列を反転させる関数。  
;; 
;; 2. vが束縛するイメージをかけ
;; V: 
;;  |a| |
;;     -> |b| |
;;           -> |c| |
;;                 -> |d|nil|
;; 評価後のV and W
;;  |d| |
;;     -> |c| |
;;           -> |b| |
;;                 -> |a|nil|
;; 
;; 3. v, wの値として何が表示されるか。 
;; (d, c, b, a)

; 3.16
#lang sicp
(define (count-pairs x)
  (if (not (pair? x))
      0
      (+ (count-pairs (car x))
         (count-pairs (cdr x))
         1)))

; first: count 3
(define frt (list 'a 'b 'c))
frt
(count-pairs frt)

; second: count 4
(define elem '(elm))
(define x (cons elem elem))

(define snd (list x))
snd
(count-pairs snd)

; third: count 7
(define third (cons x x))
third
(count-pairs third)

; endless
(define hoge (list 'a 'b 'c))
(define endless (set-cdr! (cddr hoge) hoge))
(count-pairs hoge) ; not return

; 3.17
#lang sicp

(define (count-pairs x)
  (let ((cache '()))
    (define (uncounted? x)
      (if (memq x cache)
          0
          (begin (set! cache (cons x cache))
                 1)))
    
    (define (count x)
      (if (not (pair? x))
           0
           (+ (count (car x))
              (count (cdr x))
              (uncounted? x))))
  (count x)))

 (define x '(foo)) 
 (define y (cons x x)) 
 (define str3 (cons y y)) 
 (count-pairs str3) ; 7 

; 3.18
#lang sicp
(define (last-pair x)
  (if (pair? x)
      x
      (last-pair (cdr x))))

(define (make-cycle x)
  (set-cdr! (last-pair x) x)
  x)

(define z (make-cycle (list 'a 'b 'c)))

(define (is-cycle pair)
  (let ((cache '()))
        
    (define (encounted? x)
      (if (memq x cache)
          #t
          (begin (set! cache (cons x cache))
                 #f)))
    
    (define (iter x)
        (cond
          ((null? x) #f)
          ((encounted? x) #t)
          (else (iter (cdr x)))))

    (iter pair)))

(is-cycle z) ;t
(is-cycle (list 'a 'a 'a)) ;f
(is-cycle (make-cycle (list 'a 'a 'a))) ;t

; 3.19
