# -----------------------------------------------------------------------------
# io.tcl - Core Forth words for handling console I/O
#
# Revision History
#
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
pbAsm::Variable {BASE} Base 10 CORE
 
# -----------------------------------------------------------------------------
# : DECIMAL 10 BASE ! ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {DECIMAL} Decimal 0 CORE

pbAsm::Literal   {} 10
pbAsm::Cell      {} Base
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : HEX 16 BASE ! ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {HEX} Hex 0 CORE

pbAsm::Literal   {} 16
pbAsm::Cell      {} Base
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : VALUE                              \ From the Core Extension word set.
#   ( -- x )                           \ Used to create SOURCE-ID.
#   CREATE  ,
#   DOES> @ ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {VALUE} Value 0 CORE

pbAsm::Cell      {} Create
pbAsm::Cell      {} Comma
pbAsm::Cell      {} DoesGreater
pbAsm::Cell  VALUE1 Fetch
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : TO                                 
#   ' >BODY STATE @
#   IF   POSTPONE LITERAL POSTPONE !
#   ELSE !
#   THEN
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {TO} To {IMM} CORE

pbAsm::Cell      {} Tick
pbAsm::Cell      {} ToBody
pbAsm::Cell      {} State
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TO1
pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} doLIT
pbAsm::Cell      {} CompileComma
pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} Store
pbAsm::Cell      {} Branch
pbAsm::Cell      {} TO2
pbAsm::Cell     TO1 Store
pbAsm::Cell     TO2 Exit
# -----------------------------------------------------------------------------
# 0 VALUE SOURCE-ID
# -----------------------------------------------------------------------------
pbAsm::Create {SOURCE-ID} SourceID 0 CORE 

pbAsm::Cell      {} VALUE1
pbAsm::Cell {SRCID} 0
# -----------------------------------------------------------------------------
# ANS declares #TIB and TIB to be
# obsolescent.  Standard Programs are
# to use SOURCE instead.  PAF is a
# Standard System using #TIB and TIB to
# define SOURCE.
#
# 80 CONSTANT TibSize                  \ Minimum no. of chars required by ANS
#
# VARIABLE &Source                     \ Address of input buffer used by
#                                      \ EVALUATE.  &Source is private to
#                                      \ SOURCE and EVALUATE.

# -----------------------------------------------------------------------------
pbAsm::Constant  {TibSize}   TibSize     80 CORE
pbAsm::Constant  {TIB}       Tib   _AddrTib CORE

pbAsm::Variable {#TIB}    NumberTib       0 CORE 
pbAsm::Variable {>IN}     ToIn            0 CORE 
pbAsm::Variable {&Source} AddrSource      0 CORE
 
# -----------------------------------------------------------------------------
# : SOURCE
#   ( -- c-addr u )
#   SOURCE-ID IF
#     &Source @
#   ELSE
#     TIB
#   THEN
#   #TIB @ ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {SOURCE} Source 0 CORE

pbAsm::Cell      {} SourceID
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SOURCE1
pbAsm::Cell      {} AddrSource
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Branch
pbAsm::Cell      {} SOURCE2
pbAsm::Cell SOURCE1 Tib
pbAsm::Cell SOURCE2 NumberTib
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# 32 CONSTANT BL
# -----------------------------------------------------------------------------
pbAsm::Constant  {BL}   Blank     32 CORE

# -----------------------------------------------------------------------------
# : Graphic?                           \ Support for ACCEPT
#   ( char -- flag )
#   BL [ E' MAX-CHAR 1+ ] LITERAL WITHIN
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Graphic?} GraphicQ 0 {}

pbAsm::Cell      {} Blank
# FIXME: This value should be set up at build time...
pbAsm::Literal   {} 127
pbAsm::Cell      {} Within
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : AcceptGraphic                      \ Support for Accept
#   ( Count Addr Key
#     -- Count+1 Addr+Char )
#   DUP EMIT                           \ Emit the character
#   OVER C!                            \ Store it
#   CHAR+ SWAP 1+ SWAP                 \ Increment count and address
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {AcceptGraphic} AcceptGraphic 0 {}

pbAsm::Cell      {} Over
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} OnePlus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Exit
# ---------------------------------------------------------------------------
# : AcceptNonGraphic  ( n1 c-addr1 char -- n2 c-addr2 ExitFlag )
#   DUP  cr# = IF                  \ First look for CR
#     DROP TRUE EXIT
#   THEN
#   DUP  bsp# = OVER del# = OR IF  \ First look for DEL and BSP
#     DROP OVER IF
#       1- SWAP 1- SWAP
#       ( bsp# EMIT ) sp# EMIT bsp# EMIT
#     THEN
#     FALSE EXIT
#   THEN
#   DROP bl# AcceptGraphic FALSE ;
# ---------------------------------------------------------------------------
pbAsm::Secondary {AcceptNonGraphic} AcceptNonGraphic 0 {} 

pbAsm::Cell    {} Dup
pbAsm::Literal {} 13
pbAsm::Cell    {} Equal
pbAsm::Cell    {} ZBranch
pbAsm::Cell    {} ACNG1
pbAsm::Cell    {} Drop
pbAsm::Cell    {} True
pbAsm::Cell    {} Exit
pbAsm::Cell {ACNG1} Dup
pbAsm::Literal {} 8
pbAsm::Cell    {} Equal
pbAsm::Cell    {} Over
pbAsm::Literal {} 127
pbAsm::Cell    {} Equal
pbAsm::Cell    {} Or
pbAsm::Cell    {} ZBranch
pbAsm::Cell    {} ACNG2
pbAsm::Cell    {} Drop
pbAsm::Cell    {} Over
pbAsm::Cell    {} ZBranch
pbAsm::Cell    {} ACNG3
pbAsm::Cell    {} OneMinus
pbAsm::Cell    {} Swap
pbAsm::Cell    {} OneMinus
pbAsm::Cell    {} Swap
# pbLiteral   {} 8
# pbCell      {} Emit
pbAsm::Literal   {} 32
pbAsm::Cell      {} Emit
pbAsm::Literal   {} 8
pbAsm::Cell      {} Emit
pbAsm::Cell {ACNG3} False
pbAsm::Cell      {} Exit
pbAsm::Cell {ACNG2} Drop
pbAsm::Literal   {} 32
pbAsm::Cell      {} AcceptGraphic
pbAsm::Cell      {} False
pbAsm::Cell      {} Exit
# ---------------------------------------------------------------------------
# : ACCEPT                             \ Receive a string of at most +n1
#   ( c-addr +n1 -- +n2 )              \ characters and display them.
#   LITERAL 0x11 EMIT
#   >R 0 SWAP BEGIN                    \ Save MaxChars and bury CharsCount
#     KEY DUP Graphic? IF              \ ( -- Count Addr Key )
#       2 PICK R@ < IF
#         AcceptGraphic
#       ELSE
#         DROP                         \ Drop excess key
#       THEN
#       FALSE                          \ Continue flag
#     ELSE
#       AcceptNonGraphic
#     THEN
#   UNTIL  DROP  R> DROP
#   LITERAL 0x13 EMIT ;                   
#
# Note: This is a little different that the standard MAF/PAF source. We
# use XON/XOFF flow control to pace the sender and to keep from overflowing
# our interpreter.
# ---------------------------------------------------------------------------
pbAsm::Secondary {ACCEPT} Accept 0 CORE

pbAsm::Literal   {} 17
pbAsm::Cell      {} Emit
pbAsm::Cell      {} ToR
pbAsm::Literal   {} 0
pbAsm::Cell      {} Swap
pbAsm::Cell ACCEPT1 Key 
pbAsm::Cell      {} Dup
pbAsm::Cell      {} GraphicQ
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ACCEPT2
pbAsm::Literal   {} 2
pbAsm::Cell      {} Pick
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Less
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ACCEPT4
pbAsm::Cell      {} AcceptGraphic
pbAsm::Cell      {} Branch
pbAsm::Cell      {} ACCEPT5
pbAsm::Cell ACCEPT4 Drop
pbAsm::Cell ACCEPT5 False
pbAsm::Cell      {} Branch
pbAsm::Cell      {} ACCEPT3
pbAsm::Cell ACCEPT2 AcceptNonGraphic
pbAsm::Cell ACCEPT3 ZBranch
pbAsm::Cell      {} ACCEPT1
pbAsm::Cell      {} Drop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Drop
pbAsm::Literal   {} 19
pbAsm::Cell      {} Emit
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : REFILL                             \ From the Core Extension word set.
#   ( -- Success )                     \ Support for QUIT
#     SOURCE-ID IF                     \ If not zero then source is EVALUATE.
#     FALSE
#   ELSE
#     TIB TibSize ACCEPT  #TIB !
#     0 >IN !
#     TRUE
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {REFILL} Refill 0 CORE

pbAsm::Cell      {} SourceID
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} REFILL1
pbAsm::Cell      {} False
pbAsm::Cell      {} Branch
pbAsm::Cell      {} REFILL2
pbAsm::Cell REFILL1 Tib
pbAsm::Cell      {} TibSize
pbAsm::Cell      {} Accept
pbAsm::Cell      {} NumberTib
pbAsm::Cell      {} Store
pbAsm::Literal   {} 0
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Store
pbAsm::Cell      {} True
pbAsm::Cell REFILL2 Exit
# -----------------------------------------------------------------------------
# Design Note: Parsing
# --------------------
# Finding the next word in a string is done using a sentinel character.  A
# copy of the delimiter is written immediately after the end of the string so
# that the search words can never fail to find a delimiter.  This makes for
# simple and fast search words.
#
# It also means that we write into the input buffer.  This is not a good idea
# (and a Standard Program may not do this) because the input may come from a
# string in a read-only area of memory.  I plan to revise parsing because of
# this.
# -----------------------------------------------------------------------------
# : Scan                               \ Scan through a string until the
#   ( DelimitChar &String              \ delimiting char is reached.  Make
#     -- &Delimiter CharsScanned )     \ sure there is one!
#                                      \ Returns no. of chars scanned
#                                      \ excluding the delimiter.
#   0 >R                               \ Save initial count
#   BEGIN
#     2DUP C@
#   <> WHILE
#     CHAR+                            \ &String
#     R> 1+ >R                         \ CharsScanned
#   REPEAT
#   SWAP DROP                          \ DelimitChar
#   R> ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Scan} Scan 0 {}

pbAsm::Literal   {} 0
pbAsm::Cell      {} ToR
pbAsm::Cell   SCAN1 TwoDup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} NotEqual
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SCAN2
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} OnePlus
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Branch
pbAsm::Cell      {} SCAN1
pbAsm::Cell   SCAN2 Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Skip                               \ Scan through a string until a
#   ( DelimitChar &String              \ char <> delimiting char is reached.
#     -- &Delimiter CharsScanned )     \ Return address of delimiter and
#                                      \ no. of chars scanned excluding
#                                      \ the delimiter.
#   0 >R                               \ Save initial count
#   BEGIN
#     2DUP C@
#   = WHILE
#     CHAR+                            \ &String
#     R> 1+ >R                         \ CharsScanned
#   REPEAT
#   SWAP DROP                          \ DelimitChar
#   R> ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Skip} Skip 0 {}

pbAsm::Literal   {} 0
pbAsm::Cell      {} ToR
pbAsm::Cell   SKIP1 TwoDup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Equal
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SKIP2
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} OnePlus
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Branch
pbAsm::Cell      {} SKIP1
pbAsm::Cell   SKIP2 Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : PARSE                              \ From Core Extension word set
#   ( Char "ccc<Char>" -- &String Count )
#   SOURCE >R                          \ Save chars in buffer.
#   DUP >IN @ CHARS +                  \ Get &Start
#   SWAP R@ CHARS +                    \ and & for sentinel.
#   DUP C@                             \ Get char at sentinel &.
#                                      \ -- Char &Start &End Char@End )
#   OVER >R >R >R                      \ Save sentinel data.
#   SWAP 2DUP                          \ -- &Start Char &Start Char )
#   R> C!                              \ Set the sentinel = Char
#   Scan SWAP DROP                     \ -- &Start Count )
#   R> R> C!                           \ Restore the sentinel.
#   DUP 1+ >IN @ +                     \ Advance input stream beyond
#   R> MIN >IN ! ;                     \ delimiter, but not exceeding
# -----------------------------------------------------------------------------
pbAsm::Secondary {PARSE} Parse 0 CORE

pbAsm::Cell      {} Source
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Over
pbAsm::Cell      {} ToR
pbAsm::Cell      {} ToR
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Swap
pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Scan
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Dup
pbAsm::Cell      {} OnePlus
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Plus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Min
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SkipParse                          \ As PARSE but also skips over
#   ( Char "<chars>ccc<char>" -- &String Count )
#                                      \ leading delimiters.  Used by WORD.
#   SOURCE >R                          \ Save chars in buffer.
#   DUP >IN @ CHARS +                  \ Get &Start
#   SWAP R@ CHARS +                    \ and & for sentinel.
#   DUP C@                             \ Get char at sentinel &.
#                                      \ -- Char &Start &End Char@End )
#   OVER >R >R >R                      \ Save sentinel data.
#                                      \ -- Char &Start )
#   OVER INVERT R@ C!                  \ Set the sentinel <> Char
#   OVER SWAP Skip                     \ -- Char &EndLD Count )
#   >IN +!                             \ Advance input stream.
#   OVER R> C!                         \ set the sentinel = Char
#   SWAP OVER Scan SWAP DROP           \ -- &EndLD Count )
#   R> R> C!                           \ Restore the sentinel.
#   DUP 1+ >IN @ +                     \ Advance input stream beyond
#   R> MIN >IN !                       \ delimiter, but not exceeding
# ;                                    \ chars in buffer.
# -----------------------------------------------------------------------------
pbAsm::Secondary {SkipParse} SkipParse 0 {}

pbAsm::Cell      {} Source
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Over
pbAsm::Cell      {} ToR
pbAsm::Cell      {} ToR
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Over
pbAsm::Cell      {} Invert
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Over
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Skip
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} PlusStore
pbAsm::Cell      {} Over
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Over
pbAsm::Cell      {} Scan
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Dup
pbAsm::Cell      {} OnePlus
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Plus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Min
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : CHAR                               \ Ensure end of input not reached.
#   ( "<spaces>char" -- char )
#   BL SkipParse DROP C@ ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {CHAR} Char 0 CORE

pbAsm::Cell      {} Blank
pbAsm::Cell      {} SkipParse
pbAsm::Cell      {} Drop
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : [CHAR]
#   ( C: "<spaces>name" -- ) ( -- char )
#   CHAR  POSTPONE LITERAL
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {[CHAR]} BracketChar {IMM+COMP} CORE

pbAsm::Cell      {} Char
pbAsm::Cell      {} Literal
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : \
# SOURE >IN ! DROP ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {\\} BackSlash IMM CORE

pbAsm::Cell      {} Source
pbAsm::Cell      {} ToIn
pbAsm::Cell      {} Store
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : (                                  \ Uses PARSE, not SkipParse
#   [CHAR] ) PARSE 2DROP
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {(} Paren IMM CORE

pbAsm::Literal   {} ')'
pbAsm::Cell      {} Parse
pbAsm::Cell      {} TwoDrop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SPACE  BL EMIT ;                   \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {SPACE} Space 0 CORE

pbAsm::Cell      {} Blank
pbAsm::Cell      {} Emit
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : CR 13 EMIT 10 EMIT ;               \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {CR} CR 0 CORE

pbAsm::Literal   {} 13
pbAsm::Cell      {} Emit
pbAsm::Literal   {} 10
pbAsm::Cell      {} Emit
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SPACES
#   ( Spaces -- )
#   DUP 0> IF
#     0 DO SPACE LOOP
#   ELSE
#     DROP
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {SPACES} Spaces 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZeroGreater
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SPACES1
pbAsm::Literal   {} 0
pbAsm::Cell      {} doDO
pbAsm::Cell      {} 0
pbAsm::Cell SPACES3 Space
pbAsm::Cell      {} doLOOP
pbAsm::Cell      {} SPACES3
pbAsm::Cell      {} Branch
pbAsm::Cell      {} SPACES2
pbAsm::Cell SPACES1 Drop
pbAsm::Cell SPACES2 Exit
# -----------------------------------------------------------------------------
# : TYPE
#   ( &Char Chars -- )
#   DUP 0> IF
#     0 DO  DUP C@ EMIT  CHAR+  LOOP
#     DROP
#   ELSE
#     2DROP
#   THEN
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {TYPE} Type 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZeroGreater
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TYPE1
pbAsm::Literal   {} 0
pbAsm::Cell      {} doDO
pbAsm::Cell      {} 0
pbAsm::Cell   TYPE3 Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Emit
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} doLOOP
pbAsm::Cell      {} TYPE3
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Branch
pbAsm::Cell      {} TYPE2
pbAsm::Cell   TYPE1 TwoDrop
pbAsm::Cell   TYPE2 Exit
# -----------------------------------------------------------------------------
# : COUNT                              \ [hForth]
#   ( &Char -- &NextChar Chars )
#   DUP CHAR+ SWAP C@ ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {COUNT} Count 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : <S">                               \ Support for SLITERAL.
#   ( -- &Char Chars )                 \ NOTE: <S"> expects the return stack
#   R> COUNT 2DUP CHARS + ALIGNED >R   \ to hold the address of the next word
# ;                                    \ to execute.
# -----------------------------------------------------------------------------
pbAsm::Secondary {<S">} doSQUOTE 0 CORE

pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Count
pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Aligned
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SLITERAL                           \ From the String extension word set
#   ( &Char Chars -- ) \ Compile-time  \ Support for S" and ABORT"
#   ( -- &Char Chars ) \ Run-time
#   POSTPONE <S">                      \ Run-time behaviour
#   >R
#   R@ C,  HERE R@ CHARS MOVE
#   R> CHARS ALLOT ALIGN               \ MAF NEEDS CHANGING TO MATCH
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {SLITERAL} SLiteral {IMM+COMP} CORE

pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} doSQUOTE
pbAsm::Cell      {} ToR
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} CharComma
pbAsm::Cell      {} Here
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Move
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Allot
pbAsm::Cell      {} Align
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : S"                                 \ Parse ccc delimited by ".
#   ( C: "ccc<quote>" -- )             \ At run-time leave address and count.
#   ( -- &Char Chars )
#   [CHAR] " PARSE                     \ MAF NEEDS CHANGING TO MATCH
#   POSTPONE SLITERAL
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {S"} SQuote {IMM+COMP} CORE

pbAsm::Literal   {} '"'
pbAsm::Cell      {} Parse
pbAsm::Cell      {} SLiteral
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ."                                 \ Parse ccc delimited by ".
#   ( "ccc<quote>" -- )                \ At run-time display ccc.
#   POSTPONE S"
#   POSTPONE TYPE
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {."} DotQuote {IMM+COMP} CORE

pbAsm::Cell      {} SQuote
pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} Type
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# HERE CONSTANT &Hold                  \ As numbers are composed from the
#                                      \ right working leftwards, &Hold
#                                      \ points to the top of this space
#                                      \ rather than the base.
#
# VARIABLE Hld                         \ Support for <#, #, HOLD and #>.
#
# In this implementation, we're assuming that at link time, there is a
# buffer at _AddrHold set aside for this purpose...
# -----------------------------------------------------------------------------
pbAsm::Constant {&Hold} AddrHold _AddrHold {}

pbAsm::Variable {Hld} Hld 0 {}

# -----------------------------------------------------------------------------
# : <#  0 Hld ! ;                      \ [FW]
# -----------------------------------------------------------------------------

pbAsm::Secondary {<#} LessNumber 0 CORE
pbAsm::Literal   {} 0
pbAsm::Cell      {} Hld
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : HOLD
#   ( Char -- )
#   1 Hld +!
#   &Hold Hld @
#   CHARS - C!
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {HOLD} Hold 0 CORE

pbAsm::Literal   {} 1
pbAsm::Cell      {} Hld
pbAsm::Cell      {} PlusStore
pbAsm::Cell      {} AddrHold
pbAsm::Cell      {} Hld
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Minus
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : #>                                 \ [FW]
#   ( xd -- &Char Chars )
#   2DROP Hld @  &Hold OVER CHARS - SWAP
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {#>} NumberGreater 0 CORE

pbAsm::Cell      {} TwoDrop
pbAsm::Cell      {} Hld
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} AddrHold
pbAsm::Cell      {} Over
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Minus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SIGN                               \ [FW]
#   ( n -- )
#   0< IF [CHAR] - HOLD THEN
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {SIGN} Sign 0 CORE

pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SIGN1
pbAsm::Literal   {} '-'
pbAsm::Cell      {} Hold
pbAsm::Cell   SIGN1 Exit
# -----------------------------------------------------------------------------
# : MU/Mod                             \ [FW] Support for #.
#   ( d u -- u d )
#   >R 0 R@ UM/MOD R> SWAP >R UM/MOD R>
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {MU/Mod} MUSlashMod 0 {}

pbAsm::Cell      {} ToR
pbAsm::Literal   {} 0
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} UMSlashMod
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Swap
pbAsm::Cell      {} ToR
pbAsm::Cell      {} UMSlashMod
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Num>Char                           \ Support for #.
#   ( u -- Char )
#   [ DECIMAL ]
#   DUP 9 > IF
#     [ CHAR A 10 - ] LITERAL
#   ELSE
#     [CHAR] 0
#   THEN
#   +
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Num>Char} NumToChar 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Literal   {} 9
pbAsm::Cell      {} Greater
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} NTOC1
pbAsm::Literal   {} 'A'-10
pbAsm::Cell      {} Branch
pbAsm::Cell      {} NTOC2
pbAsm::Literal NTOC1 '0'
pbAsm::Cell   NTOC2 Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Char>Num                           \ [FW] Support for >NUMBER
#   ( Char -- u )
#   [ DECIMAL ]
#   DUP [CHAR] 9 > IF
#     [ CHAR A 10 - ] LITERAL
#   ELSE
#     [CHAR] 0
#   THEN
#   -
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Char>Num} CharToNum 0 {}

pbAsm::Cell      {} Dup
pbAsm::Literal   {} '9'
pbAsm::Cell      {} Greater
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} CTON1
pbAsm::Literal   {} 'A'-10
pbAsm::Cell      {} Branch
pbAsm::Cell      {} CTON2
pbAsm::Literal CTON1 '0'
pbAsm::Cell   CTON2 Minus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : #
#   ( ud1 -- ud2 )
#   BASE @ MU/Mod
#   ROT Num>Char HOLD
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {#} NumberSign 0 CORE

pbAsm::Cell      {} Base
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} MUSlashMod
pbAsm::Cell      {} Rot
pbAsm::Cell      {} NumToChar
pbAsm::Cell      {} Hold
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : #S
#   ( ud1 -- ud2 )
#   BEGIN  #  2DUP OR WHILE REPEAT
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {#S} NumberSignS 0 CORE

pbAsm::Cell  NUMS1  NumberSign
pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} Or
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} NUMS2
pbAsm::Cell      {} Branch
pbAsm::Cell      {} NUMS1
pbAsm::Cell  NUMS2 Exit
# -----------------------------------------------------------------------------
# : U.R                                \ [FW] From the Core Extensions word set.
#   ( u n -- )                         \ Used by U..
#   >R 0 <# #S #>                      \ Same as .R but for unsigned numbers.
#   R> OVER - SPACES TYPE
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {U.R} UDotR 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Literal   {} 0
pbAsm::Cell      {} LessNumber
pbAsm::Cell      {} NumberSignS
pbAsm::Cell      {} NumberGreater
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Over
pbAsm::Cell      {} Minus
pbAsm::Cell      {} Spaces
pbAsm::Cell      {} Type
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : U.  0 U.R SPACE ;                  \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {U.} UDot 0 CORE

pbAsm::Literal   {} 0
pbAsm::Cell      {} UDotR
pbAsm::Cell      {} Space
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : .R                                 \ [FW] From the Core Extensions word set.
#   ( n1 n2 -- )                       \ Used by ..
#   >R DUP >R  ABS 0 <# #S R> SIGN #>  \ Display n1 right aligned in a field
#   R> OVER - SPACES TYPE              \ n2 characters wide.
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {.R} DotR 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Abs
pbAsm::Literal   {} 0
pbAsm::Cell      {} LessNumber
pbAsm::Cell      {} NumberSignS
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Sign
pbAsm::Cell      {} NumberGreater
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Over
pbAsm::Cell      {} Minus
pbAsm::Cell      {} Spaces
pbAsm::Cell      {} Type
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : .  0 .R SPACE ;                    \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {.} Dot 0 CORE

pbAsm::Literal   {} 0
pbAsm::Cell      {} DotR
pbAsm::Cell      {} Space
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : MU*                                \ [FW] Support for >NUMBER
#   ( ud1 u -- ud2 )
#   SWAP OVER * >R  UM*  R> +
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {MU*} MUStar 0 CORE

pbAsm::Cell      {} Swap
pbAsm::Cell      {} Over
pbAsm::Cell      {} Star
pbAsm::Cell      {} ToR
pbAsm::Cell      {} UMStar
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Digit?                             \ Support for >NUMBER
#   ( char -- u flag )                 \ True if char is a digit in the
#   Char>Num DUP 0 BASE @ WITHIN       \ current base.
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Digit?} DigitQ 0 {}

pbAsm::Cell      {} CharToNum
pbAsm::Cell      {} Dup
pbAsm::Literal   {} 0
pbAsm::Cell      {} Base
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Within
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : >NUMBER                            \ ud1 is the unsigned result of
#   ( ud1 c-addr1 u1                   \ converting the string into digits
#     -- ud2 c-addr2 u2 )              \ using the current base and adding
#   >R                                 \ each into ud1 after multiplying ud1
#   BEGIN                              \ by the base.  u2 is the number of
#   R@ WHILE
#     DUP C@                           \ unconverted characters from c-addr2.
#   Digit? WHILE
#     SWAP >R >R
#     BASE @ MU*  R> US>D D+  R> CHAR+
#     R> 1- >R
#   REPEAT                             \ Target of first WHILE
#     DROP
#   THEN                               \ Target of second WHILE
#   R>
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {>NUMBER} ToNumber 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Cell  TONUM1 RFetch
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TONUM2
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} DigitQ
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TONUM3
pbAsm::Cell      {} Swap
pbAsm::Cell      {} ToR
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Base
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} MUStar
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} UStoD
pbAsm::Cell      {} DPlus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} OneMinus
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Branch
pbAsm::Cell      {} TONUM1
pbAsm::Cell  TONUM3 Drop
pbAsm::Cell  TONUM2 RFrom
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ABORT"
#   ( C: "ccc<quote>" -- )
#   ( i*x x1 -- !i*x )
#   POSTPONE IF
#     POSTPONE S"
#     POSTPONE AbortString     \ MAF+
#     POSTPONE 2!              \ MAF+
#     -2 POSTPONE LITERAL      \ MAF+  \ Standard value
#     POSTPONE THROW           \ MAF+
#   POSTPONE THEN
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {ABORT"} AbortQuote {IMM+COMP} CORE
   
pbAsm::Cell      {} If
pbAsm::Cell      {} SQuote
pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} AbortString
pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} TwoStore
pbAsm::Literal   {} -2
pbAsm::Cell      {} Literal
pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} Throw
pbAsm::Cell      {} Then
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------