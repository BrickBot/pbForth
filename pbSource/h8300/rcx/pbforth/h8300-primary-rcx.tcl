# -----------------------------------------------------------------------------
# h8300-primary-rcx.tcl - Additional primary words that support the RCX
#
# Revision History
#
# R.Hempel 03May2002 Fix stack adjust error in SOUND_TONE
# R.Hempel 12Apr2002 Add 'UserIdle hook in KEY
# R.Hempel 22Mar2002 Clean up comments for release
# R.Hempel 10Nov2001 Fixed up direction set for SERVOs
#                    Removed dead words
# R.Hempel 30Sep2001 Cleaned up comments and optimized words
# R.Hempel 26Sep2001 Move KEY and EMIT from h8300-primary.tcl
#                    Added EKEY and EKEY?
# R.Hempel 21Sep2001 Original from old pbForth source
# -----------------------------------------------------------------------------
#  pbFORTH extensions for h8hforth for (r)LEGO RCX Target
# 
#  With comments and implementation ideas from Kekoa Proudfoot, Markus Noga,
#  and John Cooper.
#
# EKEY 
# KEY  
# EKEY?
# EMIT 
#
# -----------------------------------------------------------------------------
#  NOTE WELL that this code DEPENDS on r6 being rRCX and rTOS. The stack 
#  frame looks like this at any call into the RCX firmware:
# 
#  rDSP+6: parameter 4
#  rDSP+4: parameter 3
#  rDSP+2: parameter 2
#  rTOS  : parameter 1
# 
#  And after the function call ,the result is still in rTOS. It is up to the
#  caller to clean up the stack.
# EKEY    EKey   e-key
# ---------------------------------------------------------------------------
pbAsm::Primary {EKEY} EKey 0 CORE
          
pbAsm::Code {EKEY1}    {JSR     _getChar     }
pbAsm::Code {}         {CMP.B   #0x00,r0h    }
pbAsm::Code {}         {BNE     EKEY1        }
pbAsm::Code {}         {                     }
pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  }
pbAsm::Code {}         {MOV.W   r0,rTOS      }
pbAsm::Code {}         {                     }
pbAsm::Code {}         {JMP     NEXT         }
# ---------------------------------------------------------------------------
# EKEY?    EKeyQ   e-key-question
# ---------------------------------------------------------------------------
pbAsm::Primary {EKEY?} EKeyQ 0 CORE

pbAsm::Code {}         {JSR     _checkChar   }
pbAsm::Code {}         {MOV.W   rTOS,@-rDSP  }
pbAsm::Code {}         {MOV.W   r0,rTOS      }
pbAsm::Code {EKEYQ1}   {JMP     NEXT         }
# ---------------------------------------------------------------------------
# KEY    Key   key
#
#     TickUserIdle @ EXECUTE           \ Do some background processing
#
# ---------------------------------------------------------------------------
pbAsm::Create {'UserIdle} TickUserIdle 0 CORE 

pbAsm::Cell {}         VALUE1
pbAsm::Cell {UserIdle} NoOp
# ---------------------------------------------------------------------------
pbAsm::Secondary {KEY} Key 0 CORE

pbAsm::Cell        {KEY1} TickUserIdle
pbAsm::Cell            {} Execute
pbAsm::Cell            {} EKeyQ
pbAsm::Cell            {} ZBranch
pbAsm::Cell            {} KEY1
pbAsm::Cell            {} EKey
pbAsm::Literal         {} 127
pbAsm::Cell            {} And
pbAsm::Cell            {} Exit
# ---------------------------------------------------------------------------
# EMIT    Emit   Emit
# ---------------------------------------------------------------------------
pbAsm::Primary {EMIT} Emit 0 CORE

pbAsm::Code {}         {MOV.B   rTOSl,r0l    }
pbAsm::Code {}         {JSR     _putChar     }
pbAsm::Code {}         {MOV.W   @rDSP+,rTOS  }
pbAsm::Code {}         {JMP     NEXT         }          
# ---------------------------------------------------------------------------
# The fundamental math operators in pbForth are implemented as a series of
# shifts and adds in standard Forth. There is significant room for improvement
# if we can leverage the routines in the RCX ROM that do the guts of what
# we need.
#
# UM* -> _rom_ulong_mul
# -----------------------------------------------------------------------------
# UM*    UM* ( u1 u2 -- ud )
# -----------------------------------------------------------------------------
pbAsm::Primary {UM*} UMStar 0 CORE

pbAsm::Code {}         {MOV.W  r3,rA         } {Save the registers we're using}
pbAsm::Code {}         {MOV.W  r4,rB         } {                              }
pbAsm::Code {}         {MOV.W  r5,rC         } {                              }
pbAsm::Code {}         {MOV.W  #0x0000,r5    } {MSW of u2                     }
pbAsm::Code {}         {MOV.W  @rDSP,r4      } {u1                            }
pbAsm::Code {}         {MOV.W  #0x0000,r3    } {MSW of u1                     }

pbAsm::Code {}         {JSR    _rom_ulong_mul} {                              }
pbAsm::Code {}         {MOV.W  r6,@rDSP      } {LSW of ud                     }
pbAsm::Code {}         {MOV.W  r5,r6         } {MSW of ud                     }

pbAsm::Code {}         {MOV.W  rC,r5         } {Restore the registers we saved}
pbAsm::Code {}         {MOV.W  rB,r4         } {                              }
pbAsm::Code {}         {MOV.W  rA,r3         } {                              }

pbAsm::Code {}         {JMP    NEXT          }
# -----------------------------------------------------------------------------
# SERVOIdx is a simple counter we use for keeping track of the servo service
#
# This array holds all of the processing info we'll need for our servos as
# follows:
#
# 0 - The number of ticks left in the current pulse
# 2 - The number of ticks that the device should be reset to
# 4 - The address of the bit-pattern for the modulated output waveform
# 6 - The bit mask for the motor controller
# 7 - The bit pattern for FORWARD on the motor controller
# 8 - The bit pattern for REVERSE on the motor controller
# 9 - The bit pattern for the selected motor direction
# -----------------------------------------------------------------------------
pbAsm::Cell {SERVOidx}  {0x0000}

pbAsm::Cell {SERVO_0}   {0x0000,0x0000,0xEFCB,0x3F80,0x4000}
pbAsm::Cell {SERVO_1}   {0x0000,0x0000,0xEFCC,0xF308,0x0400}
pbAsm::Cell {SERVO_2}   {0x0000,0x0000,0xEFCD,0xFC02,0x0100}
pbAsm::Cell {SERVO_3}   {0x0000,0x0000,0x0000,0xFF00,0x0000}

pbAsm::Cell {SERVO_IDX} {SERVO_0,SERVO_1,SERVO_2,SERVO_3   }
# -----------------------------------------------------------------------------
# SERVO_SET    SERVO_SET ( value dir idx -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {SERVO_SET} SERVO_SET 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA           } {Set up pointer to servo data               }
pbAsm::Code {}         {XOR.B  rTOSh,rTOSh       } {Make the index safe                        }
pbAsm::Code {}         {AND.B  #0x03,rTOSl       } {In the range 0-3                           }
pbAsm::Code {}         {ADD.W  rTOS,rA           } {                                           }
pbAsm::Code {}         {MOV.W  @(SERVO_IDX,rA),rA} {                                           }
pbAsm::Code {}         {}
pbAsm::Code {}         {MOV.W  @(4,rA),rC        } {Force motor waveform to continuous         }
pbAsm::Code {}         {MOV.B  #0xFF,rBl         } {                                           }
pbAsm::Code {}         {MOV.B  rBl,@rC           } {                                           }
pbAsm::Code {}         {}
pbAsm::Code {}         {MOV.B  @(7,rA),rBl       } {Grab the default FWD setting for the motor }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS       } {Grab the direction                         }
pbAsm::Code {}         {SUBS.W #1,rTOS           } {If it's one, then set dir forward          }
pbAsm::Code {}         {MOV.W  rTOS,rTOS         }
pbAsm::Code {}         {BEQ    SETfwd            }
pbAsm::Code {}         {SUBS.W #1,rTOS           } {If it's two, then set dir reverse          }
pbAsm::Code {}         {MOV.W  rTOS,rTOS         }
pbAsm::Code {}         {BEQ    SETrev            }
pbAsm::Code {}         {}
pbAsm::Code {SEToff}   {MOV.W  @rDSP+,rTOS       } {Grab and discard the value                 }
pbAsm::Code {}         {SUB.W  rTOS,rTOS         } {Clear it                                   }
pbAsm::Code {}         {MOV.W  rTOS,@(2,rA)      } {Save the new value                         }
pbAsm::Code {}         {MOV.B  @0xEFCA,rCl       } {Force motor to OFF                         }
pbAsm::Code {}         {MOV.B  @(6,rA),rCh       } {Grab the mask to turn motor off            }
pbAsm::Code {}         {AND.B  rCh,rCl           } {                                           }
pbAsm::Code {}         {MOV.B  rCl,@0xEFCA       } {Save unmodulated motor state               }
pbAsm::Code {}         {MOV.B  rCl,@0xEFCE       } {Save modulated motor state for real OC1A   }
pbAsm::Code {}         {BRA    SETexit           }
pbAsm::Code {}         {}
pbAsm::Code {SETrev}   {MOV.B  @(8,rA),rBl       } {Grab the default REV setting for the motor }
pbAsm::Code {SETfwd}   {}
pbAsm::Code {SETdir}   {MOV.B  rBl,@(9,rA)       } {Set the motor direction bits               }
pbAsm::Code {}         {}
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS       } {Grab the value                             }
pbAsm::Code {}         {ADD.B  #0x7F,rTOSl       } {Adjust it to positive range                }
pbAsm::Code {}         {XOR.B  rTOSh,rTOSh       } {Clear out the high byte                    }
pbAsm::Code {}         {MOV.W  rTOS,@(2,rA)      } {Save the new value                         }
pbAsm::Code {}         {}
pbAsm::Code {SETexit}  {MOV.W  @rDSP+,rTOS       } {Grab a new top of stack item               }
pbAsm::Code {}         {JMP     NEXT             }
# -----------------------------------------------------------------------------
pbAsm::Create {'UserISR} TickUserISR 0 CORE 

pbAsm::Cell {}         VALUE1
pbAsm::Cell {UserISR}  NoOp

pbAsm::Cell {inUserISR} {0x0000}

# -----------------------------------------------------------------------------
# OCIA Wedge is the interrupt service routine for servos
# -----------------------------------------------------------------------------
pbAsm::Code {OCIAwedge} {MOV.W  rA,@-rDSP         } {Save any registers we'll use              }
pbAsm::Code {}          {MOV.W  rB,@-rDSP         } {                                          }
pbAsm::Code {}          {MOV.W  rC,@-rDSP         } {                                          }
pbAsm::Code {}          {}
pbAsm::Code {}          {MOV.W  @SERVOidx,rA      } {Recalculate the servo state counter       }
pbAsm::Code {}          {INC.B  rAh               } {                                          }
pbAsm::Code {}          {AND.B  #0x7,rAh          } {Limit range to between 0-7                }
pbAsm::Code {}          {BEQ    NEWmotor          } {We're at a new motor....                  }
pbAsm::Code {}          {}
pbAsm::Code {}          {MOV.W  rA,@SERVOidx      } {Save the new values for next time         }
pbAsm::Code {}          {XOR.B  rAh,rAh           } {Clear out the high byte                   }
pbAsm::Code {}          {ADD.W  rA,rA             } {Set up pointer to servo data              }
pbAsm::Code {}          {MOV.W  @(SERVO_IDX,rA),rA} {                                          }
pbAsm::Code {}          {MOV.W  @(2,rA),rB        } {Check if we should process this servo     }
pbAsm::Code {}          {BNE    DECticks          } {                                          }
pbAsm::Code {}          {BRA    OCIAexit          } {No, just exit right now                   }
pbAsm::Code {}          {}
pbAsm::Code {NEWmotor}  {INC.B  rAl               } {Recalculate the motor idx                 }
pbAsm::Code {}          {AND.B  #0x03,rAl         } {Limit range to between 0-3                }
pbAsm::Code {}          {MOV.W  rA,@SERVOidx      } {Save the new values for next time         }
pbAsm::Code {}          {}
pbAsm::Code {}          {ADD.W  rA,rA             } {Set up pointer to servo data              }
pbAsm::Code {}          {MOV.W  @(SERVO_IDX,rA),rA} {                                          }
pbAsm::Code {}          {}
pbAsm::Code {SETticks}  {MOV.W  @(2,rA),rB        } {Check if we should set this servo up      }
pbAsm::Code {}          {BEQ    OCIAexit          } {No, just exit right now                   }
pbAsm::Code {}          {}
pbAsm::Code {}          {MOV.B  @0xEFCA,rCl       } {Force motor to OFF                        }
pbAsm::Code {}          {MOV.B  @(6,rA),rCh       } {Grab the mask to turn motor off           }
pbAsm::Code {}          {AND.B  rCh,rCl           } {                                          }
pbAsm::Code {}          {MOV.B  rCl,@0xEFCA       } {Save unmodulated motor state              }
pbAsm::Code {}          {MOV.B  rCl,@0xEFCE       } {Save modulated motor state for real OC1A  }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {ADD.W   rB,rB            } {Multiply by two                           }
pbAsm::Code {}          {ADD.W   rB,rB            } {Multiply by four                          }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {ADD.B  #250,rBl          } {Now number of ticks is 250+(4*X)          }
pbAsm::Code {}          {ADDX.B #0,rBh            } {                                          }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W  rB,@(0,rA)        } {Save the number of ticks for the math     }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {DECticks}  {MOV.W  @(0,rA),rB        } {Grab the number of ticks left             }
pbAsm::Code {}          {MOV.W  #5,rC             } {Check for less than 5 ticks left          }
pbAsm::Code {}          {CMP.W  rC,rB             } {If there are less than 5                  }
pbAsm::Code {}          {BLO    DONEticks         } {Force the motor back on!                  }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W  #500,rC           } {Now check for more than 500 ticks left    }
pbAsm::Code {}          {CMP.W  rC,rB             } {If there are fewer than 500, set up OCIB  }
pbAsm::Code {}          {BHS    NEXTticks         } {                                          }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {BSET   #4,@H8_TOCR:8     } {Allow writes to OCRB                      }
pbAsm::Code {}          {MOV.W  rB,@H8_OCRB       } {Set the number of tick left to OCB        }
pbAsm::Code {}          {BCLR   #4,@H8_TOCR:8     } {Allow writes to OCRA                      }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {BCLR   #2,@H8_TCSR:8     } {Clear pending OCRB interrupts             }
pbAsm::Code {}          {BSET   #2,@H8_TIER:8     } {Allow OCRB interrupts                     }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {NEXTticks} {SUB.W  rC,rB             } {Do the subtract thing, and save the ticks }
pbAsm::Code {}          {MOV.W  rB,@rA            } {Save  number of ticks left for next time  }
pbAsm::Code {}          {BRA    OCIAexit          } {                                          }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {DONEticks} {MOV.B  @(9,rA),rCh       } {Grab the default setting for the motor    }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.B  @0xEFCA,rCl       } {Force motor to proper FWD/REV state       }
pbAsm::Code {}          {OR.B   rCh,rCl           } {OR since OFF was zeros!                   }
pbAsm::Code {}          {MOV.B  rCl,@0xEFCA       } {Save unmodulated motor state              }
pbAsm::Code {}          {MOV.B  rCl,@0xEFCE       } {Save modulated motor state for  real OC1A }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {OCIAexit}  {MOV.W  #_rom_OCIA_handler,r6} {Grab the original OCIA vector          }
pbAsm::Code {}          {JSR    @r6               } {And call originalOCIA routine to finish up}
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {ChkUserISR} {ORC    #0x80,ccr        } {Disable interrupts                        }
pbAsm::Code {}          {MOV.B  @inUserISR, r6l   } {Check if we're already in the UserISR     }
pbAsm::Code {}          {BNE    endUserISR        } {If yes, then skip running the UserISR     }
pbAsm::Code {}          {NOT.B  r6l               } {Set the inUserISR flag                    }
pbAsm::Code {}          {MOV.B  r6l,@inUserISR    } {And save it                               }
pbAsm::Code {}          {ANDC   #0x7F,ccr         } {Enable interrupts                         }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W   rRSP,@-rDSP      } {Save any registers we're using            }
pbAsm::Code {}          {MOV.W   rFIP,@-rDSP      } {                                          }
pbAsm::Code {}          {MOV.W   rFWP,@-rDSP      } {                                          }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W   #_IR0,rRSP       } {Set up a pointer to a private Return Stack}
pbAsm::Code {}          {MOV.W   rDSP,@-rRSP      } {Save the data stack pointer               }
pbAsm::Code {}          {MOV.W   #_IS0,rDSP       } {Set up a pointer to a private Data Stack  }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W   @UserISR,rFWP    } {Grab the CFA out of 'UserISR              }
pbAsm::Code {}          {JSR     ATO4TH           } {And jump into the Forth engine            }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W   @rRSP+,rDSP      } {Restore the original Data Stack pointer   }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W   @rDSP+,rFWP      } {Restore any registers we used             }
pbAsm::Code {}          {MOV.W   @rDSP+,rFIP      } {                                          }
pbAsm::Code {}          {MOV.W   @rDSP+,rRSP      } {                                          }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {ORC    #0x80,ccr         } {Disable interrupts                        }
pbAsm::Code {}          {MOV.B  #0, r6l           } {Clear the inUserISR flag                  }
pbAsm::Code {}          {MOV.B  r6l,@inUserISR    } {And save it                               }
pbAsm::Code {endUserISR} {ANDC   #0x7F,ccr        } {Enable interrupts                         }
pbAsm::Code {}          {                         } {                                          }
pbAsm::Code {}          {MOV.W  @rDSP+,rC         } {Restore any registers we used             }
pbAsm::Code {}          {MOV.W  @rDSP+,rB         } {                                          }
pbAsm::Code {}          {MOV.W  @rDSP+,rA         } {                                          }
pbAsm::Code {}          {RTS                      } {                                          }
# -----------------------------------------------------------------------------
# OCIBisr is a routine that will handle expiries on the OC1B comparator. Its
# job is to set the motor currently being processed to the correct state.
# -----------------------------------------------------------------------------
pbAsm::Code {OCIBisr}  {MOV.W  rA,@-rDSP         } {Save any registers we'll use               }
pbAsm::Code {}         {}
pbAsm::Code {}         {BCLR   #2,@H8_TIER:8     } {Disallow OCRB interrupts                   }
pbAsm::Code {}         {BCLR   #2,@H8_TCSR:8     } {Clear pending OCRB interrupts              }
pbAsm::Code {}         {}
pbAsm::Code {}         {MOV.W  @SERVOidx,rA      } {Figure out which motor we're on            }
pbAsm::Code {}         {XOR.B  rAh,rAh           } {                                           }
pbAsm::Code {}         {ADD.W  rA,rA             } {Set up pointer to servo data               }
pbAsm::Code {}         {MOV.W  @(SERVO_IDX,rA),rA} {                                           }
pbAsm::Code {}         {}
pbAsm::Code {OCIB1}    {MOV.B  @(9,rA),rAh       } {Grab the default setting for the motor     }
pbAsm::Code {}         {MOV.B  @0xEFCA,rAl       } {Force motor to proper FWD/REV state        }
pbAsm::Code {}         {OR.B   rAh,rAl           } {OR since OFF was zeros!                    }
pbAsm::Code {}         {MOV.B  rAl,@0xEFCA       } {Save unmodulated motor state               }
pbAsm::Code {}         {MOV.B  rAl,@0xEFCE       } {Save modulated motor state for real OC1A   }
pbAsm::Code {}         {MOV.B  rAl,@0xF000       } {Write result to motor drivers              }
pbAsm::Code {}         {}
pbAsm::Code {}         {MOV.W  @rDSP+,rA         } {                                           }
pbAsm::Code {}         {RTS                      } {                                           }
# -----------------------------------------------------------------------------
# This uses the exact same dispatch code as the RCX has in the ROM...it
# assumes that the handler saves all of the resisters it uses, but comes
# back to the caller via an RTS. The ROM routine we vectored through does
# the RTE for us!!!
#
# Knowing this, we can just load R6 (because that's the one the dispatch
# routine saved) and JSR into the old vector...
# -----------------------------------------------------------------------------
pbAsm::Code {_servo_init} {}

pbAsm::Code {}            {MOV.W  #OCIBisr,rA     } {Now set our routine to run first         }
pbAsm::Code {}            {MOV.W  rA,@_ocib_vector} {                                         }
pbAsm::Code {}            {                       }
pbAsm::Code {}            {MOV.W  #OCIAwedge,rA   } {Now set our routine to run first         }
pbAsm::Code {}            {MOV.W  rA,@_ocia_vector} {                                         }
pbAsm::Code {}            {                       }
pbAsm::Code {}            {RTS                    }
# -----------------------------------------------------------------------------
# The following routines access the firmware built into the ROM of the RCX
# which include:
# 
# LCD_SHOW ( segment -- )
# LCD_HIDE ( segment -- )
# LCD_NUMBER ( comma number int -- )
# LCD_CLEAR ( -- )
# LCD_REFRESH ( -- )
# 
# -----------------------------------------------------------------------------
# LCD_SHOW    LCD_SHOW ( segment -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {LCD_SHOW} LCD_SHOW 0 CORE

pbAsm::Code {}         {JSR    _rom_set_lcd_segment  } {                          }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS           } {Grab the next top of stack}
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# LCD_HIDE    LCD_HIDE ( segment -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {LCD_HIDE} LCD_HIDE 0 CORE

pbAsm::Code {}         {JSR    _rom_clear_lcd_segment} {                          }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS           } {Grab the next top of stack}
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# LCD_NUMBER    LCD_NUMBER ( comma value number -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {LCD_NUMBER} LCD_NUMBER 0 CORE

pbAsm::Code {}         {JSR    _rom_set_lcd_number   } {                          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP    } {Adjust the stack          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP    } {Adjust the stack          }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS           } {Grab the next top of stack}
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# LCD_CLEAR    LCD_CLEAR ( -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {LCD_CLEAR} LCD_CLEAR 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,@-rDSP           }
pbAsm::Code {}         {JSR    _rom_clear_display    }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS           }
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# LCD_4TH    LCD_4TH ( -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {LCD_4TH} LCD_4TH 0 CORE

pbAsm::Code {}         {MOV.W  #0x0020,rA            } {Fill the display bits             }
pbAsm::Code {}         {MOV.B  rAl,@0xEF43           } {                                  }
pbAsm::Code {}         {MOV.W  #0x0A00,rA            } {                                  }
pbAsm::Code {}         {MOV.W  rA,@0xEF44            } {                                  }
pbAsm::Code {}         {MOV.W  #0x0208,rA            } {                                  }
pbAsm::Code {}         {MOV.W  rA,@0xEF46            } {                                  }
pbAsm::Code {}         {MOV.W  #0xA0A0,rA            } {                                  }
pbAsm::Code {}         {MOV.W  rA,@0xEF48            } {                                  }
pbAsm::Code {}         {MOV.W  #0x002A,rA            } {                                  }
pbAsm::Code {}         {MOV.W  rA,@0xEF4A            } {                                  }
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# LCD_REFRESH    LCD_REFRESH ( -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {LCD_REFRESH} LCD_REFRESH 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,@-rDSP           }
pbAsm::Code {}         {JSR    _rom_refresh_display  }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS           }
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# RCX_SOUND ( -- a-addr )
# 
# RCX Sound Buffer - This can be used to provide a convenient address
# -----------------------------------------------------------------------------
pbAsm::Variable {RCX_SOUND} RCX_SOUND 0 CORE
# -----------------------------------------------------------------------------
# SOUND_PLAY    SOUND_PLAY ( sound code -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {SOUND_PLAY} SOUND_PLAY 0 CORE

pbAsm::Code {}         {JSR    _rom_play_system_sound} {                          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP    } {Adjust the stack          }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS           } {Grab the next top of stack}
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# SOUND_TONE    SOUND_TONE ( time freq -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {SOUND_TONE} SOUND_TONE 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,@-rDSP           } {Push the frequency first  }
pbAsm::Code {}         {MOV.W  #0x1773,rTOS          } {                          }
pbAsm::Code {}         {JSR    _rom_play_tone        } {                          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP    } {Adjust the stack          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP    } {                          }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS           } {Grab the next top of stack}
pbAsm::Code {}         {JMP     NEXT                 }
# -----------------------------------------------------------------------------
# SOUND_GET    SOUND_GET( a-addr -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {SOUND_GET} SOUND_GET 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,@-rDSP                } {Push the button code address first}
pbAsm::Code {}         {MOV.W  #0x700C,rTOS               } {                                  }
pbAsm::Code {}         {JSR    _rom_get_sound_playing_flag} {                                  }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP         } {Adjust the stack                  }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS                } {Grab the next top of stack        }
pbAsm::Code {}         {JMP     NEXT                      }
# -----------------------------------------------------------------------------
# RCX_BUTTON    RCX_BUTTON ( -- a-addr )
# -----------------------------------------------------------------------------
pbAsm::Variable {RCX_BUTTON} RCX_BUTTON 0 CORE
# -----------------------------------------------------------------------------
# BUTTON_GET    BUTTON_GET( a-addr -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {BUTTON_GET} BUTTON_GET 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,@-rDSP       } {Push the button code address first}
pbAsm::Code {}         {MOV.W  #0x3000,rTOS      } {                                  }
pbAsm::Code {}         {JSR    _rom_read_buttons } {                                  }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP} {Adjust the stack                  }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS       } {Grab the next top of stack        }
pbAsm::Code {}         {JMP     NEXT             }
# -----------------------------------------------------------------------------
# RANGE_SET    RANGE_SET( flag -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {RANGE_SET} RANGE_SET 0 CORE

pbAsm::Code {}         {JSR    _rom_set_range_short}
pbAsm::Code {}         {MOV.W  rTOS,rTOS           } {Push the button code address first}
pbAsm::Code {}         {BEQ    RGDONE              }
pbAsm::Code {}         {JSR    _rom_set_range_long }
pbAsm::Code {RGDONE}   {MOV.W  @rDSP+,rTOS         } {Grab the next top of stack        }
pbAsm::Code {}         {JMP     NEXT               }
# -----------------------------------------------------------------------------
pbAsm::Code {_rcx_init} {}
pbAsm::Code {}         {MOV.W  rTOS,@-rDSP             } {Save the TOS              }

pbAsm::Code {}         {MOV.W  #_rcx_dispatch_data,rTOS} {Get past doVAR            }
pbAsm::Code {}         {MOV.W  rTOS,@-rDSP             } {Save the RCX_DATA pointer }
pbAsm::Code {}         {MOV.W  #_rcx_firmware_data,rTOS} {Get past doVAR            }
pbAsm::Code {}         {JSR    _rom_init_timer         } {                          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP      } {Caller cleans up stack    }

pbAsm::Code {}         {MOV.W  #_rcx_handler_data,rTOS } {Get past doVAR            }
pbAsm::Code {}         {JSR    _rom_init_handlers      } {                          }

pbAsm::Code {}         {MOV.W  #_rcx_handler_data,rTOS } {Get past doVAR            }
pbAsm::Code {}         {JSR    _rom_init_program_data  } {                          }

pbAsm::Code {}         {MOV.W   #BRR_2400,r0           } {2400 baud, no RX interrupt}
pbAsm::Code {}         {MOV.W   #0,r1                  }
pbAsm::Code {}         {JSR     _initSerial            }

pbAsm::Code {}         {JSR     _rom_init_buttons      }
pbAsm::Code {}         {JSR     _servo_init            }
# pbAsm::Code {}         {JSR     _power_init            }

pbAsm::Code {}         {MOV.W  @rDSP+,rTOS             } {Grab the next top of stack}    
pbAsm::Code {}         {RTS                            }
# -----------------------------------------------------------------------------
# MOTOR_SET    MOTOR_SET ( power mode idx -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {MOTOR_SET} MOTOR_SET 0 CORE

pbAsm::Code {}         {OR.B   #0x20,rTOSh       } {Set up the motor index          }
pbAsm::Code {}         {JSR    _rom_control_motor} {                                }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP} {Caller cleans up stack          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP} {Caller cleans up stack          }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS       } {Grab the next top of stack      }
pbAsm::Code {}         {JMP     NEXT             }
# -----------------------------------------------------------------------------
pbAsm::Variable {RCX_POWER} RCX_POWER 0 CORE
# -----------------------------------------------------------------------------
# POWER_GET    POWER_GET ( addr-a code -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {POWER_GET} POWER_GET 0 CORE

pbAsm::Code {}         {JSR    _rom_get_on_off_key_state} {                          }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP       } {Adjust the stack          }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS              } {Grab the next top of stack}
pbAsm::Code {}         {JMP     NEXT                    }
# # -----------------------------------------------------------------------------
# # IRQ1 Wedge is the interrupt service routine for the On/Off switch
# # -----------------------------------------------------------------------------
# pbAsm::Code {IRQ1wedge} {MOV.W  #_rom_IRQ1_handler,r6} {Grab the original IRQ1 vector           }
# pbAsm::Code {}          {JSR    @r6               } {And call original IRQ1 routine to finish up}
# 
# pbAsm::Code {}          {MOV.W  #_entry,r6        } {Do a cold start                           }
# pbAsm::Code {}          {JSR    @r6               } {                                          }
# 
# pbAsm::Code {}          {RTS                      } {                                          }
# # -----------------------------------------------------------------------------
# # This uses the exact same dispatch code as the RCX has in the ROM...it
# # assumes that the handler saves all of the registers it uses, but comes
# # back to the caller via an RTS. The ROM routine we vectored through does
# # the RTE for us!!!
# #
# # Knowing this, we can just load R6 (because that's the one the dispatch
# # routine saved) and JSR into the old vector...
# # -----------------------------------------------------------------------------
# pbAsm::Code {_power_init} {}
# 
# pbAsm::Code {}            {MOV.W  #IRQ1wedge,rA   } {Now set our routine to run first         }
# pbAsm::Code {}            {MOV.W  rA,@_irq1_vector} {                                         }
# pbAsm::Code {}            {                       }
# pbAsm::Code {}            {BSET   #0x01,@H8_IER:8 } {IRQ1 Enable                              }
# 
# pbAsm::Code {}            {RTS                    }
# -----------------------------------------------------------------------------
# POWER_OFF    POWER_OFF ( -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {POWER_OFF} POWER_OFF 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,@-rDSP            } {                                      }
                                                      
pbAsm::Code {}         {MOV.W  #0xFF7E,rA             } { Save stack pointer in ON-CHIP memory!}
pbAsm::Code {}         {MOV.W  rDSP,@rA               } {                                      }
pbAsm::Code {}         {MOV.W  #0xFF7C,rDSP           } { Point the stack into ON_CHIP memory  }

pbAsm::Code {}         {BCLR   #2,@H8_TIER:8          } {Disallow OCRB interrupts              }
pbAsm::Code {}         {BCLR   #2,@H8_TCSR:8          } {Clear pending OCRB interrupts         }
                                                                                               
pbAsm::Code {}         {MOV.W  #_rcx_handler_data,rTOS} {Get past doVAR                        }
pbAsm::Code {}         {JSR    _rom_shutdown_handlers } {                                      }
pbAsm::Code {}         {JSR    _rom_shutdown_timer    }                                        
pbAsm::Code {}         {JSR    _rom_power_off         } {                                      }
                                                                                               
pbAsm::Code {}         {JSR    _rcx_init              } {                                      }
                                                                                               
pbAsm::Code {}         {MOV.W  #0xFF7E,rA             } {                                      }
pbAsm::Code {}         {MOV.W  @rA,rDSP               } { Restore the stack pointer            }
pbAsm::Code {}         {                              } {                                      }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS            } {                                      }
pbAsm::Code {}         {JMP     NEXT                  }
# -----------------------------------------------------------------------------
#      byte type        (sp+0)
#      byte mode        (sp+1)
#      word raw         (sp+2)
#      word value       (sp+4)
#      byte boolean     (sp+6)
# -----------------------------------------------------------------------------
pbAsm::Cell {SENSOR_0}   {0x0000,0x0000,0x0000,0x0000}
pbAsm::Cell {SENSOR_1}   {0x0000,0x0000,0x0000,0x0000}
pbAsm::Cell {SENSOR_2}   {0x0000,0x0000,0x0000,0x0000}

pbAsm::Cell {SENSOR_IDX} {SENSOR_0,SENSOR_1,SENSOR_2 }
# -----------------------------------------------------------------------------
# SENSOR_TYPE ( type idx -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {SENSOR_TYPE} SENSOR_TYPE 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA              } {Set up pointer to sensor data}
pbAsm::Code {}         {ADD.W  rTOS,rA              }
pbAsm::Code {}         {MOV.W  @(SENSOR_IDX,rA),rA  }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS          } {Grab the type code           }
pbAsm::Code {}         {MOV.B  rTOSl,@rA            } {Save the type code           }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS          } {Grab a new top of stack item }
pbAsm::Code {}         {JMP     NEXT                }
# -----------------------------------------------------------------------------
# SENSOR_MODE ( mode idx -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {SENSOR_MODE} SENSOR_MODE 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA              } {Set up pointer to sensor data  }
pbAsm::Code {}         {ADD.W  rTOS,rA              }
pbAsm::Code {}         {MOV.W  @(SENSOR_IDX,rA),rA  }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS          } {Grab the mode code             }
pbAsm::Code {}         {MOV.B  rTOSl,@(1,rA)        } {Save the mode code             }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS          } {Grab a new top of stack item   }
pbAsm::Code {}         {JMP     NEXT                }
# -----------------------------------------------------------------------------
# SENSOR_CLEAR ( idx -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {SENSOR_CLEAR} SENSOR_CLEAR 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA              } {Set up pointer to sensor data}
pbAsm::Code {}         {ADD.W  rTOS,rA              }
pbAsm::Code {}         {MOV.W  @(SENSOR_IDX,rA),rTOS}
pbAsm::Code {}         {MOV.W  #0x0000,rA           } {Get set to clear the data    }
pbAsm::Code {}         {MOV.W  rA,@(2,rTOS)         } {Clear the raw word           }
pbAsm::Code {}         {MOV.W  rA,@(4,rTOS)         } {Clear the value word         }
pbAsm::Code {}         {MOV.B  rAl,@(6,rTOS)        } {Clear the boolean byte       }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS          } {Grab a new top of stack item }
pbAsm::Code {}         {JMP     NEXT                }
# -----------------------------------------------------------------------------
# SENSOR_RAW ( idx -- value )
# -----------------------------------------------------------------------------
pbAsm::Primary {SENSOR_RAW} SENSOR_RAW 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA              } {Set up pointer to sensor data }
pbAsm::Code {}         {ADD.W  rTOS,rA              }
pbAsm::Code {}         {MOV.W  @(SENSOR_IDX,rA),rA  }
pbAsm::Code {}         {MOV.W  @(2,rA),rTOS         } {Get the raw word              }
pbAsm::Code {}         {JMP     NEXT                }
# -----------------------------------------------------------------------------
# SENSOR_VALUE ( idx -- value )
# -----------------------------------------------------------------------------
pbAsm::Primary {SENSOR_VALUE} SENSOR_VALUE 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA              } {Set up pointer to sensor data }
pbAsm::Code {}         {ADD.W  rTOS,rA              }
pbAsm::Code {}         {MOV.W  @(SENSOR_IDX,rA),rA  }
pbAsm::Code {}         {MOV.W  @(4,rA),rTOS         } {Get the value word            }
pbAsm::Code {}         {JMP     NEXT                }
# -----------------------------------------------------------------------------
# SENSOR_BOOL ( idx -- value )
# -----------------------------------------------------------------------------
pbAsm::Primary {SENSOR_BOOL} SENSOR_BOOL 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA              } {Set up pointer to sensor data }
pbAsm::Code {}         {ADD.W  rTOS,rA              }
pbAsm::Code {}         {MOV.W  @(SENSOR_IDX,rA),rA  }
pbAsm::Code {}         {MOV.B  @(6,rA),rTOSl        } {Get the boolean byte          }
pbAsm::Code {}         {SUB.B  rTOSh,rTOSh          } {Clear the high byte           }
pbAsm::Code {}         {JMP     NEXT                }
# -----------------------------------------------------------------------------
# SENSOR_READ ( idx -- code )
# -----------------------------------------------------------------------------
pbAsm::Primary {SENSOR_READ} SENSOR_READ 0 CORE

pbAsm::Code {}         {MOV.W  rTOS,rA                } {Set up pointer to sensor data     }
pbAsm::Code {}         {ADD.W  rTOS,rA                }
pbAsm::Code {}         {MOV.W  @(SENSOR_IDX,rA),rA    } {Point at the sensor data          }
pbAsm::Code {}         {MOV.W  rA,@-rDSP              } {Push the sensor data address first}
pbAsm::Code {}         {OR.B   #0x10,rTOSh            } {Set up the sensor index           }
pbAsm::Code {}         {MOV.W  rTOS,@-rDSP            } {Save a copy of the sensor index   }
                                                 
pbAsm::Code {}         {MOV.B  @rA,rBl                } { Grab the type code               }
pbAsm::Code {}         {CMP.B  #0x03,rBl              } { Is it a light sensor?            }
pbAsm::Code {}         {BEQ    SRACTV                 }
pbAsm::Code {}         {CMP.B  #0x04,rBl              } { Is it a rotation sensor?         }
pbAsm::Code {}         {BEQ    SRACTV                 }
pbAsm::Code {SRPASV}   {JSR    _rom_set_sensor_passive} {                                  }
pbAsm::Code {}         {BRA    SRREAD}
pbAsm::Code {SRACTV}   {JSR    _rom_set_sensor_active } {                                  }

pbAsm::Code {SRREAD}   {MOV.W  @rDSP+,rTOS            } {Get the sensor index back         }
pbAsm::Code {}         {JSR    _rom_read_sensor       }
pbAsm::Code {}         {ADDS.W #BytesPerCELL,rDSP     } {Caller cleans up stack            }
pbAsm::Code {}         {SUB.B  rTOSh,rTOSh            } {Clear out the high byte           }
pbAsm::Code {}         {JMP     NEXT                  }
# -----------------------------------------------------------------------------
# TIMER_SET ( value idx -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {TIMER_SET} TIMER_SET 0 CORE

pbAsm::Code {}         {MOV.W  #_rcx_TIMER_data,rA} {Point at the timer array       }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS        } {Grab the value                 }
pbAsm::Code {}         {MOV.W  rTOS,@rA           } {Now save the value             }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS        } {Grab a new top of stack value  }
pbAsm::Code {}         {JMP     NEXT              }
# -----------------------------------------------------------------------------
# TIMER_GET ( idx -- value )
# -----------------------------------------------------------------------------
pbAsm::Primary {TIMER_GET} TIMER_GET 0 CORE

pbAsm::Code {}         {MOV.W  #_rcx_TIMER_data,rA} {Point at the timer array       }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {MOV.W  @rA,rTOS           } {Now grab the value             }
pbAsm::Code {}         {JMP     NEXT              }
# -----------------------------------------------------------------------------
# timer_SET ( value idx -- )
# -----------------------------------------------------------------------------
pbAsm::Primary {timer_SET} timer_SET 0 CORE

pbAsm::Code {}         {MOV.W  #_rcx_timer_data,rA} {Point at the timer array       }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS        } {Grab the value                 }
pbAsm::Code {}         {MOV.W  rTOS,@rA           } {Now save the value             }
pbAsm::Code {}         {MOV.W  @rDSP+,rTOS        } {Grab a new top of stack value  }
pbAsm::Code {}         {JMP     NEXT              }
# -----------------------------------------------------------------------------
# timer_GET ( idx -- value )
# -----------------------------------------------------------------------------
pbAsm::Primary {timer_GET} timer_GET 0 CORE

pbAsm::Code {}         {MOV.W  #_rcx_timer_data,rA} {Point at the timer array       }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {ADD.W  rTOS,rA            } {Point to the right offset      }
pbAsm::Code {}         {MOV.W  @rA,rTOS           } {Now grab the value             }
pbAsm::Code {}         {JMP     NEXT              }
# -----------------------------------------------------------------------------

