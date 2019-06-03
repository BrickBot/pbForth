;------------------------------------------------------------------------------
; startup/startup.asm/ - startup code for the RCX
;
; Revision History
;
; R. Hempel 00-03-25 - Original for rcxdev
;------------------------------------------------------------------------------

.include "h8defs.inc"

;------------------------------------------------------------------------------

.text

.global _start
_start:
    MOV.W   #0xFE7E,r7      ;top of memory at memtop
    JMP     _entry

.global RCXLockString
RCXLockString:
.ascii "Do you byte, when I knock?"

.balign 2

;------------------------------------------------------------------------------
