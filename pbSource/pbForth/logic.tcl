# -----------------------------------------------------------------------------
# logic.tcl - Core Forth words for handling bitwise logic operations
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
# : INVERT  DUP Nand ;                 \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {INVERT} Invert 0 CORE

pbAsm::Cell      {} Dup
pbAsm::Cell      {} Nand
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : AND  Nand INVERT ;                 \ [FW]
# -----------------------------------------------------------------------------
pbAsm::Secondary {AND} And 0 CORE

pbAsm::Cell      {} Nand
pbAsm::Cell      {} Invert
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : OR  INVERT SWAP INVERT Nand ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {OR} Or 0 CORE

pbAsm::Cell      {} Invert
pbAsm::Cell      {} Swap
pbAsm::Cell      {} Invert
pbAsm::Cell      {} Nand
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
# : XOR  2DUP OR >R Nand R> AND ;
# -----------------------------------------------------------------------------
pbAsm::Secondary {XOR} Xor 0 CORE

pbAsm::Cell      {} TwoDup
pbAsm::Cell      {} Or
pbAsm::Cell      {} ToR
pbAsm::Cell      {} Nand
pbAsm::Cell      {} RFrom
pbAsm::Cell      {} And
pbAsm::Cell      {} Exit
# -----------------------------------------------------------------------------
