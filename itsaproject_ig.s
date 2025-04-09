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

LDR r0, =GPIOB_BASE
LDR r1,[r0,#GPIO_OTYPE]



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

; 4 switches on breadboard for pulling to stations A/B/C

; register to store current destination and current location

main 
	; set step register to 0 for station A
	; set station location memory to station A

	; go forward to station B (branch to forward)
	MOV r2, #0x0	; set counter
	MOV r3, #0x3000	; set comparison (3 full rotations of motor)
	BL forward
	
	; increment station register throughout transit

	; train doors open and close (branch to doors)
	BL doors

	; go forward to station C (branch to forward)
	MOV r2, #0x0	; set counter
	MOV r3, #0x3000	; set comparison (3 full rotations of motor)
	BL backward
	; set station location memory to station C

	; train doors open and close (branch to doors)
	BL doors
	; go backward to station B 

	B main ; branch back to repeat b/c it goes through stations automatically

;;;; project info ;;;;
;; clockwise is forward, counterclockwise is backwards

;; 10 full rotations between each stop maybe?
;; go forwards in order of stations: A-B-C and then backwards in reverse order: C-B-A
;; pull the skeleton of this part from lab 5 (evan can do this)

;; in between each station, stop for a little bit of time while opening the train doors (CW - doors opening, CCW - doors closing)

;; check for keypad press in between each stepper motor step cycle if not configuring as interrupt

;; communicate where the train is on tera term (pull from the keypad lab)

;; maybe store the current station in a register (0x0A, 0x0B, 0x0C)

;;;;;;;;; most of this assembly code can be copied over from the labs, so just ask me if you don't have something ;;;;;;;;;;;;;;;;;;;;;;;


; function to move stepper motor (forward)
forward
	PUSH {LR}
loop3
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
	
	ADD r2, #1 ; increment counter
	
	CMP r2, r3
	BNE loop3
	
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
	
	ADD r2, #1
	CMP r2,r3
	BNE loop4
	
	POP{LR}
	BX LR

; small delay function
delay
    MOV r6, #0x708
delay_loop1
    SUBS r6, #1
    BNE delay_loop1      ; continue loop
    BX LR               ; go back to where you were in the main function

				
__main	PROC
	
	BL System_Clock_Init
	BL UART2_Init

