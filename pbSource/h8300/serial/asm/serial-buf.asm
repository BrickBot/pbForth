;------------------------------------------------------------------------------
; serial/serial-buf.asm - interrupt service routines for the RCX serial port
;
; Revision History
;
; R. Hempel 00-03-25 - Original for rcxdev
;------------------------------------------------------------------------------

.include "h8defs.inc"

;------------------------------------------------------------------------------

.section serdata

_pTXNext:     .word 0x0000
_pTXLast:     .word 0x0000

;------------------------------------------------------------------------------
; void _sendBuf( WORD nChars, BYTE *pChar )

.text

.global _sendBuf
_sendBuf:
    MOV.W #0x0000,r2              ; Check for 0 characters to send
    CMP.W r2,r0
    BEQ   sendBufExit

    SUBS.W #1,r2                  ; Indicate that TX is busy
    MOV.W  r2,@_fTXBusy
    
    MOV.W #_handleTDRE,r2         ; Set up the TDRE interrupt vector
    MOV.W r2,@_txi_vector
    MOV.W #_handleTEIE,r2         ; Set up the TEI  interrupt vector
    MOV.W r2,@_tei_vector

    BCLR  #SCR_RE_BIT,@H8_SCR:8   ; Disable receiver

    ADD.W r1,r0                   ; Set up pointer to end of string
    MOV.W r0,@_pTXLast

sendBufSpin1:
    BTST  #SSR_TDRE_BIT,@H8_SSR:8 ; Check to see if it's OK to send
    BEQ   sendBufSpin1            ; Spin while not OK

    MOV.B @r1+,r2l                ; Grab the next character to send
    MOV.W r1,@_pTXNext
    MOV.B r2l,@H8_TDR:8           ; Put char in transmitter

    BCLR  #SSR_TDRE_BIT,@H8_SSR:8 ; Clear the TDRE flag
    BSET #SCR_TIE_BIT,@H8_SCR:8   ; Enable TDR Empty Interrupt

sendBufDone:
sendBufExit:
    RTS
  
;------------------------------------------------------------------------------
; The interrupt handlers on the RCX are redirected throught RAM vectors.
; A common interrupt handler stacks all of the registers then calls the
; routine in the RAM vector as if it was a subroutine. This is neat because
; we can write our interrupt handlers like normal functions that take
; no parameters, and we don't have to worry about saving the registers!
;
;------------------------------------------------------------------------------
; void _handleTDRE( void ) - Handles empty transmit holding register

.text

.global _handleTDRE
_handleTDRE:
    MOV.W @_pTXNext,r0
    MOV.W @_pTXLast,r1
    CMP.W r0,r1                   ; Check if any more characters to send
    BNE   handleTDRENext
 
    BCLR #SCR_TIE_BIT,@H8_SCR:8   ; Disable TDR Empty Interrupt
    BSET #SCR_TEIE_BIT,@H8_SCR:8  ; Enable TSR Empty Interrupt
    
    BRA  handleTDREDone           ; And we're done!

handleTDRENext:
    MOV.B @r0+,r1l                ; Grab the next character to send
    MOV.W r0,@_pTXNext
    MOV.B r1l,@H8_TDR:8           ; Put character in transmitter

    BCLR  #SSR_TDRE_BIT,@H8_SSR:8 ; Clear the TDRE flag
    
handleTDREDone:
    RTS                           ; Return through the vector
   
;------------------------------------------------------------------------------
; void _handleTEIE( void ) - Handles empty transmit shift register

.text

.global _handleTEIE
_handleTEIE:
    BCLR  #SCR_TEIE_BIT,@H8_SCR:8 ; Disable TSR Empty Interrupt

    MOV.W #0x0000,r0              ; Indicate that TX is no longer busy
    MOV.W r0,@_fTXBusy

handleTEIEDone:
    BSET  #SCR_RE_BIT,@H8_SCR:8   ; Enable receiver
    RTS                           ; Return through the vector

;------------------------------------------------------------------------------

.section serdata

.global _pRXHead
_pRXHead:      .word 0x0000
.global _pRXTail
_pRXTail:      .word 0x0000

;------------------------------------------------------------------------------
; void _handleRDRF( void ) - Handles full receive shift register

.text

.global _handleRDRF
_handleRDRF:
    MOV.B  @H8_SSR:8,r0h          ; Grab and mask the error status bits
    AND.B  #(SSR_ORER|SSR_FER|SSR_PER),r0h
    BNE    handleRDRFExit         ; If any are set, just quit right now

    MOV.B  @H8_RDR:8,r0h          ; Grab the actual data

    MOV.W  @_pRXHead,r1           ; Find the head pointer
    MOV.B  r0h,@r1                ; Store the received data
    ADDS.W #1,r1

handleRDRFHeadWrap:
    MOV.W  #_RXBufEnd,r3          ; Buffer end value for comparison
    CMP.W r1,r3                   ; Are we at the end of the buffer?
    BHI   handleRDRFSaveHead      ; If not, check for collision with tail
    MOV.W #_RXBufStart,r1         ; Reset to beginning of buffer

handleRDRFSaveHead:
    MOV.W r1,@_pRXHead          ; Save the new head pointer

    MOV.W @_pRXTail,r2          ; Find the tail pointer
    CMP   r2,r1                   ; Check if we've overflowed
    BNE   handleRDRFExit          ; If not, we're done
    ADDS.W #1,r2                  ; Increment the tail pointer

handleRDRFTailWrap:
    CMP.W r2,r3                   ; Are we at the end of the buffer?
    BHI   handleRDRFSaveTail      ; If not, we're done
    MOV.W #_RXBufStart,r2         ; Reset to beginning of buffer

handleRDRFSaveTail:
    MOV.W r2,@_pRXTail          ; Save the new tail pointer
 
handleRDRFExit:
    MOV.B  @H8_SSR:8,r0h          ; Grab and mask the error status bits
    AND.B #~(SSR_RDRF|SSR_ORER|SSR_FER|SSR_PER),r0l
    MOV.B r0l,@H8_SSR:8

    RTS

;------------------------------------------------------------------------------
; void _handleERI( void ) - Handles error in reciever shift register

.text

.global _handleERI
_handleERI:

    BRA   handleRDRFExit

;------------------------------------------------------------------------------
; WORD _getBuf( void ) - Receives character, 0xFFFF indicates no char

.text

.global _getBuf
_getBuf:
    MOV.W #0xFFFF,r0              ; Preload false result

    MOV.W @_pRXHead,r1            ; Get head pointer
    MOV.W @_pRXTail,r2            ; Get tail pointer
    CMP.W r1,r2
    BEQ   getBufExit              ; If they're equal, it's empty

    MOV.B #0x00,r0h
    MOV.B @r1+,r0l                ; Get the next byte

getBufTailWrap:
    MOV.W #_RXBufEnd,r3           ; Buffer end value for comparison
    CMP.W r2,r3                   ; Are we at the end of the buffer?
    BHI   getBufSaveTail          ; If not, we're done
    MOV.W #_RXBufStart,r2         ; Reset to beginning of buffer
 
getBufSaveTail:
    MOV.W r2,@_pRXTail             ; Save the new tail pointer

getBufExit:
    RTS
    
;------------------------------------------------------------------------------
