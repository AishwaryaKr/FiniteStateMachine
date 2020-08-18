;**********************************************************************
;                                                                     *
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F84A. This file contains the basic code               *
;   building blocks to build upon.                                    *
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:        FSM.asm                                        *
;    Date:            12/8/2019                                       *
;    File Version:                                                    *
;                                                                     *
;    Author:          Aishwarya Krishnan                              *
;    Company:                                                         *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files required: P16F84A.INC                                      *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************


    list      p=16F84A             ; list directive to define processor
    #include <p16F84a.inc>         ; processor specific variable definitions

    __CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _RC_OSC

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

; Macros
IFCLR macro fr, bit, label
    btfsc fr, bit
    goto label
    endm

MOVLF macro lit, fr
    movlw lit
    movwf fr
    endm
    
;***** VARIABLE DEFINITIONS
w_temp        EQU     0x0C        ; variable used for context saving 
status_temp   EQU     0x0D        ; variable used for context saving
STATE         EQU     0x0E    
J             EQU     0x0F
K             EQU     0x10
L             EQU     0x11

; State definitions
S1            EQU     1
S2            EQU     2
S3            EQU     4
S4            EQU     8
SERR          EQU     B'10000000'
SOK           EQU     0
	   
; input bits on PORTA
G1            EQU     0
G2            EQU     1
G3            EQU     2
G4            EQU     3
 
;**********************************************************************
RESET_VECTOR      CODE    0x0000  ; processor reset vector
        goto    start             ; go to beginning of program

ISR               CODE    0x0004  ; interrupt vector location

Interrupt:

        movwf  w_temp             ; save off current W register contents
        movf   STATUS,w           ; move status register into W register
        movwf  status_temp        ; save off contents of STATUS register

;  Place ISR Here

        movf   status_temp,w      ; retrieve copy of STATUS register
        movwf  STATUS             ; restore pre-isr STATUS register contents
        swapf  w_temp,f
        swapf  w_temp,w           ; restore pre-isr W register contents
        retfie                    ; return from interrupt

MAIN_PROGRAM    CODE

start:
    
	; start of the main program
	bsf STATUS, RP0  ; switch to bank 1
	movlw B'00000000'
	movwf TRISB
	
	bcf STATUS, RP0  ; switch to bank 0
	
Mloop: 
state_one:
    
    movlf S1, PORTB
    call delay_loop
    IFCLR PORTA, G2, state_error
    IFCLR PORTA, G3, state_error
    IFCLR PORTA, G4, state_error
    IFCLR PORTA, G1, state_ok
    
state_two: 
	
    movlf S2, PORTB
    call delay_loop
    IFCLR PORTA, G1, state_error
    IFCLR PORTA, G3, state_error
    IFCLR PORTA, G4, state_error
    IFCLR PORTA, G2, state_ok
    
state_three:
    
    movlf S3, PORTB
    call delay_loop
    IFCLR PORTA, G1, state_error
    IFCLR PORTA, G2, state_error
    IFCLR PORTA, G4, state_error
    IFCLR PORTA, G3, state_ok
    
state_four:
    
    movlf S4, PORTB
    call delay_loop
    IFCLR PORTA, G1, state_error
    IFCLR PORTA, G2, state_error
    IFCLR PORTA, G3, state_error
    IFCLR PORTA, G4, state_ok
	    
    goto Mloop
    
state_ok:
    
    movlf SOK, PORTB
    call delay
    IFCLR PORTA, G1, state_ok
    IFCLR PORTA, G2, state_ok
    IFCLR PORTA, G3, state_ok
    IFCLR PORTA, G4, state_ok
	    
    goto state_one
	    
state_error:
   
    movlf SERR, PORTB
    call delay
    IFCLR PORTA, G1, state_error
    IFCLR PORTA, G2, state_error
    IFCLR PORTA, G3, state_error
    IFCLR PORTA, G4, state_error
	    
    goto state_one
    
delay_loop ; 1 second delay
	    MOVLW 0x01
	    MOVWF L
	    MOVLW 0x82
	    MOVWF K
	    MOVLW 0xDD
	    MOVWF J
	    
jloop:
	    DECFSZ J, 1
	    GOTO jloop
	    DECFSZ K, 1
	    GOTO jloop
	    DECFSZ L, 1
	    GOTO jloop

	    RETURN
    
    goto Mloop

        goto $

        END                     

