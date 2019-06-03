;------------------------------------------------------------------------------
; Revision History
;
; R. Hempel 00-03-25 - Original for MAF

.include "h8defs.inc"

.text

.global _entry
_entry:

JMP RCXgetCharTest        ; Jump to whatever routine you need

RCXgetBufTest:
    MOV   #BRR_2400,r0      ; 2400 baud, no RX interrupt
    MOV   #1,r1
    JSR   _initSerial
    BSET  #SCR_RIE_BIT,@H8_SCR:8  ; Enable RDRF and ERI Interrupt
RCXgetBufTestLoop:
    JSR   _getBuf
    MOV.W #0xFFFF,r1
    CMP.W r1,r0
    BEQ   RCXgetBufTestLoop
    JSR   _putChar
    BRA   RCXgetBufTestLoop

RCXgetCharTest:
    MOV   #BRR_2400,r0      ; 2400 baud, no RX interrupt
    MOV   #0,r1
    JSR   _initSerial
RCXgetCharTestLoop:
    JSR   _getChar
    MOV.W #0xFFFF,r1
    CMP.W r1,r0
    BEQ   RCXgetCharTestLoop
    JSR   _putChar
    BRA   RCXgetCharTestLoop

RCXsendBufTest:
    MOV   #BRR_2400,r0      ; 2400 baud, no RX interrupt
    MOV   #0,r1
    JSR   _initSerial
    MOV.W #RCXLockString,r1 ; Start of string pointer
    MOV.W #26,r0         ; Length of string
    JSR   _sendBuf
RCXsendBufTestSpin:
    MOV.W @_fTXBusy,r1
    BNE   RCXsendBufTestSpin
    BRA   RCXsendBufTest

RCXputCharTest:
    MOV   #BRR_2400,r0      ; 2400 baud, no RX interrupt
    MOV   #0,r1
    JSR   _initSerial
    MOV.W #0x3730,r0       ; Loop parameters
RCXputCharTestLoop:
    MOV.W r0,@-r7       ; Save looop parms
    JSR   _putChar
    MOV.W @r7+,r0        ; Restore looop parms
    ADD.B #0x01,r0l
    CMP.B r0l,r0h
    BHI   RCXputCharTestLoop   
    BRA   RCXputCharTest

RCXputBufTest:
    MOV   #BRR_2400,r0      ; 2400 baud, no RX interrupt
    MOV   #0,r1
    JSR   _initSerial
    MOV.W #RCXLockString,r1 ; Start of string pointer
    MOV.W #26,r0         ; Length of string
    JSR   _putBuf
    BRA   RCXputBufTest

