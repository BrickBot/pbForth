# ----------------------------------------------------------------------------
# pbforth.tcl - the ANS-Forth compatible primitive words
#
# ----------------------------------------------------------------------------

set auto_path [linsert $auto_path 0 tclAsm]

package require tclAsm 1.1
package require pbAsm  1.1

# ----------------------------------------------------------------------------

fconfigure stdout -buffering full -buffersize 4096

# ::tclAsm::SetAssembler "gas"

pbAsm::StartDefinition "" "" "" "" ""

pbAsm::ClearText

# ----------------------------------------------------------------------------

::tclAsm::Comment {}
::tclAsm::Code    {} {.include "h8defs.inc"}
::tclAsm::Code    {} {.text}
::tclAsm::Label   {_entry} 1

::tclAsm::Code {} { MOV.W #_S0, rDSP }
::tclAsm::Code {} { MOV.W #_R0, rRSP }

::tclAsm::Code {} { JSR   _rcx_init                                   }           

::tclAsm::Code {} { MOV.W #Cold, rFWP                                 }

::tclAsm::Code {} { MOV.W   @rFWP,r0                                  }
::tclAsm::Code {} { JMP     @r0                                       }

# ----------------------------------------------------------------------------

source ./h8300/rcx/pbforth/h8300-primary.tcl
source ./h8300/rcx/pbforth/h8300-primary-extra.tcl
source ./h8300/rcx/pbforth/h8300-primary-rcx.tcl

source ./pbForth/address.tcl
source ./pbForth/compare.tcl
source ./pbForth/compile.tcl
source ./pbForth/control.tcl
source ./pbForth/dataspace.tcl
source ./pbForth/double.tcl

source ./pbForth/except.tcl

source ./pbForth/environment.tcl
source ./pbForth/interp.tcl
source ./pbForth/io.tcl
source ./pbForth/logic.tcl
source ./pbForth/math.tcl
source ./pbForth/stack.tcl

::tclAsm::Align 2
::tclAsm::Label initialDP 1

pbAsm::StartDefinition "" "" "" "" ""

# ----------------------------------------------------------------------------

set outFile [open "./pbforth.tcl.log" w+]
fconfigure $outFile -buffering full -buffersize 4096

puts $outFile [::pbAsm::GetText]

close $outFile

# ----------------------------------------------------------------------------
