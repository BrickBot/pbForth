#----------------------------------------------------------------------------
# serial/makefile	- Builds the serial library
#
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
#----------------------------------------------------------------------------

MODULE=serial
DEBUG =

#----------------------------------------------------------------------------
# Basic Macro, Assembler, Compiler, and Linker Definitions

include makeinc/basic.mak
include makeinc/asm.mak
include makeinc/c.mak

#----------------------------------------------------------------------------

OBJ = $(PROCESSOR_OBJ)
LST = $(PROCESSOR_LST)
S   = $(PROCESSOR_S  )
LIB = $(PROCESSOR_LIB)

all: $(OBJ) \
     $(LST) \
     $(S)   \
     $(LIB)/$(MODULE).a

#----------------------------------------------------------------------------
# Library Targets

$(LIB)/$(MODULE).a: $(OBJ)/serial-init.o     \
                    $(OBJ)/serial-put.o      \
                    $(OBJ)/serial-get.o      \
                    $(OBJ)/serial-buf.o      \
                    $(OBJ)/serial-busy.o     \
                    $(OBJ)/serial-test.o     \

#----------------------------------------------------------------------------
# Object File Targets

$(OBJ)/serial-init.o:   $(PUB_H)/h8defs.inc

$(OBJ)/serial-put.o:    $(PUB_H)/h8defs.inc

$(OBJ)/serial-get.o:    $(PUB_H)/h8defs.inc

$(OBJ)/serial-buf.o:    $(PUB_H)/h8defs.inc

$(OBJ)/serial-busy.o:   $(PUB_H)/h8defs.inc

$(OBJ)/serial-test.o:   $(PUB_H)/h8defs.inc

#----------------------------------------------------------------------------
# Other Targets

include makeinc/clean.mak
include makeinc/include.mak
include makeinc/inf.mak

#----------------------------------------------------------------------------
