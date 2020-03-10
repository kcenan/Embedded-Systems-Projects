
;;            Hexadecimal encodings for displaying the digits 0 to F
;;    Digit   gfedcba  	a	b	c	d	e	f	g
;; ------------------------------------------------------------------------
;; 	0	0?3F	on	on	on	on	on	on	off
;; 	1	0?06	off	on	on	off	off	off	off
;; 	2	0?5B	on	on	off	on	on	off	on
;; 	3	0?4F	on	on	on	on	off	off	on
;; 	4	0?66	off	on	on	off	off	on	on
;; 	5	0?6D	on	off	on	on	off	on	on
;; 	6	0?7D	on	off	on	on	on	on	on
;; 	7	0?07	on	on	on	off	off	off	off
;; 	8	0?7F	on	on	on	on	on	on	on
;; 	9	0?6F	on	on	on	on	off	on	on
;; 	A	0?77	on	on	on	off	on	on	on
;; 	b	0?7C	off	off	on	on	on	on	on
;; 	C	0?39	on	off	off	on	on	on	off
;; 	d	0?5E	off	on	on	on	on	off	on
;; 	E	0?79	on	off	off	on	on	on	on
;; 	F	0?71	on	off	off	off	on	on	on
;; ------------------------------------------------------------------------
	
;; Needed only for some assemblers
;; .include "m32def.inc"

;; Reset interrupt vector
.org $000
rjmp Reset

.org 0x016
jmp  T0_OVF ; Timer/ Counter0 Overflow Handler 

;; Define temporary register
.def tmp = R16
.def Delay0 = R17
.def Delay1 = R18
.def counter = R19
.def c1 = R21 ;c1,c2,c3 used for for showing number in decimal form
.def c2 = R22
.def c3 = R23
.def bigcounter = R24 ;counting general time with using time interrupt
.def lapcounter= R27
.def ispress= r28 ;checking first time pressed button2
.def dig0= r29 ;showing digit0
.def dig1= r30  ;showing digit1
.def dig2= r31  ;showing digit2
.def pressecond=r17	 ;checking second time pressed button2
.def laplap=r18
Reset:
	;; Initialize stack pointer
	ldi tmp, LOW(RAMEND)		;load the end of SRAM's low byte to "tmp"
	out SPL, tmp			;Initialize stack pointers low byte
	ldi tmp, HIGH(RAMEND)		;load the end of SRAM's high byte to "tmp"
	out SPH, tmp			;Initialize stack pointers high byte
	;; Initialize PortA[2:0] as an output
	ldi tmp, $07
	out DDRA, tmp
	;; Initialize PortC[7:0] as an output
	ldi tmp, $FF
	out DDRC, tmp
	;;Initialize PortD[4:0] as an input
	ldi tmp, $F0
	out DDRD, tmp  ; for button0, button1,button2,button3 we are enabeling pushable button on board
	ldi counter, $00
	ldi c1,$00
	ldi c2,$00
	ldi c3,$00
	ldi dig0,$00
	ldi dig1,$00
	ldi dig2,$00
	
	ldi R20,158 ;for 0.1 second 10Hz frequence time interrupt on machine we did this.It is explained detailed in the report
	ldi r26,1
	ldi ispress,0 ;button2 cleared -not clicked with reseting-
	ldi lapcounter,0 ;button2 is starting to count second counter,it is cleared
	ldi bigcounter, $00 ;general counter to show time
	ldi pressecond,0 ;button2 cleared -not clicked with reseting for second pressing-

	rcall Init_tov0 ;setup interrupts

Loop:
	in r25, PIND
	cpi r25,$01  ;for button1
	breq button0 ;if button1 is clicked go to button1 case
	cpi r25,$02 ;for button2
	breq button1 ;if button2 is clicked go to button1 case
	cpi r25,$04 ;for button3
	breq button2 ;if button3 is clicked go to button1 case
	cpi r25,$08 ;for button4
	breq button3 ;;if button4 is clicked go to button1 case
	rjmp aaa

	button0:
	sei ;enable to global interrups if button0 is clicked
	rjmp aaa

	button1:
	cli ;unavailable to global interrupts if button1 is clicked
	rjmp aaa

	button2:
	cpi ispress,0  ;check whether it is clicked for the first time
	breq sif ;if yes go sif
	cpi ispress,1 ;check whether it is cliked for the second time
	breq bir ;if yes go bir

	sif: ;if button2 is clicked for the first time
	rcall longdelay ;goes longdelay
	ldi ispress,1 ;change the value of is pressed and pressed second to show it is changing
	ldi pressecond,0
	rjmp aaa

	bir:
	rcall longdelay
	ldi pressecond,1
	ldi ispress,0
	;push and pop for using stack memory
	push r29
	push r30
	push r31	
	rcall forlap	
	pop r31
	pop r30
	pop r29
	rjmp aaa

	button3:  ;if button3 is clicked time interval between timer goes 10 timeslower
	ldi r26,$09
	; with aaa we are changing the numbers hexadecimal to decimal numbers to show on seven segment display
	aaa:  ;general display form
	; Display No#0
	ldi tmp, (1<<0)     ; Make bit#0 one, others zero
	out PORTA, tmp
	cp bigcounter,r26
	brne first
	inc c1
	ldi bigcounter,0
first:
	cpi ispress,1
	brne h
	mov counter,dig0
	rcall check
	mov dig0,counter
	rjmp hh

h:
	mov counter,c1
	mov dig0,c1
	rcall check
	mov c1, counter
hh:	
	out PORTC, tmp
	rcall Delay

	; Display No#1


	ldi tmp, (1<<1)     ; Make bit#1 one, others zero
	out PORTA, tmp
	cpi ispress,1
	brne k
	mov counter,dig1
	rcall check
	mov dig1,counter
	rjmp kk

k:
	mov counter,c2
	mov dig1,c2
	rcall check
	mov c2, counter
kk:	subi tmp,$80
	out PORTC, tmp
	rcall Delay
kkkk:	
	;; Display No#2

	ldi tmp, (1<<2)     ; Make bit#2 one, others zero
	out PORTA, tmp
	cpi ispress,1
	brne p
	mov counter,dig2
	rcall check
	mov dig2,counter
	rjmp pp

p:
	mov counter,c3
	mov dig2,c3
	rcall check
	mov c3, counter
pp:	out PORTC, tmp
	rcall Delay
	rjmp Loop ;goes back to loop to start again code.

;;;Init intre
Init_tov0:
ldi r16, (1<<CS02)|(1<<CS00) ;CLK/1024
out TCCR0, r16
ldi r16, (1<<TOV0) ;Clear pending interrupts
out TIFR, r16
ldi r16, (1<<TOIE0) ;Enable T0 overflow interrupt
out TIMSK, r16
ret

;;;;Init t0_0VF
	T0_OVF:
	push r16
	in r16, SREG
	push r16 ;Save processor status
	out TCNT0, r20 ;Initialize T0 with r20
	in r16,TIFR
	sbrs r16,TOV0
	cpi ispress,1 ;checking button2 is cliked and we are starting to incrementing lapcounter
	brne side ;if not continue to side
	inc lapcounter 

	mov r16,lapcounter
	out portb,r16

	side:
	inc bigcounter ;incrementing the counter which we are counting always
	pop r16
	out SREG, r16 ;Recover processor status
	pop r16
	reti

;; Delay subroutine
Delay:
	push r17
	push r18
	ldi Delay0, $05
	ldi Delay1, $01
Wait:	subi Delay0, 1
	sbci Delay1, 0
	brcc Wait

	pop r18
	pop r17
	ret

;;check subroutine to make hexadecimal numbers to decimal numbers (mod10) and counting it 
check:

	cpi counter,10 ; Display 9 on seven segment display
	brne cont
	ldi counter,$00
	inc c2

	cpi c2,10
	brne cont
	ldi c2,0
	inc c3

	cpi c3,10
	brne cont
	ldi c2,0
	ldi c3,0

	cont:
	cpi counter,0 ; Display 0 on seven segment display
	breq zero
	cpi counter,1 ; Display 1 on seven segment display
	breq one
	cpi counter,2 ; Display 2 on seven segment display
	breq two
	cpi counter,3 ; Display 3 on seven segment display
	breq three
	cpi counter,4 ; Display 4 on seven segment display
	breq four
	cpi counter,5 ; Display 5 on seven segment display
	breq five
	cpi counter,6 ; Display 6 on seven segment display
	breq six
	cpi counter,7 ; Display 7 on seven segment display
	breq seven
	cpi counter,8; Display 8 on seven segment display
	breq eight
	cpi counter,9 ; Display 9 on seven segment display
	breq nine
	cpi counter,$FF ; Display 9 on seven segment display
	breq zero
	 ;tmp values comes from the list which is in the top of the code
	one:
	ldi tmp,$06
	ret
	two:
	ldi tmp,$5B
	ret
	three:
	ldi tmp,$4f
	ret
	four:
	ldi tmp,$66
	ret
	five:
	ldi tmp,$6d
	ret
	six:
	ldi tmp,$7d
	ret
	seven:
	ldi tmp,$07
	ret
	eight:
	ldi tmp,$7f
	ret
	nine:
	ldi tmp,$6F
	ret
	zero:
	ldi tmp,$3f
	ret




	;we used it to show lapcounter on sevensegmendisplay
forlap:

	mov laplap,lapcounter

	ldi r21,0
	ldi r22,0
	ldi r23,0
	can:

	cpi laplap,10
	brlo digit0
	cpi laplap,100
	brlo digit1
	rjmp digit2
	
	digit0:

	mov r21,laplap
	rjmp gg

	digit1:
	inc r22
	subi laplap,10
	rjmp can

	digit2:
	inc r23
	subi laplap,100
	rjmp can
	

	gg:

	ldi tmp, (1<<0)     ; Make bit#0 one, others zero
	out PORTA,tmp 
	mov counter,r21
	rcall checkdef
	mov r21,counter
	out PORTC,tmp
	rcall Delay

	ldi tmp, (1<<1)     ; Make bit#0 one, others zero
	out PORTA,tmp 
	mov counter,r22
	rcall checkdef
	mov r22,counter
	subi tmp,$80
	out PORTC,tmp
	rcall Delay

	ldi tmp, (1<<2)     ; Make bit#0 one, others zero
	out PORTA,tmp 
	mov counter,r23
	rcall checkdef
	mov r23,counter
	out PORTC,tmp
	rcall Delay


	 ret
	 
	 ;longdelay subroutine is a delay estimated 2 second
	 longdelay:

		push r20 ;pushing to stack registers
		push r21
		push r22
		ldi R20,20 
		L1: ldi R21,50			
		L2: ldi R22,100		
		L3: 	
			dec R22
			brne L3
			dec R21
			brne L2
			dec R20
			brne L1
		pop r22
		pop r21
		pop r20 ; poping to stack register
	 ret

	 checkdef:
	cpi counter,0 ; Display 0 on seven segment display
	breq zerox
	cpi counter,1 ; Display 1 on seven segment display
	breq onex
	cpi counter,2 ; Display 2 on seven segment display
	breq twox
	cpi counter,3 ; Display 3 on seven segment display
	breq threex
	cpi counter,4 ; Display 4 on seven segment display
	breq fourx
	cpi counter,5 ; Display 5 on seven segment display
	breq fivex
	cpi counter,6 ; Display 6 on seven segment display
	breq sixx
	cpi counter,7 ; Display 7 on seven segment display
	breq sevenx
	cpi counter,8; Display 8 on seven segment display
	breq eightx
	cpi counter,9 ; Display 9 on seven segment display
	breq ninex
	cpi counter,$FF ; Display 9 on seven segment display
	breq zerox

	onex:
	ldi tmp,$06
	ret
	twox:
	ldi tmp,$5B
	ret
	threex:
	ldi tmp,$4f
	ret
	fourx:
	ldi tmp,$66
	ret
	fivex:
	ldi tmp,$6d
	ret
	sixx:
	ldi tmp,$7d
	ret
	sevenx:
	ldi tmp,$07
	ret
	eightx:
	ldi tmp,$7f
	ret
	ninex:
	ldi tmp,$6F
	ret
	zerox:
	ldi tmp,$3f