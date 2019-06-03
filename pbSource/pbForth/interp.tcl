# -----------------------------------------------------------------------------
# interp.tcl - Core Forth words for the interpreter
#
# Revision History
#
# R.Hempel 06Jul2002 - Fix MARKER so it doesn't leave junk on the stack
#                    - Bump version number to 2.1.5
# R.Hempel 14May2002 - Bump version number to 2.1.4
#                    - Marker now saves and restores Head too
# R.Hempel 10May2002 - Bump version number to 2.1.3
# R.Hempel 20Apr2002 - Bump version number to 2.1.2
#                    - MARKER now saves 'UserIdle and 'UserISR
# R.Hempel 12Apr2002 - Bump version number to 2.1.1
# R.Hempel 08Apr2002 - Fix bug in FIND
# R.Hempel 22Mar2002 - Clean up comments for release
# -----------------------------------------------------------------------------
# This work is based on Chris Jakeman's MAF and PAF Forth systems. Their
# goal was to build a minimal ANS Forth that could be built by a standard
# Forth system and made no assumptions about the underlying achitecture.
#
# The original source may be found at:
#
# ftp://ftp.taygeta.com/pub/Forth/Applications/ANS/maf1v02.zip
# ftp://ftp.taygeta.com/pub/Forth/Applications/ANS/paf0v04.zip
# -----------------------------------------------------------------------------
pbAsm::Variable {AbortString} AbortString 0 {}
pbAsm::Cell {}          0
# -----------------------------------------------------------------------------
# : >SNumber?                          \ Converts string to a single signed
#   ( c-addr Chars -- u SuccessFlag )  \ number.  Support for Interpret
#  OVER C@ [CHAR] - = >R
#  0 US>D 2SWAP                        \ Bury a double version of the result
#  R@ IF
#    1- SWAP CHAR+ SWAP                \ Adjust for '-' sign.
#  THEN
#  DUP IF                              \ Must be >0 digits. '-' alone is not
#                                      \ sufficient!
#    >NUMBER IF                        \ Unconverted char found.
#      2DROP  R> DROP  FALSE
#    ELSE
#      DROP UD>S
#      R> IF
#        NEGATE
#      THEN
#      TRUE
#    THEN
#  ELSE
#    2DROP  R> DROP  FALSE
#  THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {>SNumber?} ToSNumberQ 0 {}

pbAsm::Cell      {} Over
pbAsm::Cell      {} CharFetch
pbAsm::Literal   {} '-'
pbAsm::Cell      {} Equal
pbAsm::Cell      {} ToR
pbAsm::Literal   {} 0
pbAsm::Cell      {} UStoD
pbAsm::Cell      {} TwoSwap
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TOSNUM1
pbAsm::Cell      {} OneMinus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} Swap
pbAsm::Cell TOSNUM1 Dup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TOSNUM2
pbAsm::Cell      {} ToNumber
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TOSNUM4
pbAsm::Cell      {} TwoDrop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Drop
pbAsm::Cell      {} False
pbAsm::Cell      {} Branch
pbAsm::Cell      {} TOSNUM5
pbAsm::Cell TOSNUM4 Drop
pbAsm::Cell      {} UDtoS
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TOSNUM6
pbAsm::Cell      {} Negate
pbAsm::Cell TOSNUM6 True
pbAsm::Cell TOSNUM5 Branch
pbAsm::Cell      {} TOSNUM3
pbAsm::Cell TOSNUM2 TwoDrop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Drop
pbAsm::Cell      {} False
pbAsm::Cell TOSNUM3 Exit
# --------------------------------------------------------------------------- 
# : InterpretName                     \ Support for Interpret
#   ( xt Immediate -- i*x )              
#   -1 =  STATE @  AND IF              \ not Immediate = -1
#     COMPILE,
#   ELSE                               \ Immediate or not compiling
#     DUP IsCompileOnly? STATE @ 0= AND IF
#       -14 THROW
#     ELSE
#       EXECUTE
#     THEN
#   THEN ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {InterpretName} InterpretName 0 {}
pbAsm::Literal {}       -1
pbAsm::Cell {}          Equal
pbAsm::Cell {}          State
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          And
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          ITRPNA1
pbAsm::Cell {}            CompileComma
pbAsm::Cell {}          Branch
pbAsm::Cell {}          ITRPNA2
pbAsm::Cell {ITRPNA1}     Dup
pbAsm::Cell {}            IsCompileOnlyQ
pbAsm::Cell {}            State
pbAsm::Cell {}            Fetch
pbAsm::Cell {}            ZeroEqual
pbAsm::Cell {}            And
pbAsm::Cell {}            ZBranch
pbAsm::Cell {}            ITRPNA3
pbAsm::Literal {}           -14
pbAsm::Cell {}              Throw
pbAsm::Cell {}            Branch
pbAsm::Cell {}            ITRPNA2
pbAsm::Cell {ITRPNA3}       Execute
pbAsm::Cell {ITRPNA2}   Exit
# --------------------------------------------------------------------------- 
# : InterpretNumber                   \ Support for Interpret
#   ( &String Chars -- i*x )
#   2DUP >SNumber? IF
#     >R 2DROP R> STATE @ IF  POSTPONE <Literal>  COMPILE,  THEN
#   ELSE
#     -13 THROW                  \ MAF+
#   THEN ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {InterpretNumber} InterpretNumber 0 {}
pbAsm::Cell {}          TwoDup
pbAsm::Cell {}          ToSNumberQ
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          ITRPNU1
pbAsm::Cell {}            ToR
pbAsm::Cell {}            TwoDrop
pbAsm::Cell {}            RFrom
pbAsm::Cell {}            State
pbAsm::Cell {}            Fetch
pbAsm::Cell {}            ZBranch
pbAsm::Cell {}            ITRPNU3
pbAsm::Cell {}              doCOMPILE
pbAsm::Cell {}              doLIT
pbAsm::Cell {}              CompileComma
pbAsm::Cell {ITRPNU3}   Branch
pbAsm::Cell {}          ITRPNU2
pbAsm::Literal {ITRPNU1}  -13
pbAsm::Cell {}            Throw
pbAsm::Cell {ITRPNU2}   Exit
# ---------------------------------------------------------------------------
# : Interpret                          \ Support for EVALUATE and QUIT
#   BEGIN
#     DEPTH 0< IF
#       -4 THROW
#     THEN
#     BL SkipParse
#   ?DUP WHILE
#     ParseFind IF
#       InterpretName
#     ELSE
#       InterpretNumber
#     THEN
#   REPEAT
#   DROP ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {Interpret} Interpret 0 {}

pbAsm::Cell {INTRP1}    Depth
pbAsm::Cell {}          ZeroLess
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          INTRP5
pbAsm::Literal {}       -4
pbAsm::Cell {}          Throw
pbAsm::Cell {INTRP5}      Blank
pbAsm::Cell {}            SkipParse
pbAsm::Cell {}            QuestionDup
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          INTRP2
pbAsm::Cell {}            ParseFind
pbAsm::Cell {}            ZBranch
pbAsm::Cell {}            INTRP3
pbAsm::Cell {}              InterpretName
pbAsm::Cell {}            Branch
pbAsm::Cell {}            INTRP4
pbAsm::Cell {INTRP3}        InterpretNumber
pbAsm::Cell {INTRP4}    Branch
pbAsm::Cell {}          INTRP1
pbAsm::Cell {INTRP2}    Drop
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# Design Note: EVALUATE and Handling Exceptions
# The following implementation for EVALUATE is simpler than MAF as it uses
# CATCH to save and restore the input stream.
# ---------------------------------------------------------------------------
# : CatchEvaluate
#   ( i*x c-addr u -- j*x )
#   -1 TO SOURCE-ID  0 >IN !  #TIB !  &Source !
#   Interpret ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {CatchEvaluate} CatchEvaluate 0 {}

pbAsm::Literal {}       -1
pbAsm::Literal {}       SRCID
pbAsm::Cell {}          Store
pbAsm::Literal {}       0
pbAsm::Cell {}          ToIn
pbAsm::Cell {}          Store
pbAsm::Cell {}          NumberTib
pbAsm::Cell {}          Store
pbAsm::Cell {}          AddrSource
pbAsm::Cell {}          Store
pbAsm::Cell {}          Interpret
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : EVALUATE
#   ( i*x c-addr u -- j*x )
#   ['] CatchEvaluate CATCH ?DUP IF THROW THEN       \ MAF*
# ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {EVALUATE} Evaluate 0 CORE

pbAsm::Literal {}       CatchEvaluate
pbAsm::Cell {}          Catch
pbAsm::Cell {}          QuestionDup
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          EVAL1
pbAsm::Cell {}            Throw
pbAsm::Cell {EVAL1}     Exit
# ---------------------------------------------------------------------------
# Design Note: Using WORD and FIND
# WORD and FIND were defined in Forth-83 to work together.  They are present
# unchanged in ANS, but 5 restrictions imposed by WORD are recorded.  In
# particular, ANS encourages a move away from counted strings to parameter
# pairs giving start address and length.
#
# PAF provides appropriate alternatives to WORD and FIND which avoid
# counted strings - SkipParse and ParseFind.  For an example of their use,
# see Interpret above.
# ---------------------------------------------------------------------------
# : WORD
#   ( Char "<chars>ccc<char>" -- &CountedString )
#   SkipParse
#   [ E' /COUNTED-STRING ] LITERAL OVER U< IF        \ MAF+
#     -18 THROW
#   THEN
#   >R
#   HERE CHAR+  R@ CHARS
#   2DUP + BL SWAP C!                  \ Append a space character.
#   MOVE                               \ Move string to HERE.
#   HERE R> OVER C! ;                  \ Store the character count.
# ---------------------------------------------------------------------------
pbAsm::Secondary {WORD} Word 0 CORE

pbAsm::Cell {}          SkipParse
pbAsm::Literal {}        255
pbAsm::Cell {}          Over
pbAsm::Cell {}          ULess
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          WORD1
pbAsm::Literal {}         -18
pbAsm::Cell {}            Throw
pbAsm::Cell {WORD1}     ToR
pbAsm::Cell {}          Here
pbAsm::Cell {}          CharPlus
pbAsm::Cell {}          RFetch
pbAsm::Cell {}          Chars
pbAsm::Cell {}          TwoDup
pbAsm::Cell {}          Plus
pbAsm::Cell {}          Blank
pbAsm::Cell {}          Swap
pbAsm::Cell {}          CharStore
pbAsm::Cell {}          Move
pbAsm::Cell {}          Here
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Over
pbAsm::Cell {}          CharStore
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : FIND                               \ Handles zero-length string correctly.
#   ( c-addr -- c-addr 0 ! xt 1 ! xt -1 )
#   DUP COUNT ParseFind IF             \ Uses ParseFind which needs start
#     ROT DROP                         \ address and count instead of a
#   ELSE                               \ counted string.  This change is in
#     2DROP FALSE                      \ the spirit of ANS.
#   THEN ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {FIND} Find 0 CORE

pbAsm::Cell {}          Dup
pbAsm::Cell {}          Count
pbAsm::Cell {}          ParseFind
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          FIND1
pbAsm::Cell {}            Rot
pbAsm::Cell {}            Drop
pbAsm::Cell {}          Branch
pbAsm::Cell {}          FIND2
pbAsm::Cell {FIND1}       TwoDrop
pbAsm::Cell {}            False
pbAsm::Cell {FIND2}     Exit
# ---------------------------------------------------------------------------
# QUIT
# ANS provides CATCH to intercept all diversions from the normal
# flow-of-control.  Since QUIT also diverts from the normal flow-of-control,
# ANS allows QUIT to be defined as -56 THROW so that CATCH can intercept it.
# In PAF, we provide another word OInterpreter to carry out the function of
# the outer interpreter previously supplied by QUIT.
# ---------------------------------------------------------------------------
# : QUIT
#   ( -- )
#   -56 THROW ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {QUIT} Quit 0 CORE

pbAsm::Literal  {}      -56
pbAsm::Cell {}          Throw
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : EmptyStack                         \ Support for outer interpreter
#   ( -- )
#   BEGIN
#   DEPTH WHILE
#     DROP
#   REPEAT ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {EmptyStack} EmptyStack 0 {}

pbAsm::Cell {EMTSTK1}   Depth
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          EMTSTK2
pbAsm::Cell {}            Drop
pbAsm::Cell {}          Branch
pbAsm::Cell {}          EMTSTK1
pbAsm::Cell {EMTSTK2}   Exit
# ---------------------------------------------------------------------------
# : LocateError
#   ( -- )
#   ."  at"
#   CR ErrorSource 2@ TYPE
#   CR Error>In @ 1- SPACES [CHAR] ^ EMIT ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {LocateError} LocateError 0 {}

pbAsm::Cell {}          doSQUOTE
pbAsm::CString {}       { at}
pbAsm::Cell {}          Type
pbAsm::Cell {}          CR
pbAsm::Cell {}          ErrorSource
pbAsm::Cell {}          TwoFetch
pbAsm::Cell {}          Type
pbAsm::Cell {}          CR
pbAsm::Cell {}          ErrorToIn
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          OneMinus
pbAsm::Cell {}          Spaces
pbAsm::Literal {}       0x5E     {^}
pbAsm::Cell {}          Emit
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : ReportSourceError
#   ( ErrorValue -- )
#   DUP -13 = IF ." undefined name (missing ;?)"          DROP EXIT THEN
#   DUP -14 = IF ." interpreting a compile-only word"     DROP EXIT THEN
#   DUP -15 = IF ." invalid FORGET"                       DROP EXIT THEN
#   DUP -16 = IF ." no name given"                        DROP EXIT THEN
#   DUP -19 = IF ." definition name too long (>31 chars)" DROP EXIT THEN
#   DUP -22 = IF ." control structure mismatch"           DROP EXIT THEN
#   DUP -25 = IF ." return stack imbalance"               DROP EXIT THEN
#   DUP -26 = IF ." loop parameters unavailable"          DROP EXIT THEN
#   DUP -27 = IF ." invalid recursion after DOES>"        DROP EXIT THEN
#   DUP -29 = IF ." compiler nesting"                     DROP EXIT THEN
#                ." undocumented error " . ;
#
# To save space, unimplemented error conditions are commented out...
# ---------------------------------------------------------------------------
pbAsm::Secondary {ReportSourceError} ReportSourceError 0 {}

pbAsm::Cell {RSE0} Dup
pbAsm::Literal {}  -13
pbAsm::Cell {}     Equal
pbAsm::Cell {}     ZBranch
pbAsm::Cell {}     RSE1
pbAsm::Cell {}       doSQUOTE
pbAsm::CString {}    {undefined name (missing ;?)}
pbAsm::Cell {}       Type
pbAsm::Cell {}       Drop
pbAsm::Cell {}       Exit

pbAsm::Cell {RSE1} Dup
pbAsm::Literal {}  -14
pbAsm::Cell {}     Equal
pbAsm::Cell {}     ZBranch
pbAsm::Cell {}     RSE2
pbAsm::Cell {}       doSQUOTE
pbAsm::CString {}    {interpreting a compile-only word}
pbAsm::Cell {}       Type
pbAsm::Cell {}       Drop
pbAsm::Cell {}       Exit

# pbCell {RSE2}      Dup
# pbLiteral {}       -15
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RSE3
# pbCell {}            doSQUOTE
# pbCString {}         {invalid FORGET}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RSE3}      Dup
# pbLiteral {}       -16
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RSE4
# pbCell {}            doSQUOTE
# pbCString {}         {no name given}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RSE4}      Dup
# pbLiteral {}       -19
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RSE5
# pbCell {}            doSQUOTE
# pbCString {}         {definition name too long (>31 chars)}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit

pbAsm::Cell {RSE2} Dup
pbAsm::Literal {}  -22
pbAsm::Cell {}     Equal
pbAsm::Cell {}     ZBranch
pbAsm::Cell {}     RSE6
pbAsm::Cell {}       doSQUOTE
pbAsm::CString {}    {control structure mismatch}
pbAsm::Cell {}       Type
pbAsm::Cell {}       Drop
pbAsm::Cell {}       Exit

# pbCell {RSE6}      Dup
# pbLiteral {}       -25
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RSE7
# pbCell {}            doSQUOTE
# pbCString {}         {return stack imbalance}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit

pbAsm::Cell {RSE6} Dup
pbAsm::Literal {}  -26
pbAsm::Cell {}     Equal
pbAsm::Cell {}     ZBranch
pbAsm::Cell {}     RSE8
pbAsm::Cell {}       doSQUOTE
pbAsm::CString {}    {loop parameters unavailable}
pbAsm::Cell {}       Type
pbAsm::Cell {}       Drop
pbAsm::Cell {}       Exit

pbAsm::Cell {RSE8} Dup
pbAsm::Literal {}  -27
pbAsm::Cell {}     Equal
pbAsm::Cell {}     ZBranch
pbAsm::Cell {}     RSE9
pbAsm::Cell {}       doSQUOTE
pbAsm::CString {}    {invalid recursion after DOES>}
pbAsm::Cell {}       Type
pbAsm::Cell {}       Drop
pbAsm::Cell {}       Exit

pbAsm::Cell {RSE9} Dup
pbAsm::Literal {}  -29
pbAsm::Cell {}     Equal
pbAsm::Cell {}     ZBranch
pbAsm::Cell {}     RSE10
pbAsm::Cell {}       doSQUOTE
pbAsm::CString {}    {compiler nesting}
pbAsm::Cell {}       Type
pbAsm::Cell {}       Drop
pbAsm::Cell {}       Exit

pbAsm::Cell {RSE10} doSQUOTE
pbAsm::CString {}   {undocumented error}
pbAsm::Cell {}        Type
pbAsm::Cell {}      Dot

pbAsm::Cell {}     Exit
# ---------------------------------------------------------------------------
# : ReportError
#   ( ErrorValue -- )
# \ Start with those that have specified messages:
#   DUP  -1 = IF EmptyStack                     EXIT THEN
#   DUP  -2 = IF EmptyStack AbortString 2@ TYPE EXIT THEN
# \ DUP -56 = IF DROP  'OInterpreter @ EXECUTE  EXIT THEN
# \ Then the run-time exceptions:
#   CR ." ABORTED by "
#   DUP  -3 = IF ." data stack overflow"         DROP EXIT THEN
#   DUP  -4 = IF ." data stack underflow"        DROP EXIT THEN
#   DUP  -5 = IF ." return stack overflow"       DROP EXIT THEN
#   DUP  -6 = IF ." return stack underflow"      DROP EXIT THEN
#   DUP  -8 = IF ." dictionary overflow"         DROP EXIT THEN
#   DUP  -9 = IF ." invalid memory address"      DROP EXIT THEN
#   DUP -10 = IF ." division by 0"               DROP EXIT THEN
#   DUP -11 = IF ." result out of range"         DROP EXIT THEN
#   DUP -17 = IF ." pictured numeric output string overflow" DROP EXIT THEN
#   DUP -18 = IF ." parsed string overflow"      DROP EXIT THEN
#   DUP -20 = IF ." write to an invalid address" DROP EXIT THEN
#   DUP -23 = IF ." address alignment exception" DROP EXIT THEN
#   DUP -31 = IF ." >BODY or DOES> used on non-CREATEd definition" DROP EXIT THEN
# \ Finally the compile-time ones, where we display the last line of source:
#   ReportSourceError LocateError ;
#
# To save space, unimplemented error conditions are commented out...
# ---------------------------------------------------------------------------
pbAsm::Secondary {ReportError} ReportError 0 {}

pbAsm::Cell {RE0} Dup
pbAsm::Literal {} -1
pbAsm::Cell {}    Equal
pbAsm::Cell {}    ZBranch
pbAsm::Cell {}    RE1
pbAsm::Cell {}      EmptyStack
pbAsm::Cell {}      Exit

pbAsm::Cell {RE1} Dup
pbAsm::Literal {} -2
pbAsm::Cell {}    Equal
pbAsm::Cell {}    ZBranch
pbAsm::Cell {}    RE3
pbAsm::Cell {}      EmptyStack
pbAsm::Cell {}      AbortString
pbAsm::Cell {}      TwoFetch
pbAsm::Cell {}      Type
pbAsm::Cell {}      Exit

# pbCell {RE2}      Dup
# pbLiteral {}       -56
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE3
# pbCell {}            Drop
# pbCell {}            TickOInterpreter
# pbCell {}            Fetch
# pbCell {}            Execute
# pbCell {}            Exit

pbAsm::Cell {RE3} CR
pbAsm::Cell {}    doSQUOTE
pbAsm::CString {} {ABORTED by }
pbAsm::Cell {}      Type

# pbCell {}         Dup
# pbLiteral {}      -3
# pbCell {}         Equal
# pbCell {}         ZBranch
# pbCell {}         RE4
# pbCell {}           doSQUOTE
# pbCString {}        { data stack overflow}
# pbCell {}           Type
# pbCell {}           Drop
# pbCell {}           Exit

pbAsm::Cell {RE4} Dup
pbAsm::Literal {}  -4
pbAsm::Cell {}     Equal
pbAsm::Cell {}     ZBranch
pbAsm::Cell {}     RE5
pbAsm::Cell {}       doSQUOTE
pbAsm::CString {}    {data stack underflow}
pbAsm::Cell {}       Type
pbAsm::Cell {}       Drop
pbAsm::Cell {}       Exit

# pbCell {RE5}      Dup
# pbLiteral {}       -5
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE6
# pbCell {}            doSQUOTE
# pbCString {}         {return stack overflow}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE6}      Dup
# pbLiteral {}       -6
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE7
# pbCell {}            doSQUOTE
# pbCString {}         {return stack underflow}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE7}      Dup
# pbLiteral {}       -8
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE8
# pbCell {}            doSQUOTE
# pbCString {}         {dictionary overflow}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE8}      Dup
# pbLiteral {}       -9
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE9
# pbCell {}            doSQUOTE
# pbCString {}         {nvalid memory address}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE9}      Dup
# pbLiteral {}       -10
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE10
# pbCell {}            doSQUOTE
# pbCString {}         {division by 0}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE10}      Dup
# pbLiteral {}       -11
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE11
# pbCell {}            doSQUOTE
# pbCString {}         {result out of range}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE11}      Dup
# pbLiteral {}       -17
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE12
# pbCell {}            doSQUOTE
# pbCString {}         {pictured numeric output string overflow}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE12}      Dup
# pbLiteral {}       -18
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE13
# pbCell {}            doSQUOTE
# pbCString {}         {parsed string overflow}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE13}      Dup
# pbLiteral {}       -20
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE14
# pbCell {}            doSQUOTE
# pbCString {}         {write to an invalid address}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE14}      Dup
# pbLiteral {}       -23
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE15
# pbCell {}            doSQUOTE
# pbCString {}         {address alignment exception}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit
# 
# pbCell {RE15}      Dup
# pbLiteral {}       -31
# pbCell {}          Equal
# pbCell {}          ZBranch
# pbCell {}          RE16
# pbCell {}            doSQUOTE
# pbCString {}         {>BODY or DOES> used on non-CREATEd definition}
# pbCell {}            Type
# pbCell {}            Drop
# pbCell {}            Exit

pbAsm::Cell {RE5}  ReportSourceError
pbAsm::Cell {}     LocateError

pbAsm::Cell {}     Exit
# ---------------------------------------------------------------------------
#                                        \ NOTE: BYE expects the return stack
#                                        \ to hold the address of the next word
#                                        \ to execute.
# ---------------------------------------------------------------------------
# : BYE                                  \ Exit to the host system by
#   BEGIN RDepth 0> WHILE R> DROP REPEAT \ clearing the return stack.
#   CR ." Bye ..." ;                     \ From the Tools Extension word set.
# ---------------------------------------------------------------------------
pbAsm::Secondary {BYE} Bye 0 CORE  

pbAsm::Cell {BYE1}        RDepth
pbAsm::Cell {}            ZeroGreater
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          BYE2
pbAsm::Cell {}            RFrom
pbAsm::Cell {}            Drop
pbAsm::Cell {}          Branch
pbAsm::Cell {}          BYE1
pbAsm::Cell {BYE2}      CR
pbAsm::Cell {}          doSQUOTE
pbAsm::CString {}       {Bye ...}
pbAsm::Cell {}            Type
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
#                                      \ Support for QUIT
# : Prompt                             \ QUIT requires a prompt not specified
#   ."  OK " .S ;                      \ by ANS.
# ---------------------------------------------------------------------------
pbAsm::Secondary {Prompt} Prompt 0 {}

pbAsm::Cell {}          doSQUOTE
pbAsm::CString {}       { OK }
pbAsm::Cell {}          Type
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : OInterpreter
#   BEGIN                              \ This method clears the Return Stack
#     RDepth 0>                        \ but keeps the implementation
#   WHILE                              \ private and portable.
#     R> DROP
#   REPEAT
#   0 TO SOURCE-ID                     \ Prepare to read from user input device
#   POSTPONE [                         \ Enter interpretation state
#   0 Incomplete !                     \ Reset to pass checks in Header and
#                                      \ COMPILE,
#   0 ErrorSource !                    \ Prepare to save source of next error.
#   BEGIN
#   REFILL WHILE
#     ['] Interpret CATCH ?DUP IF
#       DUP -56 = IF              \ MAF+ \ If QUIT executed ...
#         DROP RECURSE
#       THEN
#       ReportError
#       STATE @ IF EmptyStack THEN     \ Clearing the stack is not
#                                      \ convenient when interpreting.
#       POSTPONE [                     \ This line was omitted from the
#                                      \ ANS document
#       0 Incomplete !
#       0 ErrorSource !                \ Prepare to save source of next error.
#     THEN
#     STATE @ 0= IF Prompt THEN CR
#   REPEAT
#   BYE ;                              \ Return to caller
# ---------------------------------------------------------------------------
pbAsm::Secondary {OInterpreter} OInterpreter 0 {}

pbAsm::Cell {OINTRP1}     RDepth
pbAsm::Cell {}            ZeroGreater
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          OINTRP2
pbAsm::Cell {}            RFrom
pbAsm::Cell {}            Drop
pbAsm::Cell {}          Branch
pbAsm::Cell {}          OINTRP1
pbAsm::Literal {OINTRP2} 0
pbAsm::Literal {}       SRCID
pbAsm::Cell {}          Store
pbAsm::Cell {}          LeftBracket 
pbAsm::Literal {}       0
pbAsm::Cell {}          Incomplete
pbAsm::Cell {}          Store
pbAsm::Literal {}       0
pbAsm::Cell {}          ErrorSource
pbAsm::Cell {}          Store
pbAsm::Cell {OINTRP3}   Refill
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          OINTRP4
pbAsm::Literal {}       Interpret
pbAsm::Cell {}          Catch
pbAsm::Cell {}          QuestionDup
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          OINTRP5
pbAsm::Cell {}          Dup
pbAsm::Literal {}       -56
pbAsm::Cell {}          Equal
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          OINTRP6
pbAsm::Cell {}          OInterpreter
pbAsm::Cell {OINTRP6}   ReportError
pbAsm::Cell {}          State
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          OINTRP7
pbAsm::Cell {}          EmptyStack
pbAsm::Cell {OINTRP7}   LeftBracket 
pbAsm::Literal {}       0
pbAsm::Cell {}          Incomplete
pbAsm::Cell {}          Store
pbAsm::Literal {}       0
pbAsm::Cell {}          ErrorSource
pbAsm::Cell {}          Store
pbAsm::Cell {OINTRP5}   State
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ZeroEqual
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          OINTRP8
pbAsm::Cell {}          Prompt
pbAsm::Cell {OINTRP8}   CR
pbAsm::Cell {}          Branch
pbAsm::Cell {}          OINTRP3
pbAsm::Cell {OINTRP4}   Bye
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : FILL
#   ( c-addr u char -- )
#   OVER 0> IF
#     ROT ROT 0 DO                     \ ( char c-addr -- )
#       2DUP C!
#       CHAR+
#     LOOP
#   ELSE
#     DROP
#   THEN 2DROP ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {FILL} Fill 0 CORE

pbAsm::Cell {}          Over
pbAsm::Cell {}          ZeroGreater
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          FILL1
pbAsm::Cell {}          Rot
pbAsm::Cell {}          Rot
pbAsm::Literal {}       0
pbAsm::Cell {}          doDO
pbAsm::Cell {}          0
pbAsm::Cell FILL3       TwoDup
pbAsm::Cell {}          CharStore
pbAsm::Cell {}          CharPlus
pbAsm::Cell {}          doLOOP
pbAsm::Cell {}          FILL3
pbAsm::Cell {}          Branch
pbAsm::Cell {}          FILL2
pbAsm::Cell FILL1       Drop
pbAsm::Cell FILL2       TwoDrop
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : COLD
#   LCD_4TH LCD_REFRESH
#   ." pbForth V2.1.4 (c)2002 Ralph Hempel"
#   Prompt CR
#   OInterpreter ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {COLD} Cold 0 CORE

pbAsm::Cell      {} EmptyStack
pbAsm::Cell      {} LCD_4TH
pbAsm::Cell      {} LCD_REFRESH
pbAsm::Cell      {} doSQUOTE
pbAsm::CString   {} {pbForth V2.1.5 (c)2002 Ralph Hempel}
pbAsm::Cell      {} Type
pbAsm::Cell      {} Prompt
pbAsm::Cell      {} CR
pbAsm::Cell      {} OInterpreter
pbAsm::Cell      {} Exit
# ---------------------------------------------------------------------------
# : MARKER ( -- )
#   HERE Head @ 'UserIdle 'UserISR
#   CREATE , , , ,
#   DOES>       DUP @ TO 'UserISR
#         CELL+ DUP @ TO 'UserIdle
#         CELL+ DUP @ HEAD !
#         CELL+     @ DP   ! ;
#
# Note that Head is normally a hidden definition. It's included in this
# comment but the actual source uses the literal value for the memory
# location.
# ---------------------------------------------------------------------------
pbAsm::Secondary {MARKER} Marker 0 CORE

pbAsm::Cell      {} Here
pbAsm::Literal   {} Head+2
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} TickUserIdle
pbAsm::Cell      {} TickUserISR
pbAsm::Cell      {} Create
pbAsm::Cell      {} Comma
pbAsm::Cell      {} Comma
pbAsm::Cell      {} Comma
pbAsm::Cell      {} Comma
pbAsm::Cell      {} DoesGreater
pbAsm::Cell      {} Dup
pbAsm::Cell      {} Fetch
pbAsm::Literal   {} UserISR
pbAsm::Cell      {} Store
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} Fetch
pbAsm::Literal   {} UserIdle
pbAsm::Cell      {} Store
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} Fetch
pbAsm::Literal   {} Head+2
pbAsm::Cell      {} Store
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} DP
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# ---------------------------------------------------------------------------
