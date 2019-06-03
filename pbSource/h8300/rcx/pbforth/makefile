#----------------------------------------------------------------------------
# serial/makefile	- Builds the serial library
#
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
#----------------------------------------------------------------------------

DEBUG =
MODULE = pbforth

PBFORTH = ./pbforth

#----------------------------------------------------------------------------
# Basic Macro, Assembler, Compiler, and Linker Definitions

include makeinc/basic.mak
include makeinc/asm.mak
include makeinc/c.mak

#----------------------------------------------------------------------------

OBJ = $(TARGET_OBJ)
LST = $(TARGET_LST)
S   = $(TARGET_S  )
LIB = $(TARGET_LIB)

all: $(OBJ) \
     $(LST) \
     $(S)   \
     $(LIB)/$(MODULE).a

#----------------------------------------------------------------------------
# Library Targets

$(LIB)/$(MODULE).a: $(OBJ)/$(MODULE).o         \

#----------------------------------------------------------------------------
# Object File Targets

$(OBJ)/$(MODULE).o: ./$(PBFORTH)/address.tcl    ./$(PBFORTH)/compare.tcl     ./$(PROCESSOR)/$(TARGET)/$(MODULE)/pbforth.tcl      \
                    ./$(PBFORTH)/compile.tcl    ./$(PBFORTH)/control.tcl     ./$(PBFORTH)/dataspace.tcl  \
		    ./$(PBFORTH)/double.tcl     ./$(PBFORTH)/environment.tcl  \
                    ./$(PBFORTH)/interp.tcl     ./$(PBFORTH)/io.tcl          ./$(PBFORTH)/logic.tcl   \
		    ./$(PBFORTH)/math.tcl       ./$(PBFORTH)/stack.tcl       ./$(PROCESSOR)/$(TARGET)/$(MODULE)/h8300-primary.tcl  \
                    ./$(PROCESSOR)/$(TARGET)/$(MODULE)/h8300-primary-extra.tcl   ./$(PROCESSOR)/$(TARGET)/$(MODULE)/h8300-primary-rcx.tcl          \
                    ./$(PBFORTH)/except.tcl
         
#----------------------------------------------------------------------------  
# Other Targets                                                              
                                                                             
include makeinc/clean.mak                                                    
include makeinc/include.mak                                                  
include makeinc/inf.mak                                                      
                                                                             
#----------------------------------------------------------------------------