/*
 * yilmaz_side_cenan_kagan_lab1_singlebutton.asm
 *
 *  Created: 10/27/2016 4:08:23 PM
 *   Author: CIT
 */ 


 ;***************************************************************************
;* 
;* File Name            : "led.asm"
;* Title                : ELEC/COMP 317 first program
;* Date                 : September 30, 2013
;* Version              : 2.0
;* Target MCU           : ATmega32
;*
;* DESCRIPTION
;*
;* A simple program that turns off LEDs on the EasyAVR Development Kit
;* when the corresponding button is pressed.
;*
;*************************************************************************** 

;.ORG 0
;.INCLUDE "M32DEF.INC"
 
;Initialize the microcontroller stack pointer
LDI    R16, low(RAMEND)
OUT    SPL, R16
LDI    R16, high(RAMEND)
OUT    SPH, R16


RESET:

	ldi	R16, $FE		; All ones makes input
	out	DDRB, R16		; port B all inout 
	ldi	R16, $FF		; All zeros makes de?i?tirdim
	out	DDRD, R16		; port D an output
	ldi R18,0			;r18 butona bas?lmadan önceki say?y? tutar
	ldi R24,0			;click counter
	rjmp OK

LOOP:	in	R16, PINB               ; Read buttons from port D (active low)
		
		cpi R16,0		
		breq OK				;r16 0 degilse 

	DO:	
		in R16,PINB		;if clicked, program goes CONT, if it is not continue to check whether click or not
		cpi R16,0		
		breq CONT
		RJMP DO

	CONT:	
		inc R24
		cpi R24,5		;if r24 clicked 5th time its value become 1 again if not it icrements
		brne OK
		ldi R24,1

	OK:	mov R16,R24

		cpi R16,0
		breq CASE_0  

		cpi R16,1	;first click and 4*1 click
		breq CASE_0  
		 
		cpi R16,2		;second click and 4*1 +1 th click
		breq CASE_1 

		cpi R16,3		;third click and 4*1 +2 th click
		breq CASE_2 

		cpi R16,4		;forth click and 4*1 +3 th click
		breq CASE_3 

		cpi R16,$00
		breq LOOP

		CASE_0:
				ldi R22,$00				;no output 
				out	PORTD, R22 
				rcall delay
				ldi R18,$00
				add R18,R16
				rjmp LOOP

		CASE_1:
				RCALL LR			;slow shift
				rjmp LOOP

		CASE_2:	
				RCALL LR			;medium shift
				rjmp LOOP

		CASE_3:
				RCALL LR			;fast shift
				rjmp LOOP

;--------------------------------
DELAY:	
		cpi R16,2				;check the cases and decide how long will be the delay
		brne C1					;it depends on R20 value which means of the how many times clicked
		ldi R20,20
		rjmp DELAYPART

	C1:	cpi R16,3
		brne C2
		ldi R20,10 
		rjmp DELAYPART

		C2:ldi R20,1 

	DELAYPART:
		L1: ldi R21,50			
		L2: ldi R22,100		
		L3: ldi R23,0
			add R23,R16	
			in	R16, PINB               ; Read buttons from port D (active low)
			cpi R16,0					
			brne LOOP					;if there is a click in portD goes back loop
			add R16,R23
				
			dec R22
			brne L3

			dec R21
			brne L2

			dec R20
			brne L1
		ret




LR:
		ldi R17,$01
		ldi R19,$08			; set R17 to lighth up the right most light

	LEFT:
		out	PORTD, R17      ; Output value of buttons to port B (active low)
		RCALL DELAY
		lsl R17		;left shift of value 1
		dec R19
		brne LEFT

		ldi R19,$06		;Counter = 8
		ldi R17,$40			; set R17 to lighth up the left most light

	RIGHT:
		out	PORTD, R17      ; Output value of buttons to port B (active low)
		RCALL DELAY
		lsr R17		;right shift of value 1
		dec R19
		brne RIGHT

		mov R18,R16			
RET