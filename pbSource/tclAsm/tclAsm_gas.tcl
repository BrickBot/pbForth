# ----------------------------------------------------------------------------
# tclAsm_gas.tcl - tclAsm format strings for gas

# Revision History
#
# R.Hempel 07Mar2002 Original
# ----------------------------------------------------------------------------
# These strings are the heart of the generic assembly process. Each assembler
# requires its own set of strings to implement the core functions as described
# in the header.

set ::tclAsm::string(COMMENT) "; %s\n"
set ::tclAsm::string(GLOBAL)  ".global %s\n%s:\n"
set ::tclAsm::string(LABEL)   "%s:\n"
set ::tclAsm::string(CODE)    "  %-32s ; %s\n"
set ::tclAsm::string(ALIGN)   "  .balign %s\n"
set ::tclAsm::string(SET)     "  .set   %s, %s\n"
set ::tclAsm::string(BYTE)    "  .byte  %-18s ; %s\n"
set ::tclAsm::string(WORD)    "  .word  %-18s ; %s\n"
set ::tclAsm::string(DWORD)   "  .long  %-18s ; %s\n"
set ::tclAsm::string(STRING)  "  .ascii \"%s\" ; %s\n"
