;;;;;;;;;;;;;;;;;;; initialize ;;;;;;;;;;;;;;;;;;;;;;;

;; enable clocks for gpio ports used
;; format (add all gpio ports):
;	Enable clocks for GPIOC, GPIOB//;	Enable clocks for GPIOA, GPIOB
	LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_AHB2ENR] ; load AHB2ENR register to enable clocks for GPIOA/B/C
    ORR r1, r1, #0x00000006 ; GPIOB/C (add others here)
    STR r1, [r0,#RCC_AHB2ENR] ; store into RCC with clocks for GPIOA/B/C turned on


;; config stepper motor (train motor) to gpioa

;; config stepper motor (train doors) to gpiob

;; config keypad to gpioc (maybe configure as an interrupt, that may take too long though)

;; config push button as interrupt for bonus to pull the train to the station A and reset the sequence of operations upon a button press (possible bonus option)

;; other bonus option is PWM or step delay (we can just alter the delay function)


;; list of available gpio ports: D,E,F,G,H

;;;;;;;;;;;;;;;;; main code ;;;;;;;;;;;;;;;;;;;;
;

;; clockwise is forward, counterclockwise is backwards

;; 10 full rotations between each stop maybe?
;; go forwards in order of stations: A-B-C and then backwards in reverse order: C-B-A
;; pull the skeleton of this part from lab 5 (evan can do this)

;; in between each station, stop for a little bit of time while opening the train doors (CW - doors opening, CCW - doors closing)

;; check for keypad press in between each stepper motor step cycle if not configuring as interrupt

;; communicate where the train is on tera term (pull from the keypad lab)



;;;;;;;;; most of this assembly code can be copied over from the labs, so just ask me if you don't have something ;;;;;;;;;;;;;;;;;;;;;;;


;; lab 5 stuff to use:
motor_rotate
	PUSH {LR}
	
	MOV r2, #0x0	; set counter
	MOV r3, #0x200	; set comparison (full rotation of motor)
	BL ccw_rotate

	MOV r2, #0x0	; set counter
	MOV r3, #0x200	; set comparison (full rotation of motor)
    BL cw_rotate
	
	POP {LR}
	BX LR		; goes back to loop2
    

; function to move stepper CCW
ccw_rotate
	PUSH {LR}
loop3
	; step 1
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 2
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 3
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 4
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 5
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 6
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 7
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 8
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	BL delay
	
	ADD r2, #1 ; increment counter
	
	CMP r2, r3
	BNE loop3
	
	POP {LR}
	BX LR


cw_rotate
	PUSH {LR}
loop4	
	; move cw
	; step 1
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 2
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 3
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 4
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 5
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 6
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 7
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 8
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay
	
	ADD r2, #1
	CMP r2,r3
	BNE loop4
	
	POP{LR}
	BX LR

; small delay function
delay
    ;; compare r3 where step is at beginning to be a larger delay and do this for multiple times in beginning, slowly incrementing (to simulate acceleration)
    ;; do the opposite towards the end of the rotation cycle

    MOV r6, #0x708      ; adjust value to change timing (change this to simulate acceleration and deceleration) 



delay_loop1
    SUBS r6, #1
    BNE delay_loop1      ; continue loop
    BX LR               ; go back to where you were in the 
    



;;;;;;;;;;; ari, add your keypad lab below ;;;;;;;;;;;;;

;; keypad lab:
;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************


	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	BL System_Clock_Init
	BL UART2_Init



;;;;;;;;;;;; YOUR CODE GOES HERE	;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;Enabling clock of both GPIO Port B and C 
    LDR r0, =RCC_BASE
	LDR r1, [r0,#RCC_AHB2ENR]
	ORR r1, r1, #0x00000006
	STR r1,[r0, #RCC_AHB2ENR]
	
	;;Configuring GPIO C Mode Register for Output
	LDR r0, =GPIOC_BASE
	LDR r1, [r0,#GPIO_MODER]
	BIC r1, r1, #0x000000FF
	ORR r1, r1, #0x00000055
	STR r1, [r0,#GPIO_MODER]
	
	;;Configuring GPIO C Output Type
	LDR r0, =GPIOC_BASE
	LDR r1, [r0,#GPIO_OTYPER]
	BIC r1, r1, #0x0000000F
	STR r1, [r0,#GPIO_OTYPER]   ;Setting it to output open-drain
	
	;;Configuring GPIO C Output Data Register
	LDR r0, =GPIOC_BASE
	LDR r1,[r0,#GPIO_PUPDR]
	ORR r1, r1, #0x000000FF
	STR r1, [r0,#GPIO_PUPDR]
	
	;;Configuring GPIO B Mode Registers for Input
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, r1, #0x000000FC
	STR r1, [r0,#GPIO_MODER]
	
	
	;;Configuring GPIO B PullUpPullDown Register
	LDR r0, =GPIOB_BASE
	LDR r1,[r0, #GPIO_PUPDR]
	BIC r1, r1, #0x000000FC
	STR r1, [r0, #GPIO_PUPDR]
	
;;;;;;;;;;;;;;;;;;;END CONFIGURATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;START LOOPING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

allrowpull
	  LDR r0, =GPIOC_BASE
	  LDR r3,[r0,#GPIO_ODR] ;Storing the output data registers within Register 3
	  MOV r3, #0x00000000 ;Pulling down all rows
	  
	  STR r3,[r0,#GPIO_ODR]
	  
	  BL delay ; Calling delay subroutine
	  
	  LDR r1, =GPIOB_BASE
	  LDR r4,[r1,#GPIO_IDR] ;Storing the input data registers within Register 4 
	  CMP r4, #0x1E ;Checking if all columns are 1 
	  BNE row1
	  
	  B allrowpull
	   
row1 
	LDR r0, =GPIOC_BASE
	LDR r3,[r0,#GPIO_ODR]
	MOV r3 , #0x7 ;Pulling down row 1 
	STR r3,[r0,#GPIO_ODR]

	BL delay ;Delay Subroutine
	
	LDR r1, =GPIOB_BASE
	LDR r4,[r1, #GPIO_IDR]
	CMP r4 , #0x1E 
	BEQ row2
	
	B testcol1
	  
row2
	LDR r0, =GPIOC_BASE
	LDR r3,[r0,#GPIO_ODR]
	MOV r3 , #0xB ;Pulling down row 2
	STR r3,[r0,#GPIO_ODR]
	
	BL delay ;Delay Subroutine
	
	LDR r1, =GPIOB_BASE
	LDR r4,[r1,#GPIO_IDR]
	CMP r4, #0x1E
	BEQ row3
	
	B testcol1
	
row3 
	LDR r0, =GPIOC_BASE 
	LDR r3,[r0,#GPIO_ODR]
	MOV r3 , #0xD ;Pulling down row 3
	STR r3,[r0,#GPIO_ODR]

	BL delay ; Delay Subroutine
	
	LDR r1, =GPIOB_BASE
	LDR r4,[r1,#GPIO_IDR]
	CMP r4, #0x1E
	BEQ row4
	
	B testcol1
	
row4 
	LDR r0, =GPIOC_BASE 
	LDR r3,[r0,#GPIO_ODR]
	MOV r3, #0xE ;Pulling down row 4
	STR r3,[r0,#GPIO_ODR]
	
	BL delay ;Delay Subroutine
	
	LDR r1, =GPIOB_BASE
	LDR r4,[r1,#GPIO_IDR]
	CMP r4, #0x1E
	BEQ allrowpull

	B testcol1

testcol1
	LDR r0, =GPIOB_BASE
	LDR r4,[r0,#GPIO_IDR] 
		CMP r4, #0x16 ;0110
		BNE testcol2
		
		BEQ keypressed


testcol2
	LDR r0, =GPIOB_BASE
	LDR r4,[r0,#GPIO_IDR] 

		CMP r4, #0x1A ;1010
		BNE testcol3
		
	    BEQ keypressed

testcol3
	LDR r0, =GPIOB_BASE
	LDR r4,[r0,#GPIO_IDR] 
		
		CMP r4, #0x1C ;1100
		BNE allrowpull
		
		BEQ keypressed
		
	
keypressed
		
		LDR r0, =GPIOB_BASE
		LDR r4,[r0,#GPIO_IDR]
		
		
		CMP r4, #0x16 ;;Checking for col 1
		BEQ columnkey1
		
		CMP r4,#0x1A ;;Checking for col 2
		BEQ columnkey2
		
		CMP r4,#0x1C ;;Checking for col 3
		BEQ columnkey3
		

columnkey1
		
	LDR r0, =GPIOC_BASE
	LDR r3,[r0,#GPIO_ODR]
	
	CMP r3,#0x7 ;;Checks if col 1, row 1
	BEQ col1rowkey1
	
	CMP r3,#0xB ;Checks if col 1 , row 2
	BEQ col1rowkey2
	
	CMP r3,#0xD ; Checks if col 1, row 3
	BEQ col1rowkey3
	
	CMP r3,#0xE ; Checks if col 1 , row 4
	BEQ col1rowkey4


columnkey2

	LDR r0, =GPIOC_BASE
	LDR r3,[r0,#GPIO_ODR]

    CMP r3,#0x7 ;Checks if col 2 , row 1 
	BEQ col2rowkey1
	
	CMP r3,#0xB ; Checks if col 2, row 2 
	BEQ col2rowkey2
	
	CMP r3,#0xD ; Checks if col 2 , row 3
	BEQ col2rowkey3
	
	CMP r3,#0xE ; Checks if col 2, row 4 
	BEQ col2rowkey4

columnkey3

	LDR r0, =GPIOC_BASE
	LDR r3,[r0,#GPIO_ODR]

    CMP r3,#0x7 ;Checks if col 3 , row 1 
	BEQ col3rowkey1
	
	CMP r3,#0xB ; Checks if col 3 , row 2
	BEQ col3rowkey2
	
	CMP r3,#0xD ; Checks if col 3, row 3
	BEQ col3rowkey3
	
	CMP r3,#0xE ; Checks if col 3, row 4 
	BEQ col3rowkey4
	
	;;Pushing the ASCII value to the set row/col combination of the keys 
col1rowkey1

	MOV r7,#0x23 ;ASCII value of # 
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key
	B displaykey

col1rowkey2
	
	MOV r7,#0x39 ;ASCII value of 9 
	LDR r6, =char1
	STRB r7,[r6]
	BL no_key

	B displaykey
	
col1rowkey3

	MOV r7,#0x36 ;ASCII value of 6
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key

	B displaykey
col1rowkey4

	MOV r7,#0x33 ;ASCII value of 3 
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key

	B displaykey

col2rowkey1

	MOV r7,#0x30 ;ASCII value of 0
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key
	B displaykey

col2rowkey2

	MOV r7,#0x38 ;ASCII value of 8
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key
	B displaykey
col2rowkey3

	MOV r7,#0x35 ;ASCII value of 5
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key
	B displaykey 

col2rowkey4
    MOV r7,#0x32 ;ASCII value of 2
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key
	B displaykey

col3rowkey1

	MOV r7,#0x2A ;ASCII value of 3 
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key
	B displaykey

col3rowkey2

	MOV r7,#0x37 ;ASCII value of 7
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key
	B displaykey 

col3rowkey3

	MOV r7,#0x34 ;ASCII value of 4
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key	
	B displaykey 

col3rowkey4

	MOV r7,#0x31 ;ASCII value of 1 
	LDR r6, =char1
	STRB r7,[r6] 
	BL no_key

	B displaykey 
	

no_key PROC
	LDR r1, =GPIOB_BASE
	LDR r4,[r1, #GPIO_IDR]
	CMP r4, #0x1E
	
	BNE no_key
	
	BX lr

displaykey
	STR	r5, [r8]
	LDR	r0, =char1
	;LDR r0, =str   ; First argument
	MOV r1, #1    ; Second argument
	BL USART2_Write
 	
	B allrowpull
	
	ENDP		

delay	PROC
	; Delay for software debouncing
	LDR	r2, =0xFFFF
delayloop
	SUBS	r2, #1
	BNE	delayloop
	BX LR
	
	ENDP
		
		
		
		
					
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN

char1	DCD	43
	END
