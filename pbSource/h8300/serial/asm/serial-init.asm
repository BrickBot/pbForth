;------------------------------------------------------------------------------
; serial/serial-init.asm - initialization for the RCX serial port
;
; Revision History
;
; R. Hempel 2002-03-26 - ISerial port set for odd parity in _initSerial
; R. Hempel 2001-09-25 - Initialize RX buffer pointers in _initSerial
; R. Hempel 2001-03-25 - Original for rcxdev
;------------------------------------------------------------------------------

.include "h8defs.inc"

;------------------------------------------------------------------------------
; void _initSerial( WORD Baud, WORD fRXInterrupt )

.text

.global _initSerial
_initSerial:
    MOV.B #0x00,r2l          ; Disable everything on the serial interface
    MOV.B r2l,@H8_SCR:8

    ; The IR carrier must be set up to give a frequency 38.5 Khz
    ; From Kekoa's internals document:
    ;
    ; timer 1: 16 Mhz div 8, toggle every 26 cycles or 13 us, yields 38.5kHz
   
    MOV.B #0x09,r2l          ; compare-match A clear, div 2,8
    MOV.B r2l,@H8_TCR1:8
    MOV.B #0x13,r2l          ; toggle on compare-match A
    MOV.B r2l,@H8_TCSR1:8
    MOV.B #0x1A,r2l          ; 26 cycle count
    MOV.B r2l,@H8_TCORA1:8

    ; Now we need to set up the serial port for the correct mode and baud rate.
    ; From the H8/300 reference manual:
    ;
    ; Baud =Fosc/[64*2^(2n)*(BRR+1) where n is 0,1,2,3 for SMR clock source
    ;
    ;  2400 Baud = 207 = 0xCF
    ;  4800 Baud = 103 = 0x67
    ;  9600 Baud =  51 = 0x33
    ; 19200 Baud =  25 = 0x19
    ; 38400 Baud =  12 = 0x0C
        
    MOV.B #0x30,r2l       ; SMR set up for 8 bits, odd parity, 1 stop bit
    MOV.B r2l,@H8_SMR:8
    MOV.B r0l,@H8_BRR:8   ; BRR from the first parameter
    MOV.B #0x00,r2l       ; SSR clear all pending status
    MOV.B r2l,@H8_SSR:8

    BSET  #SCR_TE_BIT,@H8_SCR:8   ; Enable transmitter
    BSET  #SCR_RE_BIT,@H8_SCR:8   ; Enable receiver

    MOV.W  r1,r1             ; Is the fRXInterrupt flag set?
    BEQ   initEnd

    MOV.W #_RXBufStart,r2    ; Initialize the RX buffer pointers
    MOV.W r2,@_pRXHead
    MOV.W r2,@_pRXTail

    MOV.W #_handleRDRF,r2  ; Set up the RDRF interrupt vector
    MOV.W r2,@_rxi_vector
    MOV.W #_handleERI,r2   ; Set up the ER interrupt vector
    MOV.W r2,@_eri_vector

    MOV.W  #_RXBufStart,r2        ; Set up the head pointer
    MOV.W  r2,@_pRXHead
    MOV.W  r2,@_pRXTail

    BSET  #SCR_RIE_BIT,@H8_SCR:8  ; Enable RDRF and ERI Interrupt

initEnd:

;   set bit 0 of port 4 to output (fd83, ffb5 |= 1)
;   set bit 0 of port 4 to high for low power  (ffb7)

    BSET #0,@H8_P4DDR:8
    BSET #0,@H8_P4DR:8

;   set bit 7 of port 6 to output (fd85, ffb9)
;   set bit 7 of port 6 to high (ffbb)

    BSET #7,@H8_P6DDR:8
    BSET #7,@H8_P6DR:8

;   set bit 0 of port 5 to output (fd84, ffb8)
;   set bit 0 of port 5 to low (ffba)
;   set bit 1 of port 5 to output (fd84, ffb8)
;   set bit 1 of port 5 to low (ffba);

    BSET #0,@H8_P5DDR:8
    BCLR #0,@H8_P5DR:8
    BSET #1,@H8_P5DDR:8
    BCLR #1,@H8_P5DR:8

    RTS

;------------------------------------------------------------------------------
