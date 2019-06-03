#----------------------------------------------------------------------------
# makefile	- master makefile
#
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
#----------------------------------------------------------------------------

.SUFFIXES :

#----------------------------------------------------------------------------
# The first thing we try to do is figure out if the user passed enough
# arguments to the command line. Normally, the makefile is invoked like this:
#
# make PRODUCT=PRODUCT_TYPE HWREV=x CONFIG=CONFIG_TYPE CPU_NO=CPU_xx
#
# Where PRODUCT_TYPE must be one of:
#
# serial-test
#
# And HWREV must be a number that is particular to the board revision
#
# And CONFIG_TYPE must be one of:
#
# debug
# release
#
# The CONFIG variable is assigned to its command line value to ensure that
# it is empty if the user does not specify it.
#----------------------------------------------------------------------------

CONFIGS := debug release

ifeq "" "$(filter $(CONFIGS),$(strip $(CONFIG)))"

  CFG_ERROR :
	echo "No configuration was specified"
 else

#----------------------------------------------------------------------------
# If we get to this part, we have a configuration so we can check for a legal
# target.
#----------------------------------------------------------------------------

PRODUCTS := pbforth

ifeq "" "$(filter $(PRODUCTS),$(strip $(PRODUCT)))"

  PRODUCT_ERROR :
	echo "No product was specified"
else

#----------------------------------------------------------------------------
# If we get to this part, we have a product so we can check for a legal
# processor type.
#----------------------------------------------------------------------------

PROCESSORS := h8300

ifeq "" "$(filter $(PROCESSORS),$(strip $(PROCESSOR)))"

  PROCESSOR_ERROR :
	echo "No processor was specified"
else

#----------------------------------------------------------------------------
# If we get to this part, we have a processor so we can check for a legal
# target type.
#----------------------------------------------------------------------------

TARGETS := rcx

ifeq "" "$(filter $(TARGETS),$(strip $(TARGET)))"

  TARGET_ERROR :
	echo "No target was specified"
else

#----------------------------------------------------------------------------
# We have the configuration and the target and CPU, so lets start building!
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Basic Macro, Assembler, Compiler, and Linker Definitions

include makeinc/basic.mak
include makeinc/link.mak

#----------------------------------------------------------------------------

DATE:=$(shell $(DATE) '+%d%h%Y')

#----------------------------------------------------------------------------
# Executable Targets

$(PRODUCT) : EXE_DIRS LIB_DIRS TARGET_LIBS PROCESSOR_LIBS
	$(LINK) $(CONFIG)/$(PROCESSOR)/$(TARGET)/startup/obj/startup.o $($(CONFIG)_LF) --cref -o $(PRODUCT_LST)/$(PRODUCT).coff > $(PRODUCT_LST)/$(PRODUCT).cref
	$(OBJCOPY) -I coff-h8300 -R .scratch -R .stacks -O srec $(PRODUCT_LST)/$(PRODUCT).coff $(PRODUCT_S19)/$(PRODUCT).srec
	$(OBJDUMP) $($(CONFIG)_ODF) $(PRODUCT_LST)/$(PRODUCT).coff > $(PRODUCT_LST)/$(PRODUCT).dis
	cp ./debug/h8300/rcx/exe/s19/pbforth.srec .
	find anstest h h8300 ld m4 makeinc pbForth pbScripts tclAsm pbforth.srec changelog.txt makefile pbforth.bat rcxdev.txt -type f > pbForth.lst
	$(PKZIP) -add -path=specify pbForth.zip @pbForth.lst
	$(TAR) -c --files-from=pbForth.lst | $(GZIP) > pbForth.tar.gz
	find anstest pbScripts pbforth.srec -type f > pbScripts.lst
	$(PKZIP) -add -path=specify pbScripts.zip @pbScripts.lst
	$(TAR) -c --files-from=pbScripts.lst | $(GZIP) > pbScripts.tar.gz

exe_dirs  := $(CONFIG)/$(PROCESSOR)/$(TARGET)/exe/lst \
             $(CONFIG)/$(PROCESSOR)/$(TARGET)/exe/s19

EXE_DIRS  : $(foreach exedir,$(exe_dirs),$(exedir))


lib_dirs  := $(CONFIG)/$(PROCESSOR)/$(TARGET)/lib  \
             $(CONFIG)/$(PROCESSOR)/lib

LIB_DIRS       : $(foreach libdir,$(lib_dirs),$(libdir))


target_libs := ./$(PROCESSOR)/$(TARGET)/startup   \
               ./$(PROCESSOR)/$(TARGET)/pbforth

TARGET_LIBS    : $(foreach lib,$(target_libs),$(lib).LIB)


processor_libs := ./$(PROCESSOR)/serial   \

PROCESSOR_LIBS : $(foreach lib,$(processor_libs),$(lib).LIB)

#----------------------------------------------------------------------------
# Other Targets

include makeinc/clean.mak
include makeinc/inf.mak

endif
endif
endif
endif

#---------------------------------------------------------------------------
