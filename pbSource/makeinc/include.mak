# ----------------------------------------------------------------------------
# makeinc/include.mak - generic configuration builder macros for defining
#                       include file dependencies
# Revision History
# ----------------
#
# R. Hempel 2000-12-04 - Original for RCX development tree
# ----------------------------------------------------------------------------

source1.h       : $(PROD_H)/dep1.h     $(PROD_H)/dep2.h        \
                  $(PROD_H)/depn.h

# ----------------------------------------------------------------------------
