# -----------------------------------------------------------------------------
# math.tcl - Core Forth words for handling math operations
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
# : -  NEGATE + ;                      \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {-} Minus 0 CORE

pbAsm::Cell      {} Negate
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 1+  1 + ;                          \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {1+} OnePlus 0 CORE

pbAsm::Literal   {} 1
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 1-  1 - ;                          \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {1-} OneMinus 0 CORE

pbAsm::Literal   {} 1
pbAsm::Cell      {} Minus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
#                                      \ 2* is defined as a left shift, not a
#                                      \ multiply operation.  When dealing
#                                      \ with unsigned integers there is no
#                                      \ difference.
# : 2*  DUP + ;                        \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {2*} TwoStar 0 CORE                                               

pbAsm::Cell      {} Dup
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : UM*                                \ Unsigned multiply achieved by
#   ( u1 u2 -- udProduct )             \ repeated doubling and occasional
#                                      \ addition.
#   >R
#   1 >R
#   0 US>D
#   ROT US>D
#   BEGIN
#     R> DUP R@ AND
#     SWAP 2* >R
#     IF
#       2SWAP 2OVER D+ 2SWAP
#     THEN
#     2DUP D+
#     R> R@ SWAP >R
#   R@ U<
#   R@ 0=
#   OR UNTIL
#   2DROP R> R> 2DROP ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {UM*} UMStar 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Literal   {} 1
pbAsm::Cell      {} ToR
pbAsm::Literal   {} 0
pbAsm::Cell      {} UStoD
pbAsm::Cell      {} Rot
pbAsm::Cell      {} UStoD
pbAsm::Cell  UMSTR1 RFrom
pbAsm::Cell      {} Dup
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} And
pbAsm::Cell      {} Swap
pbAsm::Cell      {} TwoStar
pbAsm::Cell      {} ToR
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} UMSTR2
pbAsm::Cell      {} TwoSwap
pbAsm::Cell      {} TwoOver
pbAsm::Cell      {} DPlus
pbAsm::Cell      {} TwoSwap
pbAsm::Cell  UMSTR2 TwoDup
pbAsm::Cell      {} DPlus
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Swap
pbAsm::Cell      {} ToR
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} ULess
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} ZeroEqual
pbAsm::Cell      {} Or
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} UMSTR1
pbAsm::Cell      {} TwoDrop
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} TwoDrop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : M*                                 \ Signed multiply.
#   ( n1 n2 -- d )
#   2DUP SignsDiffer? >R
#   ABS SWAP ABS
#   UM*
#   R> IF
#     DNEGATE
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {M*} MStar 0 CORE

pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} SignsDifferQ
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Abs
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Abs
pbAsm::Cell      {} UMStar
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} MSTAR1
pbAsm::Cell      {} DNegate
pbAsm::Cell  MSTAR1 Exit
# -----------------------------------------------------------------------------
# : (UM/Mod)                           \ Support for UM/MOD, factored out
#   ( ud1 ud2 -- ud3 u4 )              \ to allow recursion.  Gives quotient
#                                      \ u4 and remainder ud3.
#   2DUP >R >R
#   2OVER 2OVER DU<
#   OVER HighBit AND
#   OR IF
#     2DROP 0
#   ELSE
#     2DUP D+
#     RECURSE
#     2*
#   THEN
#   ROT ROT
#   R> R>
#   2OVER 2OVER DU<
#   IF
#     2DROP ROT
#   ELSE
#     DNEGATE D+
#     ROT 1+
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {(UM/Mod)} ParenUMSlashMod 0 {}

pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} ToR
pbAsm::Cell      {} TwoOver
pbAsm::Cell      {} TwoOver
pbAsm::Cell      {} DULess
pbAsm::Cell      {} Over
pbAsm::Literal   {} HighBit
pbAsm::Cell      {} And
pbAsm::Cell      {} Or
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} PUMSM1
pbAsm::Cell      {} TwoDrop
pbAsm::Literal   {} 0
pbAsm::Cell      {} Branch
pbAsm::Cell      {} PUMSM2
pbAsm::Cell  PUMSM1 TwoDup
pbAsm::Cell      {} DPlus
pbAsm::Cell      {} ParenUMSlashMod
pbAsm::Cell      {} TwoStar
pbAsm::Cell  PUMSM2 Rot
pbAsm::Cell      {} Rot
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} TwoOver
pbAsm::Cell      {} TwoOver
pbAsm::Cell      {} DULess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} PUMSM3
pbAsm::Cell      {} TwoDrop
pbAsm::Cell      {} Rot
pbAsm::Cell      {} Branch
pbAsm::Cell      {} PUMSM4
pbAsm::Cell  PUMSM3 DNegate
pbAsm::Cell      {} DPlus
pbAsm::Cell      {} Rot
pbAsm::Cell      {} OnePlus
pbAsm::Cell  PUMSM4 Exit
# -----------------------------------------------------------------------------
# : UM/MOD   \ ( ud1 u2 -- u3 u4 )     \ Divide ud1 by u2, giving the
#   ?DUP IF                            \ quotient u4 and the remainder u3.
#     US>D (UM/Mod) >R UD>S R>
#   ELSE                               \ If ud1=0 ...
# \   -10 'Throw @ EXECUTE      \ MAF+ \ Check for divide by zero.
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {UM/MOD} UMSlashMod 0 CORE

pbAsm::Cell      {} QuestionDup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} UMSMOD1
pbAsm::Cell      {} UStoD
pbAsm::Cell      {} ParenUMSlashMod
pbAsm::Cell      {} ToR
pbAsm::Cell      {} UDtoS
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Branch
pbAsm::Cell      {} UMSMOD2
pbAsm::Cell UMSMOD1 TwoDrop
pbAsm::Literal   {} 0
pbAsm::Literal   {} 0
pbAsm::Cell UMSMOD2 Exit
# -----------------------------------------------------------------------------
# : FM/MOD                             \ [FW] divide d1 by n1 giving the
#   ( d1 n1 -- n2 n3 )                 \ floored quotient n3 and the
#                                      \ remainder n2.
#   DUP >R ABS
#   ROT ROT DUP >R DABS
#   ROT UM/MOD
#   R> R@ SignsDiffer? IF
#     OVER IF
#       1+
#       R@ ABS ROT - SWAP
#     THEN
#     NEGATE
#   THEN
#   R> 0< IF
#     SWAP NEGATE SWAP
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {FM/MOD} FMSlashMod 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Abs
pbAsm::Cell      {} Rot
pbAsm::Cell      {} Rot
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} DAbs
pbAsm::Cell      {} Rot
pbAsm::Cell      {} UMSlashMod
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} SignsDifferQ
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} FMSMOD1
pbAsm::Cell      {} Over
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} FMSMOD2
pbAsm::Cell      {} OnePlus
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} Abs
pbAsm::Cell      {} Rot
pbAsm::Cell      {} Minus
pbAsm::Cell      {} Swap
pbAsm::Cell FMSMOD2 Negate
pbAsm::Cell FMSMOD1 RFrom
pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} FMSMOD3
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Negate
pbAsm::Cell      {} Swap
pbAsm::Cell FMSMOD3 Exit
# -----------------------------------------------------------------------------
#                                      \ Floored Division ------------------
# : */MOD   \ ( n1 n2 n3 -- n4 n5 )    \ [FW] Multiply n1 by n2 giving the
#   >R M* R> FM/MOD                    \ double-cell result d.  Divide d by
# ;                                    \ n3 producing remainder n4 and
#                                      \ quotient n5.
# -----------------------------------------------------------------------------
pbAsm::Secondary {*/MOD} StarSlashMod 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Cell      {} MStar
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} FMSlashMod
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : /MOD   \ ( n1 n2 -- n3 n4 )        \ [FW] Divide n1 by n2, giving the
#   >R S>D R> FM/MOD ;                 \ remainder n3 and the quotient n4.
# -----------------------------------------------------------------------------
pbAsm::Secondary {/MOD} SlashMod 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Cell      {} StoD
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} FMSlashMod
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# These routines implement the symmetric division algorithms, which are
# NOT implemented in pbForth.
#                                      \ [FW] Divide d1 by n1 giving the
# : SM/REM                             \ symmetric quotient n3 and the
#   ( d1 n1 -- n2 n3 )                 \ remainder n2.
#   ROT ROT DUP >R DABS
#   ROT DUP >R ABS
#   UM/MOD R> R@ SignsDiffer? IF
#     NEGATE
#   THEN
#   R> 0< IF
#     SWAP NEGATE SWAP
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {SM/REM} SMSlashRem 0 CORE

pbAsm::Cell      {} Rot
pbAsm::Cell      {} Rot
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} DAbs
pbAsm::Cell      {} Rot
pbAsm::Cell      {} Dup
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Abs
pbAsm::Cell      {} UMSlashMod
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} RFetch
pbAsm::Cell      {} SignsDifferQ
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SMSREM1
pbAsm::Cell      {} Negate
pbAsm::Cell SMSREM1 RFrom
pbAsm::Cell      {} ZeroLess
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} SMSREM2
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Negate
pbAsm::Cell      {} Swap
pbAsm::Cell SMSREM2 Exit
# -----------------------------------------------------------------------------
#                                      \ Symmetric Division -----------------
# : */MOD   \ ( n1 n2 n3 -- n4 n5 )    \ [FW] Multiply n1 by n2 giving the
#   >R M* R> SM/REM                    \ double-cell result d.  Divide d by
# ;                                    \ n3 producing remainder n4 and
#                                      \ quotient n5.
# -----------------------------------------------------------------------------
# pbSecondary {*/MOD} StarSlashMod 0 CORE
#
# pbCell      {} ToR
# pbCell      {} MStar
# pbCell      {} RFrom
# pbCell      {} SMSlashRem
# pbCell      {} Exit
# -----------------------------------------------------------------------------
# : /MOD   \ ( n1 n2 -- n3 n4 )        \ [FW] divide n1 by n2, giving the
#   >R S>D R> SM/REM ;                 \ remainder n3 and the quotient n4.
# -----------------------------------------------------------------------------
# pbSecondary {/MOD} SlashMod 0 CORE
# 
# pbCell      {} ToR
# pbCell      {} StoD
# pbCell      {} RFrom
# pbCell      {} SMSlashRem
# pbCell      {} Exit
# -----------------------------------------------------------------------------
# : */   \ ( n1n2n3 -- n4 n5 )         \ [FW] Multiply n1 by n2 giving the
#   */MOD SWAP DROP                    \ double-cell result d.  Divide d by
# ;                                    \ n3 producing quotient n4.
# -----------------------------------------------------------------------------
pbAsm::Secondary {*/} StarSlash 0 CORE

pbAsm::Cell      {} StarSlashMod
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : *   \ ( n1|u1 n2|u2 -- n3|u3 )     \ [FW] Multiply n1|u1 by n2|u2 giving
#   UM* DROP ;                         \ the product n3|u3.
# -----------------------------------------------------------------------------
pbAsm::Secondary {*} Star 0 CORE 

pbAsm::Cell      {} UMStar
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : /                                  \ [FW] Divide n1 by n2 giving the
#   ( n1 n2 -- n3 )                    \ quotient n3.
#   /MOD SWAP DROP   ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {/} Slash 0 CORE

pbAsm::Cell      {} SlashMod
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : MOD                                \ [FW] Divide n1 by n2 giving the
#   ( n1 n2 -- n3 )                    \ remainder n3.
#   /MOD DROP   ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {MOD} Mod 0 CORE

pbAsm::Cell      {} SlashMod
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : LSHIFT                             \ A left shift which puts zero into
#   ( x1 Bits -- x2 )                  \ the least significant bits vacated
#   ?DUP IF                            \ by the shift.
#     0 DO
#       DUP +
#     LOOP
#   THEN ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {LSHIFT} LeftShift 0 CORE

pbAsm::Cell      {} QuestionDup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} LSHIFT1
pbAsm::Literal   {} 0
pbAsm::Cell      {} doDO
pbAsm::Cell      {} 0
pbAsm::Cell LSHIFT2 Dup
pbAsm::Cell      {} Plus
pbAsm::Cell      {} doLOOP
pbAsm::Cell      {} LSHIFT2
pbAsm::Cell LSHIFT1 Exit
# -----------------------------------------------------------------------------
# : DLShift                            \ A left shift which puts zero into
#   ( dx1 Bits -- dx2 )                \ the least significant bits vacated
#   ?DUP IF                            \ by the shift.  Support for RSHIFT
#     0 DO
#       2DUP D+
#     LOOP
#   THEN  ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {DLShift} DLeftShift 0 CORE
   
pbAsm::Cell      {} QuestionDup
pbAsm::Cell      {} ZBranch
pbAsm::Cell      {} DLSHFT1
pbAsm::Literal   {} 0
pbAsm::Cell      {} doDO
pbAsm::Cell      {} 0
pbAsm::Cell DLSHFT2 TwoDup
pbAsm::Cell      {} DPlus
pbAsm::Cell      {} doLOOP
pbAsm::Cell      {} DLSHFT2
pbAsm::Cell DLSHFT1 Exit
# -----------------------------------------------------------------------------
# : RSHIFT                             \ [hForth] A right shift which puts 0
#   ( x1 ShiftBits -- x2 )             \ into the most significant bits
#                                      \ vacated by the shift.
#                                      \ This is achieved by left-shifting a
#                                      \ double number and discarding the
#                                      \ lower part.
#   >R
#   0                                  \ Convert to a +ve double number.
#   Bits/Cell R> -                     \ Calc. # of left shifts required.
#   DLShift
#   SWAP DROP ;                        \ Discard least significant part.
# -----------------------------------------------------------------------------
pbAsm::Secondary {RSHIFT} RightShift 0 CORE

pbAsm::Cell      {} ToR
pbAsm::Literal   {} 0
pbAsm::Literal   {} BitsPerCELL
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} Minus
pbAsm::Cell      {} DLeftShift
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : 2/                                 \ Defined as a right-shift which
#   ( x1 -- x2 )                       \ leaves the msb unchanged.
#   DUP HighBit AND 0<>                \ Convert to a double number and fill
#                                      \ the most significant cell with the
#                                      \ msb value.
#   Bits/Cell 1- DLShift               \ Carry out just enough left shifts.
#   SWAP DROP ;                        \ Discard least significant part.
# -----------------------------------------------------------------------------
pbAsm::Secondary {2/} TwoSlash 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Literal   {} HighBit
pbAsm::Cell      {} And
pbAsm::Cell      {} ZeroNotEqual
pbAsm::Literal   {} BitsPerCELL
pbAsm::Cell      {} OneMinus
pbAsm::Cell      {} DLeftShift
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Drop
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------