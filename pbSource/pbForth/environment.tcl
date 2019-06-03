# -----------------------------------------------------------------------------
# environment.tcl - Core Forth words for dealing with environment variables
#
# Revision History
#
# R.Hempel 17May2002 Data and return stacks set at 96 elements each
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
# The full suite of environment variable manipulations is not implemented
# here. This is because MAF/PAF created their environment limitations based
# on the host capabilities, while we are free to define them in stone for
# our targets.
#
# The code for the unimplemented environment variables is still in the source,
# but is commented out.
# -----------------------------------------------------------------------------
# Design Note: Environment Word List
# ----------------------------------
# The Environment word list is similar to but disjoint from the default word
# list.  Words like CREATE and ' can be applied to the Environment word list
# by changing Head temporarily.
# -----------------------------------------------------------------------------
# VARIABLE EHead                       \ Same as Head but for environment
#                                      \ word list
# -----------------------------------------------------------------------------
pbAsm::Variable {EHead} EHead lastENV {}

# -----------------------------------------------------------------------------
# : ECreate                            \ Same as CREATE but for environment
#   ( x "<spaces>name" -- x )          \ word list
#   Head @ >R  EHead @ Head !
#   CREATE
#   Head @ EHead !  R> Head !  ;
# -----------------------------------------------------------------------------
# pbSecondary {ECreate} ECreate 0 CORE
#
# pbCell      {} Head
# pbCell      {} Fetch
# pbCell      {} ToR
# pbCell      {} EHead
# pbCell      {} Fetch
# pbCell      {} Head
# pbCell      {} Store
# pbCell      {} Create
# pbCell      {} Head
# pbCell      {} Fetch
# pbCell      {} EHead
# pbCell      {} Store
# pbCell      {} RFrom
# pbCell      {} Head
# pbCell      {} Store
# pbCell      {} Exit
# -----------------------------------------------------------------------------
# : EConstant                          \ Same as CONSTANT but for environment
#   ( x "<spaces>name" -- )            \ word list
#   ( -- x )
#   ECreate COMPILE,
#   DOES> @ ;
# -----------------------------------------------------------------------------
# pbSecondary {EConstant} EConstant 0 CORE
#
# pbCell      {} ECreate
# pbCell      {} Comma
# pbCell      {} DoesGreater
# pbCell      {} Fetch
# pbCell      {} Exit
# -----------------------------------------------------------------------------
# : E2Constant                         \ Same as EConstant but for double
#   ( x1x2 "<spaces>name" -- )         \ numbers.  Needed by MAX-D.
#   ( -- x1x2 )
#   ECreate COMPILE, COMPILE,
#   DOES> 2@ ;
# -----------------------------------------------------------------------------
# pbSecondary {E2Constant} ETwoConstant 0 CORE 
#
# pbCell      {} ECreate
# pbCell      {} Comma
# pbCell      {} Comma
# pbCell      {} DoesGreater
# pbCell      {} TwoFetch
# pbCell      {} Exit

# -----------------------------------------------------------------------------
#                                      \ Not ANS - support for I/O words.
# : E'                                 \ Reads from the input stream and
#   ( "<spaces>name" -- i*x )          \ extracts "name" from environment
#   Head @ >R  EHead @ Head !          \ word list.  Aborts if name is not
#   ' EXECUTE                          \ present.  Needed only until
#   R> Head ! ;                        \ EVALUATE is defined and used to
#                                      \ extract /HOLD and MAX-CHAR.
# -----------------------------------------------------------------------------
# pbSecondary {E'} ETick 0 CORE
#
# pbCell      {} Head
# pbCell      {} Fetch
# pbCell      {} ToR
# pbCell      {} EHead
# pbCell      {} Fetch
# pbCell      {} Head
# pbCell      {} Store
# pbCell      {} Tick
# pbCell      {} Execute
# pbCell      {} RFrom
# pbCell      {} Head
# pbCell      {} Store
# pbCell      {} Exit
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# : ENVIRONMENT?
#   ( &String Chars -- FALSE | i*x TRUE )
#   Head @ >R  EHead @ Head !
#   ParseFind IF
#     DROP EXECUTE TRUE
#   ELSE
#     2DROP FALSE
#   THEN
#   R> Head ! ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {ENVIRONMENT?} EnvironmentQ 0 CORE

pbAsm::Cell      {} Head
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} ToR
pbAsm::Cell      {} EHead
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Head
pbAsm::Cell      {} Store
pbAsm::Cell      {} ParseFind
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ENVQ1
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Execute
pbAsm::Cell      {} True
pbAsm::Cell      {} Branch
pbAsm::Cell      {} ENVQ2
pbAsm::Cell   ENVQ1 TwoDrop
pbAsm::Cell      {} False
pbAsm::Cell   ENVQ2 RFrom
pbAsm::Cell      {} Head
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# VARIABLE MaxCharLength               \ Compute the largest positive number
# TRUE MaxCharLength C!                \ which a character can represent.
# MaxCharLength C@
#       EConstant /COUNTED-STRING
# Bits/Cell 2* 2 +
#       EConstant /HOLD                \ Minimum required by ANS
# \ PAD is not in the CORE so the next entry is commented out
# \  84 EConstant /PAD                 \ Minimum value required by ANS
# FindBits/AU
#       EConstant ADDRESS-UNIT-BITS
#  TRUE EConstant CORE
# FALSE EConstant CORE-EXT
#  TRUE EConstant FLOORED
#   126 EConstant MAX-CHAR             \ Minimum value required by ANS
#                                      \ These next conversions are suitable
#                                      \ for all ANS number reporesentations.
# HighBit INVERT                       \
#   DUP EConstant MAX-N                \ ( -- MAX-N )
# DUP HighBit OR
#   DUP EConstant MAX-U                \ ( -- MAX-N MAX-U )
#      E2Constant MAX-D
#
#                                      \ Choose stack sizes large enough for
#                                      \ the recursive (UM/MOD) (which also
#                                      \ uses >R >R).
#    93 EConstant STACK-CELLS
#    93 EConstant RETURN-STACK-CELLS
# -----------------------------------------------------------------------------
pbAsm::Constant  {/COUNTED-STRING}    SlashCStr          255 ENV
pbAsm::Constant  {/HOLD}              SlashHold           34 ENV
pbAsm::Constant  {/PAD}               SlashPad            84 ENV
pbAsm::Constant  {ADDRESS-UNIT-BITS}  AUBits              16 ENV
pbAsm::Constant  {CORE}               Core                -1 ENV
pbAsm::Constant  {CORE-EXT}           CoreExt              0 ENV
pbAsm::Constant  {FLOORED}            Floored             -1 ENV
pbAsm::Constant  {MAX-CHAR}           MaxChar            126 ENV
                                                 
pbAsm::Constant  {MAX-N}              MaxSigned        32767 ENV
pbAsm::Constant  {MAX-U}              MaxUnsigned      65535 ENV
pbAsm::2Constant {MAX-D}              MaxDouble   2147483647 ENV

pbAsm::Constant  {STACK-CELLS}        StackCells          93 ENV
pbAsm::Constant  {RETURN-STACK-CELLS} ReturnStackCells    93 ENV
# -----------------------------------------------------------------------------