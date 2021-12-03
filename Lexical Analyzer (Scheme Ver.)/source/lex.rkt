;
; Name: Brandon Mitchell
; Description:  The lexical analyzer in object oriented Scheme!  Uses good
;               encapsulation like the previous two.  Is pretty much the 
;               same as before except with the additon of a "handle-recognize"
;               function to increase readability, reduce repeat code, and make
;               it match the "handle-error" function.
;

#lang racket



(define lexical-analyzer%
  
  ; Inherits from base object%, can inherit from other, custom classes
  (class object%
  
    ; Fields are public 
    (field (cur-token ""))
    (field (cur-lexemme ""))
    (field (error-flag #f))
    (field (error-message ""))
    
    ; Calls parent's constructor, needed even if inheriting from object%
    (super-new)
    
    ; Python and C# ignore the \r but it looks like Scheme reads it in, choose 
    ; which system this will be used on, not really ideal, could avoid the 
    ; issue with some changes, but I don't really need to do this to start with
    (init (platform "win"))
    (define line-ending
      (if (string-contains? (string-downcase platform) "win")
        "\r\n"
        "\n"
      )
    )
    
    ; Using define makes a private attribute
    (define scan-table #(#()))
    (define token-table #())
    (define keyword-table (set '()))
    (define source-file "")

    (define index 0)
    
    ; brief: Looks into the scanning table to return the proper action
    ; param: cur-char: char, the char just read in
    ; param: cur-state: int, our current state (row) into the table
    ; return: string, the value at the intersection of cur-char and cur-state
    (define/private (find-action cur-char cur-state)
      (letrec (
        (char-val (number->string (char->integer cur-char)))
        (col-val (vector-member char-val (vector-ref scan-table 0))))
        
        (if col-val 
          (vector-ref (vector-ref scan-table cur-state) col-val)
          #\-
        )
      )
    )

    ; brief: Sets various values when a recognize state is reached
    ; param: tok: string, the token type from the table
    ; param: image: string, the image at the time of recognize
    (define/private (handle-recognize tok image)
      (begin
        (set! cur-lexemme image)
        (if (set-member? keyword-table image)
          (set! cur-token image)
          (set! cur-token tok)
        )
      )
    )

    ; brief: Sets various values when an error state is reached
    ; param: tok: string, the token type from the table
    ; param: image: string, the image at the time of error
    ; param: cur-char: char, the char resposeible for the error
    (define/private (handle-error tok image cur-char)
      (letrec (
        (temp (substring source-file 0 index))
        (rows 
          (+ 1 (for/sum ([ch temp]) 
            (if (equal? (~a ch) "\n") 1 0))
          )
        ))
        (begin
          (set! error-flag #t)
          (set! error-message (string-append tok ", " (format "row ~a" rows) 
            ": " (string-trim (string-append image (~a cur-char))))
          )
          
          (set! cur-token "")
          (set! cur-lexemme "")
        )
      )
    )
    
    ; brief: Reads in the scan table and sets it, resets index
    ; param: file-name: string, the file to be read
    (define/public (read-scan-table file-name)
      
      ; The use of temp is not necessary, but I need to make sure the tables 
      ; are always in a valid state.  I don't know if an error during set! 
      ; would put them in an invalid state, so I do the reading first and 
      ; assignment after.
      (let (
        (temp 
          ; Read whole file, split on new lines, and then split again
          (for/vector 
            ([line (string-split (file->string file-name) line-ending)])
            (list->vector (string-split line ","))
          )
        ))
        (begin
          (set! scan-table temp)
          (set! index 0)
        )
      )
    )

    ; brief: Reads in the token table and sets it, resets index
    ; param: file-name: string, the file to be read
    (define/public (read-token-table file-name)
      
      ; CSV is only one column, so simply split on newlines
      (let (
        (temp 
            (list->vector (string-split (file->string file-name) line-ending))
        ))
        (begin
          (set! token-table temp)
          (set! index 0)
        )
      )
    )

    ; brief: Reads in the keyword table and sets it, resets index
    ; param: file-name: string, the file to be read
    (define/public (read-keyword-table file-name)
      
      ; Same format as token table, but turn into a set as everything is unique
      (let (
        (temp (list->set (string-split (file->string file-name) line-ending))))
        (begin
          (set! keyword-table temp)
          (set! index 0)
        )
      )
    )
    
    ; brief: Reads in the source file and sets it, resets index
    ; param: file-name: string, the file to be read
    (define/public (read-source-file file-name)
      
      ; I remove the extra whitespace as it doesn't matter and we don't want 
      ; to output it anyways
      (let (
        (temp (string-trim (file->string file-name))))
        (begin
          (set! source-file temp)
          (set! index 0)
        )
      )
    )
    
    ; brief: Sets index to 0 to restart scanning
    (define/public (reset-index)
      (set! index 0)
    )

    ; brief: Returns a bool to indicate if eof was hit or not
    ; return: bool, true if eof reached, false otherwise
    (define/public (eof?)
      (>= index (string-length source-file))
    )
    
    ; brief: Loops through the source file and sets member values if one is 
    ;        found
    (define/public (read-next-token)
      (begin
        
        (set! cur-token "")
        (set! cur-lexemme "")
        
        (set! error-flag #f)
        (set! error-message "")

        ; Make a while loop using a recrusive function
        (letrec (
          (loop
            (lambda (image cur-state)
              (if (eof?)
              
                ; eof can be a valid end for a token or and improper end
                (let ((tok (vector-ref token-table cur-state)))
                  (if (not (equal? (string-ref (~a tok) 0) #\-))
                    (handle-recognize tok image)
                    (handle-error tok image "")
                  )
                )
                
                (letrec
                  ((cur-char (string-ref source-file index))
                  (action (find-action cur-char cur-state)))
                  
                  (if (not (equal? (string-ref (~a action) 0) #\-))
                  
                    ; Only place where we loop
                    (begin 
                      (set! index (+ 1 index))
                      (loop (string-append image (~a cur-char)) 
                        (string->number action)
                      )
                    )
                    
                    (let (
                      (tok (vector-ref token-table cur-state)))
                      (if (not (equal? (string-ref (~a tok) 0) #\-))
                        (handle-recognize tok image)
                        (begin
                          (set! index (+ 1 index))
                          (handle-error tok image cur-char)
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        ) (loop "" 1))
      )
    )
  )
)



; Choose what to export when the user "require" it, allows for some 
; encapsulation
(provide lexical-analyzer%)