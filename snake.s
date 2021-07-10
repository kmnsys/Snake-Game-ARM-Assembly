Stack_Size		EQU		0x400;

				AREA	STACK, NOINIT,	READWRITE,	ALIGN=3
Stack_Mem		SPACE	Stack_Size
__initial_sp	
			
				AREA	RESET, DATA, READONLY
				EXPORT  __Vectors
				EXPORT	__Vectors_End

__Vectors		DCD		__initial_sp			; Top of Stack
				DCD		Reset_Handler			; Reset Handler
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		0
				DCD		Button_Handler

__Vectors_End

				AREA	|.text|, CODE, READONLY
Reset_Handler	PROC
				EXPORT 	Reset_Handler
				ldr		r0, =0xE000E100				; NVIC Enable 0
				movs	r1, #1
				str		r1, [r0]
				CPSIE	i
				ldr		r0, =__main
				bx		r0
				ENDP
					
				
				AREA	button, CODE, READONLY
Button_Handler	PROC
				EXPORT	Button_Handler
				push	{r3, r4, r5, r1}
				ldr		r1,=0x40010010			; address of button register
				ldr		r3,	[r1]				; loading button info
				movs	r5, #0xFF				
				ands	r3, r3, r5				; getting actual button info
				ldr		r4, [r0, #0x4]			; current direction to check opposite direction
				cmp		r3, #0x80				; right button
				beq		rightb
				cmp		r3, #0x10				; up button
				beq		upb
				cmp		r3, #0x40				; left button
				beq		leftb
				cmp		r3, #0x20				; down button
				beq		downb
				str		r3, [r1]
				pop		{r3, r4, r5, r1}
				bx		lr
				
rightb			cmp		r4, #3					; checking if pressed button points opposite direction
				beq		return					; if so do nothing and return
				movs	r5, #1					; else change direction 
				str		r5, [r0, #0x4]			; and store new direction
				str		r3, [r1]
				pop		{r3, r4, r5, r1}
				bx		lr
upb				cmp		r4, #4
				beq		return
				movs	r5, #2					; dir 2
				str		r5, [r0, #0x4]			; store new dir
				str		r3, [r1]
				pop		{r3, r4, r5, r1}
				bx		lr
leftb			cmp		r4, #1
				beq		return
				movs	r5, #3					; dir 3
				str		r5, [r0, #0x4]			; store new dir
				str		r3, [r1]
				pop		{r3, r4, r5, r1}
				bx		lr
downb			cmp		r4, #2
				beq		return
				movs	r5, #4					; dir 4
				str		r5, [r0, #0x4]			; store new dir
				str		r3, [r1]
				pop		{r3, r4, r5, r1}
				bx		lr
return			str		r3, [r1]
				pop		{r3, r4, r5, r1}
				bx		lr
				ENDP
						
						
						
						
				AREA	main, CODE, READONLY
				EXPORT __main
				ENTRY	
__main			PROC
	
loadRam			ldr		r0,	=0x20000000			; ram address
				ldr		r1, =0x40010000			; lcd adderess
				ldr		r2, =0x2000001C			; pointer for food and tail
				ldr		r3, =0xFFFFFF00			; color
				str		r3, [r0]				; store color in xx0 address
				movs	r3, #1					; initial direction
				str		r3, [r0, #0x4]			; storing inital direction in x4 address
				
				; **Initial snake locations store starts
				movs	r3, #100				
				strh	r3, [r0, #8]
				movs	r3, #150				
				strh	r3, [r0, #10]
				
				movs	r3, #100				
				strh	r3, [r0, #12]
				movs	r3, #140				
				strh	r3, [r0, #14]
				
				movs	r3, #100				
				strh	r3, [r0, #16]
				movs	r3, #130				
				strh	r3, [r0, #18]
				
				movs	r3, #100				
				strh	r3, [r0, #20]
				movs	r3, #120				
				strh	r3, [r0, #22]
				
				movs	r3, #100				
				strh	r3, [r0, #24]
				movs	r3, #110				
				strh	r3, [r0, #26]
				; **Initial snake locations store ends
				
				; Food location is added next to tail
				movs	r3, #100				
				strh	r3, [r2]
				movs	r3, #250				
				strh	r3, [r2, #2]

	
drawSnake		ldr		r6, =0x20000008			; address of head of snake
draw			ldrh	r4, [r6]				; loading row
				ldrh	r5, [r6, #2]			; loading column
rnr				str		r4, [r1]				; storing row in lcd
rnc				str		r5, [r1, #0x4]			; storing col in lcd
				ldr		r3, [r0]				; loading color
				str		r3, [r1, #0x8]			; storing color in lcd
				adds	r5, r5, #1				; increment col
				ldrh	r3, [r6, #2]			; load col
				adds	r3, r3, #8				; add 8 
				cmp		r5, r3					; and check if one row is drawn
				bne		rnc			
				ldrh	r3, [r6, #2]			; reset column for next row 
				movs	r5, r3
				adds	r4, r4, #1				; increment row
				ldrh	r3, [r6]				; load row
				adds	r3, r3, #8				; add 8
				cmp		r4, r3					; and check if a piece is drawn
				bne 	rnr
				adds	r6, #4					; next piece of snake 
				cmp		r6, r2					; check if all parts of snake is drawn 
				bne		draw
				;movs	r3, #1
				;str		r3, [r1, #0xc]			; refresh
				;movs	r5, #2
				;str		r5, [r1, #0xc]			; clear
				b		drawFood
	
	
				; Same drawing starts for food but only for one piece 
drawFood		ldrh	r4, [r2]
				ldrh	r5, [r2, #2]
fnr				str		r4, [r1]			
fnc				str		r5, [r1, #0x4]
				ldr		r3, =0xFFFFFFFF
				str		r3, [r1, #0x8]				
				adds	r5, r5, #1				; prev col
				ldrh	r3, [r6, #2]
				adds	r3, r3, #8
				cmp		r5, r3					; is col done 
				bne		fnc				
				ldrh	r3, [r6, #2]
				movs	r5, r3
				adds	r4, r4, #1
				ldrh	r3, [r6]
				adds	r3, r3, #8
				cmp		r4, r3
				bne 	fnr	
				
				; End drawing food
				
				movs	r3, #1
				str		r3, [r1, #0xc]			; refresh screen
				movs	r5, #2
				str		r5, [r1, #0xc]			; clear screen
				ldr		r4, [r0, #0x8]			; head of snake to check if it cross itself
				ldr		r5, = 0x2000000c		; pointer for other parts of snake to check if it cross itself
				b		isGameOver




isGameOver		ldr		r3, [r5]				; load location info of a part of snake
				cmp		r4,	 r3					; check if it cross itself
				beq		gameOver				
				adds	r5, r5, #0x4			
				cmp		r5, r2					;check if snake check completed
				beq		delay
				b		isGameOver

gameOver		b		loadRam					; Game is over restart game
	
	
delay			ldr		r3, =150000				; delay block to slow down snake
delayCont		subs	r3, #1
				cmp		r3, #0
				beq		initList
				b		delayCont




				; Updating snake by shifting list to the right  
initList		movs	r3, r2					; pointer for end of tail
				movs	r4, r2					; pointer for one element before end of tail
				subs	r3, r3, #4				; destination 
				subs	r4, r4, #8				; source
				ldr		r7, [r3]				; saving tail location for later if snake eats food
list			adds	r5, r0, #4				; if shifting is done go to newDirection 
				cmp		r4, r5
				beq		newDirection
				ldr		r5, [r4]				; shift next element
				str		r5, [r3]				; to left
				subs	r3, r3, #4				; update destination
				subs	r4, r4, #4				; update source
				b		list
		
		
		
				; Determine direction and go to corresponsing label to update head
newDirection	ldr		r3, [r0, #0x4]			; current(head) dir
				cmp		r3, #1					
				beq		newRight
				cmp		r3, #2
				beq		newUp
				cmp		r3, #3
				beq		newLeft
				cmp		r3, #4
				beq		newDown
				b		stop
	

newRight		ldrh	r3, [r0, #0xA]			; column of head
				ldr		r4, =310				; end of screen
				cmp		r3, r4					; if snake reached end of screen keep snake inside
				bge		getInRight
				adds	r3, r3, #10				; update column
				strh	r3, [r0, #0xA]			; store new column
				b		checkFood
getInRight		movs	r3, #0					; new column
				strh	r3, [r0, #0xA]			; store new column
				b		checkFood		
					
				
				; Same operations are done for other directions
newUp			movs	r4, #0x8
				ldrsh	r3, [r0, r4]
				cmp		r3, #0
				ble		getInUp
				subs	r3, r3, #10
				strh	r3, [r0, #0x8]
				b		checkFood
getInUp			movs	r3, #230
				strh	r3, [r0, #0x8]
				b		checkFood
				
				
newLeft			movs	r4, #0xA
				ldrsh	r3, [r0, r4]
				cmp		r3, #0
				ble		getInLeft
				subs	r3, r3, #10
				strh	r3, [r0, #0xA]
				b		checkFood
getInLeft		ldr		r3, =310
				strh	r3, [r0, #0xA]
				b		checkFood
				
				
newDown			ldrh	r3, [r0, #0x8]
				cmp		r3, #230
				bge		getInDown
				adds	r3, r3, #10
				strh	r3, [r0, #0x8]
				b		checkFood
getInDown		movs	r3, #0
				strh	r3, [r0, #0x8]
				b		checkFood



				; Checking if snake eat food
checkFood		ldr		r3, [r0, #0x8]			; get head location info
				ldr		r4, [r2]				; get food location info
				cmp		r3, r4					; check if they are equal
				bne		drawSnake				; if not do nothing and draw snake
				ldrh	r3, [r2]				; get food row info	to update
				ldrh	r4, [r2, #0x2]			; get food col info to update
				str		r7, [r2]				; add tail of snake 
				adds	r2, r2, #0x4			; update food pointer
				ldr		r6, =0x20000008
				movs	r3, #0					; a register for keeping sum of rows of snake  
				movs	r4, #0					; a register for keeping sum of columns of snake  
				b		random

random			ldrh	r5, [r6]				; starting to sum up rows   
				adds	r3, r3, r5				; and columns of current snake
				ldrh	r5, [r6, #0x2]			; to be used in generating new random food 
				adds	r4, r4, r5
				adds	r6, #0x4
				cmp		r6, r2					; if snake list travel is done go to modRow				
				bne		random					
				ldr		r5, = 7					; multiplying row and col with 7
				muls	r3, r5, r3
				adds	r3, r3, #13				; adding to row and col 13
				muls	r4, r5, r4
				adds	r4, r4, #13
				b		modRow
				
modRow			cmp		r3, #23      			; row number modular with 24
				blt		modCol
				subs	r3, r3, #23
				b		modRow
				
modCol			cmp		r4, #31					; col number modular with 32
				blt		storeNewFood
				subs	r4, r4, #31
				b		modCol

storeNewFood	movs	r5, #10					; multiply moded row and col with 10
				muls	r3, r5, r3
				muls	r4, r5, r4
				strh	r3, [r2]				; store new row
				strh	r4, [r2, #0x2]			; store new col
				b		drawSnake	
				
stop			b		stop
				ENDP
				END

		


		