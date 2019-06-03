# ----------------------------------------------------------------------------
# h8300-primary-extra.tcl - Extra code Forth words for Hitachi H8300 Processor
#
# Revision History
#
# R.Hempel 06Jul2002 Add LEAVE and UNLOOP
#                    Change I and J to <I> and <J>
# R.Hempel 16Apr2002 Add ATO4TH and 'ato4th to allow asm code to call Forth
# R.Hempel 04Apr2002 Add 'next for assembler
# R.Hempel 22Mar2002 Clean up comments for release
# R.Hempel 04Oct2001 Added INVERT, I, J
# R.Hempel 30Sep2001 Added ROT
# R.Hempel 19Sep2001 Original
# ----------------------------------------------------------------------------
# This work is based on Chris Jakeman's MAF and PAF Forth systems. Their
# goal was to build a minimal ANS Forth that could be built by a standard
# Forth system and made no assumptions about the underlying achitecture.
#
# The original source may be found at:
#
# ftp://ftp.taygeta.com/pub/Forth/Applications/ANS/maf1v02.zip
# ftp://ftp.taygeta.com/pub/Forth/Applications/ANS/paf0v04.zip
# ----------------------------------------------------------------------------
# The additional core Forth words for any processor are generated here. The
# original Forth core words from MAF and PAF are the minimum required to get
# a new Forth up and running from the supplied source.
#
# Experience has shown that a number of other Forth words should be written
# in assembler to increase the speed of the system:
#
# <Loop>   2*     SWAP      <Leave>
# <+Loop>  2/     DUP       <Unloop>
# <I>      AND    ROT       
# <J>      OR     INVERT    
# 0<       XOR    (UM/Mod)  
# 0=       OVER   'next     
#
# These words should only be written after the main system is up and running
# using the known-good implementation as secondaries. The performance will
# be slow, but at least it will be correct.
#
# The FORTH source code at the beginning of each word should be kept current
# with the actual assembler source.
# ---------------------------------------------------------------------------
# <Loop> doLOOP   do-Loop
#
# : <Loop>                             \ Increment the Index and compare it
#   ( -- )                             \ to the Limit.
#   ( R: Limit Index IP
#        -- Limit Index+1 NewIP )
#   R>                                 \ Save & of next word.
#   R> 1+                              \ Increment Index.
#   DUP R@ = IF                        \ If = Limit ...
#     DROP  R> DROP                    \ Drop Index and Limit.
#     CELL+ >R                         \ Skip over address of start of loop.
#   ELSE
#     >R                               \ Save new index.
#     @                                \ Get address of start of loop.
#     >R                               \ Make it the next word.
#   THEN
# ;
# ---------------------------------------------------------------------------
pbAsm::Primary {<Loop>} doLOOP 0 {}

pbAsm::Code {}         {MOV.W   @rRSP+,rB    }
pbAsm::Code {}         {ADDS.W  #1,rB        }
pbAsm::Code {}         {MOV.W   @rRSP,rC     }
pbAsm::Code {}         {CMP.W   rB,rC        }
pbAsm::Code {}         {BNE     DOLOOP1      }
pbAsm::Code {}         {                     }
pbAsm::Code {}         {ADDS.W  #2,rRSP      }
pbAsm::Code {}         {ADDS.W  #2,rFIP      }
pbAsm::Code {}         {JMP     NEXT         }
pbAsm::Code {}         {                     }
pbAsm::Code {DOLOOP1}  {MOV.W   rB,@-rRSP    }
pbAsm::Code {}         {MOV.W   @rFIP,rFIP   }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# <+Loop> doPLOOP  do-Plus-Loop
#
# : <+Loop>                            \ Change the Index and test for end by
#   ( Increment -- )                   \ comparing top-of-stack to Index and
#   ( R: Limit Index IP                \ testing for a change of sign.
#        -- Limit Index+1 NewIP )
#   R>                                 \ Save & of next word
#   SWAP R> DUP R@ -                   \ Get Index-Limit
#   ROT ROT + DUP R@ -                 \ Increment Index-Limit
#   ROT SignsDiffer? IF                \ If sign has changed ...
#     DROP  R> DROP                    \ Drop NewIndex and Limit
#     CELL+ >R                         \ Skip over address at end of loop
#                                      \ and execute word that follows.
#   ELSE
#     >R                               \ Save new Index
#     @                                \ Get address of start of loop and
#     >R                               \ make it the next word.
#   THEN
# ;
# ---------------------------------------------------------------------------
pbAsm::Primary {<+Loop>} doPLOOP 0 {}

pbAsm::Code {}         {MOV.W   @rRSP+,rB    }
pbAsm::Code {}         {MOV.W   @rRSP,rC     }
pbAsm::Code {}         {SUB.W   rC,rB        }
pbAsm::Code {}         {ADD.W   rB,rTOS      }
pbAsm::Code {}         {XOR.B   rTOSh,rBh    }
pbAsm::Code {}         {AND.B   #0x80,rBh    }
pbAsm::Code {}         {BEQ     DOPLOOP1     }
pbAsm::Code {}         {                     }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  }
pbAsm::Code {}         {ADDS.W  #2,rRSP      }
pbAsm::Code {}         {ADDS.W  #2,rFIP      }
pbAsm::Code {}         {JMP     NEXT         }
pbAsm::Code {}         {                     }       
pbAsm::Code {DOPLOOP1} {ADD.W   rC,rTOS      }
pbAsm::Code {}         {MOV.W   rTOS,@-rRSP  }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  }
pbAsm::Code {}         {MOV.W   @rFIP,rFIP   }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# : <I>
#   ( -- Index )
#   ( R: Index IP -- Index IP )
#   R>                                 \ Save & of next word IP.
#   R@                                 \ Get Index
#   SWAP >R                            \ and restore IP.
# ;
# ---------------------------------------------------------------------------
pbAsm::Primary {<I>} doI 0 {}

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  }
pbAsm::Code {}         {MOV.W   @rRSP,rTOS   }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# : <J>
#   ( -- Index )
#   ( R: JIndex IP ILimit IIndex IP
#        -- JIndex IP ILimit IIndex IP )
#   R>                            \ Save & of next word IP
#   R> R>                         \ Save I loop control parameters
#   R@                            \ Get the J index
#   SWAP >R  SWAP >R              \ Restore I parameters
#   SWAP >R                       \ and restore IP
# ;
# ---------------------------------------------------------------------------
pbAsm::Primary {<J>} doJ 0 {}

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP   }
pbAsm::Code {}         {MOV.W   @(4,rRSP),rTOS}
pbAsm::Code {}         {JMP     NEXT          }
# ---------------------------------------------------------------------------
# : <Leave>
#   ( R: ILimit IIndex IP
#        -- IP )
#   R> @                               \ Get address of end of loop.
#   R> DROP  R> DROP                   \ Lose Index-Limit and Limit.
#   >R ;                               \ Make the end-of-loop the next word.
# ---------------------------------------------------------------------------
pbAsm::Primary {<Leave>} doLEAVE 0 {}

pbAsm::Code {}         {ADDS.W  #2,rRSP      }
pbAsm::Code {}         {ADDS.W  #2,rRSP      }
pbAsm::Code {}         {MOV.W   @rFIP,rFIP   }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# : <Unloop>
#   R>  R> R> 2DROP  >R ;
# ---------------------------------------------------------------------------
pbAsm::Primary {<Unloop>} doUNLOOP 0 {}

pbAsm::Code {}         {ADDS.W  #2,rRSP      }
pbAsm::Code {}         {ADDS.W  #2,rRSP      }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# 0<  ZeroLess  zero-less
# ---------------------------------------------------------------------------
pbAsm::Primary {0<} ZeroLess 0 CORE

pbAsm::Code {}         {MOV.W   rTOS,rTOS    } {affect the sign bit            }
pbAsm::Code {}         {BMI     ZLESS1       } {if negative, leave true result }
pbAsm::Code {}         {MOV.W   #0x0000,rTOS } {otherwise, leave false result  }
pbAsm::Code {}         {JMP     NEXT         }
pbAsm::Code {ZLESS1}   {MOV.W   #0xFFFF,rTOS } {put true result on stack       }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# 0=  ZeroEqual  zero-equal
# ---------------------------------------------------------------------------
pbAsm::Primary {0=} ZeroEqual 0 CORE

pbAsm::Code {}         {MOV.W   rTOS,rTOS    } {affect the zero bit            }
pbAsm::Code {}         {BEQ     ZEQUAL1      } {if zero, leave true result     }
pbAsm::Code {}         {MOV.W   #0x0000,rTOS } {otherwise, leave false result  }
pbAsm::Code {}         {JMP     NEXT         }
pbAsm::Code {ZEQUAL1}  {MOV.W   #0xFFFF,rTOS } {put true result on stack       }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# 2*  TwoStar  two-star
# ---------------------------------------------------------------------------
pbAsm::Primary {2*} TwoStar 0 CORE

pbAsm::Code {}         {ADD.W   rTOS,rTOS    } {double the value               }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# 2/  TwoSlash  two-slash
# ---------------------------------------------------------------------------
pbAsm::Primary {2/} TwoSlash 0 CORE

pbAsm::Code {}         {SHAR.B  rTOSh        } {shift to divide               }
pbAsm::Code {}         {ROTXR.B rTOSl        }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# AND  And  and
# ---------------------------------------------------------------------------
pbAsm::Primary {AND} And 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rA    } {grab next value for AND       }
pbAsm::Code {}         {AND.B   rAl,rTOSl    }
pbAsm::Code {}         {AND.B   rAh,rTOSh    }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# OR  Or  or
# ---------------------------------------------------------------------------
pbAsm::Primary {OR} Or 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rA    } {grab next value for AND       }
pbAsm::Code {}         {OR.B    rAl,rTOSl    }
pbAsm::Code {}         {OR.B    rAh,rTOSh    }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# XOR  Xor  xor
# ---------------------------------------------------------------------------
pbAsm::Primary {XOR} Xor 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rA    } {grab next value for AND       }
pbAsm::Code {}         {XOR.B   rAl,rTOSl    }
pbAsm::Code {}         {XOR.B   rAh,rTOSh    }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# OVER  Over  over
# ---------------------------------------------------------------------------
pbAsm::Primary {OVER} Over 0 CORE

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP   } {save current TOS       }
pbAsm::Code {}         {MOV.W   @(2,rDSP),rTOS}
pbAsm::Code {}         {JMP     NEXT          }
# ---------------------------------------------------------------------------
# SWAP  Swap  swap
# ---------------------------------------------------------------------------
pbAsm::Primary {SWAP} Swap 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP,rA     }
pbAsm::Code {}         {MOV.W   rTOS,@rDSP   }
pbAsm::Code {}         {MOV.W   rA,rTOS      }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# DUP  Dup  dupe
# ---------------------------------------------------------------------------
pbAsm::Primary {DUP} Dup 0 CORE

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  } {save current TOS       }
pbAsm::Code {}         {JMP     NEXT         } {                       }
# ---------------------------------------------------------------------------
# ROT  Rot  rot
# ---------------------------------------------------------------------------
pbAsm::Primary {ROT} Rot 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP,rA     } {Grab the next two stack items}
pbAsm::Code {}         {MOV.W   @(2,rDSP),rB } {                             }
pbAsm::Code {}         {MOV.W   rA,@(2,rDSP) } {And now rotate them...       }
pbAsm::Code {}         {MOV.W   rTOS,@rDSP   } {                             }
pbAsm::Code {}         {MOV.W   rB,rTOS      } {                             }
pbAsm::Code {}         {JMP     NEXT         } {                             }
# ---------------------------------------------------------------------------
# INVERT  Invert  invert
# ---------------------------------------------------------------------------
pbAsm::Primary {INVERT} Invert 0 CORE

pbAsm::Code {}         {NOT.B   rTOSl,rTOSl  } {Invert the TOS bits           }
pbAsm::Code {}         {NOT.B   rTOSh,rTOSh  } {                              }
pbAsm::Code {}         {JMP     NEXT         } {                              } 
# ---------------------------------------------------------------------------
# (UM/Mod) ParenUMSlashMod ( ud1 ud2 -- ud3 u4 )
# ---------------------------------------------------------------------------
pbAsm::Primary {(UM/Mod)} ParenUMSlashMod 0 {}

pbAsm::Code {}         {MOV.W  r3,@-rDSP     } {Save the registers we're using}
pbAsm::Code {}         {MOV.W  r4,@-rDSP     } {                              }
pbAsm::Code {}         {MOV.W  r5,@-rDSP     } {                              }
pbAsm::Code {}         {MOV.W  r6,r5         } {MSW of u2                     }
pbAsm::Code {}         {MOV.W  @( 6,rDSP),r6 } {LSW of u2                     }
pbAsm::Code {}         {MOV.W  @( 8,rDSP),r3 } {MSW of u1                     }
pbAsm::Code {}         {MOV.W  @(10,rDSP),r4 } {LSW of u1                     }
pbAsm::Code {}         {                     } {                              }
pbAsm::Code {}         {MOV.B  #0x20,r0l     } {Set up the loop counter       }
pbAsm::Code {}         {SUB.W  r1,r1         } {Clear out r1,2                }
pbAsm::Code {}         {SUB.W  r2,r2         } {                              }
pbAsm::Code {}         {                     } {                              }
pbAsm::Code {DIVLOOP}  {ADD.W  r4,r4         } {Shift r1,2,3,4 left one bit   }
pbAsm::Code {}         {ADDX.B r3l,r3l       } {Adds saves 2 cycles!          }
pbAsm::Code {}         {ADDX.B r3h,r3h       } {                              }
pbAsm::Code {}         {ADDX.B r2l,r2l       } {                              }
pbAsm::Code {}         {ADDX.B r2h,r2h       } {                              }
pbAsm::Code {}         {ADDX.B r1l,r1l       } {                              }
pbAsm::Code {}         {ADDX.B r1h,r1h       } {                              }
pbAsm::Code {}         {                     } {                              }
pbAsm::Code {CHKHI}    {CMP.W  r5,r1         } {Try subtracting the MSW       }
pbAsm::Code {}         {BHI    DIVSUB        } {Higer, so subtract            }
pbAsm::Code {}         {BLO    CHKLOOP       } {Lower, so loop again          }
pbAsm::Code {}         {                     } {Equal, so check the LSW       }
pbAsm::Code {CHKLO}    {CMP.W  r6,r2         } {Try subtracting the LSW       }
pbAsm::Code {}         {BHS    DIVSUB        } {Higer or same, so subtract    }
pbAsm::Code {}         {                     } {Lower, so loop again          }
pbAsm::Code {CHKLOOP}  {DEC.B  r0l           } {Decrement the loop counter    }
pbAsm::Code {}         {BNE    DIVLOOP       } {Keep going...                 }
pbAsm::Code {}         {BRA    DIVDONE       } {Otherwise we're done          }
pbAsm::Code {}         {                     } {                              }
pbAsm::Code {DIVSUB}   {SUB.W  r6,r2         } {Subtract r3,4 - r5,6 -> r3,4  }
pbAsm::Code {}         {SUBX.B r5l,r1l       } {                              }
pbAsm::Code {}         {SUBX.B r5h,r1h       } {                              }
pbAsm::Code {}         {BSET   #0,r4l        } {Set the LSB of the quotient   }
pbAsm::Code {}         {DEC.B  r0l           } {Decrement the loop counter    }
pbAsm::Code {}         {BNE    DIVLOOP       } {Keep going                    }   
pbAsm::Code {}         {                     } {                              }
pbAsm::Code {DIVDONE}  {MOV.W  r4,rTOS       } {Save the quotient             }
pbAsm::Code {}         {MOV.W  r1,@( 8,rDSP) } {Save the remainder            }
pbAsm::Code {}         {MOV.W  r2,@(10,rDSP) } {LSW of u1                     }
pbAsm::Code {}         {                     } {                              }
pbAsm::Code {}         {MOV.W  @rDSP+,r5     } {Restore the registers we saved}
pbAsm::Code {}         {MOV.W  @rDSP+,r4     } {                              }
pbAsm::Code {}         {MOV.W  @rDSP+,r3     } {                              }
pbAsm::Code {}         {ADDS.W #2,rDSP       } {Dummy stack adjustment        }
pbAsm::Code {}         {JMP    NEXT          } {                              }
# ---------------------------------------------------------------------------
# 'next TickNext
# ---------------------------------------------------------------------------
pbAsm::Constant {'next} TickNext NEXT CORE
# ---------------------------------------------------------------------------
# ATO4TH  ATO4TH  asm-to-forth
#
# This is a bit of convoluted code. Basically we need to set things up
# so that we can do the following steps in order:
#
# 1. Jump to LOADPC which gets the Forth code running
# 2. Return from EXIT to where we would leave off
#
# This code assumes that rFWP has been loaded with the CFA of the word we
# are going to execute.
# ---------------------------------------------------------------------------
pbAsm::Code {ATO4TH}   {JSR     _ATO4TH      }
pbAsm::Code {}         {ADDS.W  #2, rDSP     }
pbAsm::Code {}         {ADDS.W  #2, rDSP     }
pbAsm::Code {}         {RTS                  }

pbAsm::Code {_ATO4TH}  {MOV.W   rDSP, rFIP   } { Save pointer to pointer to return address }
pbAsm::Code {}         {MOV.W   rFIP, @-rDSP } { Save pointer to pointer to return address }
pbAsm::Code {}         {MOV.W   rDSP, rFIP   } { Copy to rFIP for EXIT                     }
pbAsm::Code {}         {JMP     LOADPC       } { Execute the Forth CFA in rFWP             }
# ---------------------------------------------------------------------------
# 'ato4th TickATO4TH
# ---------------------------------------------------------------------------
pbAsm::Constant {'ato4th} TickATO4TH ATO4TH CORE
# ---------------------------------------------------------------------------
