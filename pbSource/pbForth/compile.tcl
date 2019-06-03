# -----------------------------------------------------------------------------
# compile.tcl - Core Forth words for compiling new words
#
# Revision History
#
# R.Hempel 17May2002 Moved Head next to Latest for clarity
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
pbAsm::Variable  {STATE}      State      0         CORE
pbAsm::Variable  {DP}         DP         initialDP CORE
pbAsm::Variable  {Head}       Head       lastCORE  {}
pbAsm::Variable  {Latest}     Latest     lastCORE  {}
pbAsm::Variable  {Incomplete} Incomplete 0         {}

# -----------------------------------------------------------------------------
# Design Note: Word List
# ----------------------
# Word names are recorded in headers forming a simple linked list.  The
# headers have the following structure:
#
# -LF&--- -NF&--------                                -CF&---- -PF&------
# Link   | Name       | Length | Padding | Immediate | Code   | Parameter
# Field  | Field      | Count  | Chars   | Flag      | Field  | Field
# 1 cell | 1-31 chars | 1 char | n Chars | 1 char    | 1 cell | n cells
#
# The Link Field points to the Link Field of the previous definition.
# The Name Field contains 1-31 printable characters.
# Zero or more null padding characters (value 0) are provided to align the
# Code Field.
# The Immediate Flag is non-zero to indicate an immediate word.
#
# The Immediate Flag is next to the Code Field, from where it can be found
# easily.
# The Length Count is after the Name Field, not before it, so that the count
# can serve as a sentinel terminating attempts by FIND and hSearchWordList to
# match the name with a reference name.  Its position also allows the name
# field to be traversed in the reverse direction, starting from the Code Field
# so that a name can be found from its execution token.
# -----------------------------------------------------------------------------
# : L>Name
#   ( LinkField& -- NameField& )
#   CELL+
# -----------------------------------------------------------------------------
pbAsm::Secondary {L>Name} LinkToName 0 {}

pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Name> ( NF& -- CodeField& )
#   BEGIN                         \ Step on to the Length Count
#     CHAR+
#   DUP C@ BL < UNTIL
#   CHAR+                         \ Step beyond the Length Count
#   CHAR+                         \ and the Immediate Flag
#   ALIGNED                       \ and any padding.
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Name>} NameToCFA 0 {}

pbAsm::Cell NTOCFA1 CharPlus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Blank
pbAsm::Cell      {} Less
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} NTOCFA1
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} Aligned
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Link> ( LF& -- CF& )
#   L>Name Name>
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Link>} LinkToCFA 0 {}
pbAsm::Cell      {} LinkToName
pbAsm::Cell      {} NameToCFA
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : >Name ( CF& -- NF& )
#   [ -1 CHARS ] LITERAL +        \ Step back over the Immediate Flag.
#   BEGIN                         \ Step back to the Length Count.
#     [ -1 CHARS ] LITERAL +
#   DUP C@ UNTIL
#   DUP C@ CHARS -                \ Jump back to the Name Field.
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {>Name} CFAtoName 0 {}

pbAsm::Literal   {} -(BytesPerCHAR)
pbAsm::Cell      {} Plus
pbAsm::Literal CFATON1 -(BytesPerCHAR)
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} CFATON1
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Minus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : N>Link ( NF& -- LF& )
#   [ -1 hCELLS ] LITERAL +
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {N>Link} NameToLink 0 {}

pbAsm::Literal   {} -(BytesPerCELL)
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : >Flags ( CF& -- &IFlag )
#   1 hCHARS -
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {>Flags} CFAtoFlags 0 {}

pbAsm::Literal   {} BytesPerCHAR
pbAsm::Cell      {} Minus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : IsImmediate?
#   ( CF& -- 1=Yes,-1=No )
#   >Imm
#   C@ IsImmediate = IF  1  ELSE  -1  THEN
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {IsImmediate?} IsImmediateQ 0 {}

pbAsm::Cell      {} CFAtoFlags
pbAsm::Cell      {} CharFetch
pbAsm::Literal   {} IMM
pbAsm::Cell      {} And
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ISIMM1
pbAsm::Literal   {} 1
pbAsm::Cell      {} Branch
pbAsm::Cell      {} ISIMM2
pbAsm::Literal ISIMM1 -1
pbAsm::Cell ISIMM2  Exit
# -----------------------------------------------------------------------------
# : IsCompileOnly?
#   ( CF& -- !0=Yes,0=No )
#   >Imm
#   C@ IsCompileOnly AND
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {IsCompileOnly?} IsCompileOnlyQ 0 {}

pbAsm::Cell      {} CFAtoFlags
pbAsm::Cell      {} CharFetch
pbAsm::Literal   {} COMP
pbAsm::Cell      {} And
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : AddLink ( -- )               \ Adds a link field to the word list
#   ALIGN
#   Head @ DUP IF
#    >Name N>Link                \ Head holds CF& not LF&.
#   THEN
#   ,                            \ Add link field
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {AddLink} AddLink 0 {}

pbAsm::Cell      {} Align
pbAsm::Cell      {} Head
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ADDLNK1
pbAsm::Cell      {} CFAtoName
pbAsm::Cell      {} NameToLink
pbAsm::Cell ADDLNK1 CompileComma
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : AddPadding                   \ Adds padding characters to ensure code field
#   ( -- CF& )                   \ is aligned.  Also adds space for Immediate.
#                                \ Returns code field address.
#   DP @
#   1 CHARS ALLOT                \ Allow for Immediate Char.
#   ALIGN
#   DP @ SWAP                    \ -- DPAligned DPBefore )
#   BEGIN
#   2DUP > WHILE                 \ While & is not aligned ...
#     0 OVER C!                  \ Pad with zeroes.
#     CHAR+
#   REPEAT
#   DROP
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {AddPadding} AddPadding 0 {}

pbAsm::Cell      {} DP
pbAsm::Cell      {} Fetch
pbAsm::Literal   {} 1
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Allot
pbAsm::Cell      {} Align
pbAsm::Cell      {} DP
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Swap
pbAsm::Cell ADDNAM1 TwoDup
pbAsm::Cell      {} Greater
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ADDNAM2
pbAsm::Literal   {} 0
pbAsm::Cell      {} Over
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} CharPlus
pbAsm::Cell      {} Branch
pbAsm::Cell      {} ADDNAM1
pbAsm::Cell ADDNAM2 Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : AddName                       \ After the link field appends a name, with
#   ( &String Count -- )          \ padding and immediate char.
#   ( Convert to upper case )     \ Insert code here to remove case-sensitivity.
#   ( Abort if Count >= BL )      \ Insert checks here for names too long.
#   ( Abort if String invalid )   \ Insert checks here for control chars.
#   >R                            \ Save Count.
#   DP @                          \ -- &From &To )
#   R@ CHARS ALLOT                \
#   R@ CHARS MOVE                 \
#   R> C,                         \ Add terminating Count char
#   AddPadding Latest !           \ and padding.
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {AddName} AddName 0 {}

pbAsm::Cell      {} ToR
pbAsm::Cell      {} DP
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Allot
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Move
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} CharComma
pbAsm::Cell      {} AddPadding
pbAsm::Cell      {} Latest
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ParseName
#   ( -- &String Count )
#   BL WORD COUNT
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {ParseName} ParseName 0 {}

pbAsm::Cell      {} Blank
pbAsm::Cell      {} SkipParse
pbAsm::Literal   {} 31
pbAsm::Cell      {} Min
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Header
#   ( -- )
#   ParseName AddLink AddName
#   Latest @
#   Head !             \ Add name to word list.
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Header} Header 0 {}

pbAsm::Cell      {} ParseName
pbAsm::Cell      {} AddLink
pbAsm::Cell      {} AddName
pbAsm::Cell      {} Latest
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Head
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
pbAsm::Secondary {SetWordFlags} SetWordFlags 0 {}

pbAsm::Cell {}          CFAtoFlags
pbAsm::Cell {}          Swap
pbAsm::Cell {}          Dup
pbAsm::Cell {}          Invert
pbAsm::Literal {}       2
pbAsm::Cell {}          Pick
pbAsm::Cell {}          CharFetch
pbAsm::Cell {}          And
pbAsm::Cell {}          Or
pbAsm::Cell {}          Swap
pbAsm::Cell {}          CharStore
pbAsm::Cell {}          Exit
# -----------------------------------------------------------------------------
# : IMMEDIATE
#   IsImmediate Head @ SetWordFlags
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {IMMEDIATE} Immediate 0 CORE

pbAsm::Literal   {} IMM
pbAsm::Cell      {} Head
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} SetWordFlags
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : COMPILE-ONLY
#   IsCompileOnly Head @ SetWordFlags
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {COMPILE-ONLY} CompileOnly 0 CORE

pbAsm::Literal   {} COMP
pbAsm::Cell      {} Head
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} SetWordFlags
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SearchWordList                \ Search target word list for a match with
# \ ( &ReferenceString LF& --     \ ReferenceString.  Uses a sentinel method
# \   -- CF&|0 )                  \ for fast searching so the ReferenceString
#                                 \ must end in BL.
#                                 \ Assumes word list is not empty.
#   BEGIN
#   DUP WHILE                     \ While not at end of list ...
#     2DUP CELL+ MatchString
#     C@ BL < IF                  \ If target terminator found ...
#       C@ BL = IF                \ If reference terminator found ...
#         Link> SWAP DROP EXIT
#       THEN
#     ELSE
#       DROP
#     THEN
#     @
#   REPEAT
#   2DROP 0
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {SearchWordList} SearchWordList 0 {}

pbAsm::Cell SWLIST1 Dup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SWLIST2
pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} MatchString
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Blank
pbAsm::Cell      {} Less
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SWLIST3
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} Blank
pbAsm::Cell      {} Equal
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SWLIST5
pbAsm::Cell      {} LinkToCFA
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
pbAsm::Cell SWLIST5 Branch
pbAsm::Cell      {} SWLIST4
pbAsm::Cell SWLIST3 Drop
pbAsm::Cell SWLIST4 Fetch
pbAsm::Cell      {} Branch
pbAsm::Cell      {} SWLIST1
pbAsm::Cell SWLIST2 TwoDrop
pbAsm::Literal   {} 0
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ParseFind                     \ Does FIND on the target word list but
#                                 \ requires 2 parameters, not a counted string.
# \ ( &String Count -- CF& ImmediateFlag TRUE )
# \ (               or &String Count    FALSE )
#   DUP IF                        \ If String is not empty ...
#     2DUP CHARS +                \ Get & for sentinel.
#     DUP >R DUP C@ >R            \ Save it and character at sentinel.
#     BL SWAP C!                  \ Set sentinel to BL.
#     OVER Head @
#     DUP IF                      \ If word list not empty ...
#       >Name N>Link SearchWordList DUP IF
#         >R 2DROP R>
#         DUP IsImmediate? TRUE
#       THEN
#     ELSE
#       SWAP DROP
#     THEN
#     R> R> C!                    \ Restore sentinel.
#   ELSE
#     FALSE
#   THEN
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {ParseFind} ParseFind 0 {}

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} PFIND1
pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} Chars
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CharFetch
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Blank
pbAsm::Cell      {} Swap
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Over
pbAsm::Cell      {} Head
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} PFIND3
pbAsm::Cell      {} CFAtoName
pbAsm::Cell      {} NameToLink
pbAsm::Cell      {} SearchWordList
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} PFIND5
pbAsm::Cell      {} ToR
pbAsm::Cell      {} TwoDrop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Dup
pbAsm::Cell      {} IsImmediateQ
pbAsm::Cell      {} True
pbAsm::Cell  PFIND5 Branch
pbAsm::Cell      {} PFIND4
pbAsm::Cell  PFIND3 Swap
pbAsm::Cell      {} Drop
pbAsm::Cell  PFIND4 RFrom
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} CharStore
pbAsm::Cell      {} Branch
pbAsm::Cell      {} PFIND2
pbAsm::Cell  PFIND1 False
pbAsm::Cell  PFIND2 Exit
# -----------------------------------------------------------------------------
# : 'Immediate                   \ Support for ' and POSTPONE
#   ( ++ -- CF& ImmediateFlag )
#   BL WORD COUNT
#   ParseFind 0= IF
#     CR ." ' cannot find "
#     HERE COUNT TYPE ABORT
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {'Immediate} TickImmediate 0 {}

pbAsm::Cell      {} Blank
pbAsm::Cell      {} SkipParse
pbAsm::Cell      {} ParseFind
pbAsm::Cell      {} ZeroEqual
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TICKIM1
pbAsm::Cell      {} CR
pbAsm::Cell      {} doSQUOTE
pbAsm::CString   {} {' cannot find }
pbAsm::Cell      {} Type
pbAsm::Cell      {} Here
pbAsm::Cell      {} Count
pbAsm::Cell      {} Type
pbAsm::Cell      {} Abort
pbAsm::Cell TICKIM1 Exit
# -----------------------------------------------------------------------------
# : '                            \ Does ' on the target word list
#   ( ++ -- CF& )
#   'Immediate DROP ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {'} Tick 0 CORE

pbAsm::Cell      {} TickImmediate
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : >BODY                           \ >BODY ( xt -- &DataField )
#   DUP @
#   [ ' <Does> ] LITERAL = IF       \ Word was defined using CREATE
#     CELL+                         \ so skip over 2nd cell in code field
#   THEN
#   CELL+ ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {>BODY} ToBody 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} Fetch
pbAsm::Literal   {} doDOES+2
pbAsm::Cell      {} Equal
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} TOBODY1
pbAsm::Cell      {} CellPlus
pbAsm::Cell TOBODY1 CellPlus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : Reveal ( -- ) Latest @ Head ! ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {Reveal} Reveal 0 {}

pbAsm::Cell      {} Latest
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Head
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : [  ( -- )
#   0 STATE !
# ; IMMEDIATE
# -----------------------------------------------------------------------------
pbAsm::Secondary {[} LeftBracket IMM CORE

pbAsm::Literal   {} 0
pbAsm::Cell      {} State
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ]  ( -- )
#   -1 STATE !
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {]} RightBracket 0 CORE

pbAsm::Literal   {} -1
pbAsm::Cell      {} State
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# ---------------------------------------------------------------------------
# : RECURSE                    \ Define RECURSE to exclude its use       
#   Incomplete @ 1 > IF        \ after DOES> .. ;.  Not sure why this may
#     -27 THROW                \ be disallowed.  It seems OK to me.      
#   THEN
#   Latest @ COMPILE,
# ; IMMEDIATE
# ---------------------------------------------------------------------------
pbAsm::Secondary {RECURSE} Recurse {IMM+COMP} CORE

pbAsm::Cell {}          Incomplete
pbAsm::Cell {}          Fetch
pbAsm::Literal {}       1
pbAsm::Cell {}          Greater
pbAsm::Cell {}          ZBranch
pbAsm::Cell {}          RECURSE1
pbAsm::Literal {}         -27
pbAsm::Cell {}            Throw
pbAsm::Cell {RECURSE1}  Latest
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          CompileComma
pbAsm::Cell {}          Exit
# --------------------------------------------------------------------------- 
# : COMPILE,                   \ And redefine COMPILE, to prevent its use
#   ( xt -- )                  \ during a definition - see ANS 3.4.5
#   Incomplete @ IF -29 THROW EXIT THEN
#   ALIGN DP @ !
#   [ 1 CELLS ] LITERAL ALLOT ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {COMPILE,} CompileComma 0 CORE

# pbCell {}          Incomplete
# pbCell {}          Fetch
# pbCell {}          ZBranch
# pbCell {}          CCOMMA1
# pbLiteral {}         -29
# pbCell {}            Throw
# pbCell {}            Exit
pbAsm::Cell {CCOMMA1}   Align
pbAsm::Cell {}          DP
pbAsm::Cell {}          Fetch
pbAsm::Cell {}          Store
pbAsm::Literal {}       BytesPerCELL
pbAsm::Cell {}          Allot
pbAsm::Cell {}          Exit
# ---------------------------------------------------------------------------
# : LITERAL   \ ( C: x -- )
#             \ ( -- x )       \ This definition would be simpler if
#   [ ' <Literal> COMPILE,     \ recursive definition is possible :-)
#     ' <Literal> COMPILE, ]   \
#   COMPILE, COMPILE,          \ (The code repeats as DUP is not defined yet)
# ; IMMEDIATE COMPILE-ONLY
# --------------------------------------------------------------------------- 
pbAsm::Secondary {LITERAL} Literal IMM+COMP CORE

pbAsm::Cell      {} doCOMPILE
pbAsm::Cell      {} doLIT
pbAsm::Cell      {} CompileComma
pbAsm::Cell      {} Exit
# --------------------------------------------------------------------------- 
# tI : [']  \ ( C: "<spaces>name" -- )
#           \ ( -- xt )
# tI   '
# tI   POSTPONE LITERAL
# tI ; IMMEDIATE COMPILE-ONLY
# --------------------------------------------------------------------------- 
pbAsm::Secondary {[']} BracketTick {IMM+COMP} CORE

pbAsm::Cell      {} Tick
pbAsm::Cell      {} Literal
pbAsm::Cell      {} Exit
# --------------------------------------------------------------------------- 
# : DOES>  \ ( C: -- )
#          \ ( -- &DataField )
#   R>
#   Latest @
#   CELL+ ! ;
# --------------------------------------------------------------------------- 
pbAsm::Secondary {DOES>} DoesGreater {COMP} CORE

pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Latest
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : CREATE  \ ( C: "<spaces>name" -- )
#           \ ( -- &DataField )
#   Header Reveal
#   [ <Does> ] LITERAL COMPILE,        \ Place <Does> in the code field.
#   0 COMPILE,                         \ <Does> needs an extra cell in the
#                                      \ code field for a pointer to new code.
#   ALIGN
#   DOES> EXIT                         \ DOES> here fills the extra cell with
# ;                                    \ a pointer to EXIT.  This is the
#                                      \ default behaviour for
#                                      \ CREATEd words and is overwritten by
#                                      \ executing DOES> before the end of
#                                      \ the current definition.
# -----------------------------------------------------------------------------
pbAsm::Secondary {CREATE} Create 0 CORE

pbAsm::Cell      {} Header
pbAsm::Cell      {} Reveal
pbAsm::Literal   {} doDOES+2
pbAsm::Cell      {} CompileComma
pbAsm::Literal   {} 0
pbAsm::Cell      {} CompileComma
pbAsm::Cell      {} Align
pbAsm::Cell      {} DoesGreater
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : CONSTANT \ ( x "<spaces>name" -- ) \ Alternative definition:
#            \ ( -- x )                \   : CONSTANT
#   Header Reveal                      \     CREATE , DOES> @
#   [ <Constant> ] LITERAL COMPILE,    \   ;
#   , ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {CONSTANT} Constant 0 CORE

pbAsm::Cell      {} Header
pbAsm::Cell      {} Reveal
pbAsm::Literal   {} doCONST+2
pbAsm::Cell      {} CompileComma
pbAsm::Cell      {} Comma
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : VARIABLE   \ ( "<spaces>name" -- ) \ Note that a Standard Program must
#                ( -- &DataField )     \ not assume that a variable is
#   Header Reveal                      \ initialised to 0 as VARIABLE does
#   [ <Variable> ] LITERAL COMPILE,    \ here.
#   0 ,                                \ Alternative definition:
# ;                                    \   : VARIABLE
#                                      \     CREATE 0 , DOES>
#                                      \   ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {VARIABLE} Variable 0 CORE

pbAsm::Cell      {} Header
pbAsm::Cell      {} Reveal
pbAsm::Literal   {} doVAR+2
pbAsm::Cell      {} CompileComma
pbAsm::Literal   {} 0
pbAsm::Cell      {} Comma
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : <Compile>                     \ <Compile> ( ++ -- )
#                                 \ A primitive for POSTPONE to use.  It will
#                                 \ not appear in the target dictionary.
#   R>                            \ Increment Interpret Pointer to skip over
#   DUP CELL+ >R                  \ next word.
#   @ COMPILE,                    \ Add the next word to the current definition.
#                                 \ Note: Within a : word, we could increment
# ;                               \ the top of the Return Stack.  As we are
#                                 \ within a primitive, we must adjust IP instead.
# -----------------------------------------------------------------------------
pbAsm::Secondary {<Compile>} doCOMPILE 0 {}

pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Dup
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} CompileComma
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : pPOSTPONE ( T( ++ -- )
#   'Immediate
#   IsImmediate = 0= IF
#     [ <Compile> ] COMPILE,        \ Compile a headerless primitive by compiling
#   THEN                            \ a pointer to the code.
#   COMPILE, ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {POSTPONE} Postpone IMM CORE

pbAsm::Cell      {} TickImmediate
pbAsm::Literal   {} IMM
pbAsm::Cell      {} Equal
pbAsm::Cell      {} ZeroEqual
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} POSTP1
pbAsm::Literal   {} doCOMPILE
pbAsm::Cell      {} CompileComma
pbAsm::Cell  POSTP1 CompileComma
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------