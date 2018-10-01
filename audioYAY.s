.equ count, 163628
.global yay
yay:
    .incbin "yay.wav"
hi: 
    .skip 4
.equ audioAddress, 0xff203040	# Audio device base address: DE1-SoC

.global audioYAY

audioYAY:
    movia r6, audioAddress
	movia r22, hi
    movia r8, count
    movia r4, yay #pointer to yay list
	mov r11, r8

WaitForWriteSpace:
    ldwio r2, 4(r6)
    andhi r3, r2, 0xff00
    beq r3, r0, WaitForWriteSpace
    andhi r3, r2, 0xff
    beq r3, r0, WaitForWriteSpace

	ldw r5, 0(r4)
	#beq r5, r0, WaitForWriteSpace
    stwio r5, 8(r6)	#left channel
    stwio r5, 12(r6) #right channel
    addi r4, r4, 4 #pointer to next sample
    addi r11, r11, -1
    bne r11, r0, WaitForWriteSpace
 

	
exit:
	ret


    # 	mov r11, r8
    #   movia r4, yay
    #  br WaitForWriteSpace



