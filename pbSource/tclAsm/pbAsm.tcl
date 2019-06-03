# ----------------------------------------------------------------------------
# pbAsm.tcl - package that provides a standard interface to generate
#             assembler source code for pbForth
#
# This package is designed to translate generic source for a Forth system
# into specific assembler directives for different processors through the
# tclAsm package. It uses the basic assembler constructs to build a Forth
# run-time image in assembler.
#
# The available constructs for Forth are:
#
# StartDefinition - begins a new definition, with optional header
# Header          - builds a word header
# Primary         - builds a primary word definition
# Secondary       - builds a secondary word definition
# Create          - builds an empty word definition
# Literal         - builds a literal
# Constant        - builds a constant
# Variable        - builds a variable
# CString         - builds a counted string
# 2Constant       - builds a double-length constant
# Cell            - builds a cell of data
# Code            - builds a line of inline assebler
#
# The best feature of this Forth generator is that it allows the user to
# write additional primitive words in assembler for speed. They will
# automatically take precedence over and subsequent secondary definitions
# of the same word.
#
# Revision History
#
# R.Hempel 07Mar2002 Updated comments, cleaned up code for release
# R.Hempel 04Oct2001 pbLiteral now accepts comments
# R.Hempel 21Sep2001 Added pb2Constant
# R.Hempel 18Sep2001 Original split from pbForth generator
# ----------------------------------------------------------------------------

package require tclAsm 1.1

package provide pbAsm 1.1

namespace eval ::pbAsm:: {
  variable text

  variable wordList
  set wordList(CORE) 0
  set wordList(ENV)  0

  variable currentWord
  set currentWord(NAME) ""
  set currentWord(TYPE) ""

  variable primary

  namespace export StartDefinition
  namespace export Header
  namespace export Primary
  namespace export Secondary
  namespace export Create
  namespace export Literal
  namespace export Constant
  namespace export Variable
  namespace export CString
  namespace export 2Constant
  namespace export Cell
  namespace export 2Cell
  namespace export Code

  namespace export ClearText
  namespace export GetText

}
       
# ----------------------------------------------------------------------------

proc ::pbAsm::ClearText { } {
  set ::pbAsm::text ""
}

proc ::pbAsm::GetText { } {
  return $::pbAsm::text
}

# ----------------------------------------------------------------------------

proc ::pbAsm::Cell { label value {comment ""} } {
  ::tclAsm::Word $label $value $comment
}

proc ::pbAsm::2Cell { label value {comment ""} } {
  ::tclAsm::Dword $label $value $comment
}

proc ::pbAsm::Code { label code {comment ""} } {
  ::tclAsm::Code $label $code $comment
}                                   

proc ::pbAsm::CString { label string } {
  ::tclAsm::Byte   $label [string length $string]
  ::tclAsm::String {} $string

  if { 0 == [expr [string length $string]%2] } {
    ::tclAsm::Byte {} 0
  }
}

# ----------------------------------------------------------------------------

proc ::pbAsm::Header { name label flags link } {
  if { 0 == [string length $link] } {
    return
  }

  if { 0 == [info exists ::pbAsm::primary($::pbAsm::currentWord(NAME))] } {
    set prevLink $link$::pbAsm::wordList($link)
    ::pbAsm::Cell $link[incr ::pbAsm::wordList($link)] $prevLink
    
    ::tclAsm::String {} $name
    ::tclAsm::Byte   {} [string length [subst -nocommands -novariables $name]] "Name length"
    
    if { 1 == [expr [string length [subst -nocommands -novariables $name]]%2] } {
      ::tclAsm::Byte {} 0 "Padding..."
    }
    
    ::tclAsm::Byte {} $flags "Flags"
    
    ::tclAsm::Set last$link $label
  }
}

# ----------------------------------------------------------------------------
# When we start a definition, we need to print the contents of the previous
# definition, except if it has been superseded by a PRIMITIVE declaration.

proc ::pbAsm::StartDefinition { name type label flags link} {

  if { 0 == [info exists ::pbAsm::primary($::pbAsm::currentWord(NAME))] } {
    append ::pbAsm::text  [::tclAsm::GetText]
  } else {
    puts stdout "$::pbAsm::currentWord(NAME) primary overrides secondary!"
  }

  ::tclAsm::ClearText

  if { 0 == [string compare $::pbAsm::currentWord(TYPE) "PRIMARY"] } {
    set ::pbAsm::primary($::pbAsm::currentWord(NAME)) 1
  }

  set ::pbAsm::currentWord(NAME) $name
  set ::pbAsm::currentWord(TYPE) $type

  ::pbAsm::Header $name $label $flags $link  
  ::tclAsm::Label $label 1
}

# ----------------------------------------------------------------------------

proc ::pbAsm::Literal { label value {comment ""} } {
  ::pbAsm::Cell  $label doLIT
  ::pbAsm::Cell  {} $value $comment
}

proc ::pbAsm::Variable { name label value link } {
  ::pbAsm::StartDefinition $name VARIABLE $label 0 $link

  ::pbAsm::Cell  {} "doVAR+2"
  ::pbAsm::Cell  {} $value
}

proc ::pbAsm::Constant { name label value link } {
  ::pbAsm::StartDefinition $name CONSTANT $label 0 $link

  ::pbAsm::Cell  {} "doCONST+2"
  ::pbAsm::Cell  {} $value
}

proc ::pbAsm::2Constant { name label value link } {
  ::pbAsm::StartDefinition $name 2CONSTANT $label 0 $link

  ::pbAsm::Cell  {} "do2CONST+2"
  ::pbAsm::2Cell {} $value
}

proc ::pbAsm::Primary { name label flags link } {
  ::pbAsm::StartDefinition $name PRIMARY $label $flags $link

  ::pbAsm::Cell  {} $label+2
}

proc ::pbAsm::Secondary { name label flags link } {
  ::pbAsm::StartDefinition $name SECONDARY $label $flags $link

  ::pbAsm::Cell  {} "doCOLON+2"
}

proc ::pbAsm::Create { name label flags link } {
  ::pbAsm::StartDefinition $name CREATE $label $flags $link

  ::pbAsm::Cell  {} "doDOES+2"
}

# ----------------------------------------------------------------------------