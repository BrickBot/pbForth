# ----------------------------------------------------------------------------
# h8300-primary.tcl - Core Forth words for Hitachi H8300 Processor
#
# Revision History
#
# R.Hempel 16Apr2002 Optimize EXIT by merging in NEXT
# R.Hempel 22Mar2002 Clean up comments for release
# R.Hempel 26Oct2001 @ and ! need to work on byte boundaries
# R.Hempel 01Oct2001 Fixed stupid problem with ROLL definition
#                     that changed the DSP on the fly!
# R.Hempel 26Sep2001 DEPTH, RDepth should used signed division
#                    Added SPInit, RPInit primitives
#                    Move KEY and EMIT to h8300-primary-rcx.tcl
# R.Hempel 21Sep2001 Fixed bug in direction of overlapping MOVE
#                    Added do2CONST
# R.Hempel 19Sep2001 Added more comments
# R.Hempel 04Mar2001 Original
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
# The original MAF specification requires the following words be defined
# as primitives:
#
# EXECUTE   ROLL     CELLS         <Does>       Nand
# !         DROP     CHARS         <Variable>   NEGATE
# @         DEPTH    ALIGNED       <Constant>   DNEGATE
# C!        >R       MatchString   <Literal>    KEY
# C@        R@       Branch!       <Branch>     EMIT
# MOVE      R>       <:>           <0Branch>
# PICK      RDepth   EXIT          +
#
# The assembler source used in this file corresponds to the format expected
# by the GNU assembler for the H8/300. We've adopted a number of register
# naming conventions that should make the source easier to read:
#
# r7 - rDSP - The Forth Data Stack pointer
# r6 - rTOS - The Forth Top of Stack, also first parameter for RCX functions
# r5 - rRSP - The Forth Return Stack pointer
# r4 - rFIP - The Forth Instruction Pointer
# r3 - rFWP - The Forth Word Pointer
# r2 - rC   - Spare register rC
# r1 - rB   - Spare register rB
# r0 - rA   - Spare register rA
#
# The H8/300 register operations have post-increment and pre-decrement
# modifiers. The register always points at a current entry, and stacks
# grow downward in memory.
# 
# The MAF source code explains the design decisions in great detail. This
# Forth implementation is the classic indirect threaded model because
# it provides maximum portability. The definition of secondary words does
# not require any processor-specific information.
#
# The minimum set of primary words required for a complete system are
# defined below. All other words are secondaries.
# ---------------------------------------------------------------------------
# EXECUTE   Execute   Execute
# ---------------------------------------------------------------------------
pbAsm::Primary {EXECUTE} Execute 0 CORE

pbAsm::Code {}         {MOV.W   rTOS,rFWP    } {get the CFA to EXECUTE     }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  } {get a new item from stack  }
pbAsm::Code {}         {JMP     LOADPC       } {jump to that address       }
# ---------------------------------------------------------------------------
# !   Store   Store
# ---------------------------------------------------------------------------
pbAsm::Primary {!} Store 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rA    } {get the x to store         }
pbAsm::Code {}         {MOV.B   rAh,@rTOS    } {and store in through rTOS  }
pbAsm::Code {}         {MOV.B   rAl,@(1,rTOS)} {and store in through rTOS  }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  } {grab new value for TOS     }
pbAsm::Code {}         {JMP     NEXT         } {                           }
# ---------------------------------------------------------------------------
# @    Fetch  Fetch
# ---------------------------------------------------------------------------
pbAsm::Primary {@} Fetch 0 CORE

pbAsm::Code {}         {MOV.B   @rTOS,rAh    }
pbAsm::Code {}         {MOV.B   @(1,rTOS),rAl}
pbAsm::Code {}         {MOV.W   rA,rTOS      }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# C!  CharStore   Char-Store
# ---------------------------------------------------------------------------
pbAsm::Primary {C!} CharStore 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rA    }
pbAsm::Code {}         {MOV.B   rAl,@rTOS    }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# C@  CharFetch  Char-Fetch
# ---------------------------------------------------------------------------
pbAsm::Primary {C@} CharFetch 0 CORE

pbAsm::Code {}         {MOV.B   @rTOS,rTOSl  }
pbAsm::Code {}         {MOV.B   #0,rTOSh     }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# MOVE  Move   Move
# ---------------------------------------------------------------------------
pbAsm::Primary {MOVE} Move 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rB    } {grab the TO address                 }
pbAsm::Code {}         {MOV.W   @rDSP+,rA    } {grab the FROM address               }
pbAsm::Code {}         {MOV.W   rTOS,rTOS    } {check for zero bytes to move        }
pbAsm::Code {}         {BEQ     MOVE2        } {                                    }
pbAsm::Code {}         {                     } {                                    }
pbAsm::Code {}         {CMP.W   rA,rB        } {check for direction                 }
pbAsm::Code {}         {BHI     MOVEUP       } {                                    }
pbAsm::Code {}         {                     } {                                    }
pbAsm::Code {MOVEDOWN} {ADD.W   rA,rTOS      } {set up loop end condition           }
pbAsm::Code {}         {                     } {                                    }
pbAsm::Code {MOVE1}    {MOV.B   @rA+,rCl     } {grab the next source byte and adjust}
pbAsm::Code {}         {MOV.B   rCl,@rB      } {write the next dest byte and adjust }
pbAsm::Code {}         {ADDS.W  #1,rB        } {                                    }
pbAsm::Code {}         {CMP.W   rA,rTOS      } {check if we're done yet             }
pbAsm::Code {}         {BNE     MOVE1        } {                                    }
pbAsm::Code {}         {                     } {                                    }
pbAsm::Code {MOVE2}    {MOV.W   @rDSP+,rTOS  } {grab new top stack item             }
pbAsm::Code {}         {JMP     NEXT         } {                                    }
pbAsm::Code {}         {                     } {                                    }
pbAsm::Code {MOVEUP}   {ADD.W   rTOS,rB      } {Adjust TO pointer                   }
pbAsm::Code {}         {ADD.W   rA,rTOS      } {Adjust FROM pointer                 }
pbAsm::Code {}         {                     } {                                    }
pbAsm::Code {MOVE3}    {SUBS.W  #1,rTOS      } {                                    }
pbAsm::Code {}         {MOV.B   @rTOS,rCl    } {adjust and grab the next source byte}
pbAsm::Code {}         {MOV.B   rCl,@-rB     } {adjust and write the next dest byte }
pbAsm::Code {}         {CMP.W   rTOS,rA      } {check if we're done yet             }
pbAsm::Code {}         {BNE     MOVE3        } {                                    }
pbAsm::Code {}         {BRA     MOVE2        } {exit through MOVE2                  }
# ---------------------------------------------------------------------------
# PICK  Pick   Pick
# ---------------------------------------------------------------------------
pbAsm::Primary {PICK} Pick 0 CORE

pbAsm::Code {}         {ADD.W   rTOS,rTOS    } {Point at the pick entry }
pbAsm::Code {}         {ADD.W   rDSP,rTOS    } { by doubling...         }
pbAsm::Code {}         {MOV.W   @rTOS,rTOS   } {and grab it             }
pbAsm::Code {}         {JMP     NEXT         } {                        }
# ---------------------------------------------------------------------------
# ROLL  Roll   Roll
# ---------------------------------------------------------------------------
pbAsm::Primary {ROLL} Roll 0 CORE

pbAsm::Code {}         {ADD.W   rTOS,rTOS    } {point to nth entry              }
pbAsm::Code {}         {ADD.W   rDSP,rTOS    } {                                }
pbAsm::Code {}         {MOV.W   @rTOS,rA     } {Save the nth entry              }
pbAsm::Code {}         {                     } {                                }
pbAsm::Code {ROLL1}    {CMP.W   rTOS,rDSP    } {check if more loops...          }
pbAsm::Code {}         {BEQ     ROLL2        } {and if not, just exit           }
pbAsm::Code {}         {SUBS.W  #2,rTOS      } {Point at the next entry to grab }
pbAsm::Code {}         {MOV.W   @rTOS,rB     } {Grab it                         }
pbAsm::Code {}         {MOV.W   rB,@(2,rTOS) } {And move it up one cell         }
pbAsm::Code {}         {BRA     ROLL1        } {and go back for more...         }
pbAsm::Code {}         {                     } {                                }
pbAsm::Code {ROLL2}    {ADDS.W   #2,rDSP     } {Adjust stack pointer            }
pbAsm::Code {}         {MOV.W   rA,rTOS      } {Copy the nth entry to TOS       }
pbAsm::Code {}         {JMP     NEXT         } {                                }
# ---------------------------------------------------------------------------
# DROP  Drop  Drop
# ---------------------------------------------------------------------------
pbAsm::Primary {DROP} Drop 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# DEPTH  Depth   Depth
#
# Note, this will have to be changed for multi-tasking!
# ---------------------------------------------------------------------------
pbAsm::Primary {DEPTH} Depth 0 CORE

pbAsm::Code {}         {MOV.W   #_S0,rA      } {figure out stack depth     }
pbAsm::Code {}         {SUB.W   rDSP,rA      } {                           }
pbAsm::Code {}         {SHAR.B  rAh          } {divide by two, signed!     }
pbAsm::Code {}         {ROTXR.B rAl          } {                           }
pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  } {make room for the result   }
pbAsm::Code {}         {MOV.W   rA,rTOS      } {                           }
pbAsm::Code {}         {JMP     NEXT         } {                           }
# ---------------------------------------------------------------------------
# SPInit  SPInit   sp-init
# ---------------------------------------------------------------------------
pbAsm::Primary {SPInit} SPInit 0 {}

pbAsm::Code {}         {MOV.W   #_S0, rDSP   }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# >R   ToR To-R
# ---------------------------------------------------------------------------
pbAsm::Primary {>R} ToR COMP CORE

pbAsm::Code {}         {MOV.W   rTOS,@-rRSP  } {move TOS to return stack }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  } {grab new TOS value       }
pbAsm::Code {}         {JMP     NEXT         } {                         }
# ---------------------------------------------------------------------------
# R@   RFetch  R-Fetch
# ---------------------------------------------------------------------------
pbAsm::Primary {R@} RFetch COMP CORE

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  } {save the top of stack    }
pbAsm::Code {}         {MOV.W   @rRSP,rTOS   } {grab new value for TOS   }
pbAsm::Code {}         {JMP     NEXT         } {                         }
# ---------------------------------------------------------------------------
# R>  RFrom  R-From
# ---------------------------------------------------------------------------
pbAsm::Primary {R>} RFrom COMP CORE

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  } {save the top of stack               }
pbAsm::Code {}         {MOV.W   @rRSP+,rTOS  } {grab top of return stack and adjust }
pbAsm::Code {}         {JMP     NEXT         } {                                    }
# ---------------------------------------------------------------------------
# RDepth  RDepth  R-Depth
#
# Note, this will have to be changed for multi-tasking!
# ---------------------------------------------------------------------------
pbAsm::Primary {RDepth} RDepth 0 {}

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  } {make room for the result   }
pbAsm::Code {}         {MOV.W   #_R0,rTOS    } {figure out stack depth     }
pbAsm::Code {}         {SUB.W   rRSP,rTOS    } {                           }
pbAsm::Code {}         {SHAR.B  rTOSh        } {divide by two, signed!     }
pbAsm::Code {}         {ROTXR.B rTOSl        } {                           }
pbAsm::Code {}         {JMP     NEXT         } {                           }
# ---------------------------------------------------------------------------
# RPInit  RPInit   rp-init
# ---------------------------------------------------------------------------
pbAsm::Primary {RPInit} RPInit 0 {}

pbAsm::Code {}         {MOV.W   #_R0, rRSP   }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# CELLS  Cells  Cells
# ---------------------------------------------------------------------------
pbAsm::Primary {CELLS} Cells 0 CORE

pbAsm::Code {}         {ADD.W   rTOS,rTOS    } {just double the value     }
pbAsm::Code {}         {JMP     NEXT         } {                          }
# ---------------------------------------------------------------------------
# CHARS Chars  Chars
# ---------------------------------------------------------------------------
pbAsm::Primary {CHARS} Chars 0 CORE

pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# ALIGNED Aligned  Aligned
# ---------------------------------------------------------------------------
pbAsm::Primary {ALIGNED} Aligned 0 CORE

pbAsm::Code {}         {ADDS.W  #1,rTOS      } {move to the next cell       }
pbAsm::Code {}         {BCLR    #0,rTOSl     } {and make sure it's even     }
pbAsm::Code {}         {JMP     NEXT         } {                            }
# ---------------------------------------------------------------------------
# MatchString   MatchString  Match-String
# ---------------------------------------------------------------------------
pbAsm::Primary {MatchString} MatchString 0 {}

pbAsm::Code {}         {MOV.W   @rDSP,rA       } {grab the reference address   }
pbAsm::Code {}         {                       } {                             }
pbAsm::Code {MATCH1}   {MOV.B   @rA+,rBh       } {get reference string byte    }
pbAsm::Code {}         {MOV.B   @rTOS+,rBl     } {get target string byte       }
pbAsm::Code {}         {CMP.B   rBh,rBl        } {compare for equality         }
pbAsm::Code {}         {BEQ     MATCH1         } {if equal, keep going         }
pbAsm::Code {}         {                       } {                             }
pbAsm::Code {}         {SUBS.W  #1,rA          } {adjust auto-incremented ptrs }
pbAsm::Code {}         {MOV.W   rA,@rDSP       } {put the reference ptr back   }
pbAsm::Code {}         {SUBS.W  #1,rTOS        } {                             }
pbAsm::Code {}         {JMP     NEXT           } {                             }
# ---------------------------------------------------------------------------
# Branch!  BranchStore  Branch-Store  (Same as Store)
# ---------------------------------------------------------------------------
pbAsm::Primary {Branch!} BranchStore 0 {}

pbAsm::Code {}         {MOV.W   @rDSP+,rA      } {get the x to store         }
pbAsm::Code {}         {MOV.W   rA,@rTOS       } {and store in through rTOS  }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS    } {grab new value for TOS     }
pbAsm::Code {}         {JMP     NEXT           } {                           }
# ---------------------------------------------------------------------------
# <:>   doCOLON   do-Colon
# ---------------------------------------------------------------------------
pbAsm::Primary {<:>} doCOLON 0 {}

pbAsm::Code {}         {MOV.W   rFIP,@-rRSP    }
pbAsm::Code {}         {MOV.W   rFWP,rFIP      }
pbAsm::Code {}         {ADDS.W  #2,rFIP        }
pbAsm::Code {}         {                       }
pbAsm::Code {NEXT}     {MOV.W   @rFIP+,rFWP    }
pbAsm::Code {LOADPC}   {MOV.W   @rFWP,r0       }
pbAsm::Code {}         {JMP     @r0            }
# ---------------------------------------------------------------------------
# EXIT  Exit    Exit
# ---------------------------------------------------------------------------
pbAsm::Primary {EXIT} Exit COMP CORE

pbAsm::Code {}         {MOV.W   @rRSP+,rFIP    }
pbAsm::Code {}         {MOV.W   @rFIP+,rFWP    } { This is an optimization }
pbAsm::Code {}         {MOV.W   @rFWP,r0       } { A copy of the NEXT code }
pbAsm::Code {}         {JMP     @r0            } { replaces JMP NEXT       }
# ---------------------------------------------------------------------------
# <Does>  doDOES  do-Does
# ---------------------------------------------------------------------------
pbAsm::Primary {<Does>} doDOES 0 {}

pbAsm::Code {}         {MOV.W   rFIP,@-rRSP    }
pbAsm::Code {}         {ADDS.W  #2,rFWP        }
pbAsm::Code {}         {MOV.W   @rFWP+,rFIP    }
pbAsm::Code {}         {MOV.W   rTOS,@-rDSP    }
pbAsm::Code {}         {MOV.W   rFWP,rTOS      }
pbAsm::Code {}         {JMP     NEXT           }
# ---------------------------------------------------------------------------
# <Variable>  doVAR  do-Var
# ---------------------------------------------------------------------------
pbAsm::Primary {<Variable>} doVAR 0 {}

pbAsm::Code {}         {ADDS.W  #2,rFWP        }
pbAsm::Code {}         {MOV.W   rTOS,@-rDSP    }
pbAsm::Code {}         {MOV.W   rFWP,rTOS      }
pbAsm::Code {}         {JMP     NEXT           }
# ---------------------------------------------------------------------------
# <Constant>   doCONST  do-Const
# ---------------------------------------------------------------------------
pbAsm::Primary {<Constant>} doCONST 0 {}

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP    }
pbAsm::Code {}         {MOV.W   @(2,rFWP),rTOS }
pbAsm::Code {}         {JMP     NEXT           }
# ---------------------------------------------------------------------------
# <2Constant>   do2CONST  do-2Const
# ---------------------------------------------------------------------------
pbAsm::Primary {<2Constant>} do2CONST 0 {}

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP    }
pbAsm::Code {}         {MOV.W   @(2,rFWP),rTOS }
pbAsm::Code {}         {MOV.W   rTOS,@-rDSP    }
pbAsm::Code {}         {MOV.W   @(4,rFWP),rTOS }
pbAsm::Code {}         {JMP     NEXT           }
# ---------------------------------------------------------------------------
# <Literal>    doLIT    do-Lit
# ---------------------------------------------------------------------------
pbAsm::Primary {<Literal>} doLIT 0 {}

pbAsm::Code {}         {MOV.W   rTOS,@-rDSP    }
pbAsm::Code {}         {MOV.W   @rFIP+,rTOS    }
pbAsm::Code {}         {JMP     NEXT           }
# ---------------------------------------------------------------------------
# <Branch>  Branch  Branch
# ---------------------------------------------------------------------------
pbAsm::Primary {<Branch>} Branch 0 {}

pbAsm::Code {}         {MOV.W   @rFIP,rFIP     }
pbAsm::Code {}         {JMP     NEXT           }
# ---------------------------------------------------------------------------
# <0Branch>  ZBranch  ZBranch
# ---------------------------------------------------------------------------
pbAsm::Primary {<0Branch>} ZBranch 0 {}

pbAsm::Code {}         {MOV.W   rTOS,rTOS    }
pbAsm::Code {}         {BEQ     ZBRANCH1     }
pbAsm::Code {}         {ADDS.W  #2,rFIP      }
pbAsm::Code {}         {BRA     ZBRANCH2     }
pbAsm::Code {ZBRANCH1} {MOV.W   @rFIP,rFIP   }
pbAsm::Code {ZBRANCH2} {MOV.W   @rDSP+,rTOS  }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# +    Plus   Plus
# ---------------------------------------------------------------------------
pbAsm::Primary {+} Plus 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP+,rA    }
pbAsm::Code {}         {ADD.W   rA,rTOS      }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# Nand    Nand   Nand
# ---------------------------------------------------------------------------
pbAsm::Primary {Nand} Nand 0 {}

pbAsm::Code {}         {MOV.W   @rDSP+,rA    }
pbAsm::Code {}         {AND.B   rAl,rTOSl    }
pbAsm::Code {}         {AND.B   rAh,rTOSh    }
pbAsm::Code {}         {NOT.B   rTOSl        }
pbAsm::Code {}         {NOT.B   rTOSh        }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# NEGATE    Negate      Negate
# ---------------------------------------------------------------------------
pbAsm::Primary {NEGATE} Negate 0 CORE

pbAsm::Code {}         {NOT.B   rTOSl        }
pbAsm::Code {}         {NOT.B   rTOSh        }
pbAsm::Code {}         {ADDS.W  #1,rTOS      }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# DNEGATE    DNegate   D-Negate
#
# Lotsa code, but faster than conditionals!
# ---------------------------------------------------------------------------
pbAsm::Primary {DNEGATE} DNegate 0 CORE

pbAsm::Code {}         {MOV.W   @rDSP,rA     } {copy the LSB of the double }
pbAsm::Code {}         {NOT.B   rTOSl        } {Invert the complete number }
pbAsm::Code {}         {NOT.B   rTOSh        } {                           }
pbAsm::Code {}         {NOT.B   rAl          } {                           }
pbAsm::Code {}         {NOT.B   rAh          } {                           }
pbAsm::Code {}         {ADD.B   #1,rAl       } {And add one!               }
pbAsm::Code {}         {ADDX.B  #0,rAh       } {                           }
pbAsm::Code {}         {ADDX.B  #0,rTOSl     } {                           }
pbAsm::Code {}         {ADDX.B  #0,rTOSh     } {                           }
pbAsm::Code {}         {MOV.W   rA,@rDSP     } {and save the new LSB       }
pbAsm::Code {}         {JMP     NEXT         } {                           }
# ---------------------------------------------------------------------------
