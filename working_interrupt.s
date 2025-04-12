
;;Just keeping the interrupt code here while I figure out how to write it
;;Registers to avoid : 7,6,3,2
;;r5 is going to be the interrupt, this will set the destination with the 3 buttons
;;Starting in A rotate B rotate C rotate B rotate A ....
;;values are updated within the interrupts as of 4/11

;;Interrupt for Station A
;;Plan on using PB1(input) for A interrupt
EXTI1_IRQHandler 

 PUSH{R2,R3,R6,R7,LR}

    ;;Set R5 to Destination A

    MOV R5, #0x0000 ; 0x0000 is the starting location

 POP{R2,R3,R6,R7,LR}

 BX LR

 ;;Interrupt for Station B
 ;;Plan on using PB3(input) for B interrupt
EXTI3_IRQHandler:

 PUSH{R2,R3,R6,R7,LR}

   ;;Set R5 to Destination B

   MOV R5, #0x0600

 POP{R2,R3,R6,R7,LR}

 BX LR

 ;;Interrupt for Station C
 ;;Plan on using PB4(input) for C interrupt
EXTI4_IRQHandler:

 PUSH{R2,R3,R6,R7,LR}
    
    ;;Set R5 to Destination C 
    
    MOV R5, #0x0C00

 POP{R2,R3,R6,R7,LR}

 BX LR
    
;;Interrupt for the emergency stop 
;;Plan on using PB5(input) for Emergency Interrupt
EXTI5_IRQHandler:

 PUSH{R2,R3,R6,R7,LR}

    ;;Turn LED ON FIRST
    LDR r0, =GPIOB_BASE
    LDR r10,[r0,#GPIO_ODR]
    MOV r10, #1
    STR r10,[r0,#GPIO_ODR]
   
    ;;THEN OPEN DOORS
    BL doors_open ;;this will branch to doors open 
    ;;evan has sequence to close the doors
    BL doors_close

 POP{R2,R3,R6,R7,LR}

 BX LR
