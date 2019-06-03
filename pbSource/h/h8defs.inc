;------------------------------------------------------------------------------
; h/h8defs.inc - assembler include file for H8/300 registers and bits
;
; Revision History
;
; R. Hempel 00-03-25 - Original for rcxdev
;------------------------------------------------------------------------------
;.equ H8_SMR,  0xFFD8  ; Serial Mode Register

.equ SMR_CA,   0x80   ; Async/Clocked       - defaults to async
.equ SMR_CHR,  0x40   ; 8/7 Bits/Chr        - defaults to 8
.equ SMR_PE,   0x20   ; Parity Enable       - defaults to no parity
.equ SMR_OE,   0x10   ; Odd/Even Parity     - defaults to even
.equ SMR_STOP, 0x08   ; 1/2 Stop Bits       - defaults to 1 stop bit
.equ SMR_MP,   0x04   ; Multiprocessor Mode - defaults to disabled
.equ SMR_CKS1, 0x02   ; Clock select        - defaults to direct
.equ SMR_CKS0, 0x01   ; 
;----------------------------------------------------------------------------
;.equ H8_SCR,  0xFFDA  ; Serial Control Register

.equ SCR_TIE,  0x80   ; TDR Empty interrupt enable      - defaults to disabled  
.equ SCR_TIE_BIT, 7
.equ SCR_RIE,  0x40   ; RDRF and ERI interrupt enable   - defaults to disabled  
.equ SCR_RIE_BIT, 6
.equ SCR_TE,   0x20   ; Transmitter enable              - defaults to disabled  
.equ SCR_TE_BIT,  5
.equ SCR_RE,   0x10   ; Receiver enable                 - defaults to disabled  
.equ SCR_RE_BIT,  4
.equ SCR_MPIE, 0x08   ; Multiprocessor interrupt enable - defaults to disabled  
.equ SCR_TEIE, 0x04   ; TSR Empty interrupt enable      - defaults to disabled  
.equ SCR_TEIE_BIT,2
.equ SCR_CKE1, 0x02   ; Internal/External clock select  - defaults to internal
.equ SCR_CKE0, 0x01   ; SCK output enable               - defaults to disabled
;----------------------------------------------------------------------------
;.equ H8_SSR,  0xFFDC  ; Serial Status Register

.equ SSR_TDRE, 0x80   ; Transmit Data Register Empty
.equ SSR_TDRE_BIT,7 
.equ SSR_RDRF, 0x40   ; Receive Data Register Full
.equ SSR_RDRF_BIT,6 
.equ SSR_ORER, 0x20   ; Overrun Error
.equ SSR_ORER_BIT,5 
.equ SSR_FER,  0x10   ; Framing Error 
.equ SSR_FER_BIT, 4 
.equ SSR_PER,  0x08   ; Parity Error  
.equ SSR_PER_BIT, 3 
.equ SSR_TEND, 0x04   ; Transmit End
.equ SSR_TEND_BIT,2 
.equ SSR_MPB,  0x02   ; Multiprocessor Bit
.equ SSR_MPBT, 0x01   ; Multiprocessor Bit Transfer
;----------------------------------------------------------------------------
;.equ H8_BRR,  0xFFD9  ; Bit Rate Register

.equ BRR_2400,  0xCF
.equ BRR_4800,  0x67
.equ BRR_9600,  0x33
.equ BRR_19200, 0x19
.equ BRR_38400, 0x0C
;----------------------------------------------------------------------------
;.equ H8_SCTR, 0xFFC3  ; Serial/Timer Control Register
;----------------------------------------------------------------------------
;.equ H8_TCR0,   0xFFC8  ; TMR0 Control Register
;.equ H8_TCR1,   0xFFD0  ; TMR1 Control Register

.equ TCR_CMIEB, 0x80  ; 
.equ TCR_CMIEA, 0x40  ; 
.equ TCR_OVIE,  0x20  ; 
.equ TCR_CCLR1, 0x10  ; 
.equ TCR_CCLR0, 0x08  ; 
.equ TCR_CKS2,  0x04  ; 
.equ TCR_CKS2,  0x02  ; 
.equ TCR_CKS2,  0x01  ; 
;----------------------------------------------------------------------------
;.equ H8_TCSR0,  0xFFC9  ; TMR0 Status Register
;.equ H8_TCSR1,  0xFFD1  ; TMR1 Status Register

.equ TCSR_CMFB, 0x80  ; 
.equ TCSR_CMFA, 0x40  ; 
.equ TCSR_OVF,  0x20  ; 

.equ TCSR_OS3,  0x08  ; 
.equ TCSR_OS2,  0x04  ; 
.equ TCSR_OS2,  0x02  ; 
.equ TCSR_OS2,  0x01  ; 
;----------------------------------------------------------------------------
;.equ H8_TCORA0, 0xFFCA  ; TMR0 Counter Register A
;.equ H8_TCORA1, 0xFFD2  ; TMR1 Counter Register A

;.equ H8_TCORB0, 0xFFCB  ; TMR0 Counter Register B
;.equ H8_TCORB1, 0xFFD3  ; TMR1 Counter Register B

;.equ H8_TCNT0,  0xFFCC  ; TMR0 Count Register
;.equ H8_TCNT1,  0xFFD4  ; TMR1 Count Register
;----------------------------------------------------------------------------
