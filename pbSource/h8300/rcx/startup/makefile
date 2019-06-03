#----------------------------------------------------------------------------
# startup/makefile	- Builds the startup library
#
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
#----------------------------------------------------------------------------

MODULE=startup
DEBUG =-gg

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

$(OBJ)/startup.o:	$(PUB_H)/h8defs.inc

#----------------------------------------------------------------------------
# Other Targets

include makeinc/clean.mak
include makeinc/include.mak
include makeinc/inf.mak

#----------------------------------------------------------------------------
