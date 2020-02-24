; Blackjack (blackjack_game.asm)
; Authors: Kingsley Chukwu and Heather DiRuscio
; CS 271 Final Project, Oregon State University, Winter 2020 Term


INCLUDE Irvine32.inc

; =============================================================================================
;         MACRO: write string to terminal that is in given memory location
;		  Receives: memory address
;		  Returns: none
;		  Preconditions: none
;		  Registers changed: none
; =============================================================================================
stringMacro	MACRO	mem_addr
	push	edx
	
	mov		edx, mem_addr	; print string at memory location
	call	WriteString

	pop		edx
ENDM

.data
	title_blk	BYTE "              ______________________________________________________________		",13,10,
		             "             |                                                              |		",13,10,
		             "             |      ______ _            _    _            _                 |		",13,10,
		             "             |      | ___ \ |          | |  (_)          | |     *          |		",13,10,0
	title_blk2	BYTE "             |      | |_/ / | __ _  ___| | ___  __ _  ___| | __             |		",13,10,
					 "     *       |      | ___ \ |/ _` |/ __| |/ / |/ _` |/ __| |/ /             |		",13,10,
		             "             |      | |_/ / | (_| | (__|   <| | (_| | (__|   <              |		",13,10,
		             "             |      \____/|_|\__,_|\___|_|\_\ |\__,_|\___|_|\_\             |		",13,10,0
	title_blk3	BYTE "             |                  _          _/ |                             |		",13,10,
					 "             |                 (_)        |__/                              |		",13,10,                    
		             "             |    .------.      _ _ __                                      |		",13,10, 
		             "             |    |K.--. |     | | '_ \           *                         |		",13,10,0  
	title_blk4	BYTE " *          .-----| :/\: |     | | | | |                                    |		",13,10, 
					 "            | A.--| :\/: |     |_|_| |_|                                    |		",13,10,
		             "            | (\/)| '--'K|    _____                                         |		",13,10,                                                                              
		             "            | :\/:`------'   /  ___|                                        |		",13,10,0
	title_blk5	BYTE "            | '--'A|         \ `--. _ __   __ _  ___ ___                    |		",13,10,
					 "            `------'          `--. \ '_ \ / _` |/ __/ _ \           *       |		",13,10,
		             "             |     *         /\__/ / |_) | (_| | (_|  __/                   |		",13,10,
		             "             |               \____/| .__/ \__,_|\___\___|                   |		",13,10,0
	title_blk6	BYTE "             |                     | |                                      |		",13,10,
					 "             |                     |_|    [ PRESS ANY KEY TO START ]        |		",13,10,
		             "       *     |______________________________________________________________|		",13,10,0

	card_drawn	BYTE "Card drawn: ",0

	; WIP, trying to figure out how to represent cards graphically. Not sure this will work.
	card_L1		BYTE ".------.",0                                                    
	card_L2		BYTE "|A.--. |",0
	card_L3		BYTE "| |  | |",0                                                       
	card_L4		BYTE "| |  | |",0                                                        
	card_L5		BYTE "| '--'A|",0                                                    
	card_L6		BYTE "`------'",0
.code

; =============================================================================================
;         Procedure: main
;       Description: Calls other procedures to drive the program.
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
main proc

	push	OFFSET title_blk6				; 28
	push	OFFSET title_blk5				; 24
	push	OFFSET title_blk4				; 20
	push	OFFSET title_blk3				; 16
	push	OFFSET title_blk2				; 12
	push	OFFSET title_blk				; 8
	call	Title_Screen					; call graphical title screen

	call	Draw_Card
	call	Crlf
	call	Draw_Card
	call	Crlf

	call ReadInt

	exit

main ENDP

; Display 'Blackjack in Space' Title Screen
; WIP, trying to find ways to:
;			- wait for a user keypress to start game
;			- clear screen after user keypress, then draw gameboard to terminal
; If not feasible within our timeframe, we can implement an easier "scrolling" style,
; like the programs we have done before, in which each new action is just printed at the bottom
Title_Screen proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	call	Crlf	
	stringMacro [ebp + 8]
	stringMacro [ebp + 12]
	stringMacro [ebp + 16]
	stringMacro [ebp + 20]
	stringMacro [ebp + 24]
	stringMacro [ebp + 28]
	call	Crlf

	popad
	pop ebp

	ret 24								; 6 parameters * 4 bytes = return 24
Title_Screen ENDP

; Experimenting with getting random number in a specified range
; to simulate drawing cards during each turn.
; using Kip Irvine's "Randomize" function.
; In Blackjack, all cards have a value of 1 - 11.
; Face cards are valued as follows: 
;	Jack  =	10
;	Queen = 10
;	King  =	10
;	Ace   = 11 OR 1, depending on current cards in hand. See full blackjack rules.
;
; Our range needs to have 13 possibilities, for the 13 types of cards that can be drawn:
; Types of cards in deck:        A, 2, 3, 4, 5, 6, 7, 8, 9, 10,  J,  Q,  K
; Value in game:           1 or 11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10
;
; Random Number Drawn:           1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
;
Draw_Card PROC
    call	Randomize               ; Sets seed

    mov		eax,13                  ; Keeps the range 0 - 12
    call	RandomRange
	add		eax, 1					; Add 1 to shift range to 1 - 13

	mov		edx, offset card_drawn
	call	WriteString
	call	WriteDec

    ret
Draw_Card ENDP

end main