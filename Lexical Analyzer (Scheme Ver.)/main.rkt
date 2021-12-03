;
; Name: Brandon Mitchell
; Description:  Entry point to the program, same as other versions, load in 
;               tables, pass lex instance to the gui and run.  Run this file to 
;               run the program.
;

#lang racket/gui

(require "source/lex.rkt")
(require "source/gui.rkt")



(let (
  (lex (new lexical-analyzer%)))
  (when
    (with-handlers 
      ([exn:fail?
        (lambda (exn)
        
          ; Last item in a begin is returned
          (begin
            (message-box "Error Loading Files!"     
              (string-append "The default files could not be loaded due "
                "to an error.\n\n" (exn-message exn)
              )
              #f '(ok stop)
            )
            #f
          )
        )
      ])
      (begin 
        (send lex read-scan-table DEF_SCAN_TABLE)
        (send lex read-token-table DEF_TOKEN_TABLE)
        (send lex read-keyword-table DEF_KEYWORD_TABLE)
        (send lex read-source-file DEF_SOURCE_FILE)
      )
      
      ; If the above reading suceeds, then true is returned and we start
      #t
    )
    (run-gui lex)
  )
)