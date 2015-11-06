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


; Exit success
exit:
	mov eax,exitcmd			; Prepare to exit 0
	mov ebx,exit_succ
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
	cmp byte [ecx + edx],0		; Check if not null.
	jne loop_ba0
	call writeErr
					; Now, print the rest of that string
	mov ecx,usage1
	mov edx,usage1len
	call writeErr

quit:
	mov eax,exitcmd			; Prepare to exit 1
	mov ebx,exit_fail		
	int 80h

;-------------------------------------------------------------------------------
; Helper Functions
;-------------------------------------------------------------------------------
; writeErr: prints whatever is pointed by ecx out to length edx
writeErr:
	mov eax,writecmd	
	mov ebx,stderr
	int 80h
	ret
