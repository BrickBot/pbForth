# ----------------------------------------------------------------------------
# makeinc/link.mak	- generic configuration builder macros for defining
#			  linker and imager specific flags and options
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
# ----------------------------------------------------------------------------
# Linker flag descriptions

debug_LF  := -L $(LD) -T h8300_rcx.ld -Map $(PRODUCT_LST)/$(PRODUCT).map
release_LF:=

debug_ODF := --disassemble-all --no-show-raw-insn -m h8300

