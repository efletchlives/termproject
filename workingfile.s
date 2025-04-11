
	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
;;;;;;;;;;;;;;;;;;; initialize ;;;;;;;;;;;;;;;;;;;;;;;

	;; enable clocks for gpio ports used
	;; format (add all gpio ports):
	;	Enable clocks for GPIOA, GPIOB,GPIOC //;	Enable clocks for GPIOA, GPIOB
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR] ; load AHB2ENR register to enable clocks for GPIOA/B/C
	ORR r1, r1, #0x00000007 ; GPIOA/B/C (add others here)
	STR r1, [r0,#RCC_AHB2ENR] ; store into RCC with clocks for GPIOA/B/C turned on


	;;;; config stepper motor (train motor) to gpioa ;;;;

	; Set GPIOA pins 2, 3, 6, 7 as output pins 
	LDR r0, = GPIOA_BASE     ; load gpioa
	LDR r1, [r0,#GPIO_MODER] ; load moder
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0 ; clear moder for pins 2,3,6,7 to prepare for setting 
	ORR r1, r1, #0x00005000 ; set moder for pins 2,3,6,7 (moder pins: 4,6,12,14) to output ('01')
	ORR r1, r1, #0x00000050
	STR r1, [r0,#GPIO_MODER] ; store moder to set pins 2,3,6,7
	
	; otyper for output
	LDR r0, =GPIOA_BASE
	LDR r1, [r0,#GPIO_OTYPER]
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0
	STR r1, [r0,#GPIO_OTYPER]
	
	; pupdr for output
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0
	STR r1, [r0,#GPIO_PUPDR]


	;; Set GPIOB pin 2 (PB2) for LED 

	;LDR r0, =GPIOB_BASE
	;LDR r1,[r0,#GPIO_OTYPE]



	;;;; config stepper motor (train doors) to gpioc ;;;;
    
	; Set GPIOB pins 2, 3, 6, 7 as output pins 
	LDR r0, = GPIOC_BASE     ; load gpiob
	LDR r1, [r0,#GPIO_MODER] ; load moder
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0 ; clear moder for pins 2,3,6,7 to prepare for setting 
	ORR r1, r1, #0x00005000 ; set moder for pins 2,3,6,7 (moder pins: 4,6,12,14) to output ('01')
	ORR r1, r1, #0x00000050
	STR r1, [r0,#GPIO_MODER] ; store moder to set pins 2,3,6,7
	
	; otyper for output
	LDR r0, =GPIOC_BASE
	LDR r1, [r0,#GPIO_OTYPER]
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0
	STR r1, [r0,#GPIO_OTYPER]
	
	; pupdr for output
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0
	STR r1, [r0,#GPIO_PUPDR]



;; config push buttons as interrupt to pull the train to the station A and reset the sequence of operations upon a button press (possible bonus option)

;CONFIG FOR LED (gpio port d)


;; list of available gpio ports: E,F,G,H

;;;;;;;;;;;;;;;;; main code ;;;;;;;;;;;;;;;;;;;;

; 3 switches on breadboard for pulling to stations A/B/C

; register to store current destination and current location

	; initialize registers to start point
	LDR r4, =0x0000 ; starting train location (station A)
	LDR r5, =0x3000 ; train station destination (station B)
	LDR r6, =0x0001 ; train direction (right)

main_loop ; while(1)

	; compare train location and destination
	;CMP r4, r5
	;BNE check_dir

	; initialize doors step counter to 0
	MOV r8, #0x0000
	; set door steps to 180 degrees (doors open)
	MOV r9, #0x0400
	BL doors_open

    B main_loop


doors_open
	PUSH {LR}
loop5
	; move ccw
	; step 1
    LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 2
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 3
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 4
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 5
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 6
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 7
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 8
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	BL delay
	
	ADD r4, #1 ; increment counter
	
	CMP r4, r5
	BNE loop5
	
	POP {LR}
	BX LR

delay
    MOV r7, #0x708
delay_loop1
    SUBS r7, #1
    BNE delay_loop1      ; continue loop
    BX LR               ; go back to where you were in the main function

			
