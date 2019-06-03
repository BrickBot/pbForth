;------------------------------------------------------------------------------
; serial/serial-put.asm - interrupt service routines for the RCX serial port
;
; Revision History
;
; R. Hempel 00-03-25 - Original for rcxdev
;------------------------------------------------------------------------------

.include "h8defs.inc"

;------------------------------------------------------------------------------
; void _putChar( BYTE Char )
;
; Waits until TDRE is set before sending the character to the serial port.
; The routine returns when TEND is set, which means the transmission is
; complete.

.text

.global _putChar
_putChar:

putCharSpin1:
    BTST  #SSR_TDRE_BIT,@H8_SSR:8 ; Check to see if it's ready yet
    BEQ   putCharSpin1            ; Spin while not OK

    BCLR  #SCR_RE_BIT,@H8_SCR:8   ; Disable receiver

    MOV.B r0l,@H8_TDR:8           ; Put char in transmitter
    BCLR  #SSR_TDRE_BIT,@H8_SSR:8 ; Clear the TDRE flag

putCharSpin2:
    BTST  #SSR_TEND_BIT,@H8_SSR:8 ; Check to see if it's done yet
    BEQ   putCharSpin2            ; Spin while not OK

    BSET  #SCR_RE_BIT,@H8_SCR:8   ; Enable receiver
    RTS

;------------------------------------------------------------------------------
; void _putBuf( WORD nChars, BYTE *pChar )

.text

.global _putBuf
_putBuf:
    MOV.W #0x0000,r2              ; Check for 0 characters to send
    CMP.W r2,r0
    BEQ   putBufExit

    BCLR  #SCR_RE_BIT,@H8_SCR:8   ; Disable receiver
    ADD.W r1,r0                   ; Set up pointer to end of string

putBufLoop:
    CMP.W r1,r0                   ; Check if any more characters to send
    BEQ   putBufDone
 
putBufSpin1:
    BTST  #SSR_TDRE_BIT,@H8_SSR:8 ; Check to see if it's OK to send
    BEQ   putBufSpin1             ; Spin while not OK

    MOV.B @r1+,r2l                ; Grab the next character to send
    MOV.B r2l,@H8_TDR:8           ; Put char in transmitter

    BCLR  #SSR_TDRE_BIT,@H8_SSR:8 ; Clear the TDRE flag
    BRA   putBufLoop              ; And go send the next byte!

putBufDone:
putBufSpin2:
    BTST  #SSR_TEND_BIT,@H8_SSR:8 ; Check to see if it's done yet
    BEQ   putBufSpin2             ; Spin while not OK

    BSET  #SCR_RE_BIT,@H8_SCR:8   ; Enable receiver

putBufExit:
    RTS

;------------------------------------------------------------------------------
