/* ----------------------------------------------------------------------------
|  h8300_rcx.ld - GNU linker description file for the RCX          
|
|  Note that this file is based on the original linker script from the
|  legOS project, h8300.rcx (c) 1999 by Markus L. Noga <markus@noga.de> 
|
| I've taken the time to document some of the more esoteric aspects of
| the script...
|
| Information I have found useful in the preparation of this file includes:
|
| Kekoa Proudfoot's RCX Internals  - http://graphics.stanford.edu/~kekoa/rcx/
|
| Revision History
|
| R. Hempel 2002-05-17 - Data and return stacks set at 96 elements each
| R. Hempel 2002-04-20 - Added private ISR stacks
| R. Hempel 2001-03-25 - Revised for pbForth
| -------------------------------------------------------------------------- */

OUTPUT_FORMAT("coff-h8300")
OUTPUT_ARCH(h8300)

SEARCH_DIR ( ./debug/h8300/rcx/lib/ )

INPUT ( startup.a )
/* INPUT ( serial.a  )  */

/* INPUT ( pbforth.a  ) */

/* ----------------------------------------------------------------------------
| The entry point to the program. I always use _start, replace this with
| whatever you're using.
|
| Note that the RCX firmware expects the entry point of the firmware to
| be fixed at 0x8000 and that the string "Do you byte, when I knock?" is
| required to allow the new firmware to be unlocked!
| -------------------------------------------------------------------------- */

ENTRY("_start")

/* ----------------------------------------------------------------------------
|  The MEMORY command is used to tell the linker where it can put data from
|  the input objects it is linking.
|
|  For many types of projects, this is the last place the programmer has
|  any control of where things live in memory. It is probably the best place
|  to specify the location of registers and memory areas because it does
|  not require ANY changes to source code.
|
|  I tend to make link scripts like this for each device and hardware
|  revision within a project.
|
|  The RCX is pretty stable, so I don't expect this to ever change...
|
|  There are "holes" in the 32K RAM chip to allow for motor controllers
|  and other I/O devices and data.
| -------------------------------------------------------------------------- */

MEMORY {
  rom (R)  : o = 0x0000, l = 0x8000    /* on-chip masked ROM area            */
  ram0     : o = 0x8000, l = 0x6D00    /* pbForth firmware                   */
/*ram0b    : o = 0x8200, l = 0x6C00  *//* pbForth firmware                   */
  ram0a    : o = 0xEB00, l = 0x0250    /* pbForth stacks                     */
  ram0c    : o = 0xED50, l = 0x0100    /* pbForth scratch                    */
  rcxdata  : o = 0xEE5E, l = 0x00B0    /* RCX scratch                        */
  lcddata  : o = 0xEF30, l = 0x0020    /* LCD memory                         */
  motor    : o = 0xF000, l = 0x0010    /* motor port                         */
  romdata  : o = 0xFD80, l = 0x0040    /* port shadows, interrupt vectors    */
  ram3     : o = 0xFE00, l = 0x0100    /* on-chip RAM (sleep safe!!!)        */
  ports    : o = 0xFF00, l = 0x0100    /* on-chip IO ports                   */
}

/* ----------------------------------------------------------------------------
|  The SECTIONS command is used to tell the linker EXACTLY where and in
|  what order the input objects go into the output sections.
|
|  Once again, this is where you want to specify ROM entry points or the
|  exact address of an IO port. If you do it in the source code, you'll end
|  up having to do conditional compiles if your hardware changes. If you
|  do it here, in the linker script, you'll just need to specify a different
|  script for a new hardware revision.
|
|  The RCX is pretty stable, so I don't expect this to ever change...
| -------------------------------------------------------------------------  */

SECTIONS {

  /* --------------------------------------------------------------------------
  | RCX ROM entry points
  |
  | For all of the details on the internals, see Kekoa Proudfoot's commented
  | disassebly of the RCX ROM at <http://graphics.stanford.edu/~kekoa/rcx/>  */

  .rom : {
    _rom_reset                  = 0x03AE ;
    _rom_uint_mul               = 0x0130 ;
    _rom_uint_mod               = 0x014A ;
    _rom_int_div                = 0x0156 ;
    _rom_int_mod                = 0x0188 ;
    _rom_uint_div               = 0x01BE ;
    _rom_ulong_mul              = 0x01FE ;
    _rom_long_div               = 0x026E ;
    _rom_ulong_div              = 0x0306 ;
    _rom_init_mem               = 0x03CA ;
    _rom_copy_mem               = 0x042A ;
    _rom_clear_mem              = 0x0436 ;
    _rom_init_control_registers = 0x0442 ;
    _rom_dummy_handler          = 0x046A ;
    _rom_init_handlers          = 0x0688 ;
    _rom_shutdown_handlers      = 0x0D18 ;
    _rom_power_off              = 0x0D3C ;
    _rom_init_program_data      = 0x0D44 ;
    _rom_init_sensors           = 0x1498 ;
    _rom_read_sensor            = 0x14C0 ;
    _rom_set_sensor_active      = 0x1946 ;
    _rom_set_sensor_passive     = 0x19C4 ;
    _rom_shutdown_sensors       = 0x1A22 ;
    _rom_control_motor          = 0x1A4E ;
    _rom_init_buttons           = 0x1ABA ;
    _rom_set_lcd_segment        = 0x1B62 ;
    _rom_clear_lcd_segment      = 0x1E4A ;
    _rom_read_buttons           = 0x1FB6 ;
    _rom_set_lcd_number         = 0x1FF2 ;
    _rom_clear_display          = 0x27AC ;
    _rom_refresh_display        = 0x27C8 ;
    _rom_shutdown_buttons       = 0x27F4 ;
    _rom_IRQ1_handler           = 0x294A ;
    _rom_init_power             = 0x2964 ;
    _rom_play_system_sound      = 0x299A ;
    _rom_get_power_status       = 0x29F2 ;
    _rom_get_on_off_key_state   = 0x29F2 ;
    _rom_get_battery_voltage    = 0x29F2 ;
    _rom_shutdown_power         = 0x2A62 ;
    _rom_TEI_handler            = 0x2A84 ;
    _rom_TXI_handler            = 0x2A9C ;
    _rom_RXI_handler            = 0x2C10 ;
    _rom_ERI_handler            = 0x30A4 ;
    _rom_init_serial            = 0x30D0 ;
    _rom_set_range_long         = 0x3250 ;
    _rom_set_range_short        = 0x3266 ;
    _rom_play_tone              = 0x327C ;
    _rom_shutdown_serial        = 0x3636 ;
    _rom_OCIA_handler           = 0x36BA ;
    _rom_AD_handler             = 0x3B74 ;
    _rom_init_timer             = 0x3B9A ;
    _rom_get_sound_playing_flag = 0x3CCC ;
    _rom_shutdown_timer         = 0x3ED4 ;
  } > rom

  /* --------------------------------------------------------------------------
  |  Here's where the .text section, which is normally executable code, goes */

  serial : {
    debug/h8300/rcx/startup/obj/startup.o (.text)

    debug/h8300/serial/obj/serial-init.o (.text)
    debug/h8300//serial/obj/serial-put.o (.text)
    debug/h8300/serial/obj/serial-get.o (.text)

/* 
    . += 0x100 - . ;

  } > ram0 =0x0000


  stuff : {
*/

    debug/h8300/serial/obj/serial-busy.o (.text)
    debug/h8300/serial/obj/serial-buf.o (.text)

    debug/h8300/rcx/pbforth/obj/pbforth.o (.text) 
  } > ram0
/*
  } > ram0b
*/
/*    debug/startup/obj/startup.o (.text)
    debug/startup/obj/startup.o (.text)
 */

  /* --------------------------------------------------------------------------
  |  Any data that your program needs goes here. Note that output records with
  |  default initial values will be generated for this area                  */

  .data : {
  } > ram0b

  /* --------------------------------------------------------------------------
  |  This is where uninitialized data for your program goes. It is customary
  |  for the startup code to zero out the .bss section                       */

  .bss : {
  } > ram0b

  /* --------------------------------------------------------------------------
  |  It is CRUCIAL that the data stacks _SO and _ISO never cross a 256
  |  byte boundary!                                                                        */


  .stacks :  {
    . += 0x0C0 ;
    _S0 = . - 6 ;
    
    . += 0x0C0 ;
    _R0 = . - 6 ;
    
    . += 0x080 ;
    _IS0 = . - 2 ;

    . += 0x050 ;
    _IR0 = . - 2 ;

  } > ram0a

  .scratch : {
    _AddrTib = . ;
    . += 0x80 ;
    . += 0x20 ;
    _AddrHold = . - 2 ;

    _RXBufStart  = . ;
    . += 0x40 ;
    _RXBufEnd    = . ;
    _RXBufLen    = ABSOLUTE(_RXBufEnd - _RXBufStart) ;

    debug/h8300/serial/obj/serial-buf.o  (serdata)
    debug/h8300/serial/obj/serial-busy.o (serdata)
  } > ram0c

  /* --------------------------------------------------------------------------
  |  The LCD data and controller ports live here                             */

  .lcddata : {
    display_memory =  0xef3e - 0xef30 ; 
  } > lcddata
    
  /* --------------------------------------------------------------------------
  |                                                                          */

  .rcxdata : {           
    _rcx_handler_data          = . + 0x00 ;
    _rcx_dispatch_data         = . + 0x06 ;
    _rcx_firmware_data         = . + 0x16 ;
    _rcx_TIMER_data            = . + 0x18 ;
    _rcx_timer_data            = . + 0x24 ;
  } > rcxdata

  /* --------------------------------------------------------------------------
  |  The memory-mapped motor controller...                                   */
  
  .motor : {
    _motor_controller = 0 ;
  } > motor
  
  /* --------------------------------------------------------------------------
  |  RCX ROM shadow registers for the H8 microcontroller and redirectable
  |  interrupt vectors                                                       */

  .romdata : {
    _rom_port1_ddr = 0x00 ; 
    _rom_port2_ddr = 0x01 ; 
    _rom_port3_ddr = 0x02 ; 
    _rom_port4_ddr = 0x03 ; 
    _rom_port5_ddr = 0x04 ; 
    _rom_port6_ddr = 0x05 ; 
    _rom_port7_pin = 0x06 ; 
    
    _reset_vector  = 0x10 ; 
    _nmi_vector    = 0x12 ; 
    _irq0_vector   = 0x14 ; 
    _irq1_vector   = 0x16 ; 
    _irq2_vector   = 0x18 ; 
    _icia_vector   = 0x1A ; 
    _icib_vector   = 0x1C ; 
    _icic_vector   = 0x1E ; 
    _icid_vector   = 0x20 ; 
    _ocia_vector   = 0x22 ; 
    _ocib_vector   = 0x24 ; 
    _fovi_vector   = 0x26 ; 
    _cmi0a_vector  = 0x28 ; 
    _cmi0b_vector  = 0x2A ; 
    _ovi0_vector   = 0x2C ; 
    _cmi1a_vector  = 0x2E ; 
    _cmi1b_vector  = 0x30 ; 
    _ovi1_vector   = 0x32 ; 
    _eri_vector    = 0x34 ; 
    _rxi_vector    = 0x36 ; 
    _txi_vector    = 0x38 ; 
    _tei_vector    = 0x3A ; 
    _ad_vector     = 0x3C ; 
    _wovf_vector   = 0x3E ; 
    
  } > romdata

  /* --------------------------------------------------------------------------
  |                                                                          */

  .ram3 : {
  } > ram3

  /* --------------------------------------------------------------------------
  |  On-chip ports and registers to control the H8/300 used in the RCX       */

  .ports : {
    H8_TIER   = 0x90 ;
    H8_TCSR   = 0x91 ;
    H8_FRC    = 0x92 ;
    H8_OCRA   = 0x94 ;
    H8_OCRB   = 0x94 ;
    H8_TCR    = 0x96 ;
    H8_TOCR   = 0x97 ;
    H8_ICRA   = 0x98 ;
    H8_ICRB   = 0x9A ;
    H8_ICRC   = 0x9C ;
    H8_ICRD   = 0x9E ;
    H8_P1PCR  = 0xAC ;
    H8_P2PCR  = 0xAD ;
    H8_P3PCR  = 0xAE ;
    H8_P1DDR  = 0xB0 ;
    H8_P2DDR  = 0xB1 ;
    H8_P1DR   = 0xB2 ;
    H8_P2DR   = 0xB3 ;
    H8_P3DDR  = 0xB4 ;
    H8_P4DDR  = 0xB5 ;
    H8_P3DR   = 0xB6 ;
    H8_P4DR   = 0xB7 ;
    H8_P5DDR  = 0xB8 ;
    H8_P6DDR  = 0xB9 ;
    H8_P5DR   = 0xBA ;
    H8_P6DR   = 0xBB ;
    H8_P7PIN  = 0xBE ;
    H8_STCR   = 0xC3 ;
    H8_SYSCR  = 0xC4 ;
    H8_MDCR   = 0xC5 ;
    H8_ISCR   = 0xC6 ;
    H8_IER    = 0xC7 ;
    H8_TCR0   = 0xC8 ;
    H8_TCSR0  = 0xC9 ;
    H8_TCORA0 = 0xCA ;
    H8_TCORB0 = 0xCB ;
    H8_TCNT0  = 0xCC ;
    H8_TCR1   = 0xD0 ;
    H8_TCSR1  = 0xD1 ;
    H8_TCORA1 = 0xD2 ;
    H8_TCORB1 = 0xD3 ;
    H8_TCNT1  = 0xD4 ;
    H8_SMR    = 0xD8 ;
    H8_BRR    = 0xD9 ;
    H8_SCR    = 0xDA ;
    H8_TDR    = 0xDB ;
    H8_SSR    = 0xDC ;
    H8_RDR    = 0xDD ;
    H8_ADDRA  = 0xE0 ;
    H8_ADDRAh = 0xE0 ;
    H8_ADDRAl = 0xE1 ;
    H8_ADDRB  = 0xE2 ;
    H8_ADDRBh = 0xE2 ;
    H8_ADDRBl = 0xE3 ;
    H8_ADDRC  = 0xE4 ;
    H8_ADDRCh = 0xE4 ;
    H8_ADDRCl = 0xE5 ;
    H8_ADDRD  = 0xE6 ;
    H8_ADDRDh = 0xE6 ;
    H8_ADDRDl = 0xE7 ;
    H8_ADCSR  = 0xE8 ;
    H8_ADCR   = 0xE9 ;
  } > ports

} /* SECTIONS */

/* ----------------------------------------------------------------------------
|  The following section defines symbols that may be used anywhere in the
|  target program from either assembler or high-level source.
|
|  The reason for putting these here is that the symbols may be used by both
|  assembler and C language routines, which means that we don't need to manage
|  them separately in two types of source code.
|
|  Granted, the H8/300 register bits are not likely to change, but there may 
|  be other things which may need to be synchronized between assembler
|  and high-level source code
| -------------------------------------------------------------------------  */

  /* --------------------------------------------------------------------------
  |  H8/300 register bit masks and positions. The H8 has the ability to do
  |  normal bytewide logical operations. It also has special bitwise opcodes
  |  that use a bit number ranging from 0 (lsb) to 7 (msb).
  |
  |  This means that every bit must be defines as both a mask and a bit
  |  position. To make things easier, my convention is to use the register
  |  name followed by the bit name for the mask, and appending _BIT for the
  |  bit number.
  |
  | Unfortunately, GNU-as is not smart enought to truncate the values of the
  | bit positions to 3 bits, so they have to be defined separately at the
  | source level...                                                          */

  /* H8_SMR - Serial Mode Register                                           */

  SMR_CA       = 0x80 ; /* Async/Clocked            - defaults to async      */
  SMR_CHR      = 0x40 ; /* 8/7 Bits/Chr             - defaults to 8          */
  SMR_PE       = 0x20 ; /* Parity Enable            - defaults to no parity  */
  SMR_OE       = 0x10 ; /* Odd/Even Parity          - defaults to even       */
  SMR_STOP     = 0x08 ; /* 1/2 Stop Bits            - defaults to 1 stop bit */
  SMR_MP       = 0x04 ; /* Multiprocessor Mode      - defaults to disabled   */
  SMR_CKS1     = 0x02 ; /* Clock select             - defaults to direct     */
  SMR_CKS0     = 0x01 ; /* 

  /* H8_SCR - Serial Control Register                                        */

  SCR_TIE      = 0x80 ; /* TDR Empty interrupt      - defaults to disabled   */
  SCR_RIE      = 0x40 ; /* RDRF & ERI interrupt     - defaults to disabled   */
  SCR_TE       = 0x20 ; /* Transmitter Enable       - defaults to disabled   */
  SCR_RE       = 0x10 ; /* Receiver Enable          - defaults to disabled   */
  SCR_MPIE     = 0x08 ; /* Multiprocessor interrupt - defaults to disabled   */
  SCR_TEIE     = 0x04 ; /* TSR Empty interrupt      - defaults to disabled   */
  SCR_CKE1     = 0x02 ; /* Int/Ext clock select     - defaults to internal   */
  SCR_CKE0     = 0x01 ; /* SCK output               - defaults to disabled   */

  /* H8_SSR - Serial Status Register                                         */

  SSR_TDRE     = 0x80 ; /* Transmit Data Register Empty                      */
  SSR_RDRF     = 0x40 ; /* Receive Data Register Full                        */
  SSR_ORER     = 0x20 ; /* Overrun Error                                     */
  SSR_FER      = 0x10 ; /* Framing Error                                     */
  SSR_PER      = 0x08 ; /* Parity Error                                      */
  SSR_TEND     = 0x04 ; /* Transmit End                                      */
  SSR_MPB      = 0x02 ; /* Multiprocessor Bit                                */
  SSR_MPBT     = 0x01 ; /* Multiprocessor Bit Transfer                       */

  /* H8_TCR0 - TMR0 Control Register                                         */
  /* H8_TCR1 - TMR1 Control Register                                         */

  TCR_CMIEB    = 0x80 ; 
  TCR_CMIEA    = 0x40 ; 
  TCR_OVIE     = 0x20 ; 
  TCR_CCLR1    = 0x10 ; 
  TCR_CCLR0    = 0x08 ; 
  TCR_CKS2     = 0x04 ; 
  TCR_CKS2     = 0x02 ; 
  TCR_CKS2     = 0x01 ;
 
  /* H8_TCSR0 - TMR0 Status Register                                         */
  /* H8_TCSR1 - TMR1 Status Register                                         */
  
  TCSR_CMFB    = 0x80 ; 
  TCSR_CMFA    = 0x40 ; 
  TCSR_OVF     = 0x20 ; 
  TCSR_OS3     = 0x08 ; 
  TCSR_OS2     = 0x04 ; 
  TCSR_OS2     = 0x02 ; 
  TCSR_OS2     = 0x01 ;
 
/* ------------------------------------------------------------------------- */
