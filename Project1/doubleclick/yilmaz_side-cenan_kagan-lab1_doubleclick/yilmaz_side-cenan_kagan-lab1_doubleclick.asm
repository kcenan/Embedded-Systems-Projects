/*
 * yilmaz_side_cenan_kagan_lab1_doubleclick.asm
 *
 *  Created: 10/27/2016 4:11:05 PM
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
	ldi R18,0
	ldi R24,0
	rjmp OK

LOOP:	in	R16, PINB               ; Read buttons from port D (active low)
		cpi R16,0		
		breq OK				;r16 0 degilse 

	DO:	
		in R16,PINB
		cpi R16,0		   ;
		breq CONT
		RJMP DO

	CONT:

		rcall INTER		;TO GO CLICKDELAY
		inc R24
		cpi R24,5		;r24 tick count 
		brne OK			; if we click 24 5th time we are making it 1 again
		ldi R24,1

	OK:	mov R16,R24
	;we are checking the cases
		cpi R16,0
		breq CASE_0  

		cpi R16,1
		breq CASE_0  
		
		cpi R16,2
		breq CASE_1 

		cpi R16,3
		breq CASE_2 

		cpi R16,4
		breq CASE_3 

		cpi R16,$00
		breq LOOP

		CASE_0:			;first time double clicked
				ldi R22,$00
				out	PORTD, R22 
				rcall delay
				ldi R18,$00
				add R18,R16
				rjmp LOOP

		CASE_1:			;second time double clicked
				RCALL LR
				rjmp LOOP

		CASE_2:		;third time double clicked
				RCALL LR
				rjmp LOOP

		CASE_3:		;forth time double clicked 
				RCALL LR
				rjmp LOOP

;--------------------------------
INTER: 
RCALL CLICKDELAY			;go to CLIKDELAY
RET


DELAY:	
		cpi R16,2
		brne C1 
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
			brne LOOP
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
		lsl R17
		dec R19
		brne LEFT

		ldi R19,$06			;Counter = 6
		ldi R17,$40			; set R17 to lighth up the left most light

	RIGHT:
		out	PORTD, R17      ; Output value of buttons to port B (active low)
		RCALL DELAY
		lsr R17
		dec R19
		brne RIGHT

		mov R18,R16
RET


CLICKDELAY:
			 ldi R20,10
		L1C: ldi R21,50			
		L2C: ldi R22,80		
		L3C: 

			in	R16, PINB               ; Read buttons from port D (active low)
			cpi R16,1			;if it is click in CLICKDELAY it goes back to where it comes from which let it to increment counter
			breq XX		
			RJMP YY
			XX:	ret				;if it is not clicked it continue to what is going on

			YY:	
			dec R22
			brne L3C
			dec R21
			brne L2C

			dec R20
			brne L1C
	RCALL OK