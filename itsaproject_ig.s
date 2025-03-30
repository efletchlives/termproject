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
