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

;-------------------------------------------------------------------------------
segment .text 
global _start
;-------------------------------------------------------------------------------
_start:
					; Attempt to get argc, argv.
	pop eax				; Check the number of arguments.
	cmp eax,min_args		; Later replace this with min and max
	jne bad_args			; comparisons.
; Ready to parse some integers now.
	pop ebx				; Throw away the file name.
	pop ebx				; Get String numDice.
;	mov edi,nDice			; Target numDice as opposed to nSides.
;	call parseInt			; Turn that into an Int.

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



;; parseInt: attempts to take a string and produce an integer.
;; params:
;;	ebx - the string pointer to convert
;;	edi - what to put it into
;; outputs:
;;	[edi] - the integer produced
;parseInt:
;	mov eax,0			; Start at 0
;	mov ecx,10			; Keep 10 in ecx for multiplication
;	mov esi,ebx			; Preserve the start of the string
;loop_pa0:
;	cmp byte [ebx - 1],0		; if current position is null
;	jne loop_pa0			; then stop looping
;	dec ebx				; fencepost issue
;
;	; test the parse
;	mov ebx,eax
;	jmp exit 
;	ret	




	
