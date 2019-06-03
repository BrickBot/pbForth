# ----------------------------------------------------------------------------
# address.tcl - Core Forth words for address manipulation
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
pbAsm::Secondary {CELL+} CellPlus 0 CORE

pbAsm::Literal   {} BytesPerCELL
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
pbAsm::Secondary {CHAR+} CharPlus 0 CORE

pbAsm::Literal   {} BytesPerCHAR
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
pbAsm::Secondary {2@} TwoFetch 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
pbAsm::Secondary {2!} TwoStore 0 CORE

pbAsm::Cell      {} Swap
pbAsm::Cell      {} Over
pbAsm::Cell      {} Store
pbAsm::Cell      {} CellPlus
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
pbAsm::Secondary {+!} PlusStore 0 CORE

pbAsm::Cell      {} Swap
pbAsm::Cell      {} Over
pbAsm::Cell      {} Fetch
pbAsm::Cell      {} Plus
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Store
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------