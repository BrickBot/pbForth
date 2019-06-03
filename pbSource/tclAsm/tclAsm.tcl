# ----------------------------------------------------------------------------
# tclAsm.tcl - package that provides a standard interface to generate
#              generic assembler source code for a variety of assemblers.
#
# This package is designed to allow a Tcl script to generate source for
# different assemblers from a generic set of operations. These operations
# include:
#
#   Comment - a line of comment text
#   Label   - a label with an optional global modifier
#   Code    - a line of code
#   Align   - a directive to align the following data
#   Set     - a directive to set an assembler variable
#   Byte    - a directive to generate a byte
#   Word    - a directive to generate a word
#   Dword   - a directive to generate a double word
#   String  - a directive to generate a string
#
# Instead of sending the results of the operation to a file, the text is
# accumulated in a variable which can be cleared and read at any time. The
# intent is to generate short sections of code, and then grab the result
# and grab the results for further manipulation. This avoids having to deal
# with where the output is supposed to be sent at this level.
# 
# These additional functions hide the internal representation of the data
#
#   SetAssembler - specify which assembler we are targetting
#   ClearText    - clear the text buffer
#   GetText      - get the contents of the text buffer
#
# Revision History
#
# R.Hempel 07Mar2002 Updated comments, cleaned up code for release
# R.Hempel 18Sep2001 Original split from pbForth generator
# ----------------------------------------------------------------------------

package provide tclAsm 1.1

namespace eval ::tclAsm:: {
  variable  text      ""
  variable  string()  ""

  namespace export SetAssembler
  namespace export ClearText
  namespace export GetText
                      
  namespace export Comment
  namespace export Label
  namespace export Code
  namespace export Align
  namespace export Set
  namespace export Byte
  namespace export Word
  namespace export Dword
  namespace export String
}
       
# ----------------------------------------------------------------------------

proc ::tclAsm::SetAssembler { assembler } {
  source "tclAsm/tclAsm_$assembler.tcl"
}

proc ::tclAsm::ClearText { } {
  set ::tclAsm::text ""
}

proc ::tclAsm::GetText { } {
  return $::tclAsm::text
}

# ----------------------------------------------------------------------------
# Set the default assembler to GNU "as" - gas

::tclAsm::SetAssembler "gas"

# ----------------------------------------------------------------------------

proc ::tclAsm::Comment { comment } {
  append ::tclAsm::text [format $::tclAsm::string(COMMENT) $comment]
}

proc ::tclAsm::Label { label glob } {
  if { 0 != [string length $label] } {
    if { $glob } {
      append ::tclAsm::text [format $::tclAsm::string(GLOBAL) $label $label]
    } else {
      append ::tclAsm::text [format $::tclAsm::string(LABEL) $label]
    }
  }
}  
    
proc ::tclAsm::Code { label code {comment ""} } {
  ::tclAsm::Label $label 0
  append ::tclAsm::text [format $::tclAsm::string(CODE) $code $comment]
}                                   

# ----------------------------------------------------------------------------

proc ::tclAsm::Align { mod } {
  append ::tclAsm::text [format $::tclAsm::string(ALIGN) $mod]
}

proc ::tclAsm::Set { var value } {
  append ::tclAsm::text [format $::tclAsm::string(SET) $var $value]
}

# ----------------------------------------------------------------------------

proc ::tclAsm::Byte { label byte {comment ""} } {
  ::tclAsm::Label $label 0
  append ::tclAsm::text [format $::tclAsm::string(BYTE) $byte $comment]
}

proc ::tclAsm::Word { label word {comment ""} } {
  ::tclAsm::Label $label 0
  append ::tclAsm::text [format $::tclAsm::string(WORD) $word $comment]
}

proc ::tclAsm::Dword { label dword {comment ""} } {
  ::tclAsm::Label $label 0
  append ::tclAsm::text [format $::tclAsm::string(DWORD) $dword $comment]
}

proc ::tclAsm::String { label string {comment ""} } {
  ::tclAsm::Label $label 0

  regsub -all {\"} $string {\\"} string
  append ::tclAsm::text [format $::tclAsm::string(STRING) $string $comment]
}

# ----------------------------------------------------------------------------