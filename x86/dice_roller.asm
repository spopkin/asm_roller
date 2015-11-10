;-------------------------------------------------------------------------------
;	file: dice_roller.asm
;
;	author: spopkin
;
;	Prints random numbers for each dice roll, as well as the total sum of
;	the dice rolls.
;
;	build:
;	nasm -f elf dice_roller.asm
;	ld -s -o dice_roller dice_roller.o
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Global things
;-------------------------------------------------------------------------------
bits 32
min_args equ 3
max_args equ 3
exit_succ equ 0
exit_fail equ 1
stdin equ 0
stdout equ 1
stderr equ 2
exitcmd equ 1
writecmd equ 4
intSize equ 10
;-------------------------------------------------------------------------------
segment .data
;-------------------------------------------------------------------------------
usage0		db	"Usage: "	; The beginning of the usage string.
usage0len 	equ 	($-usage0)	; Its length.

; More parts of the usage string and their lengths
usage1		db	" <Number of Dice> <Number of Sides>",0Ah
usage1len 	equ 	($-usage1)	; Its length.

; The allocation for the number of dice to roll
nDice		dd	0		

; The allocation for the number of sides per die
nSides		dd	0	

invalidInts	db	"Invalid number of sides/dice",0Ah
iilen	 	equ 	($-invalidInts)	; Its length.

diceNumSelect	db	"You have selected to roll "
dnumsellen 	equ 	($-diceNumSelect)

diceMid		db	" x D"
dmidlen 	equ 	($-diceMid)	

diceEnd		db	" dice.",0Ah
dEndLen 	equ 	($-diceEnd)	

rollStart	db	"Roll "
rollStartLen 	equ 	($-rollStart)	

intBuffer	times	(intSize+1)	db	"0"

base		dd	10		; the numeric base we are working in,
; currently this is constrained to 10, but maybe someday i'll mess with this.

doE		db	0Ah,0Ah,"Number of Sides/dice was" 
		db	"too big, was zero, or was empty.",0Ah,0Ah
doELen		equ	($-doE)

;-------------------------------------------------------------------------------
segment .text 
global _start
;-------------------------------------------------------------------------------
_start:
					; Attempt to get argc, argv.
	pop eax				; Check the number of arguments.
	cmp eax,min_args		; Later replace this with min and max
	jne bad_args			; comparisons.

; Ready to do things now.
	pop ebx				; Throw away the file name.

; here we prepare to write parts of the dice string
	mov ecx,diceNumSelect		; Prepare to write the string about dice
	mov edx,dnumsellen		; length ready
	call writeValid

; Parse the number of dice	
	pop ebx				; Get String numDice.
	mov edi,nDice			; Target numDice as opposed to nSides.
	call parseInt			; Turn that into an Int.

; Prepare to write the number of dice we just parsed	

;call intToString			; reset what we plan to write
;	mov ecx,ebx
;	mov edx,ecx

	mov ecx,ebx			; prepare to write whatever our input number was
	mov edx,esi			; prepare to write	
	call writeValid			; write valid number


; Write the middle part of the string.
	mov ecx,diceMid			; prepare to write the middle of the string
	mov edx,dmidlen			; including its length
	call writeValid	

; Now, we will need the number of sides per die
	pop ebx				; get the second argument
	mov edi,nSides			; target number of sides
	call parseInt			; parse the number of sides

; Write that new number
;	mov ecx,ebx
;	mov edx,esi			; prepare to write	
;	call writeValid			; write valid number

	mov eax,[nSides]		; Prepare to convert nSides to a string
	call intToString		; Do the conversion.
	mov edx,ecx			; Set the new string length 
	mov ecx,eax			; Set the new string as what to write
	call writeValid			; Write the new string.
	

; Prepare to write the end of the dice string
	mov ecx,diceEnd			; get what to write
	mov edx,dEndLen			; get the length
	call writeValid

mov ebx,[nSides]

; Prepare to do rolls
	

; Exit success
exit:
	mov eax,exitcmd			; Prepare to exit 0
;	mov ebx,exit_succ
	int 80h

;-------------------------------------------------------------------------------
; Exit failures
;-------------------------------------------------------------------------------
; Bad number of command line arguments
bad_args:
	mov ecx,usage0			; Prepare to print the first part of 
	mov edx,usage0len		; the usage string.
	call writeErr
	pop ecx
	mov edx,0

; Prepare to print the file name
loop_ba0:
	inc edx				; The length is one greater.
	cmp byte [ecx + edx-1],0	; Check if not null.
	jne loop_ba0
	dec edx				; handle the preincrement fencepost
	call writeErr
					; Now, print the rest of that string
	mov ecx,usage1
	mov edx,usage1len
	call writeErr

quit:
	mov eax,exitcmd			; Prepare to exit 1
	mov ebx,exit_fail		
	int 80h

; dice too big/small to be supported, or were ""
dice_overflow:
	mov ecx,doE			; prepare to write that there was a problem
	mov edx,doELen			; how long the error message was
	call writeErr			; write that there was a problem

; Bad number of sides/dice
bad_ints:
	mov ecx,invalidInts		; Set what to write
	mov edx,iilen			; Set length to write
	call writeErr	
	jmp quit

;-------------------------------------------------------------------------------
; Helper Functions
;-------------------------------------------------------------------------------
; writeErr: prints whatever is pointed by ecx out to length edx
; params:
;	ecx - the string to write's pointer
;	edx - the length to write
writeErr:
	mov eax,writecmd	
	mov ebx,stderr
	int 80h
	ret

; writeValid: prints whatever is pointed by ecx out to length edx
; params:
;	ecx - the string to write's pointer
;	edx - the length to write
writeValid:
	mov eax,writecmd	
	mov ebx,stdout
	int 80h
	ret

; parseInt: attempts to take a string and produce an integer.
; Due to pains regarding not wiping the wrong registers, it will behave 
; somewhat like a C function, in that it will push and restore registers.
; params:
;	ebx - the string pointer to convert
;	edi - what to put it into
; outputs:
;	[edi] - the integer produced
;	esi - the length of the string (so we can print it later)
parseInt:
	push eax			; preserve eax, as we will use it
	mov eax,0			; set it to 0
	push ecx			; preserve ecx
	push edx			; preserve edx
	mov esi,0			; strlen starts at 0
	mov ecx,0			; avoid leftovers contaminating current char
loop_pa0:
	mov cl,[ebx+esi]		; get the current character
	
	cmp cl,0			; if null, break
	je break_pa0			
	sub cl,"0"			; else if too low, bad int, also shift it to value
	jl bad_ints			
	cmp cl,9			; else if too high, bad int
	jg bad_ints			
	inc esi				; good enough, look at the next one.	

	mov edx,[base]
	mul edx				; shift our current number left one digit
	add eax,ecx			; add the new digit to the number	
	
	jmp loop_pa0			; loop back around	

break_pa0:
; verify that the number of bytes used did not exceed the memory space allotted for dice
	cmp esi,intSize			; compare for this
	jg dice_overflow		; if fails, then print error	
	cmp eax,0			; if zero, then bad
	je dice_overflow		; if fails, then print error	
	mov [edi],eax			; store our int

; prepare to return to the previous function
	pop edx				; retrieve edx
	pop ecx				; retrieve ecx's original value
	pop eax				; retrieve eax's original value
	ret	

; intToString: takes an integer in eax and converts it into a string of up to intSize bytes.
; Params: 
;	eax - the int to convert
; Returns:
;	eax - a string pointer to what to print out
;	ecx - the length of the string to print out
intToString:

;	mov ebx,eax
;	jmp exit
	mov ecx,intSize-1		; so we can count down the size of the string
	mov ebx,intBuffer		; the front of the string
lopits:
	mov edx,0
	div dword [base]	
	add dl,"0"
	mov [ebx+ecx],dl
	cmp eax,0
	je breakits
	cmp ecx,0
	je breakits
	dec ecx
	jmp lopits


breakits:
;	mov eax,ecx			; put the string offset in eax
;	add eax,ebx			; now eax should be the front of the string
;	sub ecx,intBuffer		; put the length - intsize - length into ecx 
;	neg ecx				; now ecx should be the string length
;stub return fixes
	mov eax,intBuffer
	mov ecx,intSize
	ret






	mov ebx,intBuffer		; point at the appropriate pointer
	mov ecx,intSize-1		; make sure that we have the appropriate value to add
;lopits:					; loop to here 
	mov edx,0			; avoid corrupting our selected char each iteration
	div dword [base]		; get current char, and get the rest of the number
	add dl,"0"			; convert the current char to be printable
	mov [ebx+ecx],dl		; put it into our string
	cmp eax,0			; if eax is 0, then break, else continue
	je breakits			
	cmp ecx,0			; if we have just written to the front of the string
	je breakits			; then that's it for the loop.
	dec ecx				; decrement where in the string we need to update
;breakits:
	mov eax,ecx			; put the front of the string into eax
	sub ecx,intBuffer		; put the length - intsize - length into ecx 
	neg ecx				; now ecx should be the string length

	ret
