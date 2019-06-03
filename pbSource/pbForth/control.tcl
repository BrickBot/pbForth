# -----------------------------------------------------------------------------
# control.tcl - Core Forth words for compiling flow control
#
# Revision History
#
# R.Hempel 06Jul2002 Fix LEAVE and UNLOOP definitions
# R.Hempel 22Mar2002 Clean up comments for release
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
# Design Note: Balanced Control Structures
# ----------------------------------------
# This design for balancing control structures is from a suggestion by Gordon
# Charlton, FIG UK member.  We will need to check for the following
# compilation errors:
#
#       - attempting to >Resolve something not an Orig
#       - attempting to <Resolve something not a Dest
#       - failing to resolve all Origs and Dests in a definition
#
# First we use Unique to create Orig and Dest from ANS section 3.1.
#
# Note that in pbForth, we'll just use the pbVariable directive to
# get the same effect!
#
# : Unique VARIABLE ;        \ Words created by Unique return a value
#                            \ guaranteed to be different from all other
#                            \ Unique numbers and from all valid data
#                            \ addresses.
#
# And provide a way to check them:
# --------------------------------------------------------------------------- 
# : <CheckCS>
# ( control-sys1 control-sys2 -- )
#   = INVERT IF
#     -22 THROW
#   THEN ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {CheckCS} CheckCS 0 {} 

pbAsm::Cell {}          Equal
pbAsm::Cell {}          Invert
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          CHKCS1
pbAsm::Literal {}         -22
pbAsm::Cell {}            Throw
pbAsm::Cell {CHKCS1}    Exit
# --------------------------------------------------------------------------- 
# The elements on the control stack are 2 cells wide, comprising an address
# and a Unique.
# The dummy words >CS and CS> are just to indicate that 2 cells are moved to
# and from the notional control-flow stack.
# --------------------------------------------------------------------------- 
# : >CS                                \ A dummy word
# ; IMMEDIATE                          \ Immediate to avoid any overhead
# --------------------------------------------------------------------------- 
pbAsm::Secondary {>CS} ToCS IMM {}
 
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : CS>
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {CS>} CSFrom IMM {} 
 
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : CS-PICK                            \ MAF+ From the Tools Extension word set
#   ( C: Uu ... U0 -- Uu ... U0 Uu )   \ Not used yet!
#   ( S: u -- )
#   1+ 2* DUP PICK
#   SWAP 1- PICK ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {CS-PICK} CSPick 0 {} 
 
pbAsm::Cell {}          OnePlus
pbAsm::Cell {}          TwoStar
pbAsm::Cell {}          Dup
pbAsm::Cell {}          Pick
pbAsm::Cell {}          Swap
pbAsm::Cell {}          OneMinus
pbAsm::Cell {}          Pick
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : CS-ROLL                            \ MAF* Used by ELSE and WHILE
#   ( C: Uu ... U0 -- Uu-1 ... U0 Uu )
#   ( S: u -- )
#   1+ 2* DUP ROLL
#   SWAP 1- ROLL ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {CS-ROLL} CSRoll 0 {}
 
pbAsm::Cell {}          OnePlus
pbAsm::Cell {}          TwoStar
pbAsm::Cell {}          Dup
pbAsm::Cell {}          Roll
pbAsm::Cell {}          Swap
pbAsm::Cell {}          OneMinus
pbAsm::Cell {}          Roll
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# Compiler Security
# ANS Forth suggests that : lays down a value 'colon-sys' for DOES> and ; to
# check.  Note that if we omit colon-sys, then the fragment : TRY THEN ; will
# fail at THEN due to stack underflow, when it should fail due to control
# structure mismatch.
#
# Unique colon-sys1               \ MAF+
# Unique colon-sys2               \ MAF+
# Unique does-sys                 \ MAF+
# VARIABLE Loops                  \ MAF+ Used within : .. ; as compiler
#                                 \ security for I, J, LEAVE and UNLOOP.
#
# The Unique word just creates a variable - the address returned when the
# variable executes is guaranteed to be unique! 
# --------------------------------------------------------------------------- 
pbAsm::Variable {colon-sys1} ColonSys1 0 {}
pbAsm::Variable {colon-sys2} ColonSys2 0 {}
pbAsm::Variable {does-sys}   DoesSys   0 {}
pbAsm::Variable {Loops}      Loops     0 {}
# --------------------------------------------------------------------------- 
# This implementation of PAF is not intended to be compiled by Forth, so
# we won't go through the steps of redefining the old definitions of the
# compiling words ...
# --------------------------------------------------------------------------- 
# : :                                  \ MAF+
#   Header [ <:> ] LITERAL COMPILE,    \ Do the standard : operations...
#   colon-sys1 colon-sys2 >CS          \ Place 2 Uniques on CStack, the 1st
#                                      \ for ; to check and the second
#                                      \ for DOES>.
#   0 Loops !                          \ Set loop count to 0 ready for I and
#                                      \ J to test.
#   1 Incomplete ! ;                   \ Set to detect compiler nesting.
#                                      \ Checked by Header and COMPILE,
# --------------------------------------------------------------------------- 
pbAsm::Secondary {:} Colon 0 CORE

pbAsm::Cell {}          Header
pbAsm::Literal {}       doCOLON+2
pbAsm::Cell {}          CompileComma
pbAsm::Cell {}          ColonSys1
pbAsm::Cell {}          ColonSys2
pbAsm::Cell {}          ToCS
pbAsm::Literal {}       0
pbAsm::Cell {}          Loops
pbAsm::Cell {}          Store
pbAsm::Literal {}       1
pbAsm::Cell {}          Incomplete
pbAsm::Cell {}          Store
pbAsm::Cell {}          RightBracket
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : ;                          \ MAF+
#   CS> DROP
#   colon-sys1 CheckCS
#   POSTPONE [
#   POSTPONE EXIT
#   DP @ ALIGNED DP !          \ ANS 6.1.0460
#   Reveal                     \    Reveal
#   0 Incomplete !
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {;} SemiColon {IMM+COMP} CORE
 
pbAsm::Cell {}          CSFrom
pbAsm::Cell {}          Drop
pbAsm::Cell {}          ColonSys1
pbAsm::Cell {}          CheckCS
pbAsm::Cell {}          LeftBracket
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          Exit
pbAsm::Cell {}          Align
pbAsm::Cell {}          Reveal
pbAsm::Literal {}       0
pbAsm::Cell {}          Incomplete
pbAsm::Cell {}          Store
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# Control Flow Words
# ---------------------------------------------------------------------------
# : Mark>   \ ( -- Orig )              \ Prepare for a forward jump.
#   HERE
#   0 COMPILE, ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {MARK>} MarkFwd 0 {} 

pbAsm::Cell {}          Here
pbAsm::Literal {}       0
pbAsm::Cell {}          CompileComma
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : >Resolve   \ ( Orig u1 u2 -- )     \ Complete it.
#   CheckCS                            \ MAF+
#   HERE SWAP Branch! ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {>Resolve} FwdResolve 0 {}

pbAsm::Cell {}          CheckCS
pbAsm::Cell {}          Here
pbAsm::Cell {}          Swap
pbAsm::Cell {}          BranchStore
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : Mark<   \ ( -- Dest )              \ Prepare for a backward jump.
#   HERE ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {MARK<} MarkBack 0 {}
 
pbAsm::Cell {}          Here
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : <Resolve   \ ( Dest u1 u2 -- )     \ Complete it.
#   CheckCS                            \ MAF+
#   HERE 0 COMPILE, Branch! ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {<Resolve} BackResolve 0 {} 

pbAsm::Cell {}          CheckCS
pbAsm::Cell {}          Here
pbAsm::Literal {}       0
pbAsm::Cell {}          CompileComma
pbAsm::Cell {}          BranchStore
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
#                               \ IF .. THEN and BEGIN .. UNTIL
# Unique Orig                   \ MAF+
# Unique Dest                   \ MAF+
#
# Once again, we'll just make these invisible variables...
# ---------------------------------------------------------------------------
pbAsm::Variable {Orig} Orig 0 {}
pbAsm::Variable {Dest} Dest 0 {}
# ---------------------------------------------------------------------------
# : AHEAD   \ ( C: -- Orig )           \ From the Programming Tools Extension
#   POSTPONE <Branch>                  \ word set.  Used by ELSE.
#   Mark> Orig >CS
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {AHEAD} Ahead IMM {}
 
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          Branch
pbAsm::Cell {}          MarkFwd
pbAsm::Cell {}          Orig
pbAsm::Cell {}          ToCS
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : IF   \ ( C: -- Orig ) ( x -- )
#   POSTPONE <0Branch>
#   Mark> Orig >CS
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {IF} If {IMM+COMP} CORE
 
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          MarkFwd
pbAsm::Cell {}          Orig
pbAsm::Cell {}          ToCS
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : THEN   \ ( C: Orig -- ) ( -- )
#   CS> Orig >Resolve
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {THEN} Then {IMM+COMP} CORE

pbAsm::Cell {}          CSFrom
pbAsm::Cell {}          Orig
pbAsm::Cell {}          FwdResolve
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : ELSE   \ ( C: Orig1 -- Orig2 ) ( -- )
#   POSTPONE AHEAD  1 CS-ROLL  POSTPONE THEN
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {ELSE} Else {IMM+COMP} CORE

pbAsm::Cell {}          Ahead
pbAsm::Literal {}       1
pbAsm::Cell {}          CSRoll
pbAsm::Cell {}          Then
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : BEGIN   \ ( C: -- Dest )
#   Mark< Dest >CS
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {BEGIN} Begin {IMM+COMP} CORE

pbAsm::Cell {}          MarkBack
pbAsm::Cell {}          Dest
pbAsm::Cell {}          ToCS
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : AGAIN                              \ From the Core Extension word set.
#   POSTPONE <Branch>
#   CS> Dest <Resolve
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {AGAIN} Again {IMM+COMP} CORE

pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          Branch
pbAsm::Cell {}          CSFrom
pbAsm::Cell {}          Dest
pbAsm::Cell {}          BackResolve
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : UNTIL
#   POSTPONE <0Branch>
#   CS> Dest <Resolve
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {UNTIL} Until {IMM+COMP} CORE

pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          CSFrom
pbAsm::Cell {}          Dest
pbAsm::Cell {}          BackResolve
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : WHILE
#   POSTPONE IF  1 CS-ROLL
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {WHILE} While {IMM+COMP} CORE

pbAsm::Cell {}          If
pbAsm::Literal {}       1
pbAsm::Cell {}          CSRoll
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : REPEAT
#   POSTPONE AGAIN  POSTPONE THEN
# ; IMMEDIATE
# --------------------------------------------------------------------------- 
pbAsm::Secondary {REPEAT} Repeat {IMM+COMP} CORE

pbAsm::Cell {}          Again
pbAsm::Cell {}          Then
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# Design Note: DO Loops
# ---------------------
# Our version of DO..[LEAVE]..[I]..[J]..[UNLOOP]..(+)LOOP uses a chain of
# addresses to store sizes for forward and backward jumps.  After compiling
# LOOP we may have:
#
#            &0 &1          &2             &3            &4 &5
#       <Do>  0 ... <Leave> &5 ... <Leave> &5 ... <Loop> &1 ...
#
# so that <Leave> can jump forward to &5 and <Loop> can jump back to &1.
# These addresses are laid down in a backward-pointing chain by each LEAVE
# and point back to the end-of-chain address &0.  &0 is just after <Do> and
# contains 0 to indicate end-of-chain.
#
# These jumps are finally resolved by LOOP.  For example, before executing
# <Loop> we might have:
#
#            &0 &1          &2             &3
#       <Do>  0 ... <Leave> &0 ... <Leave> &2 ...
# --------------------------------------------------------------------------- 
# : ResolveLeaves                             \ The target address is 2 cells
#    ( &Target &LastLeave -- &End-Of-Chain )  \  after &<Loop>.
#   BEGIN
#     DUP @                            \ ( -- &Target &Leave &PrevLeave )
#   ?DUP WHILE
#     >R OVER SWAP Branch! R>          \ Point the <Leave> to &Target.
#   REPEAT
#   SWAP DROP ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {ResolveLeaves} ResolveLeaves 0 {}

pbAsm::Cell {RSLVS1}      Dup
pbAsm::Cell {}            Fetch
pbAsm::Cell {}            QuestionDup
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          RSLVS2
pbAsm::Cell {}            ToR
pbAsm::Cell {}            Over
pbAsm::Cell {}            Swap
pbAsm::Cell {}            BranchStore
pbAsm::Cell {}            RFrom
pbAsm::Cell {}          Branch
pbAsm::Cell {}          RSLVS1
pbAsm::Cell {RSLVS2}    Swap
pbAsm::Cell {}          Drop
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : ResolveLoop                        \ &BranchBack is 1 cell after &<Loop>.
#   ( &LastLeave &BranchBack -- )
#   DUP CELL+ ROT ResolveLeaves        \ ( -- &BranchBack &End-Of-Chain )
#   CELL+ SWAP Branch!                 \ Point the &BranchBack to 1 cell
# ;                                    \ after &End-Of-Chain.
# --------------------------------------------------------------------------- 
pbAsm::Secondary {ResolveLoop} ResolveLoop 0 {}

pbAsm::Cell {}          Dup
pbAsm::Cell {}          CellPlus
pbAsm::Cell {}          Rot
pbAsm::Cell {}          ResolveLeaves
pbAsm::Cell {}          CellPlus
pbAsm::Cell {}          Swap
pbAsm::Cell {}          BranchStore
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# Design Note: DO Using The Return Stack
# --------------------------------------
# This version of DO ... LOOP uses the return stack to maintain the loop index
# keeping the values Limit and Index there under the address of the
# next word (IP).  LOOP and LEAVE change IP to force jumps backward and
# forward.
# --------------------------------------------------------------------------- 
# : <Do>                               \ Save Limit & Index and skip
#   ( High Low -- )                    \ over end-of-chain address &0.
#   ( R: IP -- High Low IP+CELL )
#   R> CELL+                           \ Save & of word after next
#   ROT >R SWAP >R
#   >R ;                               \ and restore it
# ---------------------------------------------------------------------------
pbAsm::Secondary {<Do>} doDO 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          CellPlus
pbAsm::Cell {}          Rot
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Swap
pbAsm::Cell {}          ToR
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# VARIABLE &LeaveChain                 \ Between compiling DO and LOOP, we
#                                      \ store the address of the chain in a
#                                      \ variable.  It can't be left on the
#                                      \ control flow stack because LEAVE may
#                                      \ be (and usually is) used inside an
#                                      \ IF .. THEN structure, which also
#                                      \ uses the control flow stack.          
#
# Unique DoOrig                        \ MAF+
# ---------------------------------------------------------------------------
pbAsm::Variable {&LeaveChain} AddrLeaveChain 0 {}
pbAsm::Variable {DoOrig}      DoOrig         0 {}
# ---------------------------------------------------------------------------
# : DO
#   ( C: -- do-sys )
#   POSTPONE <Do>
#   &LeaveChain @                      \ Save the old one so that loops can
#                                      \ be nested.
#   Mark> &LeaveChain !                \ Create the end-of-chain and store it.
#   DoOrig >CS                         \ MAF+ Leave for checking.
#   1 Loops +!                         \ MAF+ Increment Loops for checking.
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {DO} Do {IMM+COMP} CORE

pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          doDO
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          MarkFwd
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Store
pbAsm::Cell {}          DoOrig
pbAsm::Cell {}          ToCS
pbAsm::Literal {}       1
pbAsm::Cell {}          Loops
pbAsm::Cell {}          PlusStore
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : <Loop>                             \ Increment the Index and compare it
#   ( -- )                             \ to the Limit.
#   ( R: Limit Index IP
#        -- Limit Index+1 NewIP )
#   R>                                 \ Save & of next word.
#   R> 1+                              \ Increment Index.
#   DUP R@ = IF                        \ If = Limit ...
#     DROP  R> DROP                    \ Drop Index and Limit.
#     CELL+ >R                         \ Skip over address of start of loop.
#   ELSE
#     >R                               \ Save new index.
#     @                                \ Get address of start of loop.
#     >R                               \ Make it the next word.
#   THEN ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {<Loop>} doLOOP 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          OnePlus
pbAsm::Cell {}          Dup
pbAsm::Cell {}          RFetch
pbAsm::Cell {}          Equal
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          DOLOOP1
pbAsm::Cell {}          Drop
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Drop
pbAsm::Cell {}          CellPlus
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Branch
pbAsm::Cell {}          DOLOOP2
pbAsm::Cell {DOLOOP1}   ToR
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ToR
pbAsm::Cell {DOLOOP2}   Exit
# ---------------------------------------------------------------------------
# : LOOP
#   ( C: do-sys -- )
#   CS> DoOrig CheckCS                \ MAF+
#   POSTPONE <Loop>
#   &LeaveChain @
#   Mark> ResolveLoop
#   &LeaveChain !                      \ Restore the old value.
#   -1 Loops +!                        \ MAF+ Decrement Loops for checking.
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {LOOP} Loop {IMM+COMP} CORE

pbAsm::Cell {}          CSFrom
pbAsm::Cell {}          DoOrig
pbAsm::Cell {}          CheckCS
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          doLOOP
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          MarkFwd
pbAsm::Cell {}          ResolveLoop
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Store
pbAsm::Literal {}       -1
pbAsm::Cell {}          Loops
pbAsm::Cell {}          PlusStore
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : <+Loop>                            \ Change the Index and test for end by
#   ( Increment -- )                   \ comparing top-of-stack to Index and
#   ( R: Limit Index IP                \ testing for a change of sign.
#        -- Limit Index+1 NewIP )
#   R>                                 \ Save & of next word
#   SWAP R> DUP R@ -                   \ Get Index-Limit
#   ROT ROT + DUP R@ -                 \ Increment Index-Limit
#   ROT SignsDiffer? IF                \ If sign has changed ...
#     DROP  R> DROP                    \ Drop NewIndex and Limit
#     CELL+ >R                         \ Skip over address at end of loop
#                                      \ and execute word that follows.
#   ELSE
#     >R                               \ Save new Index
#     @                                \ Get address of start of loop and
#     >R                               \ make it the next word.
#   THEN ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {<+Loop>} doPLOOP 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Swap
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Dup
pbAsm::Cell {}          RFetch
pbAsm::Cell {}          Minus
pbAsm::Cell {}          Rot
pbAsm::Cell {}          Rot
pbAsm::Cell {}          Plus
pbAsm::Cell {}          Dup
pbAsm::Cell {}          RFetch
pbAsm::Cell {}          Minus
pbAsm::Cell {}          Rot
pbAsm::Cell {}          SignsDifferQ
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          DOPLOOP1
pbAsm::Cell {}          Drop
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Drop
pbAsm::Cell {}          CellPlus
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Branch
pbAsm::Cell {}          DOPLOOP2
pbAsm::Cell {DOPLOOP1}  ToR
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          ToR
pbAsm::Cell {DOPLOOP2}  Exit
# ---------------------------------------------------------------------------
# : +LOOP
#   ( C: do-sys -- )
#   CS> DoOrig CheckCS         \ MAF+
#   POSTPONE <+Loop>
#   &LeaveChain @ Mark> ResolveLoop
#   &LeaveChain !                      \ Restore the old value.
#   -1 Loops +!                \ MAF+ Decrement Loops for checking.
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {+LOOP} PlusLoop {IMM+COMP} CORE

pbAsm::Cell {}          CSFrom
pbAsm::Cell {}          DoOrig
pbAsm::Cell {}          CheckCS
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          doPLOOP
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          MarkFwd
pbAsm::Cell {}          ResolveLoop
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Store
pbAsm::Literal {}       -1
pbAsm::Cell {}          Loops
pbAsm::Cell {}          PlusStore
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# For pbForth, we'll need to define the run-time behaviours of words that
# manipulate the return stack for loop parameters so we can use them
# in the words that check the loop depth at compile time.
#
# This is easier than trying to get this functionality in just one word!
#
# The first thing we need is a word to check the loop depth for us...
# ---------------------------------------------------------------------------
# : ?Loops
#   ( Loops -- )
#   Loops @ > IF                       \ If Loops < loops compiled ...
#     -26 THROW                        \ "loop parameters unavailable"
#   THEN ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {?Loops} QLoops 0 {}

pbAsm::Cell {}          Loops
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          Greater
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          QLOOPS1
pbAsm::Literal {}         -26
pbAsm::Cell {}            Throw
pbAsm::Cell {QLOOPS1}   Exit
# ---------------------------------------------------------------------------
# : <I>
#   ( -- Index )
#   ( R: Index IP -- Index IP )
#   R>                                 \ Save & of next word IP.
#   R@                                 \ Get Index
#   SWAP >R ;                          \ and restore IP.
# ---------------------------------------------------------------------------
pbAsm::Secondary {<I>} doI 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFetch
pbAsm::Cell {}          Swap
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : I
#   1 ?Loops
#   POSTPONE I
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {I} I {IMM+COMP} CORE

pbAsm::Literal {}       1
pbAsm::Cell {}          QLoops
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          doI
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : <J>                              \ ->PAF
#   ( -- Index )
# ( R: JIndex ILimit IIndex IP
#   -- JIndex IP ILimit IIndex IP )
#      R>                            \ Save & of next word IP
#      R> R>                         \ Save I loop control parameters
#      R@                            \ Get the J index
#      SWAP >R  SWAP >R              \ Restore I parameters
#      SWAP >R ;                     \ and restore IP
# ---------------------------------------------------------------------------
pbAsm::Secondary {<J>} doJ 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFetch
pbAsm::Cell {}          Swap
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Swap
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Swap
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : J
#   2 ?Loops
#   POSTPONE J
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {J} J {IMM+COMP} CORE

pbAsm::Literal {}       2
pbAsm::Cell {}          QLoops
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          doJ
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : <Leave>
#   R> @                               \ Get address of end of loop.
#   R> DROP  R> DROP                   \ Lose Index-Limit and Limit.
#   >R ;                               \ Make the end-of-loop the next word.
# ---------------------------------------------------------------------------
pbAsm::Secondary {<Leave>} doLEAVE 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Drop
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          Drop
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : LEAVE
#   1 ?Loops
#   POSTPONE <Leave>
#   HERE  &LeaveChain @ COMPILE,
#   &LeaveChain !
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {LEAVE} LEAVE {IMM+COMP} CORE

pbAsm::Literal {}       1
pbAsm::Cell {}          QLoops
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          doLEAVE
pbAsm::Cell {}          Here
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          CompileComma
pbAsm::Cell {}          AddrLeaveChain
pbAsm::Cell {}          Store
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : <Unloop>
#   R>  R> R> 2DROP  >R ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {<Unloop>} doUNLOOP 0 {}

pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          RFrom
pbAsm::Cell {}          TwoDrop
pbAsm::Cell {}          ToR
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : UNLOOP
#   1 ?Loops
#   POSTPONE <Unloop>
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {UNLOOP} UNLOOP {IMM+COMP} CORE

pbAsm::Literal {}       1
pbAsm::Cell {}          QLoops
pbAsm::Cell {}          doCOMPILE
pbAsm::Cell {}          doUNLOOP
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------