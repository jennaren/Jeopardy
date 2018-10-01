#timer counts down 15 seconds 
#period is 500M which 08f0 d180
.equ TIMER, 0xFF202000
.equ time15, 0x3B9ACA00
.equ time30, 0xB2D05E00
.equ LEDS, 0xFF200000
.equ PS2KEYBOARD, 0xFF200100 				# controller 1

.equ a, 0x1C 								# the letter "a"
.equ l, 0x4B								# the letter "l"
.equ one, 0x16								# the number "1"
.equ two, 0x1E								# the number "2"
.equ three, 0x26							# the number "3"

.section .data 
.global QuestionNumber

QuestionNumber:
	.byte -1
	
ANSWERS:
	.byte 1
	.byte 2
	.byte 1
	.byte 2
	.byte 2
	.byte 1
	.byte 1
	.byte 2
	.byte 3
	.byte 1

PS2Interrupts:
	.byte 0

Player1Score:
	.byte 0

Player2Score:
	.byte 0

State:
	.byte 0

.section .text
.global _start

_start:
	movia r8, PS2KEYBOARD
	stwio r0, 0(r8)
	movia r8, LEDS
	stwio r9, 0(r8)
	movia sp, 0x03fffff0
	
	movi r8, 1
	wrctl ctl0, r8						# enable all interrupts
	movi r8, 0b10000000
	wrctl ctl3, r8						# enable interrupts for IQR 7

	movia r8, PS2KEYBOARD				# enable read interrupt for PS2
	movi r9, 0b1
	stwio r9, 4(r8) 	
	#call VGAStart						#initial load page	 

loadAnswer:
	movia r8, QuestionNumber			# get the question number
	ldb r9, 0(r8)
	addi r9, r9, 1						# move on to the next question
	stb r9, 0(r8)
	movia r20, ANSWERS					# DONT TOUCH R20 THIS IS THE REGISTER THAT STORES ALL TEH ANSWERS !!!!
	add r20, r20, r9					# shifts it to the right answer for specified question
	ldb r20, 0(r20)
	
# this is the time that the two players get to press the button. There are 15 seconds to be the first person to press their respective key for the
# chance to answer the question but the quicker they press their button the less time they have to answer the question
timer15:
	call VGAStart
	movia r16, PS2Interrupts			# reset the state for interrupts to 0
	stb r0, 0(r16)	
	
	movia r8, TIMER 					# initial loading address into r8 and setting the cycle to 15 seconds
	movui r9, %lo(time15)					
	stwio r9, 8(r8)						
	movui r9, %hi(time15)					
	stwio r9, 12(r8)					
	
	stwio 		r0, (r8)				# Start the timer for 15 seconds
	movi 		r9, 0b0100
	stwio		r9, 4(r8)				

poll15:
	ldwio		r9, (r8) 				#polling for 15 seconds
	andi 		r9, r9, 1
	beq 		r9, r0, poll15
	
	movia r8, LEDS
	movi r9, 0b1000000000
	br loadAnswer
	 
# this is the time that the player has to answer the question. If they do not answer the question in time, it will move on to the next question	
timer30:
	movia r16, PS2Interrupts			# reset the state for interrupts to 0
	stb r0, 0(r16)	
	
	movia r8, TIMER 					# initial loading address into r8 and setting the cycle to 30 seconds
	movui r9, %lo(time30) 				
	stwio r9, 8(r8)						
	movui r9, %hi(time30)					
	stwio r9, 12(r8)					

	stwio 		r0, (r8)				# Start the timer for 30 seconds
	movi 		r9, 0b0100
	stwio		r9, 4(r8)	

poll30:
	ldwio		r9, (r8) 				# polling for 30 seconds
	andi 		r9, r9, 1
	beq 		r9, r0, poll30	
	
	br loadAnswer							# goes back to the questionnaire stage

loop: 

	br loop

# r16 stores player 1's score
# r17 stores player 2's score
# r18 stores the answer that the user inputted (1, 2, 3)
# et stores the keyboard code
# r19 byte 0 stores player 1's turn state, byte 1 stores player 2's turn state
# r20 stores the correct answer

.section .exceptions, "ax"
	subi sp, sp, 16							#store everything
	stw r16, 12(sp) 					
	stw r17, 8(sp)					
	stw r19, 4(sp)					
	stw r20, 0(sp)


	movia r16, Player1Score					#for vermin infestation purposes
	ldb r16, 0(r16)
	movia r17, Player2Score
	ldb r17, 0(r17)
	movia r18, PS2Interrupts
	ldb r18, 0(r18)

	rdctl et, ctl4 							#load IQR into et
	andi et, et, 0b10000000 				#check if it's IQR 7
	beq et, r0, interruptReturnIgnore				#return if is not

	movia et, PS2KEYBOARD					#load the content of PS2 interrupt into et
	ldwio et, 0(et)							#reads the data !!
	andi et, et, 0xFF						#get the last 8 bits

	movia r23, LEDS							#moves the address of LEDS in r23
	stwio r0, 0(r23)

	movi r22, a								#checks if the input is "a"
	beq et, r22, player1turn

	movi r22, l								#checks if the input is "l"
	beq et, r22, player2turn

	movi r22, one							#checks if the input is "1"
	beq et, r22, isOne

	movi r22, two							#checks if the input is "2"
	beq et, r22, isTwo

	movi r22, three							#checks if the input is "3"
	beq et, r22, isThree

	br interruptReturnIgnore

isOne:
	movia r16, PS2Interrupts			#checks to see if the input has already been taken in
	ldb r17, 0(r16)
    
    movi r21, 0b100 					#DEBUGGING
	stwio r21, 0(r23)					#DEBUGGING
    
	bne r0, r17, interruptReturnIgnore
	
	movi r17, 1							#changes status bit to 1
	stb r17, 0(r16)					
	
	movi r18, 1
	br checkForPlayer
	
isTwo:
	movia r16, PS2Interrupts			#checks to see if the input has already been taken in
	ldb r17, 0(r16)
	
    movi r21, 0b1000 					#DEBUGGING
	stwio r21, 0(r23)					#DEBUGGING

	bne r0, r17, interruptReturnIgnore
		
	movi r17, 1							#changes status bit to 1
	stb r17, 0(r16)					

	movi r18, 2
	br checkForPlayer
	
isThree:
	movia r16, PS2Interrupts			#checks to see if the input has already been taken in
	ldb r17, 0(r16)
    
    movi r21, 0b10000 					#DEBUGGING
	stwio r21, 0(r23)					#DEBUGGING
    
	bne r0, r17, interruptReturnIgnore
	
	movi r17, 1							#changes status bit to 1
	stb r17, 0(r16)					
	
	movi r18, 3
	br checkForPlayer
	
player1turn:
	movia r16, PS2Interrupts			#checks to see if the input has already been taken in
	ldb r17, 0(r16)

	movi r21, 1 						#DEBUGGING
	stwio r21, 0(r23)					#DEBUGGING

	bne r0, r17, interruptReturnIgnore
	
	movi r17, 1							#changes status bit to 1
	stb r17, 0(r16)					
	
	movia r19, State					#changes the state to P1 turn for next round
	movi r17, 1
	stbio r17, 0(r19)
	
	br interruptReturnToTimer30			#starts the second timer

player2turn:
	movia r16, PS2Interrupts			#checks to see if the input has already been taken in
	ldb r17, 0(r16)
    
    movi r21, 0b10 						#DEBUGGING
	stwio r21, 0(r23)					#DEBUGGING
    
	bne r0, r17, interruptReturnIgnore
	
	movi r17, 1							#changes status bit to 1
	stb r17, 0(r16)					
	
	movia r19, State					#changes the state to P1 turn for next round
	movi r17, 0b10
	stbio r17, 0(r19)
	ldb r19, 0(r19) 					#debug
	
	br interruptReturnToTimer30			#starts the second timer

checkForPlayer:
	movia r19, State
	ldb r19, 0(r19)
	movi r22, 1 						
	andi r19, r19, 1	 				#gets the 0th bit of r19
	beq r19, r22, player1guess			#if 0th bit is 1, it is player 1's turn
	
	movia r19, State
	ldb r19, 0(r19)
	movi r22, 0b10 						
	andi r19, r19, 0b10 				#retrieves bit1 of r19
	beq r19, r22, player2guess 			#if 1st bit is 1, it is player 2's turn
	
player1guess:
	movia r19, State					#reset State back to 00 for next round
	stb r0, 0(r19)
	beq r18, r20, player1correct		#if the player is correct
	br player1Incorrect					#if the player is incorrect

player2guess:
	movia r19, State					#reset State back to 00 for next round
	stb r0, 0(r19)
	beq r18, r20, player2correct	

br interruptReturnIgnore					

# adds or subtracts a point if they player is right
player1correct:
	movia r16, Player1Score				#moves in the address of Player 1 Score
	ldb r17, 0(r16)						#load that value into r17
	addi r17, r17, 1					#add one to that score	
	stb r17, 0(r16)						#store it back into that address
	call audioYAY						#calls the audio file
	br interruptReturnToStart

player2correct:							#if player 2 is correct
	movia r16, Player2Score				
	ldb r17, 0(r16)
	addi r17, r17, 1
	stb r17, 0(r16)
	call audioYAY						#calls the audio file
	br interruptReturnToStart
	
player1Incorrect:
	movia r16, Player1Score				#if player 1 is wrong
	ldb r17, 0(r16)
	subi r17, r17, 1
	stb r17, 0(r16)
	call audioNAY						#calls the audio file
	br interruptReturnToStart
	
player2Incorrect:
	movia r16, Player2Score				#if player 2 is wrong 
	ldb r17, 0(r16)
	subi r17, r17, 1
	stb r17, 0(r16)
	call audioNAY						#calls the audio file
	br interruptReturnToStart
	
interruptReturnToStart:
	ldw r16, 12(sp) 					#resets the registers to the values they were at before the interrupt				
	ldw r17, 8(sp)					
	ldw r19, 4(sp)					
	ldw r20, 0(sp)

	addi sp, sp, 16
	movia ea, loadAnswer				#starts at the beginning
	eret
	
interruptReturnToTimer30:
	ldw r16, 12(sp) 					#resets the registers to the values they were at before the interrupt				
	ldw r17, 8(sp)					
	ldw r19, 4(sp)					
	ldw r20, 0(sp)

	addi sp, sp, 16
	movia ea, timer30
	eret
	
interruptReturnIgnore:
	ldw r16, 12(sp) 					#resets the registers to the values they were at before the interrupt
	ldw r17, 8(sp)					
	ldw r19, 4(sp)					
	ldw r20, 0(sp)
	
	addi sp, sp, 16
	subi ea, ea, 4
	eret
