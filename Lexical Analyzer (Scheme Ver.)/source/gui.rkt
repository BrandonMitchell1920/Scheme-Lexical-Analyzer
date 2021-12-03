;
; Name: Brandon Mitchell
; Description:  The GUI portion of the lexical analyzer.  I thought about making
;               aking a class like the lexical analyzer for enscapulation 
;               reasons, but I didn't feel like doing that, so I simply export 
;               everything and enscapulate the GUI elements in a run function
;               that takes the lex object.  I also thought about different ways
;               to refactor it, but I feel as though they would make it more 
;               confusing to read even if they would be more in line with 
;               Scheme.  Being a class would also allow me to better organize
;               things, but I don't know if Scheme has late binding, so it may
;               not even help.
;
;               It is pretty similar to the other two.  In fact, it operates
;               the same except there are no key bindings like the Python one.
;               The C# one lacked key bindings as well as I couldn't figure out
;               how to work them.
;

#lang racket/gui

(define DEF_TABLE_DIR "tables/")
(define DEF_SOURCE_DIR "testFiles/")

(define DEF_SCAN_TABLE 
  (string-append DEF_TABLE_DIR "DefaultScanTable.csv")
)
(define DEF_TOKEN_TABLE 
  (string-append DEF_TABLE_DIR "DefaultTokenTable.csv")
)
(define DEF_KEYWORD_TABLE 
  (string-append DEF_TABLE_DIR "DefaultKeywordTable.csv")
 )
(define DEF_SOURCE_FILE 
  (string-append DEF_SOURCE_DIR "DefaultTestFile.c")
)

; Should I want to modifiy what files are allowed, easy to do so
(define DEF_TABLE_TYPES '(("CSV Files" "*.csv") ("All Files" "*")))
(define DEF_SOURCE_TYPES '(("All Files" "*")))

; brief: Creates the elements and runs the GUI, should ideally be broken into
;        several smaller functions like with my Python version
; param: lex: lexical-analyzer%, the lexical analyzer to work with
(define (run-gui lex)
  (begin

    ; root, main window
    (define root 
      (new frame% 
        [label "Lexical Analyzer (Scheme Ver.)"] 
        [style '(no-resize-border)]
      )
    )
    
    ; Sets the window icon, couldn't get .ico to work and used .png instead
    (send root set-icon 
      (make-object bitmap% "icon/A Pumpkin For All Seasons Clear.png" 
        'png/alpha
      )
    )

    ; Placement of elements is a bit tricky, have to place things in 
    ; containers to control their location
    (define root-container 
      (new horizontal-pane% [parent root] [alignment '(left center)])
    )



    ; Contains the output label and the output text box
    (define left-container 
      (new vertical-pane% [parent root-container] [alignment '(center top)])
    )

    ; Output window
    (define output-label-container 
      (new pane% [parent left-container] [alignment '(center bottom)])
    )
    (new message% 
      [parent output-label-container] 
      [label "Output"] 
      [font (make-object font% 10 'default)]
    )

    (define output-text-container 
      (new pane% 
        [parent left-container] 
        [alignment '(center top)] 
        [vert-margin 5] 
        [horiz-margin 5]
      )
    )
    (define output-text 
      (new text-field% 
        [label #f]
        [parent output-text-container]
        [style '(multiple vertical-label)]
        [font (make-object font% 10 'modern)]
        [min-width 360]
        [min-height 480]
      )
    )
    (send (send output-text get-editor) insert 
      (string-append "~ " (~a (file-name-from-path DEF_SOURCE_FILE)) " ~\n")
    )
    (send (send output-text get-editor) lock #t)



    ; For containing the text boxes and buttons
    (define right-container 
      (new vertical-pane% 
        [parent root-container] 
        [alignment '(center top)] 
        [vert-margin 5] 
        [horiz-margin 5] 
        [spacing 5]
      )
    )

    (define scan-table-container 
      (new horizontal-pane% 
        [parent right-container] 
        [alignment '(center bottom)]
        [vert-margin 5] 
        [horiz-margin 5] 
        [spacing 5]
      )
    )
    (define scan-table-text 
      (new text-field% 
        [label "Scan Table"]
        [parent scan-table-container]
        [init-value (~a (file-name-from-path DEF_SCAN_TABLE))]
        [style '(single vertical-label)]
        [font (make-object font% 10 'default)]
        [min-width 300]
      )
    )
    (send (send scan-table-text get-editor) lock #t)

    (define token-table-container 
      (new horizontal-pane% 
        [parent right-container] 
        [alignment '(center bottom)] 
        [vert-margin 5] 
        [horiz-margin 5] 
        [spacing 5]
      )
    )
    (define token-table-text 
      (new text-field% 
        [label "Token Table"]
        [parent token-table-container]
        [init-value (~a (file-name-from-path DEF_TOKEN_TABLE))]
        [style '(single vertical-label)]
        [font (make-object font% 10 'default)]
        [min-width 300]
      )
    )
    (send (send token-table-text get-editor) lock #t)

    (define keyword-table-container 
      (new horizontal-pane% 
        [parent right-container] 
        [alignment '(center bottom)] 
        [vert-margin 5] 
        [horiz-margin 5] 
        [spacing 5]
      )
    )
    (define keyword-table-text 
      (new text-field% 
        [label "Keyword Table"]
        [parent keyword-table-container]
        [init-value (~a (file-name-from-path DEF_KEYWORD_TABLE))]
        [style '(single vertical-label)]
        [font (make-object font% 10 'default)]
        [min-width 300]
      )
    )
    (send (send keyword-table-text get-editor) lock #t)

    (define source-file-container 
      (new horizontal-pane% 
        [parent right-container] 
        [alignment '(center bottom)] 
        [vert-margin 5] 
        [horiz-margin 5] 
        [spacing 5]
      )
    )
    (define source-file-text 
      (new text-field% 
        [label "Source File"]
        [parent source-file-container]
        [init-value (~a (file-name-from-path DEF_SOURCE_FILE))]
        [style '(single vertical-label)]
        [font (make-object font% 10 'default)]
        [min-width 300]
      )
    )
    (send (send source-file-text get-editor) lock #t)



    ; Due to late binding in the other langauges, I was able to seperate the 
    ; functions from the GUI elements, but I can't here and instead have to 
    ; have them sandwiched between the text box code and the button code
    
    ; brief: Displays an error message to the user when the file couldn't be
    ;        read in
    ; param: file-name: string, the name of the file or file path
    ; param: message: string, the error message to show
    (define (error-user-file-error file-name message)
      (message-box "Error Opening File!"
        (string-append "\"" file-name "\" "
          "could not be opened due to an error.\n\n" message
        )
        root '(ok stop)
      )
    )



    ; brief: Displays an warning message that EOF was hit and there are no
    ;        more tokents to display
    (define (warn-user-eof-hit)
      (message-box "EOF Hit!"
        "End-of-file has been reached!\nNo more tokens to read!" root
      )
    )



    ; brief: Displays an warning message to let the user choose to restart
    ;        scanning or not
    ; return: bool, true if "OK", false if "Cancel"
    (define (warn-user-file-open)
      (if (send lex eof?)
        #t
        (equal? 'ok 
          (message-box "Restart Scanning?" 
            (string-append "Opening a new file will restart scanning.  Do "
              "you want to continue?"
            )
            root '(ok-cancel caution)
          )
        )
      )
    )



    ; brief: Opens a file dialog and lets the user save the file, shows an 
    ;        error message if the file could not be saved
    (define (save-output-text)
      (let (
        (file-name 
          (put-file "Save Output" root "./" #f #f null '(("All Files" "*")))
        ))
        
        ; file-name is false if user doesn't choose a file
        (when file-name
          (with-handlers
            ([exn:fail?
              (lambda (exn)
                (message-box "Error Saving File!"   
                  (string-append "\"" file-name "\" "
                    "could not be saved due to an error.\n\n" 
                    (exn-message exn)
                  )
                  root '(ok stop)
                )
              )
            ])
            (call-with-output-file file-name
              (lambda (out)
                (display (send output-text get-value) out)
              )
              #:exists 'replace
            )
          )
        )
      )
    )



    ; brief: Opens a file dialog and lets the user choose a table, passes
    ;        file name to lex to read, shows error messes if reading fails
    (define (open-scan-table)
        
      ; Ensure user wants to restart scanning, don't do anything if not
      (when (warn-user-file-open)
        (let (
          (file-name 
            (get-file 
              "Choose a Scan Table" root DEF_TABLE_DIR #f #f null 
              DEF_TABLE_TYPES
            )
          ))
          
          ; Like above file-name is false if user doesn't choose a file
          (when file-name
            (when (with-handlers 
              ([exn:fail? 
                (lambda (exn)
                
                  ; Last statement is #f, so that is what the begin returns
                  (begin
                    (error-user-file-error file-name (exn-message exn))
                    #f
                  )
                )
              ])
              (send lex read-scan-table file-name)
              
              ; Last thing to execute is true, so it returns true if the 
              ; reading doesn't error
              #t)
              
              (begin
                (send (send scan-table-text get-editor) lock #f)
                (send scan-table-text set-value 
                
                  ; Need to convert from path object to string
                  (~a (file-name-from-path file-name))
                )
                (send (send scan-table-text get-editor) lock #t)
              )
            )
          )
        )
      )
    )



    ; brief: Opens a file dialog and lets the user choose a table, passes
    ;        file name to lex to read, shows error messes if reading fails
    (define (open-token-table)
        
      ; Ensure user wants to restart scanning, don't do anything if not
      (when (warn-user-file-open)
        (let (
          (file-name 
            (get-file 
              "Choose a Token Table" root DEF_TABLE_DIR #f #f null 
              DEF_TABLE_TYPES
            )
          ))
          
          ; file-name is false if user doesn't choose a file
          (when file-name
            (when (with-handlers 
              ([exn:fail? 
                (lambda (exn)
                
                  ; Last statement is #f, so that is what the begin returns
                  (begin
                    (error-user-file-error file-name (exn-message exn))
                    #f
                  )
                )
              ])
              (send lex read-token-table file-name) #t)
              
              (begin
                (send (send token-table-text get-editor) lock #f)
                (send token-table-text set-value 
                  (~a (file-name-from-path file-name))
                )
                (send (send token-table-text get-editor) lock #t)
              )
            )
          )
        )
      )
    )



    ; brief: Opens a file dialog and lets the user choose a table, passes
    ;        file name to lex to read, shows error messes if reading fails
    (define (open-keyword-table)
        
      ; Ensure user wants to restart scanning, don't do anything if not
      (when (warn-user-file-open)
        (let (
          (file-name 
            (get-file 
              "Choose a Keyword Table" root DEF_TABLE_DIR #f #f null 
              DEF_TABLE_TYPES
            )
          ))
          
          ; file-name is false if user doesn't choose a file
          (when file-name
            (when (with-handlers 
              ([exn:fail? 
                (lambda (exn)
                
                  ; Last statement is #f, so that is what the begin returns
                  (begin
                    (error-user-file-error file-name (exn-message exn))
                    #f
                  )
                )
              ])
              (send lex read-keyword-table  file-name) #t)
              
              (begin
                (send (send keyword-table-text get-editor) lock #f)
                (send keyword-table-text set-value 
                  (~a (file-name-from-path file-name))
                )
                (send (send keyword-table-text get-editor) lock #t)
              )
            )
          )
        )
      )
    )



    ; brief: Opens a file dialog and lets the user choose a table, passes
    ;        file name to lex to read, shows error messes if reading fails
    (define (open-source-file)
        
      ; Ensure user wants to restart scanning, don't do anything if not
      (when (warn-user-file-open)
        (let (
          (file-name 
            (get-file 
              "Choose a Source File" root DEF_SOURCE_DIR #f #f null 
              DEF_SOURCE_TYPES
            )
          ))
          
          ; file-name is false if user doesn't choose a file
          (when file-name
            (when (with-handlers 
              ([exn:fail? 
                (lambda (exn)
                
                  ; Last statement is #f, so that is what the begin returns
                  (begin
                    (error-user-file-error file-name (exn-message exn))
                    #f
                  )
                )
              ])
              (send lex read-source-file file-name) #t)
              
              (begin
                (send (send source-file-text get-editor) lock #f)
                (send source-file-text set-value 
                  (~a (file-name-from-path file-name))
                )
                (send (send source-file-text get-editor) lock #t)
                
                ; Ideally, I should create a "with-unlock" macro for this
                (send (send output-text get-editor) lock #f)
                (send (send output-text get-editor) move-position 'end) 
                (send (send output-text get-editor) insert 
                  (if (equal? (send output-text get-value) "")
                    (string-append "~ " (~a (file-name-from-path file-name))
                      " ~\n"
                    )
                    (string-append "\n~ " (~a (file-name-from-path file-name))
                      " ~\n"
                    )
                  )
                )
                (send (send output-text get-editor) lock #t)
              )
            )
          )
        )
      )
    )



    ; brief: Calls the lex's read token function, repeatedly calls until 
    ;        something other than whiteSpace or a comment is found
    (define (scan-manager (warn #t))
      (if (send lex eof?)
        (warn-user-eof-hit)
        
        (begin
          (send lex read-next-token)
          
          ; Loop until something other than whiteSpace or comment
          (letrec (
            (loop
              (lambda ()
                (when 
                  (and 
                    (or 
                      (equal? (get-field cur-token lex) "whiteSpace") 
                      (equal? (get-field cur-token lex) "comment")
                    ) 
                    (not (send lex eof?))
                  )
                  (begin
                    (send lex read-next-token)
                    (loop)
                  )
                )
              )
            )
          ) (loop))
          
          ; Same code as before, deal with edge case
          (if (and warn (equal? (get-field cur-token lex) "comment"))
            (warn-user-eof-hit)
            
            (unless (equal? (get-field cur-token lex) "comment")
              (begin
                (send (send output-text get-editor) lock #f)
                (send (send output-text get-editor) move-position 'end) 
                
                (if (get-field error-flag lex)
                  (send (send output-text get-editor) insert 
                    (string-append (get-field error-message lex) "\n")
                  )
                  (send (send output-text get-editor) insert 
                    (string-append "Token: " (~a (get-field cur-token lex) 
                      #:min-width 12 #:align 'left #:right-pad-string " ")
                      " Lexemme: " (get-field cur-lexemme lex) "\n"
                    )
                  )
                )
                
                (send (send output-text get-editor) lock #t)
              )
            )
          )       
        )
      )
    )

    ; brief: Calls the scan-manager repeatedly until EOF is hit
    (define (auto-scan-manager)
      (if (not (send lex eof?))
        (letrec (
          (loop
            (lambda ()
              (unless (send lex eof?)
                (begin
                  (scan-manager #f)
                  (loop)
                )
              )
            )
          )
        ) (loop))
        (warn-user-eof-hit)
      )
    )

    ; Create the menu, use let as these items won't be used elsewhere after
    ; their creation
    (letrec (
      (menu-bar (new menu-bar% [parent root]))
      (file-menu (new menu% [label "File"] [parent menu-bar]))
      (edit-menu (new menu% [label "Edit"] [parent menu-bar]))
      (scan-menu (new menu% [label "Scan"] [parent menu-bar]))
      (help-menu (new menu% [label "Help"] [parent menu-bar])))
      (begin
        (new menu-item% 
          [label "Open Scan Table ..."] 
          [parent file-menu] 
          [callback (lambda (t e) (open-scan-table))]
        )

        (new menu-item% 
          [label "Open Token Table ..."] 
          [parent file-menu] 
          [callback (lambda (t e) (open-token-table))]
        )

        (new menu-item% 
          [label "Open Keyword Table ..."] 
          [parent file-menu] 
          [callback (lambda (t e) (open-keyword-table))]
        )

        (new menu-item% 
          [label "Open Source File ..."] 
          [parent file-menu] 
          [callback (lambda (t e) (open-source-file))]
        )

        (new separator-menu-item% [parent file-menu])

        (new menu-item% 
          [label "Save Output ..."] 
          [parent file-menu] 
          [callback (lambda (t e) (save-output-text))]
        )

        (new separator-menu-item% [parent file-menu])

        (new menu-item% 
          [label "Exit"] 
          [parent file-menu] 
          [callback (lambda (t e) (exit))]
        )



        (new menu-item% 
          [label "Clear Output"] 
          [parent edit-menu] 
          [callback (lambda (t e) 
            (begin
              (send (send output-text get-editor) lock #f)
              (send (send output-text get-editor) erase)
              (send (send output-text get-editor) lock #t)
            ))
          ]
        )



        (new menu-item% 
          [label "Next Token"] 
          [parent scan-menu] 
          [callback (lambda (t e) (scan-manager))]
        )

        (new menu-item% 
          [label "Auto Scan"] 
          [parent scan-menu] 
          [callback (lambda (t e) (auto-scan-manager))]
        )

        (new menu-item% 
          [label "Restart Scanning"] 
          [parent scan-menu] 
          [callback (lambda (t e) (send lex reset-index))]
        )



        (new menu-item% 
          [label "About ..."] 
          [parent help-menu] 
          [callback (lambda (t e) 
            (message-box "README.txt!"     
              (string-append "To learn how to use this program and what it "
                "is, view the README.txt located at the root of this program!"
              )
              root
            )
          )]
        )

        (new menu-item% 
          [label "Copyright Info ..."]
          [parent help-menu] 
          [callback (lambda (t e) 
            (message-box "Copyright!"
              (string-append "Copyright (C) Brandon Mitchell, 2021, All "
                "Rights Reserved\nCSCI 305, Programming Languages, F21\n\n"
                "Don't steal!!!"
              )
              root
            )
          )]
        )
      )
    )

    ; Create the various buttons to go with the table text boxes
    (new button% 
      [label "Browse ..."] 
      [parent scan-table-container] 
      [callback (lambda (t e) (open-scan-table))]
    )
    (new button% 
      [label "Browse ..."] 
      [parent token-table-container] 
      [callback (lambda (t e) (open-token-table))]
    )
    (new button% 
      [label "Browse ..."] 
      [parent keyword-table-container] 
      [callback (lambda (t e) (open-keyword-table))]
    )
    (new button% 
      [label "Browse ..."] 
      [parent source-file-container] 
      [callback (lambda (t e) (open-source-file))]
    )

    ; Create scan controls, use a let to limit scope
    (let (
      (scan-control-container 
        (new horizontal-pane% 
          [parent right-container]
          [alignment '(left bottom)]
          [vert-margin 5]
          [horiz-margin 5]
          [spacing 30]
        )
       ))
       (begin
        (new message% 
          [parent scan-control-container]
          [label "Scan Controls"]
          [font (make-object font% 10 'default)]
        )
        (new button% 
          [parent scan-control-container]
          [label "Next Token"]
          [callback (lambda (t e) (scan-manager))]
        )
        (new button% 
          [parent scan-control-container]
          [label "Auto Scan"]
          [callback (lambda (t e) (auto-scan-manager))]
        )
      )
    )

    ; Just for a little bit of extra space below the buttons
    (new pane% [parent right-container])
    
    ; Runs the frame
    (send root show #t)
  )
)

; I guess this is frowned upon, could get around by using a class with the 
; defaults as static memebers like with the previous two versions, static 
; variables are possible, but I don't think I can access them like normal 
; static class variables and methods
(provide (all-defined-out))