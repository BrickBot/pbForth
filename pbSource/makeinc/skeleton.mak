#----------------------------------------------------------------------------
# makeinc/skeleton.mak - Skeleton for task makefile
#
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
#-----------------------------------------------------------------------------

MODULE=xyztask
DEBUG =

#----------------------------------------------------------------------------
# Basic Macro, Assembler, Compiler, and Linker Definitions

include makeinc/basic.mak
include makeinc/asm.mak
include makeinc/c.mak
include makeinc/link.mak

#----------------------------------------------------------------------------

all: $(CONFIG)/$(MODULE)/obj \
     $(CONFIG)/$(MODULE)/lst \
     $(PUB_LIB)/$(MODULE).a

#----------------------------------------------------------------------------
# Library Targets

$(PUB_LIB)/$(MODULE).a :! source1.o  \
                          source2.o  \
                          ...        \
                          sourcen.o

#----------------------------------------------------------------------------
# Object Targets

source1.o       : $(PROD_H)/dep1.h     $(PROD_H)/dep2.h        \
                  $(PROD_H)/depn.h

source2.o       :

sourcen.o       :

#----------------------------------------------------------------------------
# Include File Dependencies and Inference Rules

include makeinc/include.mak
include makeinc/inf.mak

#----------------------------------------------------------------------------
