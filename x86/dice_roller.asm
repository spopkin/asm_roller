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
o_rdonly equ 0				; see /usr/include/asm-generic/fcntl.h
;-------------------------------------------------------------------------------
segment .data
;-------------------------------------------------------------------------------
usage0		db	"Usage: "	; The beginning of the usage string.
usage0len 	equ 	($-usage0)	; Its length.

; More parts of the usage string and their lengths
usage1		db	" <Number of Dice> <Number of Sides>",0Ah
usage1len 	equ 	($-usage1)	; Its length.

; Dice values and sum value.
total		dd	0		; The total value of all rolls so far.
nDice		dd	0		; The number of dice to roll.
nSides		dd	0		; The number of sides on each die.

; Warning messages for inputs.
invalidInts	db	"Invalid number of sides/dice",0Ah
iilen	 	equ 	($-invalidInts)	
doE		db	0Ah,0Ah,"Number of Sides/dice was" 
		db	"too big, was zero, or was empty.",0Ah,0Ah
doELen		equ	($-doE)

; The output string components for selected number of sides and dice. 
diceNumSelect	db	"You have selected to roll "
dnumsellen 	equ 	($-diceNumSelect)
diceMid		db	" x D"
dmidlen 	equ 	($-diceMid)	
diceEnd		db	" dice.",0Ah
dEndLen 	equ 	($-diceEnd)	

rollStart	db	"Roll "		; Print out at the start of each roll
rollStartLen 	equ 	($-rollStart)	; The length of that.
rollMid		db	": "		; Separate the roll number from value
rollMidLen	equ	($-rollMid)	; The length of that
rollNumber	dd	0		; What number roll is currently in play.

lineTerm	db	0Ah		; Good for printing out newlines.

intBuffer	times	(intSize+1)	db	"0"

randFile	db	"/dev/urandom",0	; Where our randomness is.


base		dd	10		; the numeric base we are working in,
; currently this is constrained to 10, but maybe someday i'll mess with this.
; I allocated this so I could divide directly from memory.
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
	call writeValid			; Write the beginning of dice selected.

; Parse the number of dice	
	pop ebx				; Get String numDice.
	mov edi,nDice			; Target numDice as opposed to nSides.
	call parseInt			; Turn that into an Int.

; Prepare to write the number of dice we just parsed	
	mov eax,[nDice]			; Prepare to write the fresh number of dice.
	call intToString		; Make a string out of it.
	mov edx,ecx			; Put the length in the appropriate position.
	mov ecx,eax			; Put the pointer in the appropriate position.
	call writeValid			; Write the number of dice parsed.

; Write the middle part of the string.
	mov ecx,diceMid			; prepare to write the middle of the string
	mov edx,dmidlen			; including its length
	call writeValid			; Write the " x D" part of the string.

; Now, we will need the number of sides per die
	pop ebx				; get the second argument
	mov edi,nSides			; target number of sides
	call parseInt			; parse the number of sides

; Write that new number
	mov eax,[nSides]		; Prepare to convert nSides to a string
	call intToString		; Do the conversion.
	mov edx,ecx			; Set the new string length 
	mov ecx,eax			; Set the new string as what to write
	call writeValid			; Write the new string.
	

; Prepare to write the end of the dice string
	mov ecx,diceEnd			; get what to write
	mov edx,dEndLen			; get the length
	call writeValid			; Write the end of the dice seleciton string.

; Open the random file.
	mov eax,5			; Prepare to open the file
	mov ebx,randFile		; The file is /dev/urandom
	mov ecx,o_rdonly		; We only need to read it
	mov edx,0			; Unnecessary, as we don't create the file.
	int 80h				;, but zero seems like a safe default.

	mov ebx,eax	; stub so we return the descriptor.	
	jmp exit

; Prepare to do rolls
	mov ecx,[nDice]			; For each die chosen to roll, roll once.
mainLoop:
	push ecx			; Preserve our loop counter

	mov ecx,rollStart		; Prepare to write the start 
	mov edx,rollStartLen		; of our roll string.
	call writeValid			; Write "Roll: "
	
	mov ecx,lineTerm		; Prepare a newline character
	mov edx,1			; Get ready to write it.
	call writeValid			; Write it.
	
	pop ecx				; Retrieve the loop counter for usage
	loop mainLoop			; Loop back around.	

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
	mov ecx,intSize-1		; so we can count down the size of the string
	mov ebx,intBuffer		; the front of the string
lopits:					; Loop back to here to handle each character
	mov edx,0			; Prevent problems with division.
	div dword [base]		; Divide our int by our base to get values & remainder
	add dl,"0"			; Convert our remainder into the rightmost character.
	mov [ebx+ecx],dl		; Store that character in our string to return.
	cmp eax,0			; If the value of the int left in eax is 0, then
	je breakits			; we have hit the end of our int, so break.
;	cmp ecx,0			; If the value of ecx hits 0, then we have hit the
;	je breakits			; end of our int, so break.  <redundant?>
	dec ecx				; Reduce the position in the string that we fill.
	jmp lopits			; Continue the loop.

breakits:
	mov eax,ecx			; put the string offset in eax
	add eax,ebx			; now eax should be the front of the string
	
	sub ecx,intSize			; put the length - intsize - length into ecx 
	neg ecx				; now ecx should be the string length
	ret



