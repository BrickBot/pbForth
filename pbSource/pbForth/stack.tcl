# -----------------------------------------------------------------------------
# stack.tcl - Core Forth words for stack manipulations
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
# : DUP  0 PICK ;              \ ( x -- x x )
# -----------------------------------------------------------------------------
pbAsm::Secondary {DUP} Dup 0 CORE

pbAsm::Literal   {} 0
pbAsm::Cell      {} Pick
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : OVER  1 PICK ;             \ ( x1 x2 -- x1 x2 x1 )
# -----------------------------------------------------------------------------
pbAsm::Secondary {OVER} Over 0 CORE

pbAsm::Literal   {} 1
pbAsm::Cell      {} Pick
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : SWAP  1 ROLL ;             \ ( x1 x2 -- x2 x1 )
# -----------------------------------------------------------------------------
pbAsm::Secondary {SWAP} Swap 0 CORE

pbAsm::Literal   {} 1
pbAsm::Cell      {} Roll
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ROT  2 ROLL ;              \ ( x1 x2 x3 -- x2 x3 x1 )
# -----------------------------------------------------------------------------
pbAsm::Secondary {ROT} Rot 0 CORE

pbAsm::Literal   {} 2
pbAsm::Cell      {} Roll
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 2DUP  OVER OVER ;          \ ( x1 x2 -- x1 x2 x1 x2 )
# -----------------------------------------------------------------------------
pbAsm::Secondary {2DUP} TwoDup 0 CORE

pbAsm::Cell      {} Over
pbAsm::Cell      {} Over
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 2DROP  DROP DROP ;         \ ( x1 x2 -- )
# -----------------------------------------------------------------------------
pbAsm::Secondary {2DROP} TwoDrop 0 CORE

pbAsm::Cell      {} Drop
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 2OVER  3 PICK  3 PICK ;    \ ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
# -----------------------------------------------------------------------------
pbAsm::Secondary {2OVER} TwoOver 0 CORE

pbAsm::Literal   {} 3
pbAsm::Cell      {} Pick
pbAsm::Literal   {} 3
pbAsm::Cell      {} Pick
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 2SWAP  3 ROLL  3 ROLL ;    \ ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
# -----------------------------------------------------------------------------
pbAsm::Secondary {2SWAP} TwoSwap 0 CORE

pbAsm::Literal   {} 3
pbAsm::Cell      {} Roll
pbAsm::Literal   {} 3
pbAsm::Cell      {} Roll
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ?DUP  DUP  IF DUP THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {?DUP} QuestionDup 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} QDUP1
pbAsm::Cell      {} Dup
pbAsm::Cell {QDUP1} Exit
# -----------------------------------------------------------------------------