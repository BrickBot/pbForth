# ----------------------------------------------------------------------------
# makeinc/asm.mak	- generic configuration builder macros for defining
#			  assembler specific flags and options
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
#----------------------------------------------------------------------------
# Assembler flag descriptions

AFLAGS=-I $(PUB_H) -o $(OBJ)/$*.o

# ----------------------------------------------------------------------------
