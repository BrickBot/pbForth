# ----------------------------------------------------------------------------
# except.tcl - Core Forth words for exception processing
#
# Revision History
#
# R.Hempel 20Apr2002 Link NoOp into the wordlist
# R.Hempel 22Mar2002 Clean up comments for release
# R.Hempel 08Oct2001 CATCH was not restoring input stream and EVALUATE
#                     would fail
# R.Hempel 03Oct2001 Original from PAF source
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
# Design Note: THROW code assignments
#
# Checking is comprehensive and checks are provided for all the ANS reserved
# codes which are appropriate.  Since checking has a performance cost, some
# types of checking can be omitted at compile time.  The codes reserved by ANS
# are implemented using three methods:
#
#       cf - optional by including a Check File to redefine with extra checks
#       no - not optional and built-in to PAF
#       ok - optional by re-compiling the kernel with checking turned on
#       na - not appropriate
#
# These methods reflect the different reasons for making checks and the
# performance cost of making them.
#
# Checks made by including the Check File apply to any code that is compiled
# after the Check File is loaded.  This file is used to isolate coding errors
# and includes general checks such as 'return stack imbalance'.  It also
# includes specific pre-conditions, post-conditions and invariants for all the
# words available to the user.  The Check File serves both as a debugging tool
# and as a glossary of tested code.
#
# Use the Check File as follows:
# - Before adding new code, insert a line to include the Check File.
# - As new code is added, consult the word definitions, together with their
#   pre-conditions, invariants and post-conditions, in the Check File.
# - Once the new code has been tested, remove the line which includes the
#   check file.
# - Finally add the new tested words to the Check File, providing appropriate
#   conditions for each one, ready for future development.
#
# Other failures, such as 'stack overflow' are due to resources being
# exhausted, not coding errors.  This failure can be triggered by any part
# of the code so this type of check is provided within PAF.  Some checking,
# including 'stack overflow', takes place within the kernel because the
# information needed is only available within the kernel.
#
# For maximum performance, the kernel can be recompiled with checking disabled.
# This will only be safe if the program being run is a turnkey program that:
#
# - prohibits access to the Forth text interpreter
# - checks all input for invalid data
# - takes care to avoid exhausting resources
#
# Method  Code  Meaning
#   no     -1   ABORT
#   no     -2   ABORT"
#   ok     -3   stack overflow
#   ok     -4   stack underflow
#   ok     -5   return stack overflow
#   ok     -6   return stack underflow
#   na     -7   do-loops nested too deeply during execution
#                 (na: we use return stack for looping)
#   no&ok  -8   dictionary overflow
#   cf     -9   invalid memory address
#   no    -10   division by zero
#   no    -11   result out of range (ie when converting from a double
#                 number back to a single number).  Note that ANS ignores
#                 numeric over/underflow.
#   na    -12   argument type mismatch (I don't know what this means)
#   no    -13   undefined word (or missing ;)
#   no    -14   interpreting a compile-only word
#   no    -15   invalid FORGET
#   no    -16   attempt to use zero-length string as a name
#   no    -17   pictured numeric output string overflow (ie HOLD)
#   no    -18   parsed string overflow (ie WORD)
#   no    -19   definition name too long (>31 chars)
#   cf    -20   write to a read-only location
#   no    -22   control structure mismatch
#   cf    -23   address alignment exception
#   cf    -25   return stack imbalance
#   no    -26   loop parameters unavailable
#   no    -27   invalid recursion (ie RECURSE after DOES>)
#   no    -29   compiler nesting
#   no    -31   >BODY or DOES> used on non-CREATEd definition
#   no    -56   QUIT
#
# Design Note: Exception Words CATCH and THROW
# These definitions comply with the Standard but are only suitable for
# implementations like this one which use the Return Stack for nesting
# execution tokens.
#
# QUIT uses CATCH (below) to provide an exception handler of last resort
# which catches any errors not caught elsewhere.
# This CATCH saves the Data and Return Stacks.  Other state information may
# be saved by redefining CATCH to save and restore it.  Examples are other
# stacks and input stream words like LOAD and INCLUDE-FILE, see ANS p. 163.
#
# THROW is extended beyond the Standard to include 'UserThrow @ EXECUTE.
# This allows the user to insert his own debug code to examine both stacks
# prior to restoring them.  Appropriate debug code can reveal the nesting
# of words which led to the exception.  There is also the opportunity to
# cancel the raising of the exception.
# ---------------------------------------------------------------------------
# VARIABLE CatchRDepth
# : NoOp ;                             \ A word to do nothing.
# VARIABLE 'UserThrow                  \ Vector to a user word
# ' NoOp 'UserThrow !                  \ which initially does nothing.
# ---------------------------------------------------------------------------
pbAsm::Variable {CatchRDepth} CatchRDepth 0 {}

pbAsm::Secondary {NoOp} NoOp 0 CORE
pbAsm::Cell {}          Exit

pbAsm::Variable {TickUserThrow} TickUserThrow NoOp {}
# ---------------------------------------------------------------------------
# CATCH   Catch   catch
#
# : CATCH
#   ( i*x xt -- j*x 0 | i*x n )
#   SOURCE-ID  &Source @  #TIB @  >IN @ >R >R >R >R
#   DEPTH 1-                           \ Allow for xt
#   >R
#   CatchRDepth @ >R
#   RDepth CatchRDepth !
#   EXECUTE
#   R> CatchRDepth !
#   R> DROP
#   R> R> R> R>                    \ Restore the input stream
#   >IN !  #TIB !  &Source !  TO SOURCE-ID
#   0 ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {CATCH} Catch 0 CORE

pbAsm::Cell {}          SourceID
pbAsm::Cell {}          AddrSource
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          NumberTib
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ToIn
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ToR
pbAsm::Cell {}          ToR
pbAsm::Cell {}          ToR
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Depth
pbAsm::Cell {}          OneMinus
pbAsm::Cell {}          ToR
pbAsm::Cell {}          CatchRDepth
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ToR
pbAsm::Cell {}          RDepth
pbAsm::Cell {}          CatchRDepth
pbAsm::Cell {}          Store
pbAsm::Cell {}          Execute
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          CatchRDepth
pbAsm::Cell {}          Store
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Drop
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          ToIn
pbAsm::Cell {}          Store
pbAsm::Cell {}          NumberTib
pbAsm::Cell {}          Store
pbAsm::Cell {}          AddrSource
pbAsm::Cell {}          Store
pbAsm::Literal {}       SRCID
pbAsm::Cell {}          Store
pbAsm::Literal {}       0
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# RestoreDepth   RestoreDepth   restore-depth
#
# : RestoreDepth                       \ Adjusts the data stack to provide
#   ( RequiredDepth -- )               \ the depth required not counting the
#                                      \ parameter on top of the stack.
#   >R DEPTH R>                        \ -- Actual Required
#   2DUP > IF                          \ If Actual > Required ...
#     DO  DROP  LOOP                   \ Drop surplus
#   ELSE
#     SWAP
#     2DUP > IF                        \ If Required > Actual ...
#       DO  0  LOOP                    \ Add zeroes
#     ELSE
#       2DROP
#     THEN
#   THEN ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {RestoreDepth} RestoreDepth 0 {}

pbAsm::Cell {}          ToR
pbAsm::Cell {}          Depth
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          TwoDup
pbAsm::Cell {}          Greater
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          RSDPTH1
pbAsm::Cell {}            doDO
pbAsm::Cell {}            0
pbAsm::Cell {RSDPTH3}       Drop
pbAsm::Cell {}            doLOOP
pbAsm::Cell {}            RSDPTH3
pbAsm::Cell {}          Branch
pbAsm::Cell {}          RSDPTH2
pbAsm::Cell {RSDPTH1}     Swap
pbAsm::Cell {}            TwoDup
pbAsm::Cell {}            Greater
pbAsm::Cell {}            ZBranch
pbAsm::Cell {}            RSDPTH4
pbAsm::Cell {}              doDO
pbAsm::Cell {}              0
pbAsm::Literal {RSDPTH6}      0
pbAsm::Cell {}              doLOOP
pbAsm::Cell {}              RSDPTH6
pbAsm::Cell {}            Branch
pbAsm::Cell {}            RSDPTH2
pbAsm::Cell  {RSDPTH4}      TwoDrop
pbAsm::Cell  {RSDPTH2}  Exit
# ---------------------------------------------------------------------------
# RestoreRDepth   RestoreRDepth   restore-r-depth
#
# : RestoreRDepth                      \ Reduces the Return Stack to the
#   ( RDepthRquired -- )               \ depth required.
#   R>                                 \ Save the next word.
#   RDepth ROT -                       \ -- Actual-Required
#   BEGIN
#   DUP 0> WHILE
#     R> DROP
#     1-
#   REPEAT
#   DROP                               \ the count
#   >R ;                               \ Restore the next word
# ---------------------------------------------------------------------------
pbAsm::Secondary {RestoreRDepth} RestoreRDepth 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RDepth
pbAsm::Cell {}          Rot
pbAsm::Cell {}          Minus
pbAsm::Cell {RSRDPTH1}    Dup
pbAsm::Cell {}            ZeroGreater
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          RSRDPTH2
pbAsm::Cell {}            RFrom
pbAsm::Cell {}            Drop
pbAsm::Cell {}            OneMinus
pbAsm::Cell {}          Branch
pbAsm::Cell {}          RSRDPTH1
pbAsm::Cell {RSRDPTH2}  Drop
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# Design Note: Details of the source string are saved in the following
# variables by THROW once an error has been detected for later printing by
# LocateError.  Note that the details must be saved by THROW as the
# values returned by SOURCE may change when THROW executes.
# ---------------------------------------------------------------------------
# tI VARIABLE ErrorSource                 \ Holds &String
# tI 1 CELLS ALLOT                        \ and count
# tI VARIABLE Error>In                    \ Holds offset
# ---------------------------------------------------------------------------
pbAsm::Variable {ErrorSource} ErrorSource 0 {}
pbAsm::Cell {}  0

pbAsm::Variable {Error>In} ErrorToIn 0 {}
# ---------------------------------------------------------------------------
# Design Note: Saving Source
# The source associated with an error is saved only once and then kept until
# ErrorSource is reset.  Without this mechanism, the details would be
# overwritten when errors were re-thrown by nested THROWs.
# ---------------------------------------------------------------------------
# : SaveErrorSource                    \ For later reporting where error
#   ( -- )                             \ in source was located.
#   ErrorSource @ 0= IF
#     SOURCE ErrorSource 2!
#     >IN @ Error>In !
#   THEN
# ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {SaveErrorSource} SaveErrorSource 0 {}
           
pbAsm::Cell {}          ErrorSource
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ZeroEqual
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          SVERSRC1
pbAsm::Cell {}            Source
pbAsm::Cell {}            ErrorSource
pbAsm::Cell {}            TwoStore
pbAsm::Cell {}            ToIn
pbAsm::Cell {}            Fetch
pbAsm::Cell {}            ErrorToIn
pbAsm::Cell {}            Store
pbAsm::Cell {SVERSRC1}  Exit
# ---------------------------------------------------------------------------
# : THROW                              \ Taken from Standard
#   ( k*x ErrorCode|0 -- k*x | i*x ErrorCode )
#   ?DUP IF
#     SaveErrorSource
#     'UserThrow @ EXECUTE ?DUP IF     \ This line not in Standard.
#       CatchRDepth @ RestoreRDepth    \ Restore the Return Stack to depth
#                                      \ saved by CATCH.
#       R> CatchRDepth !               \ Restore value from any previous CATCH.
#       R>                             \ Get previous DEPTH
#       SWAP >R                        \ Move the ErrorCode off the Data Stack.
#       RestoreDepth                   \ Restore Data Stack as best we can.
#       R>
#       R> R> R> R>                    \ Restore the input stream
#       >IN !  #TIB !  &Source !  TO SOURCE-ID
#     THEN
#   THEN
# ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {THROW} Throw 0 CORE

pbAsm::Cell {}          QuestionDup
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          THROW1
pbAsm::Cell {}            SaveErrorSource
pbAsm::Cell {}            TickUserThrow
pbAsm::Cell {}            Fetch
pbAsm::Cell {}            Execute
pbAsm::Cell {}            QuestionDup
pbAsm::Cell {}            ZBranch
pbAsm::Cell {}            THROW1
pbAsm::Cell {}              CatchRDepth
pbAsm::Cell {}              Fetch
pbAsm::Cell {}              RestoreRDepth
pbAsm::Cell {}              RFrom
pbAsm::Cell {}              CatchRDepth
pbAsm::Cell {}              Store
pbAsm::Cell {}              RFrom
pbAsm::Cell {}              Swap
pbAsm::Cell {}              ToR
pbAsm::Cell {}              RestoreDepth
pbAsm::Cell {}              RFrom
pbAsm::Cell {}              RFrom
pbAsm::Cell {}              RFrom
pbAsm::Cell {}              RFrom
pbAsm::Cell {}              RFrom
pbAsm::Cell {}              ToIn
pbAsm::Cell {}              Store
pbAsm::Cell {}              NumberTib
pbAsm::Cell {}              Store
pbAsm::Cell {}              AddrSource
pbAsm::Cell {}              Store
pbAsm::Literal {}           SRCID
pbAsm::Cell {}              Store
pbAsm::Cell {THROW1}    Exit
# ---------------------------------------------------------------------------
# Warning: Don't enter commands such as 'tI DROP' to test exception handling
#          as THROW will not work unless CATCH has been executed.
#          OInterpreter does this, so use 'tI OInterpreter' before testing.
# ---------------------------------------------------------------------------
# : ABORT                              \ Throws an exception with a standard
#   -1 THROW                           \ value, caught by QUIT which then
# ;                                    \ empties the stack.
# ---------------------------------------------------------------------------
pbAsm::Secondary {ABORT} Abort 0 CORE

pbAsm::Literal {}       -1
pbAsm::Cell {}          Throw
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# Note: ANS says that ABORT empties the stack and carries out the functions of
# QUIT - emptying the return stack, making the user input device the input
# stream and entering interpretation state.  In this implementation, we rely
# on the CATCH (in a loop within QUIT) to carry out most of these functions.
# ---------------------------------------------------------------------------