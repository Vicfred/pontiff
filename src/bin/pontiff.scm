(module bin.pontiff ()

(import scheme)
(import chicken.base)
(import chicken.type)
(import chicken.string)
(import chicken.format)
(import chicken.process-context)

(import tabulae)
(import tabulae.monad)
(import tabulae.parsec)
(import ix)

(import (prefix state state:))
(import (prefix argv argv:))
(import (prefix command command:))

; XXX ok so my basic flow is like
; * load and parse pontiff file if it exists, set global state
; * parse args to get command and options
; * pass that off to the relevant command
; build will have basically the opposite structure as pontiff1
; I get the root module from pfile then convert to filename
; load the file, get imports, load those
; whereas before I would find all files and then convert to module names
(define (main)
  (state:init)
  (define ret (do/m <either>
    (args <- (argv:process (command-line-arguments)))
    (return (printf "MAZ args:\n~A\n" (stringify:ix args)))
    (declare arg-tag (ix:ident->tag ((^.! ident) args)))
    (cmd <- (maybe->either (command:tag->function arg-tag)
                           `(1 . ,(<> "pontiff error: unknown command " (symbol->string arg-tag)))))
    ; XXX make commands all eithers?
    (return (cmd args))))
  (when (left? ret) (printf (<> (cdadr ret) "\n"))
                    (exit (caadr ret)))
  (exit 0))

(main)

)
