#-----------------------------------------------------------------------------
# makeinc/basic.mak - Fundamental macros for project directories. These
#                     should only need changes when setting up a new project.
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
#-----------------------------------------------------------------------------
# DO NOT PUT COMMENTS ON THE SAME LINE AS THE VARIABLE STRING, OR THE COMMENT
# IS INTERPRETED AS PART OF THE STRING!!!
#-----------------------------------------------------------------------------

.DEFAULT:

#-----------------------------------------------------------------------------
# CYGNUS utilities directory

CYGWIN_BIN:=./bin/cygwin

RM   :=$(CYGWIN_BIN)/rm
ECHO :=$(CYGWIN_BIN)/echo
MKDIR:=$(CYGWIN_BIN)/mkdir --parents
DATE :=$(CYGWIN_BIN)/date
M4   :=$(CYGWIN_BIN)/m4
TAR  :=$(CYGWIN_BIN)/tar
GZIP :=$(CYGWIN_BIN)/gzip
TOUCH:=$(CYGWIN_BIN)/touch

ASSEMBLE:=$(CYGWIN_BIN)/h8300-hms/h8300-hms-as
LINK    :=$(CYGWIN_BIN)/h8300-hms/h8300-hms-ld
OBJCOPY :=$(CYGWIN_BIN)/h8300-hms/h8300-hms-objcopy
OBJDUMP :=$(CYGWIN_BIN)/h8300-hms/h8300-hms-objdump

#-----------------------------------------------------------------------------
# PKZIP utilities directory

PKZIP_BIN:=./bin/pkzip

PKZIP    := $(PKZIP_BIN)/pkzip25

#-----------------------------------------------------------------------------
# Rule directories and paths

PUB_H  :=./h
H             :=./$(MODULE)/h

PROCESSOR_ASM :=./$(PROCESSOR)/$(MODULE)/asm
TARGET_ASM    :=./$(PROCESSOR)/$(TARGET)/$(MODULE)/asm
 
C             :=./$(MODULE)/c
PROCESSOR_C   :=./$(PROCESSOR)/$(MODULE)/asm
TARGET_C      :=./$(PROCESSOR)/$(TARGET)/$(MODULE)/asm

#-----------------------------------------------------------------------------
# Output and library directories

LST           :=./$(CONFIG)/$(MODULE)/lst
PROCESSOR_LST :=./$(CONFIG)/$(PROCESSOR)/$(MODULE)/lst
TARGET_LST    :=./$(CONFIG)/$(PROCESSOR)/$(TARGET)/$(MODULE)/lst

OBJ           :=./$(CONFIG)/$(MODULE)/obj
PROCESSOR_OBJ :=./$(CONFIG)/$(PROCESSOR)/$(MODULE)/obj
TARGET_OBJ    :=./$(CONFIG)/$(PROCESSOR)/$(TARGET)/$(MODULE)/obj

S             :=./$(CONFIG)/$(MODULE)/s
PROCESSOR_S   :=./$(CONFIG)/$(PROCESSOR)/$(MODULE)/s
TARGET_S      :=./$(CONFIG)/$(PROCESSOR)/$(TARGET)/$(MODULE)/s

PROCESSOR_LIB :=./$(CONFIG)/$(PROCESSOR)/lib
TARGET_LIB    :=./$(CONFIG)/$(PROCESSOR)/$(TARGET)/lib

PRODUCT_LST := $(CONFIG)/$(PROCESSOR)/$(TARGET)/exe/lst
PRODUCT_S19 := $(CONFIG)/$(PROCESSOR)/$(TARGET)/exe/s19


EXE   :=./$(CONFIG)/exe

OUT   :=./$(EXE)/out
HEX   :=./$(EXE)/hex
S19   :=./$(EXE)/s19
SYM   :=./$(EXE)/sym
EXELST:=./$(EXE)/lst
LD    :=./ld

# ----------------------------------------------------------------------------
