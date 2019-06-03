# -----------------------------------------------------------------------------
# compare.tcl - Core Forth words for arithmetic comparison
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
pbAsm::Constant {FALSE} False  0 CORE
pbAsm::Constant {TRUE}  True  -1 CORE
# -----------------------------------------------------------------------------
# : 0=  IF FALSE ELSE TRUE THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {0=} ZeroEqual 0 CORE

pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ZEQ1
pbAsm::Cell      {} False
pbAsm::Cell      {} Branch
pbAsm::Cell      {} ZEQ2
pbAsm::Cell    ZEQ1 True
pbAsm::Cell    ZEQ2 Exit
# -----------------------------------------------------------------------------
# : =  - 0= ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {=} Equal 0 CORE

pbAsm::Cell      {} Minus
pbAsm::Cell      {} ZeroEqual
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 0<>  0= INVERT ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {0<>} ZeroNotEqual 0 CORE

pbAsm::Cell      {} ZeroEqual
pbAsm::Cell      {} Invert
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : <>  = INVERT ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {<>} NotEqual 0 CORE

pbAsm::Cell      {} Equal
pbAsm::Cell      {} Invert
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 0<  HighBit AND 0<> ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {0<} ZeroLess 0 CORE

pbAsm::Literal   {} HighBit
pbAsm::Cell      {} And
pbAsm::Cell      {} ZeroNotEqual
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 0>  NEGATE 0< ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {0>} ZeroGreater 0 CORE

pbAsm::Cell      {} Negate
pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# Design Note: U< and <
# ---------------------
# U< and < are tricky.  Using - gives the right result for values which are
# less then MaxPos apart.  If the values have a different sign,
# then just check the sign of one.
# -----------------------------------------------------------------------------
# : U<
#   ( u1 u2 -- Truth )
#   2DUP SignsDiffer? IF
#     SWAP DROP                        \ Drop u1.  Prepare to test u2 < 0.
#   ELSE
#     -
#   THEN
#   0<
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {U<} ULess 0 CORE

pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} SignsDifferQ
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ULESS1
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Branch
pbAsm::Cell      {} ULESS2
pbAsm::Cell  ULESS1 Minus
pbAsm::Cell  ULESS2 ZeroLess
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : <
#   ( n1 n2 -- Truth )
#   2DUP SignsDiffer? IF
#     DROP                             \ Drop n2.  Prepare to test n1 < 0.
#   ELSE
#     -
#   THEN
#   0<
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {<} Less 0 CORE

pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} SignsDifferQ
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} LESS1
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Branch
pbAsm::Cell      {} LESS2
pbAsm::Cell   LESS1 Minus
pbAsm::Cell   LESS2 ZeroLess
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : U> SWAP U< ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {U>} UGreater 0 CORE

pbAsm::Cell      {} Swap
pbAsm::Cell      {} ULess
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : >  SWAP < ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {>} Greater 0 CORE

pbAsm::Cell      {} Swap
pbAsm::Cell      {} Less
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ABS  DUP 0< IF NEGATE THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {ABS} Abs 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} ABS1
pbAsm::Cell      {} Negate
pbAsm::Cell   ABS1  Exit
# -----------------------------------------------------------------------------
# : MAX  2DUP < IF SWAP THEN DROP ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {MAX} Max 0 CORE

pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} Less
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} MAX1
pbAsm::Cell      {} Swap
pbAsm::Cell   MAX1  Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : MIN  2DUP > IF SWAP THEN DROP ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {MIN} Min 0 CORE

pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} Greater
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} MIN1
pbAsm::Cell      {} Swap
pbAsm::Cell   MIN1  Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : WITHIN                             \ From the Core Extensions word set.
#( n1|u1 n2|u2 n3|u3 -- Truth )        \ Used by Graphic? and Digit?.
#                                      \ Taken from the ANS document.
#   OVER -                             \ Calculate n3-n2
#   >R
#   -                                  \ Calculate n1-n2
#   R> U<                              \ True if n2 <= n1 and n1 < n3 where
# ;                                    \ numbers are all signed or all
#                                      \ unsigned as in:
#                                      \ u-------n2....n1....n3---------o
#                                      \ Where n3 < n2, then true if n2 <= n1
#                                      \ or n1 < n3 as in:
#                                      \ u..n1..n3--------------n2......o
# -----------------------------------------------------------------------------
pbAsm::Secondary {WITHIN} Within 0 CORE

pbAsm::Cell      {} Over
pbAsm::Cell      {} Minus
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Minus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} ULess
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SignsDiffer?                       \ Support for <+Loop> < U< and M*.
#   ( n1 n2 -- Truth )                 \ HighBit is set for -ve integers.
#   XOR                                \ Find the bits which differ.
#   HighBit AND 0<>                    \ Is one of them the HighBit?
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {SignsDiffer?} SignsDifferQ 0 {}

pbAsm::Cell      {} Xor
pbAsm::Literal   {} HighBit
pbAsm::Cell      {} And
pbAsm::Cell      {} ZeroNotEqual
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------