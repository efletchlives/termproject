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
	
	;;;;;;;;;;;;;;;;;;; initialize ;;;;;;;;;;;;;;;;;;;;;;;

	;; enable clocks for gpio ports used
	;; format (add all gpio ports):
	;	Enable clocks for GPIOA, GPIOB,GPIOC //;	Enable clocks for GPIOA, GPIOB
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR] ; load AHB2ENR register to enable clocks for GPIOA/B/C
	ORR r1, r1, #0x00000007 ; GPIOA/B/C (add others here)
	STR r1, [r0,#RCC_AHB2ENR] ; store into RCC with clocks for GPIOA/B/C turned on
	LTORG

	;;;; config stepper motor (train motor) to gpioa ;;;;

	; Set GPIOA pins 2, 3, 6, 7 as output pins 
	LDR r0, = GPIOA_BASE     ; load gpioa
	LDR r1, [r0,#GPIO_MODER] ; load moder
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0 ; clear moder for pins 2,3,6,7 to prepare for setting 
	ORR r1, r1, #0x00005000 ; set moder for pins 2,3,6,7 (moder pins: 4,6,12,14) to output ('01')
	ORR r1, r1, #0x00000050
	STR r1, [r0,#GPIO_MODER] ; store moder to set pins 2,3,6,7
	LTORG
	
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

;;ALL GPIOB PIN USAGE(RED LED AND INTERRUPT BUTTON INPUT)

;; Set GPIOB pin 2 (PB2) for LED 
	
	;;Set PB2 Mode To Output
	LDR r0, =GPIOB_BASE
	LDR r1,[r0,#GPIO_MODER]
	BIC r1,r1,#0x00000030
	ORR r1,r1,#0x00000010
	STR r1,[r0,#GPIO_MODER]
	LTORG ;Fixes the issue of the literal pools being too far away from each other
 	;LTORG assembles it to be within 4KB

	;;Select push-pull output
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_OTYPER]
	BIC r1,r1,#0x00000004
	STR r1,[r0,#GPIO_OTYPER]
	LTORG

	;;Output 1 to turn on red LED
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_ODR]
	ORR r1,r1,#0x00000004
	STR r1,[r0,#GPIO_ODR]
	LTORG
	

;; Set GPIOB PIN 1(PB1),PIN 3(PB3), PIN 4(PB4), and PIN 5(PB5) for Station A,B,C, and emergency button interrupt

	;;Set PB1,PB3,PB4,PB5 as Input
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_MODER]
	BIC r1,r1,#0x00000F00 ;;Masking
	BIC r1,r1,#0x00000077
	STR r1,[r0,#GPIO_MODER]
	LTORG

	;;Set PB1,PB3,PB4,PB5 as NoPullUp,Pull-Down
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_PUPDR]
	BIC r1,r1,#0x00000F00
    BIC r1,r1,#0x00000077
	STR r1,[r0,#GPIO_PUPDR]
	LTORG

	;;;; config stepper motor (train doors) to gpioc ;;;;
    
	; Set GPIOB pins 2, 3, 6, 7 as output pins 
	LDR r0, = GPIOC_BASE     ; load gpiob
	LDR r1, [r0,#GPIO_MODER] ; load moder
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0 ; clear moder for pins 2,3,6,7 to prepare for setting 
	ORR r1, r1, #0x00005000 ; set moder for pins 2,3,6,7 (moder pins: 4,6,12,14) to output ('01')
	ORR r1, r1, #0x00000050
	STR r1, [r0,#GPIO_MODER] ; store moder to set pins 2,3,6,7
	LTORG
	; otyper for output
	LDR r0, =GPIOC_BASE
	LDR r1, [r0,#GPIO_OTYPER]
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0
	STR r1, [r0,#GPIO_OTYPER]
	LTORG
	
	; pupdr for output
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1, #0x0000F000
	BIC r1, r1, #0x000000F0
	STR r1, [r0,#GPIO_PUPDR]
	LTORG

;;Initialization of Interrupts

    	MOVS r0, #0
		MSR FAULTMASK , r0

	;;Initializing Interrupt 1(STATION A)
       LDR r0,=RCC_BASE
       LDR r1,[r0,#RCC_AHB2ENR]
       ORR r1,r1,#RCC_APB2ENR_SYSCFGEN
       STR r1,[r0,#RCC_AHB2ENR]
	   LTORG

       LDR r0,=SYSCFG_BASE
       LDR r1,[r0,#SYSCFG_EXTICR0]
       BIC r1,#SYSCFG_EXTICR1_EXTI1
       ORR r1,#SYSCFG_EXTICR1_EXTI1_PB
       STR r1,[r0,#SYSCFG_EXTICR0]
	   LTORG
	
       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_RTSR1]
       ORR r1,#EXTI_RTSR1_RT1 ;;Setting it to trigger on rising edge
       STR r1,[r0,#EXTI_RTSR1]
	   LTORG

       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_IMR1]
       ORR r1, #EXTI_IMR1_IM1
       STR r1,[r0,#EXTI_IMR1]
	   LTORG

       ;;Initializing Interrupt 3(STATION B)
        LDR r0,=RCC_BASE
       LDR r1,[r0,#RCC_AHB2ENR]
       ORR r1,r1,#RCC_APB2ENR_SYSCFGEN
       STR r1,[r0,#RCC_AHB2ENR]
		LTORG
       LDR r0,=SYSCFG_BASE
       LDR r1,[r0,#SYSCFG_EXTICR0]
       BIC r1,#SYSCFG_EXTICR1_EXTI3
       ORR r1,#SYSCFG_EXTICR1_EXTI3_PB
       STR r1,[r0, # SYSCFG_EXTICR0]
	   LTORG
	
       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_RTSR1]
       ORR r1,#EXTI_RTSR1_RT3 ;;Setting it to trigger on rising edge
       STR r1,[r0,#EXTI_RTSR1]
	   LTORG

       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_IMR1]
       ORR r1, #EXTI_IMR1_IM3
       STR r1,[r0,#EXTI_IMR1]
		LTORG
       ;;Initializing Interrup 4(STATION C)
        LDR r0,=RCC_BASE
       LDR r1,[r0,#RCC_AHB2ENR]
       ORR r1,r1,#RCC_APB2ENR_SYSCFGEN
       STR r1,[r0,#RCC_AHB2ENR]
	   LTORG

       LDR r0,=SYSCFG_BASE
       LDR r1,[r0,#SYSCFG_EXTICR2]
       BIC r1,#SYSCFG_EXTICR2_EXTI4
       ORR r1,#SYSCFG_EXTICR2_EXTI4_PB
       STR r1,[r0, # SYSCFG_EXTICR2]
	
       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_RTSR1]
       ORR r1,#EXTI_RTSR1_RT4 ;;Setting it to trigger on rising edge
       STR r1,[r0,#EXTI_RTSR1]

       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_IMR1]
       ORR r1, #EXTI_IMR1_IM4
       STR r1,[r0,#EXTI_IMR1]

       ;;Initializing Interrupt 5(Emergency Button Interrupt)
        LDR r0,=RCC_BASE
       LDR r1,[r0,#RCC_AHB2ENR]
       ORR r1,r1,#RCC_APB2ENR_SYSCFGEN
       STR r1,[r0,#RCC_AHB2ENR]

       LDR r0,=SYSCFG_BASE
       LDR r1,[r0,#SYSCFG_EXTICR2]
       BIC r1,#SYSCFG_EXTICR2_EXTI5
       ORR r1,#SYSCFG_EXTICR2_EXTI5_PB
       STR r1,[r0, # SYSCFG_EXTICR2]
	
       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_RTSR1]
       ORR r1,#EXTI_RTSR1_RT5 ;;Setting it to trigger on rising edge
       STR r1,[r0,#EXTI_RTSR1]

       LDR r0,=EXTI_BASE
       LDR r1,[r0,#EXTI_IMR1]
       ORR r1, #EXTI_IMR1_IM5
       STR r1,[r0,#EXTI_IMR1]

       

;; config push buttons as interrupt to pull the train to the station A and reset the sequence of operations upon a button press (possible bonus option)

;CONFIG FOR LED (gpio port d)


;; list of available gpio ports: E,F,G,H

;;;;;;;;;;;;;;;;; main code ;;;;;;;;;;;;;;;;;;;;

; 3 switches on breadboard for pulling to stations A/B/C

; register to store current destination and current location
    ; initialize registers to start point
	LDR r4, =0x0000 ; starting train location (station A)
	LDR r5, =0x0600 ; train station destination (station B) (3 rotations)
	LDR r6, =0x0001 ; train direction (right)

main_loop   
    CMP r4, r5
    BNE check_dir

    ; station A
    CMP r4, #0x0000             ; check if at station A
        MOVEQ r5, #0x0600       ; set destination = B
                                ; set 7-segment display to 11 (B)
        BEQ main_loop           ; exit back to main loop
    ; station B
    CMP r4, #0x0600             ; check if at station B
        CMPEQ r6, #1                ; if direction = forward
            MOVEQ r5, #0x1200           ; set destination = C
                                        ; set 7-segment display to 12 (C)
            BEQ main_loop               ; exit back to main loop
        CMP r6, #0                  ; check if direction = backward
            MOVNE r5, #0x0000           ; set destination = A
                                        ; set 7-segment display to 10 (A)
            BNE main_loop               ; go back to main loop
    ; station C
    CMP r4, #0x1200             ; check if at station C
        MOVEQ r5, #0x0600           ; set destination = B
                                    ; set 7-segment display to 11 (B)
        BEQ main_loop               ; exit back to main loop

    
check_dir
    CMP r4, r5
                    ; if location < destination
    MOVLE r6, #1        ; change direction to forward
    BLLE forward        ; branch to forward (rotate one cycle forward)
                    ; if location > destination
    MOVGT r6, #0        ; change direction to backward
    BLGT backward       ; branch to backward (rotate one cycle backward)

    B main_loop


forward
	PUSH {LR}
loop3

	;;;;;;;; temporary ;;;;;;;;;;
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000000
	STR r1, [r0, #GPIO_ODR]
	BL delay
	;;;;;;;;;;;;;;;;;;;;;;;;
	
	; step 1
    LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 2
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 3
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 4
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 5
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 6
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 7
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 8
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	BL delay
	
	ADD r4, #1 ; increment counter
	
	POP {LR}
	BX LR

backward
	PUSH {LR}
loop4	
	; move cw	
	; step 1
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 2
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 3
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 4
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 5
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 6
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 7
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 8
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay
	
	SUBS r4, #1
	
	POP{LR}
	BX LR


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
	
	ADD r8, #1 ; increment counter
	
	CMP r8, r9
	BNE loop5
	
	POP {LR}
	BX LR


doors_close
	PUSH {LR}
loop6	
	; move cw
	; step 1
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 2
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 3
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 4
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 5
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 6
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 7
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay
	; step 8
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay
	
	ADD r8, #1
	CMP r8,r9
	BNE loop6
	
	POP{LR}
	BX LR

;;;;;;;;;;;;;;;;;;;;;INTERRUPTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EXTI1_IRQHandler PROC 

    PUSH{R2,R3,R6,R7}
    ;;Initializing the interrupt
	;;Also serves as a safety check; makes sure that the interrupt that was pressed is the correct one
    LDR r0,=EXTI_BASE
    LDR r1,[r0,#EXTI_PR1]
    AND r1,r1,#EXTI_PR1_PIF1
    CMP r1,#0
    BNE stop
    ;;Set R5 to Destination A

    MOV R5, #0x0000 ; 0x0000 is the starting location
	
	;;Clearing the Interrupt by writing to 1
	
	LDR r0, =EXTI_BASE
	LDR r1,[r0,#EXTI_PR1]
	ORR r1, #EXTI_PR1_PIF1
	STR r1,[r0,#EXTI_PR1]
	
	POP{R2,R3,R6,R7}
	BX LR 	
	
	ENDP
	
 ;;Interrupt for Station B
 ;;Plan on using PB3(input) for B interrupt
EXTI3_IRQHandler PROC

    PUSH{R2,R3,R6,R7}
	;;Initializing the interrupt
	;;Adding a safety check to this interrupt
    LDR r0,=EXTI_BASE
    LDR r1,[r0,#EXTI_PR1]
    AND r1,r1,#EXTI_PR1_PIF3
    CMP r1,#0
    BNE stop
   
	;;Set R5 to Destination B

    MOV R5, #0x0600

	LDR r0, =EXTI_BASE
	LDR r1,[r0,#EXTI_PR1]
	ORR r1, #EXTI_PR1_PIF3
	STR r1,[r0,#EXTI_PR1]
	
	POP{R2,R3,R6,R7}
	BX LR 
    ENDP

 ;;Interrupt for Station C
 ;;Plan on using PB4(input) for C interrupt
EXTI4_IRQHandler PROC

 PUSH{R2,R3,R6,R7}
    
    LDR r0,=EXTI_BASE
    LDR r1,[r0,#EXTI_PR1]
    AND r1,r1,#EXTI_PR1_PIF4
    CMP r1,#0
    BNE stop
    
    ;;Set R5 to Destination C 
    
    MOV R5, #0x0C00
	
	LDR r0,=EXTI_BASE
	LDR r1,[r0,#EXTI_PR1]
	ORR r1,#EXTI_PR1_PIF4
	STR r1,[r0,#EXTI_PR1]
	
	POP{R2,R3,R6,R7}
	BX LR
	ENDP
    
;;Interrupt for the emergency stop 
;;Plan on using PB5(input) for Emergency Interrupt
EXTI5_IRQHandler PROC

 ;;Pushing the LR as well to avoid bugs with the doors_open and doors_close functions
 PUSH{R2,R3,R6,R7,LR}

    LDR r0,=EXTI_BASE
    LDR r1,[r0,#EXTI_PR1]
    AND r1,r1,#EXTI_PR1_PIF5
    CMP r1,#0
    BNE stop

    ;;Turn LED ON FIRST
    LDR r0, =GPIOB_BASE
    LDR r10,[r0,#GPIO_ODR]
    MOV r10, #1
    STR r10,[r0,#GPIO_ODR]
   
    ;;THEN OPEN AND CLOSE DOORS
    BL doors_open 
    POP{LR}

    PUSH{LR}
    BL doors_close
	
	
	LDR r0,=EXTI_BASE
	LDR r1,[r0,#EXTI_PR1]
	ORR r1,#EXTI_PR1_PIF5
	STR r1,[r0,#EXTI_PR1]
	

    POP{R2,R3,R6,R7,LR}
	BX LR
	
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END INTERRUPTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delay
    MOV r7, #0x708
delay_loop1
    SUBS r7, #1
    BNE delay_loop1      ; continue loop
    BX LR               ; go back to where you were in the main function

long_delay
    MOV r7, #0xFFFF
delay_loop2
    SUBS r7, #1
    BNE delay_loop2      ; continue loop
    BX LR               ; go back to where you were in the main function




stop 	B 		stop     		; dead loop & program hangs here

	ENDP
								

	AREA myData, DATA, READWRITE
	ALIGN

	END
