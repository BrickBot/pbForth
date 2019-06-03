# ----------------------------------------------------------------------------
# makeinc/inf.mak  - Inference rules for building objects
#
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
# ----------------------------------------------------------------------------

vpath %.c   $(C)   product/c
vpath %.asm $(TARGET_ASM) $(PROCESSOR_ASM)
vpath %.tcl $(PROCESSOR)/$(TARGET)/$(MODULE)

vpath %.o $(TARGET_OBJ) $(PROCESSOR_OBJ)
vpath %.s $(S)

.SUFFIXES:

%.h :
	touch -c $@
 
$(OBJ)/%.o : %.c
	$(COMPILE) $< $(CFLAGS)

$(OBJ)/%.o : %.asm
	$(ASSEMBLE) $(AFLAGS) $<

$(OBJ)/%.o : %.tcl
	cygtclsh80 $<
	$(M4) ./m4/h8300.m4 ./pbforth.tcl.log > ./h8300.S
	rm ./pbforth.tcl.log
	$(ASSEMBLE) $(AFLAGS) ./h8300.S
	rm ./h8300.S

%.a :
	$(AR) -rc $@ $?

%.LIB :
	$(MAKE) -f $*/makefile

%.CORELIB :
	$(MAKE) -f $*/makefile

%/obj :
	$(MKDIR) $(basename $@)
 
%/lst :
	$(MKDIR) $(basename $@)
 
%/s   :
	$(MKDIR) $(basename $@)

%/lib :
	$(MKDIR) $(basename $@)
 
%/libc :
	$(MKDIR) $(basename $@)
 
%/sym :
	$(MKDIR) $(basename $@)
 
%/out :
	$(MKDIR) $(basename $@)
 
%/s19 :
	$(MKDIR) $(basename $@)
 
%.mak :

# ----------------------------------------------------------------------------
