/*
 * yilmaz_side_cenan_kagan_lab1_lightmovecontrol.asm
 *
 *  Created: 10/27/2016 4:03:47 PM
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

	ldi	R16, $F0		; All ones makes
	out	DDRB, R16		; port B all inout 
	ldi	R16, $FF		; All zeros makes de?i?tirdim
	out	DDRD, R16		; port D an output
	ldi R18,0
	ldi R24,0

LOOP:	in	R16, PINB               ; Read buttons from port D (active low)
		
		cpi R16,0		
		brne DO					;r16 0 degilse DO branch?na gitmesini sa?l?yor

		cpi R18,0				;r18 bir önceki durumdaki hangi casede kald???n? check edip yap?lan ?etin tekrarlanmas?n? sa?l?yor
		breq LOOP

		add R16,R18
		
		DO:						;r16 let cases happen

		cpi R16,1
		breq CASE_0  
		 
		cpi R16,2
		breq CASE_1 

		cpi R16,4
		breq CASE_2 

		cpi R16,8
		breq CASE_3 

		cpi R16,$00
		breq LOOP


		CASE_0:   ;stay with no light
				ldi R22,$00
				out	PORTD, R22 
				ldi R18,$00
				add R18,R16
				rjmp LOOP


		CASE_1:     ;case_1 , case_2, case_3 check which button is clicked and in the cases it decide the delay lenght with the R20 value 
				RCALL LR	
				rjmp LOOP

		CASE_2:	
				RCALL LR
				rjmp LOOP

		CASE_3:
				RCALL LR
				rjmp LOOP



;--------------------------------
		DELAY:	
					cpi R16,2  ;if 2nd button clicked
					brne RR 
					ldi R20,20  ;slow
					rjmp THERE

				RR:	cpi R16,4  ;if 3th button clicked
					brne RRR
					ldi R20,10 ;medium
					rjmp THERE

				RRR:ldi R20,1 ; if 4th button clicked, fast

			THERE:
				
			L1S: ldi R21,50		
			L2S: ldi R22,100		
			L3S:
				ldi R23,0
		add R23,R16	
		in	R16, PINB               ; Read buttons from port D (active low)
		cpi R16,0		
		brne LOOP
		add R16,R23
				
				dec R22
				brne L3S

				dec R21
				brne L2S

				dec R20
				brne L1S
				ret




LR:
					ldi R17,$01
					ldi R19,$08			;counter

			LEFTS:
					out	PORTD, R17      ; Output value of buttons to port B (active low)
					RCALL DELAY
					lsl R17  ;left shift from the beggining
					dec R19
					brne LEFTS

					ldi R19,$06			;Counter = 6
					ldi R17,$40	

			RIGHTS:
					out	PORTD, R17      ; Output value of buttons to port B (active low)
					RCALL DELAY
					lsr R17				;right shift from left side of the leds which means 1 value.
					dec R19
					brne RIGHTS

					ldi R18,$00
					add R18,R16

					RET

