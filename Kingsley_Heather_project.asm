;TITLE Dog years     (Kingsley_chukwu_exercise_week_6.asm)
; Description:  This program get a number from the user and calculates the fibonacci series.
INCLUDE Irvine32.inc

; the macro checks if the hit card is available in the deck
errorcheck macro hit_card, ava_card
    
    ;mov	EDX, OFFSET prompt		
	;call  WriteString
	;call  ReadInt
	;call	Crlf
 mov ECX, 13
 mov EDI, 0
 mov ebx, 0
 checkloop:
	mov eax, hit_card
	add ebx, 1
	cmp eax, ebx
	
	je else1
	jmp outofif
 else1:
    
    mov eax, cards[EDI]
	cmp eax, 0
	jg else2
	mov eax,0
	mov ava_card, eax
    jmp outofif
  else2:
	mov eax,1
	mov ava_card, eax
 outofif:
    add EDI, 4
 loop checkloop
ENDM

.data
tot_card_left	     dword  52
ava_card     dword  0
hit_card   dword   0
card_1     dword   4
card_2     dword   4
card_3     dword   4
card_4     dword   4
card_5     dword   4
card_6     dword   4
card_7     dword   4
card_8     dword   4
card_9     dword   4
card_10    dword   4
card_11    dword   4
card_12    dword   4
card_13    dword   4
prompt   byte    "Please enter a value:",0
cards    dword    13  DUP(?)



.code
main PROC
; fill in the each element in the array with 4
        mov EDI, 0
		mov EAX, 4
		mov cards[EDI], EAX
		mov ECX, 12
		addloop:
		add EDI,4
		mov cards[EDI], EAX
		loop addloop
		;call WriteDec
		;mov ebx, 0
		;mov cards[0],ebx
	    mov	EDX, OFFSET prompt		
	    call  WriteString
		call  ReadInt
		mov  hit_card, EAX
	    ;call	Crlf
		;call  Check
		errorcheck hit_card, ava_card
		mov eax, ava_card
		call WriteDec
		call crlf
		call  Check
		mov EDI, 0
		mov ECX, 13
		amakaloop:
		mov eax, cards[EDI]
		add EDI, 4
		call WriteDec
		call crlf
        loop amakaloop
		mov eax, tot_card_left
		call WriteDec
	    exit					    ;exit to operating system
	
main ENDP

; the procedure reduces the card by one based on the hitcard
Check PROC
    mov EDI, 0
	mov ECX, 13
	mov ebx, 0
    subloop:
	mov eax, hit_card
	add ebx, 1
	cmp eax, ebx	
	je else3
    jmp outofif1
 else3:
	mov eax, cards[EDI]
	dec eax
	mov cards[EDI], eax
	mov eax, tot_card_left
	dec eax
	mov tot_card_left, eax
outofif1:
   add EDI, 4
  loop subloop
 
    ret 

Check ENDP

END main
