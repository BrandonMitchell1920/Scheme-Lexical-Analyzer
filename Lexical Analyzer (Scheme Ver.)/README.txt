Copyright (C) Brandon Mitchell, 2021, All Rights Reserved
CSCI 305, Programming Languages, F21

To Run:

    You can open "main.rkt" in DrRacket and then run from there.  I prefer 
    using Notepad++ (though it refused to color my code so I didn't get nice 
    syntax coloring), so I used that and ran from the commandline.  Racket was
    not added to my path when I installed it, so I added it manually.  If it is
    on your path, then just run
    
        racket main.rkt
        
    If it is not on your path, then
        
        "C:/Program Files/Racket/racket" main.rkt
        
    will work.  If you installed it somewhere else, then you are on your own.
    
    There is also a compiler with Racket.  As such, you can run the program by
    clicking the EXE in the directory.  If it doesn't work, you can recompile 
    it with (assuming Racket is on your path)
    
        raco exe --gui -o "Lexical Analyzer" main.rkt
        
    It may take a half a mintue or so, so be patient.  raco is the name of the 
    compiler, and exe tells it to create an executable.  Doing "raco doc" 
    brings up the Racket docs in the browser, which is useful if you are 
    offline like I was when writing most of this.  --gui prevents an extra 
    command line window from being created when ran, and -o just names the 
    exectuable.  There are several other options, most not useful to me.  I 
    tried to get it to set the icon of the exectuable, but that command never 
    worked, and I could find other people online saying it didn't work but no
    solution.  Setting the window icon with my .ico didn't work and I had to 
    use a .png.  Perhaps Racket is picky about the specific size of the .ico?

To Use:
    
    Default files should be loaded automatically, if they are missing, the 
    program will not run.  This is because I didn't want to deal with a 
    situation where one or more tables are missing, so I just don't allow that 
    to ever happen.

    Several options are available from the menu bar that aren't available from 
    the buttons.  Everything you need is available from the GUI.  The various 
    browse buttons open a file dialog for the tables and source file.  Note 
    that the tables must be in the proper format or they may not be read in 
    properly or the program may exhibit odd behavior.  "Next Token" reads a 
    single token. "Auto Scan" reads the whole file by getting the next token 
    until EOF is hit.  whiteSpace and comments are returned by the lexical 
    analyzer, but the GUI ignores them.

What is this?:

    This is a lexical analyzer written in Scheme, specifically the Racket 
    dialect.  Its purpose is to scan a source code file and identify 
    collections of characters and return what token category they are.  These 
    tokens are then fed to a parser.

    To do this, the analyzer uses a couple of tables (stored as CSV files).  
    The scan table consists of states and the transistions between those 
    states.  The first row consists of all the legal characters in the 
    langauge.  You always start at state 1.  If you get a '{', then you find 
    the instersection of your current state and the column of '{' and then move 
    to that state.  This repeats until a '-' is found in the table.

    We then look into the token table using our current state as an index.  If 
    the token is prepended with '-', then it is an error state, and the error 
    flag and message are set.

    If it is a valid token, we then look up the lexemme in the keyword table (a 
    set or map in code) to see if it is a keyword.  If so, the token category 
    is changed to be the same as the lexemme.  For example, "int" is an 
    "indentifier", but since it is also a keyword, we change the token category 
    to "int".

Updates & Misc.:

    For the most part, it is nearly the exact same as the C# one.  I am not too
    happy with the GUI code.  It works fine, but I just don't care for how it 
    is organized.  C# had the nice partial class stuff to keep things 
    organized, and both it and Python has static class members and late 
    binding.  Scheme has static variables, but I don't know how to access from
    the class and not an instance of the class.  I also don't know if it has 
    late binding, so rewriting to a class may not even help with any of the 
    organizational parts.  
    
    C# with WinForms is the best for writing GUIs as it does most of the heavy 
    lifting for you, though the experience of doing GUIs in other languages is 
    certaintely a good experience.  Taking a program written in a procedural/OO 
    langauge and converting it to a functional langauge was also a good 
    experience, though I did use Scheme's procedural, object-oriented, and 
    iterative capabilities.  I mainly did the OO and iterative parts just to 
    see how they work in Scheme.  Recursion, from what I read, is faster than 
    iteration, but setting up the iteration in a specific way can make it as 
    fast as recursion.  I don't think I set it up correctly as it requires a
    special keyword.  Still, doing this project let me experience a lot more of
    Scheme than I otherwise would have.  It is not that scary of a language as
    it may have first appeared to be.