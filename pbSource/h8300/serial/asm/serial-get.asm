;------------------------------------------------------------------------------
; serial/serial-get.asm - interrupt service routines for the RCX serial port
;
; Revision History
;
; R. Hempel 2002-05-10 - Fix bug in receive logic. RDRF was never being set
;                         after a character is received with errors
; R. Hempel 2001-03-25 - Original for rcxdev
;------------------------------------------------------------------------------

.include "h8defs.inc"

;------------------------------------------------------------------------------

.text

;------------------------------------------------------------------------------
; WORD _getChar( void )

.global _getChar
_getChar:
    MOV.W #0xFFFF,r0                       ; Preload false result

    MOV.B @H8_SSR:8,r1l                    ; Check to see if there's a char
    MOV.B r1l,r1h
    AND.B #(SSR_RDRF|SSR_ORER|SSR_FER|SSR_PER),r1h
    BEQ   getCharExit

    AND.B #(SSR_ORER|SSR_FER|SSR_PER),r1h  ; Check the status bits
    BNE   getCharError

    MOV.B #0x00,r0h
    MOV.B @H8_RDR:8,r0l                    ; Grab the actual data

getCharError:
    AND.B #~(SSR_RDRF|SSR_ORER|SSR_FER|SSR_PER),r1l ; Clear the error bits
    MOV.B r1l,@H8_SSR:8

getCharExit:
    RTS

;------------------------------------------------------------------------------
; WORD _checkChar( void )

.global _checkChar
_checkChar:
    SUB.W r0,r0                   ; Preload false result
    
    MOV.B @H8_SSR:8,r1l           ; Check to see if there's a char
    AND.B #(SSR_RDRF|SSR_ORER|SSR_FER|SSR_PER),r1l
    BEQ   checkCharExit

    SUBS.W #1,r0                  ; Load true result

checkCharExit:
    RTS

;------------------------------------------------------------------------------
