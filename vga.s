.equ WHITE, 0xFFFF
.equ vgaAdress, 0x08000000

.data
.align 2
Question0:
	.incbin "1.bmp"
Question1:
	.incbin "2.bmp"
Question2:
	.incbin "3.bmp"
Question3:
	.incbin "4.bmp"
Question4:
	.incbin "5.bmp"
Question5:
	.incbin "6.bmp"
Question6:
	.incbin "7.bmp"
Question7:	
	.incbin "8.bmp"
Question8:	
	.incbin "9.bmp"
Question9:
	.incbin "10.bmp"

numbers:
	.byte 0
	.byte 1
	.byte 2
	.byte 3
	.byte 4
	.byte 5
	.byte 6
	.byte 7
	.byte 8
	.byte 9
	#.byte -1

.section .text
.global VGAStart

VGAStart:
	movia r8, vgaAdress
	movia r15, numbers
	movia r16, QuestionNumber
	ldb r16, 0(r15)
	ldb r15, 0(r16)
	beq r16, r15, question0
	ldb r15, 1(r15)
	beq r16, r15, question1
	ldb r15, 2(r15)
	beq r16, r15, question2
	ldb r15, 3(r15)
	beq r16, r15, question3
	ldb r15, 4(r15)
	beq r16, r15, question4
	ldb r15, 5(r15)
	beq r16, r15, question5
	ldb r15, 6(r15)
	beq r16, r15, question6
	ldb r15, 7(r15)
	beq r16, r15, question7
	ldb r15, 8(r15)
	beq r16, r15, question8
	ldb r15, 9(r15)
	beq r16, r15, question9


loadImage:
	addi r4, r4, 70
	movui r5, 240	#y pos
	movui r6, 320	#x pos 
	mov r7 , r4 
	mov r10, r0 #x val
	mov r11,r0 #initial y

forLoop:	
	ldh r9, (r7) #load the half word out of memory (pixel value)		
	muli r12, r11, 1024 #1024y
	muli r13, r10, 2 #2x
	add r12, r12, r13 #r12 = 2x + 1024y
	add r14, r12, r8 #find pixel to write to (start address + offset)
	sthio r9, 0(r14) #store the picture pixel into vga
			
	addi r7, r7, 2 #go to the next picture hword
	addi r10, r10, 1 #increment x
	blt r10, r6, forLoop
			
	mov r10, r0
	addi r11,r11, 1
	blt r11,r5, forLoop

LOOP:
	ret	

question0:
	movia r4, Question0	#r4 pointer to image
	br loadImage

question1:
	movia r4, Question1	#r4 pointer to image
	br loadImage

question2:
	movia r4, Question2	#r4 pointer to image
	br loadImage

question3:
	movia r4, Question3	#r4 pointer to image
	br loadImage

question4:
	movia r4, Question4	#r4 pointer to image
	br loadImage

question5:
	movia r4, Question5	#r4 pointer to image
	br loadImage

question6:
	movia r4, Question6	#r4 pointer to image
	br loadImage

question7:
	movia r4, Question7	#r4 pointer to image
	br loadImage

question8:
	movia r4, Question8	#r4 pointer to image
	br loadImage

question9:
	movia r4, Question9	#r4 pointer to image
	br loadImage
