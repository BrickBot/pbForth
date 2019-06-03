;------------------------------------------------------------------------------
; serial/serial-busy.asm - tx busy check routine for the RCX serial port
;
; Revision History
;
; R. Hempel 00-03-25 - Original for rcxdev
;------------------------------------------------------------------------------

.include "h8defs.inc"

.section serdata

.global _fTXBusy
_fTXBusy:     .word 0x0000

;------------------------------------------------------------------------------
; WORD _isSendBusy( void )

.text

.global _isSendBusy
_isSendBusy:
    MOV.W @_fTXBusy,r0
    RTS

;------------------------------------------------------------------------------
