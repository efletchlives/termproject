
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

	;; for tera term display ;;
	; these 2 lines cause issues
	;BL System_Clock_Init
	;BL UART2_Init      
	
	;; enable clocks for gpio ports used
	;; format (add all gpio ports):
	;	Enable clocks for GPIOA, GPIOB,GPIOC //;	Enable clocks for GPIOA, GPIOB
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR] ; load AHB2ENR register to enable clocks for GPIOA/B/C
	ORR r1, r1, #0x00000007 ; GPIOA/B/C (add others here)
	STR r1, [r0,#RCC_AHB2ENR] ; store into RCC with clocks for GPIOA/B/C turned on
	LTORG

;;;;;;;;;;;;;;;;;;;;;; GPIOA ;;;;;;;;;;;;;;;;;;;;;;;;
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
	LTORG
;;;;;;;;;;;;;;;;;;;;;; end GPIOA ;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;; GPIOB ;;;;;;;;;;;;;;;;;;;;;;;;;
;;ALL GPIOB PIN USAGE(RED LED AND INTERRUPT BUTTON INPUT)

;; Set GPIOB pin 2 (PB2) for LED 
	
	;;Set PB2 Mode To Output
	LDR r0, =GPIOB_BASE
	LDR r1,[r0,#GPIO_MODER]
	BIC r1,r1,#0x00000030
	ORR r1,r1,#0x00000010
	STR r1,[r0,#GPIO_MODER]

	;;Select push-pull output
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_OTYPER]
	BIC r1,r1,#0x00000004
	STR r1,[r0,#GPIO_OTYPER]

	;;Output 1 to turn on red LED
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_ODR]
	ORR r1,r1,#0x00000004
	STR r1,[r0,#GPIO_ODR]
	
	
	;; Set GPIOB PIN 1(PB1),PIN 3(PB3), PIN 4(PB4), and PIN 5(PB5) for Station A,B,C, and emergency button interrupt

	;;Set PB1,PB3,PB4,PB5 as Input (00)
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_MODER]
	BIC r1,r1,#0x000000CC ; PB5 (10,11) PB4 (8,9), PB3 (6,7), PB1 (2,3)
	BIC r1,r1,#0x00000F00
	STR r1,[r0,#GPIO_MODER]

	;;Set PB1,PB3,PB4,PB5 as Pull-Down (10)
	LDR r0,=GPIOB_BASE
	LDR r1,[r0,#GPIO_PUPDR]
	BIC r1,r1,#0x000000CC
	BIC r1,r1,#0x00000F00
    ORR r1,r1,#0x00000A00
	ORR r1,r1,#0x00000088
	STR r1,[r0,#GPIO_PUPDR]
	LTORG
;;;;;;;;;;;;;;;;;;;; end GPIOB ;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;; GPIOC ;;;;;;;;;;;;;;;;;;;;;;;
	;;;; config stepper motor (train doors) and 7 segment display to gpioc ;;;;
    
	; Set GPIOC pins 2, 3, 6, 7 as output pins (bits 4,5,6,7,12,13,14,15) and set GPIOC pins 8, 9, 10, 11 as output pins (01) (bits 16,17,18,19,20,21,22,23)
	LDR r0, = GPIOC_BASE     ; load gpiob
	LDR r1, [r0,#GPIO_MODER] ; load moder
	BIC r1, r1, #0x00FF0000  ; for 7 segment
	BIC r1, r1, #0x0000F000  ; for stepper motor
	BIC r1, r1, #0x000000F0 ; for stepper motor, clear moder for pins 2,3,6,7 to prepare for setting
	ORR r1, r1, #0x00550000 ; for 7 segment, set pins 8, 9, 10, 11 to output
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
	
;;;;;;;;;;;;;;;;;; end GPIOC ;;;;;;;;;;;;;;;;;;;;;;;

	; set 7 segment display to B
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000200
	STR r1, [r0, #GPIO_ODR]
	
	
	; initialize registers to start point
	MOV r4, #0x0000 ; starting train location (station A)
	MOV r5, #0x0600 ; train station destination (station B) (3 rotations)
	MOV r6, #0x0001 ; train direction (right)
	
	
	
	
	
main_loop   
    CMP r4, r5
    BNE check_dir
	;;;; doors sequence ;;;;
	MOV r8, #0
	MOV r9, #0x0096
	BL doors_open
	
	MOV r8, #0
	MOV r9, #0x0096
	BL doors_close
	;;;; end doors ;;;;
	
    ; station A
    CMP r4, #0x0000             ; check if at station A
    MOVEQ r5, #0x0600       	; set destination = B
	BEQ station_a
	
    ; station B
    CMP r4, #0x0600             ; check if at station B
	BEQ b_direction				; if at station B, branch to check direction
	
	; station C
	B station_c					; go to station C check

station_a
	PUSH {LR}

	; set 7 segment display to B (2)
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000200
	STR r1, [r0, #GPIO_ODR]
	LTORG
	
	; display B to tera term
	MOV r0, #66
	MOV r1, #1
	BL USART2_Write
	
	B main_loop

b_direction
	
	; go to station A
    CMP r6, #0x0000           ; check if direction = backward
	BEQ next_station_a			
	BNE next_station_c			; branch to station C code
	
next_station_a

	MOV r5, #0x0000 			; set destination = A
	; set 7 segment display to A (1)
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000100
	STR r1, [r0, #GPIO_ODR]
	
	; display A to tera term
	MOV r0, #65
	MOV r1, #1
	BL USART2_Write
	
	B main_loop

next_station_c

	MOV r5, #0x0C00			; set destination = C
	; set 7 segment display to C (3)
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000300
	STR r1, [r0, #GPIO_ODR]

	; display C to tera term
	MOV r0, #67
	MOV r1, #1
	BL USART2_Write
	
	B main_loop

station_c
    ; station C
    CMP r4, #0x0C00             	; check if at station C
    MOVEQ r5, #0x0600           ; set destination = B

	; set 7 segment display to B (2)
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000200
	STR r1, [r0, #GPIO_ODR]
	
	; display B to tera term
	MOV r0, #66
	MOV r1, #1
	BL USART2_Write
	
    BEQ main_loop               ; exit back to main loop


check_dir
    CMP r4, r5
	BGT dir_backward       ; branch to backward (rotate one cycle backward)
    BLE dir_forward        ; branch to forward (rotate one cycle forward)	
	
	
	
dir_forward    ; if location < destination
	MOV r6, #1        ; change direction to forward
	BL forward
    B main_loop

dir_backward   ; if location > destination
    MOV r6, #0        ; change direction to backward
	BL backward
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
	BL delay_check
	;;;;;;;;;;;;;;;;;;;;;;;;
	
	; step 1
    LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 2
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 3
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 4
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 5
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 6
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 7
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 8
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	
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
	BL delay_check
	; step 2
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000004
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 3
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 4
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000040
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 5
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 6
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000008
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 7
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	; step 8
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000080
	STR r1, [r0, #GPIO_ODR]
	BL delay_check
	
	SUB r4, #1
	
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

delay
    MOV r7, #0x6FF		; 708
delay_loop1
	SUBS r7, #1
    BNE delay_loop1      ; continue loop
    BX LR               ; go back to where you were in the main function

delay_check
	MOV r7, #0x150    ; 0x708
delay_loop2
;;;; check for push button manual override ;;;;
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	
	; clear stepper motor bits
	BIC r1, r1, #0x00000004 ; PB2 LED
	;; check for each case ;;
	; station A manual override (PB1)
	CMP r1, #0x00000002
	BEQ case_A
	
	; station B manual override (PB3)
	CMP r1, #0x00000008
	BEQ case_B
	
	; station C manual override (PB4)
	CMP r1, #0x00000010
	BEQ case_C
	
	; emergency manual override (PB5)
	CMP r1, #0x00000020
	BEQ emergency
	
	SUBS r7, #1
    BNE delay_loop2      ; continue loop
    BX LR               ; go back to where you were in the main function




; case for station A manual override (PB1)
case_A
	PUSH{LR}
	
	MOV r5, #0x0000 ; set destination to station A

	; set 7 segment display to A (1)
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000100
	STR r1, [r0, #GPIO_ODR]
	
	POP{LR}
	BX LR

; case for station B manual override (PB3)
case_B
	PUSH{LR}
	
	MOV r5, #0x0600 ; set destination to station B
	
	; set 7 segment display to B (2)
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000200
	STR r1, [r0, #GPIO_ODR]
	
	POP{LR}
	BX LR
	
; case for station C manual override (PB4)
case_C
	PUSH{LR}
	
	MOV r5, #0x0C00 ; set destination to station C

	; set 7 segment display to C (3)
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x00000F00
	ORR r1, r1, #0x00000300
	STR r1, [r0, #GPIO_ODR]
	
	POP{LR}
	BX LR

; case for emergency override (PB5)
emergency
	PUSH{LR}
	
	;;Turn LED ON FIRST
    LDR r0, =GPIOB_BASE
    LDR r1,[r0,#GPIO_ODR]
    MOV r1, #0x0002
    STR r1,[r0,#GPIO_ODR]
   
    ;;;; doors sequence ;;;;
	MOV r8, #0
	MOV r9, #0x0096
	BL doors_open

loop7
	LDR r0, =GPIOB_BASE
	LDR r2,[r0,#GPIO_IDR]
	CMP r2,#0x00000020
	BEQ loop7
	
	MOV r8, #0
	MOV r9, #0x0096
	BL doors_close
	;;;; end doors ;;;;
	
	
	;;Turn LED OFF
    LDR r0, =GPIOB_BASE
    LDR r1,[r0,#GPIO_ODR]
    MOV r1, #0x0000
    STR r1,[r0,#GPIO_ODR]
	
	POP{LR}
	BX LR
	
	
long_delay
    MOV r7, #0xFFFF
delay_loop3
    SUBS r7, #1
    BNE delay_loop3      ; continue loop
    BX LR               ; go back to where you were in the main function

stop 	B 		stop     		; dead loop & program hangs here

	ENDP
								

	AREA myData, DATA, READWRITE
	ALIGN

	END
