# -----------------------------------------------------------------------------
# double.tcl - Core Forth words for dealing with double integers
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
# Design Note: When the integer representation is Two's Complement, then
# simpler conversions are possible - see Appendix D.
#
# Design Note: The next 2 words US>D and UD>S are not from ANS.  They are
# used to improve code clarity by indicating integer conversions.  UD>S is
# also used to check for loss of precision.
# -----------------------------------------------------------------------------
# APPENDIX D - Alternative Definitions For Two's Complement Arithmetic
# ====================================================================
# Note: If Two's Complement is used, then several simplifications are
# possible:
#
# : NEGATE  INVERT 1+ ;
#
# : DNEGATE   \ ( d1 -- d2 )           \ [FW] From the Double-Number word set.
#   INVERT SWAP INVERT SWAP 1 0 D+     \ Used by DABS, M* and UM/MOD
# ;
#
# : S>D  DUP 0< ;
#
# : D>S  DROP ;
# -----------------------------------------------------------------------------
# : US>D                               \ Convert the number u to the
#   ( u -- ud )                        \ number d with the same numerical
#   0 ;                                \ value.
# -----------------------------------------------------------------------------
pbAsm::Secondary {US>D} UStoD 0 CORE

pbAsm::Literal   {} 0
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : UD>S                               \ Convert the double number ud to the
#   ( ud -- u )                        \ single number u with the same
#   DROP ;                             \ numerical value.
# -----------------------------------------------------------------------------
pbAsm::Secondary {UD>S} UDtoS 0 CORE

pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : S>D                                \ Convert the number n to the
#   ( n -- d )                         \ number d with the same numerical
#   DUP 0< IF                          \ value.  Used by /MOD.
#     NEGATE  US>D  DNEGATE
#   ELSE
#     US>D
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {S>D} StoD 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} STOD1
pbAsm::Cell      {} Negate
pbAsm::Cell      {} UStoD
pbAsm::Cell      {} DNegate
pbAsm::Cell      {} Branch
pbAsm::Cell      {} STOD2
pbAsm::Cell   STOD1 UStoD
pbAsm::Cell   STOD2 Exit
# -----------------------------------------------------------------------------
# : D>S                                \ Convert the double number d to the
#   ( d -- n )                         \ single number n with the same
#   DUP 0< IF                          \ numerical value.
#     DNEGATE  UD>S  NEGATE
#   ELSE
#     UD>S
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {D>S} DtoS 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} DTOS1
pbAsm::Cell      {} DNegate
pbAsm::Cell      {} UDtoS
pbAsm::Cell      {} Negate
pbAsm::Cell      {} Branch
pbAsm::Cell      {} DTOS2
pbAsm::Cell   DTOS1 UDtoS
pbAsm::Cell   DTOS2 Exit
# -----------------------------------------------------------------------------
# : D+                                 \ [FW] From the Double-Number word set.
#   ( d1|ud1 d2|ud2 -- d3|ud3 )        \ Used by UM* and UM/MOD.
#   >R
#   ROT OVER +                         \ Add the less significant cells.
#   DUP >R
#   U> IF                              \ If their sum is less than one of
#     1+                               \ them then the addition overflowed,
#   THEN                               \ so increment one of the more
#   R>                                 \ significant cells.
#   SWAP R> + ;                        \ Add the more significant cells.
# -----------------------------------------------------------------------------
pbAsm::Secondary {D+} DPlus 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Cell      {} Rot
pbAsm::Cell      {} Over
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} UGreater
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} DPLUS1
pbAsm::Cell      {} OnePlus
pbAsm::Cell  DPLUS1 RFrom
pbAsm::Cell      {} Swap
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : DU<                                \ [FW] From the Double Number Extension
#   ( ud1 ud2 -- Truth )               \ word set.  Used by UM/MOD.
#   ROT 2DUP <> IF                     \ If the more significant cells <> ...
#     SWAP                             \ Exchange them ready for U<.
#     2SWAP                            \ Prepare to drop the less sig. cells.
#   THEN
#   2DROP                              \ Drop the unwanted cells
#   U< ;                               \ and compare the others.
# -----------------------------------------------------------------------------
pbAsm::Secondary {DU<} DULess 0 CORE

pbAsm::Cell      {} Rot
pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} NotEqual
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} DULESS1
pbAsm::Cell      {} Swap
pbAsm::Cell      {} TwoSwap
pbAsm::Cell DULESS1 TwoDrop
pbAsm::Cell      {} ULess
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : DABS                               \ [FW] From the Double Number Extension
#   ( d -- ud )                        \ word set.  Used by FM/MOD and SM/REM.
#   DUP 0< IF DNEGATE THEN
# ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {DABS} DAbs 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} DABS1
pbAsm::Cell      {} DNegate
pbAsm::Cell   DABS1 Exit
# -----------------------------------------------------------------------------