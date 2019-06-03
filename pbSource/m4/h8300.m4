changecom(`;')

;------------------------------------------------------------------------------
; Revision History
;
; R. Hempel 01-03-25 - Original for rcxdev
;------------------------------------------------------------------------------
;
; The H8/300 Forth machine register usage has to be closely intertwined with
; the RCX. The following facts from Kekoa Proudfoot's page make things a little
; clearer.
;
; 1. The RCX (and the H8/300) use r7 as the stack pointer - so will we
; 2. The RCX clobbers r6 as the first parameter passed and the return value.
;    We will use it as the top of stack item, saving it when necessary.
; 3. The RCX clobbers r3-6 when processing math functions. We'll save them
;    if we ever call these routines. Registers r3-5 are otherwise preserved.
; 4. Other parameters are passed on the stack
;    
; So we can summarize the H8/300 Register usage as:
;
; R7: Data stack pointer
; R6: Top of data stack item - RCX first parameter
; R5: Forth virtual machine return stack pointer
; R4: Forth virtual machine instruction pointer
; R3: Forth virtual machine word pointer
; R2: Available as rC
; R1: Available as rB
; R0: Available as rA
;
;------------------------------------------------------------------------------
; m4 macros for register names
;
; rDSP,  r7
; rTOS,  r6
; rRSP,  r5 
; rFIP,  r4
; rFWP,  r3
;------------------------------------------------------------------------------

define( `rDSP',`r7' )

define( `rRCX',`r6' )

define( `rTOS',`r6' )
define( `rTOSl',`r6l' )
define( `rTOSh',`r6h' )

define( `rRSP',`r5' )
define( `rFIP',`r4' )
define( `rFWP',`r3' )

define( `rC',`r2' )
define( `rCl',`r2l' )
define( `rCh',`r2h' )

define( `rB',`r1' )
define( `rBl',`r1l' )
define( `rBh',`r1h' )

define( `rA',`r0' )
define( `rAl',`r0l' )
define( `rAh',`r0h' )

define( `IMM',`1' )
define( `COMP',`2' )

define( `BytesPerCELL',`2' )
define( `BytesPerCHAR',`1' )
define( `BitsPerCELL',`16' )
define( `HighBit', `32768' )

define( `CORE0',`0' )
define( `ENV0', `0' )

;------------------------------------------------------------------------------