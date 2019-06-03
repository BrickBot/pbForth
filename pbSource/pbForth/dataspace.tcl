# -----------------------------------------------------------------------------
# dataspace.tcl - Core Forth words for dealing with dataspace information
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
# : HERE   DP @ ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {HERE} Here 0 CORE

pbAsm::Cell      {} DP
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ALIGN  DP @ ALIGNED DP ! ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {ALIGN} Align 0 CORE

pbAsm::Cell      {} DP
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Aligned
pbAsm::Cell      {} DP
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ALLOT  \ ( x -- )
#   DP +! ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {ALLOT} Allot 0 CORE

pbAsm::Cell      {} DP
pbAsm::Cell      {} PlusStore
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : ,  \ ( x -- )
#   HERE !
#   [ 1 CELLS ] LITERAL ALLOT ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {,} Comma 0 CORE

pbAsm::Cell      {} Here
pbAsm::Cell      {} Store
pbAsm::Literal   {} BytesPerCELL
pbAsm::Cell      {} Allot
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : C,  \ ( char -- )
#   HERE C!
#   1 ALLOT ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {C,} CharComma 0 CORE

pbAsm::Cell      {} Here
pbAsm::Cell      {} CharStore
pbAsm::Literal   {} BytesPerCHAR
pbAsm::Cell      {} Allot
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------