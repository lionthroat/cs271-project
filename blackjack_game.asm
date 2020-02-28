; Blackjack (blackjack_game.asm)
; Authors: Kingsley Chukwu and Heather DiRuscio
; CS 271 Final Project, Oregon State University, Winter 2020 Term

; BUG!!!!!!
; - Can't print Q and K for Queen and King cards (I haven't figured this out yet)
; - Crashes when player Stand's or trying to show Gameboard again after Dealer's turn
;
; Unfinished Features:
;
;	Card Values and Display:
; - Ace never adjusts from value of 11 to 1 like it should
; - Dealer's first card value should be hidden (should look face down until end of round)
;
;	User Gameplay:
; - When user chooses to stand, they should not have any more moves during that hand
;
;	Resetting Game:
; - Each index of cards_left array needs to be reset to 4 after winning or losing a hand
;
;	Winning the Game:
; - Whole game needs to be won (when player gets 10 pts) or lost (when dealer gets 10 pts)
;
;	Winning Points:
; - Player should be able to win even if neither dealer nor player busts but player ends a hand with more points

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
	whose_turn			DWORD	0 ; 0 for player turn, 1 for dealer turn
	card_index			DWORD	?
	card				DWORD	?
	card_middles		DWORD	?
	divider				BYTE	"         ________________________________________________________________________",13,10,0


	; cards array initializes a full deck of 52: 4 aces, 4 2's, 4 3's ... 4 Queens, 4 Kings
	cards_left			DWORD   4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
	ace					BYTE	"A",0
	jack				BYTE	"J",0
	queen				BYTE	"Q",0
	king				BYTE	"K",0

	; These next 6 title_blocks display the game's name at the beginning of the program. Note that
	; while one BYTE can display multiple lines of text, it seems like they run out of capacity at
	; about 4 lines, and the program breaks. So the main screen has been split into slices.
	title_block1		BYTE "                      ______ _            _    _            _                       ",13,10,
							 "                      | ___ \ |          | |  (_)          | |     *           	  ",13,10,0
	title_block2		BYTE "                      | |_/ / | __ _  ___| | ___  __ _  ___| | __              	* ",13,10,
							 "     *        ________| ___ \ |/ _` |/ __| |/ / |/ _` |/ __| |/ /____________ 	  ",13,10,
							 "             |        | |_/ / | (_| | (__|   <| | (_| | (__|   <            |		  ",13,10,
							 "             |        \____/|_|\__,_|\___|_|\_\ |\__,_|\___|_|\_\           |		  ",13,10,0
	title_block3		BYTE "             |                _              _/ |                           |		  ",13,10,
							 "             |               (_)            |__/                     *      |		  ",13,10,                    
							 "             |    .------.    _ _ __                                        |		  ",13,10, 
							 "             |    |K.--. |   | | '_ \      _____                            |		  ",13,10,0  
	title_block4		BYTE " *          .-----| :/\: |   | | | | |    /  ___|                           |		  ",13,10, 
							 "            | A.--| :\/: |   |_|_| |_|    \ `--. _ __   __ _  ___ ___       |		  ",13,10,
							 "            | (\/)| '--'K|                 `--. \ '_ \ / _` |/ __/ _ \      |		  ",13,10,                                                                              
							 "            | :\/:`------'                /\__/ / |_) | (_| | (_|  __/      |		  ",13,10,0
	title_block5		BYTE "            | '--'A|                      \____/| .__/ \__,_|\___\___|      |		* ",13,10,
							 "            `------'                            | |                         |		  ",13,10,
							 "             |     *                            |_|                         |		  ",13,10,
							 "             |______________________________________________________________|		  ",13,10,0

	; This short instructional prompt displays once at the beginning of the game
	begin_game_prompt	BYTE "    	                 ---- Get 10 points before the dealer! ----",13,10,
							 "                              [ PRESS ENTER TO BEGIN GAME ]	        ",0
	begin_hand_prompt	BYTE "                            [ PRESS ENTER TO START NEW HAND ]	        ",0

	hand_over_flag		DWORD	?	; When the hand_over_flag is set to 1, one hand of blackjack has been completed
	game_over_flag		DWORD	? 	; When the game_over_flag is set to 1, one entire game of blackjack has been completed.

	player_points		DWORD	?
	player_hand			DWORD	15 DUP(?)
	player_hand_size	DWORD	?
	player_hand_subtotal DWORD	?
	dealer_points		DWORD	?
	dealer_hand			DWORD	15 DUP(?) 
	dealer_hand_size	DWORD	?
	dealer_hand_subtotal DWORD  ?


	score_box_top		BYTE	"                                                         ______________________",13,10,
								"                                                         |     Game Score:    |",13,10,
								"                                                         |  Player  | Dealer  |",13,10,0
	score_box_left		BYTE	"                                                         |     ",0
	score_box_center	BYTE	"    |    ",0
	score_box_right		BYTE	"    |",13,10,0
	score_box_bottom	BYTE	"                                                         |__________|_________|",13,10,0

	count_card_loop		DWORD	?
	player_hand_msg		BYTE	"    Your Hand: ",0
	dealer_hand_msg		BYTE	"Dealer's Hand: ",0
	subtotal_msg1		BYTE	"(Hand Total: ",0
	subtotal_msg2		BYTE	")",0

	hit_or_stand		BYTE    "         1. Hit",13,10,
								"         2. Stand",13,10,
								"         Your choice: ",0

	you_chose_hit		BYTE	"		  You chose to hit!",0
	you_chose_stand		BYTE	"		  You chose to stand!",0
	you_got_blackjack	BYTE	"                            YOU GOT BLACKJACK! You get a point.",0
	you_went_bust		BYTE	"                            YOU WENT BUST! Dealer gets a point.",0

	dealer_chose_hit	BYTE	"		  The dealer chose to hit!",0
	dealer_chose_stand	BYTE	"		  The dealer chose to stand!",0
	dealer_got_blackjack BYTE	"                      THE DEALER GOT BLACKJACK! Dealer gets a point.",0
	dealer_went_bust	BYTE	"                            DEALER WENT BUST! You get a point",0

	card_slice_top		BYTE ".--------.",0                                                    
	card_slice_2a		BYTE "|",0
	spacer				BYTE " ",0
	card_slice_2b		BYTE ".--.  |",0
	card_slice_middle	BYTE "|  |  |  |",0     ; need this to print three times in a row to build middle                                              
    card_slice_3a       BYTE "|  '--'",0
	card_slice_3b		BYTE "|",0
	card_slice_bottom	BYTE "`--------'",0


	exit_message		BYTE	"         What would you like to do now?",13,10,
								"         1. Play again				",13,10,
								"         2. Quit						",13,10,
								"         Your choice: ",0

.code

; =============================================================================================
;         Procedure: main
;       Description: Calls other procedures to drive the program.
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
main proc

	push	OFFSET title_block5				; 24
	push	OFFSET title_block4				; 20
	push	OFFSET title_block3				; 16
	push	OFFSET title_block2				; 12
	push	OFFSET title_block1				; 8
	call	Title_Screen					; call graphical title screen

	push	OFFSET	begin_game_prompt		; 8
	call	Start_New_Game

	game_loop:
		cmp		game_over_flag, 1
		je		game_end

		start_new_hand:
			mov		whose_turn, 0
			mov		hand_over_flag, 0
			mov		player_hand_size, 0
			mov		player_hand_subtotal, 0
			mov		dealer_hand_size, 0
			mov		dealer_hand_subtotal, 0

			push	OFFSET begin_hand_prompt
			call	Deal_New_Hand					; Starts new hands for dealer and player with 2 cards each

		show_game:
			push	OFFSET	subtotal_msg2			; 48
			push	OFFSET	subtotal_msg1			; 44
			push	OFFSET	spacer					; 40
			push	OFFSET	dealer_hand_msg			; 36
			push	OFFSET	player_hand_msg			; 32
			push	OFFSET	score_box_bottom		; 28
			push	OFFSET	score_box_right			; 24
			push	OFFSET	score_box_center		; 20
			push	OFFSET	score_box_left			; 16
			push	OFFSET	score_box_top			; 12
			push	OFFSET	divider					; 8
			call	Display_Gameboard				; Display scores and cards

		check_win_or_lose:
			push	OFFSET	you_got_blackjack		; 16
			push	OFFSET	you_went_bust			; 8
			call	Check_Player_Blackjack_Or_Bust	; See if player started the game with Blackjack

			cmp		hand_over_flag, 1				; Is the hand over before any player turns?
			je		game_loop						; If so, start new hand.

			push	OFFSET	dealer_got_blackjack	; 16
			push	OFFSET	dealer_went_bust		; 8
			call	Check_Dealer_Blackjack_Or_Bust	; See if dealer started the game with Blackjack

			cmp		hand_over_flag, 1				; Is the hand over before any player turns?
			je		game_loop						; If so, start new hand.

			cmp		whose_turn, 0
			je		player_goes_next

			jmp		dealer_goes_next

		player_goes_next:
			push	OFFSET	you_chose_stand			; 16
			push	OFFSET	you_chose_hit			; 12
			push	OFFSET	hit_or_stand			; 8
			call	Player_Turn						; Give player option to Hit or Stand
			jmp		show_game

		dealer_goes_next:
			push	OFFSET	dealer_chose_stand		; 12
			push	OFFSET	dealer_chose_hit		; 8
			call	Dealer_Turn						; If dealer's hand subtotal is less than 17, dealer will Hit
			jmp		show_game
				
	game_end:
		push	OFFSET exit_message				; 12
		push	OFFSET divider					; 8
		call	Exit_Blackjack

	exit

main ENDP

; =============================================================================================
;         Procedure: Start_New_Game
;       Description: Reset cards and points
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Start_New_Game proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	stringMacro [ebp + 8]			; Instruct player to get to 10 points first
	call	ReadInt

	mov		player_points, 0		; Player starts with 0 points
	mov		dealer_points, 0		; Dealer starts with 0 points
	mov		game_over_flag, 0		; 0 means that a game is now in progress and has not been won or lost
	mov		hand_over_flag, 0		; 0 means that a hand is now in progress and has not been won or lost
	mov		player_hand_size, 0		; player starts with 0 cards
	mov		dealer_hand_size, 0		; dealer starts with 0 cards
	mov		player_hand_subtotal, 0
	mov		dealer_hand_subtotal, 0
	popad
	pop ebp

	ret 4
Start_New_Game ENDP

; =============================================================================================
;         Procedure: Deal_New_Hand
;       Description: Gives two cards to player, two cards to dealer
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Deal_New_Hand proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	stringMacro [ebp + 8]				; Tell player to press enter to start new hand
	call	ReadInt						; Wait for keyboard input

    call	Randomize					; Sets seed
	
	; Draw Two Cards for Player's Starting Hand
	mov		ecx, 2						; Loop counter to draw test cards
	lea		esi, player_hand			; Load player hand array address into ESI

	draw_player_card:
		mov		eax,13                  ; Keeps the range 0 - 12
		call	RandomRange
		mov		card_index, eax
		mov		ebx, 4
		mul		ebx						; Multiplies the result by 4 to get array address
		mov		edi, eax				; Moves this value into edi to get array value
		cmp		cards_left[edi], 0		; Compare given index of array to 0. The value for each
										; card type is 4 at the start of a hand, representing
										; 4 of each card value in deck, e.g. 4 aces, 4 jacks, etc.
		je		draw_player_card		; IF it's 0, there are no more of that card type to draw,
										; and the draw_card subroutine should run again.

										; ELSE that is a valid card to draw. Subtract 1 from array index.
		sub		cards_left[edi], 1

		add		card_index, 1			; Increment card value to be 1 - 13 (Starts out 0 - 12 which wouldn't make sense)
		mov		eax, card_index			; Move card value into EAX

		.if eax > 11
			add		player_hand_subtotal, 10	; If card added is a Jack, Queen, or King, add 10 points to hand
		.elseif eax == 1
			add		player_hand_subtotal, 11	; This is an Ace's default value
		.else
			add		player_hand_subtotal, eax	; If card is between 2 - 10, add this amount to hand's points
		.endif

		mov		[esi], eax				; Store card value in array
		add		esi, type dword			; Move array address to next available spot

		add		player_hand_size, 1 	; Increment player hand size

		call	Crlf					; Newline
		loop	draw_player_card

	; Draw Two Cards for Dealer's Starting Hand
	mov		ecx, 2						; Loop counter to draw test cards
	lea		esi, dealer_hand			; Load dealer hand array address into ESI

	draw_dealer_card:
		mov		eax,13                  ; Keeps the range 0 - 12
		call	RandomRange
		mov		card_index, eax
		mov		ebx, 4
		mul		ebx						; Multiplies the result by 4 to get array address
		mov		edi, eax				; Moves this value into edi to get array value
		cmp		cards_left[edi], 0		; Compare given index of array to 0. The value for each
										; card type is 4 at the start of a hand, representing
										; 4 of each card value in deck, e.g. 4 aces, 4 jacks, etc.
		je		draw_dealer_card		; IF it's 0, there are no more of that card type to draw,
										; and the draw_card subroutine should run again.

										; ELSE that is a valid card to draw. Subtract 1 from array index.
		sub		cards_left[edi], 1

		add		card_index, 1			; Increment card value to be 1 - 13 (Starts out 0 - 12 which wouldn't make sense)
		mov		eax, card_index			; Move card value into EAX

		.if eax > 11
			add		dealer_hand_subtotal, 10	; If card added is a Jack, Queen, or King, add 10 points to hand
		.elseif eax == 1
			add		dealer_hand_subtotal, 11	; This is an Ace's default value
		.else
			add		dealer_hand_subtotal, eax	; If card is between 2 - 10, add this amount to hand's points
		.endif

		mov		[esi], eax				; Store card value in dealer's hand array
		add		esi, type dword			; Move array address to next available spot

		add		dealer_hand_size, 1 	; Increment dealer hand size
		call	Crlf					; Newline
		loop	draw_dealer_card

	popad
	pop ebp

	ret 4
Deal_New_Hand ENDP

; =============================================================================================
;         Procedure: Display_Gameboard
;       Description: Displays current scores and cards, presents player with choices
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Display_Gameboard proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	stringMacro [ebp + 8]	 ; divider
	stringMacro	[ebp + 12]   ; score_box_top
	stringMacro	[ebp + 16]   ; score_box_left
	mov		eax, player_points
	call	WriteDec
	stringMacro	[ebp + 20]   ; score_box_center
	mov		eax, dealer_points
	call	WriteDec
	stringMacro	[ebp + 24]   ; score_box_right
	stringMacro	[ebp + 28]   ; score_box_right

	; DISPLAY PLAYER HAND
	stringMacro	[ebp + 32]	 ; "Your hand: "
	call	Crlf
	call	Print_Player_Hand

	stringMacro	[ebp + 40]	 ; spacer
	stringMacro [ebp + 44]	 ; (Subtotal:
	mov		eax, player_hand_subtotal
	call	WriteDec
	stringMacro [ebp + 48]	 ; )
	call	Crlf
	call	Crlf

	; DISPLAY DEALER HAND
	stringMacro	[ebp + 36]	 ; "Dealer hand: "
	call	Crlf
	call	Print_Dealer_Hand
	stringMacro	[ebp + 40]	 ; spacer
	call	Crlf

	popad
	pop ebp

	ret 44
Display_Gameboard ENDP

; =============================================================================================
;         Procedure: Player_Turn
;       Description: Player chooses to do stuff
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Player_Turn proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	stringMacro [ebp + 8]	 ; hit_or_stand
	call	ReadInt

	cmp		eax, 1			; See if the player chose 1 for Hit
	je		Hit

	cmp		eax, 2			; See if the player chose 2 for Stand
	je		Stand

	Hit:
		call	Crlf
		stringMacro [ebp + 12]
		call	Crlf
		call	Player_Hits
		jmp		outOfIf
	Stand:
		call	Crlf
		stringMacro [ebp + 16]
		call	Crlf
		jmp		outOfIf
	outOfIf:
		mov	whose_turn, 1	; The dealer goes next

	popad
	pop ebp

	ret 12
Player_Turn ENDP

; =============================================================================================
;         Procedure: Player_Hits
;       Description: (draw a card and add to hand)
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Player_Hits proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

    call	Randomize					; Sets seed
	
	; Draw A Cards for Player's Hand
	lea		esi, player_hand			; Load player hand array address into ESI
	mov		ecx, player_hand_size
	find_open_spot_in_array:
		add		esi, type dword			; Move array address to next available spot
		loop	find_open_spot_in_array

	draw_player_card:
		mov		eax,13                  ; Keeps the range 0 - 12
		call	RandomRange
		mov		card_index, eax
		mov		ebx, 4
		mul		ebx						; Multiplies the result by 4 to get array address
		mov		edi, eax				; Moves this value into edi to get array value
		cmp		cards_left[edi], 0		; Compare given index of array to 0. The value for each
										; card type is 4 at the start of a hand, representing
										; 4 of each card value in deck, e.g. 4 aces, 4 jacks, etc.
		je		draw_player_card		; IF it's 0, there are no more of that card type to draw,
										; and the draw_card subroutine should run again.

										; ELSE that is a valid card to draw. Subtract 1 from array index.
		sub		cards_left[edi], 1

		add		card_index, 1			; Increment card value to be 1 - 13 (Starts out 0 - 12 which wouldn't make sense)
		mov		eax, card_index			; Move card value into EAX

		.if eax > 11
			add		player_hand_subtotal, 10	; If card added is a Jack, Queen, or King, add 10 points to hand
		.elseif eax == 1
			add		player_hand_subtotal, 11	; This is an Ace's default value
		.else
			add		player_hand_subtotal, eax	; If card is between 2 - 10, add this amount to hand's points
		.endif

		mov		[esi], eax				; Store card value in array
		add		esi, type dword			; Move array address to next available spot

		add		player_hand_size, 1 	; Increment player hand size

	popad
	pop ebp

	ret
Player_Hits ENDP

; =============================================================================================
;         Procedure: Dealer_Turn
;       Description: Dealer behavior: will hit if hand is 17 or less, stand otherwise
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Dealer_Turn proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	mov		eax, dealer_hand_subtotal
	cmp		eax, 17
	jle		Hit

	jmp		Stand

	Hit:
		call	Crlf
		stringMacro [ebp + 12]
		call	Crlf
		call	Dealer_Hits
		jmp		outOfIf
	Stand:
		call	Crlf
		stringMacro [ebp + 16]
		call	Crlf
		jmp	outOfIf
	outOfIf:
		mov	whose_turn, 1	; The dealer goes next
	popad
	pop ebp

	ret 12
Dealer_Turn ENDP

; =============================================================================================
;         Procedure: Dealer_Hits
;       Description: (draw a card and add to hand)
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Dealer_Hits proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

    call	Randomize					; Sets seed
	
	; Draw A Cards for Dealer's Hand
	lea		esi, dealer_hand			; Load player hand array address into ESI
	mov		ecx, dealer_hand_size
	find_open_spot_in_array:
		add		esi, type dword			; Move array address to next available spot
		loop	find_open_spot_in_array

	draw_dealer_card:
		mov		eax,13                  ; Keeps the range 0 - 12
		call	RandomRange
		mov		card_index, eax
		mov		ebx, 4
		mul		ebx						; Multiplies the result by 4 to get array address
		mov		edi, eax				; Moves this value into edi to get array value
		cmp		cards_left[edi], 0		; Compare given index of array to 0. The value for each
										; card type is 4 at the start of a hand, representing
										; 4 of each card value in deck, e.g. 4 aces, 4 jacks, etc.
		je		draw_dealer_card		; IF it's 0, there are no more of that card type to draw,
										; and the draw_card subroutine should run again.

										; ELSE that is a valid card to draw. Subtract 1 from array index.
		sub		cards_left[edi], 1

		add		card_index, 1			; Increment card value to be 1 - 13 (Starts out 0 - 12 which wouldn't make sense)
		mov		eax, card_index			; Move card value into EAX

		.if eax > 11
			add		dealer_hand_subtotal, 10	; If card added is a Jack, Queen, or King, add 10 points to hand
		.elseif eax == 1
			add		dealer_hand_subtotal, 11	; This is an Ace's default value
		.else
			add		dealer_hand_subtotal, eax	; If card is between 2 - 10, add this amount to hand's points
		.endif

		mov		[esi], eax				; Store card value in array
		add		esi, type dword			; Move array address to next available spot

		add		dealer_hand_size, 1 	; Increment player hand size

	popad
	pop ebp

	ret
Dealer_Hits ENDP

; =============================================================================================
;         Procedure: Check_Player_Blackjack_Or_Bust
;       Description: Check for player blackjack or bust
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Check_Player_Blackjack_Or_Bust proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	mov eax, player_hand_subtotal
	.if eax > 21
		stringMacro [ebp + 8]		; Tell player they went bust
		add		dealer_points, 1	; Give dealer 1 point
		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf
	.elseif eax == 21
		stringMacro [ebp + 12]		; Tell player they got Blackjack
		add		player_points, 1	; Give player 1 point
		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf
	.else
		; continue
	.endif

	popad
	pop ebp

	ret 8
Check_Player_Blackjack_Or_Bust ENDP

; =============================================================================================
;         Procedure: Check_Dealer_Blackjack_Or_Bust
;       Description: Check for player blackjack or bust
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Check_Dealer_Blackjack_Or_Bust proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	mov eax, dealer_hand_subtotal
	.if eax > 21
		stringMacro [ebp + 8]		; Tell dealer they went bust
		add		player_points, 1	; Give player 1 point
		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf
	.elseif eax == 21
		stringMacro [ebp + 12]		; Tell dealer they got Blackjack
		add		dealer_points, 1	; Give dealer 1 point
		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf
	.else
		; continue
	.endif

	popad
	pop ebp

	ret 8
Check_Dealer_Blackjack_Or_Bust ENDP

; =============================================================================================
;         Procedure: Title_Screen
;       Description: Display Blackjack in Space title screen
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
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
	call	Crlf

	popad
	pop ebp

	ret 24								; 6 parameters * 4 BYTEs = return 24
Title_Screen ENDP

; =============================================================================================
;         Procedure: Exit_Blackjack
;       Description: After game ends, player is presented with options to play new game or quit
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
Exit_Blackjack proc
	push		ebp
	mov			ebp, esp
	pushad

	call	Crlf	
	stringMacro [ebp + 8]	; divider
	call	Crlf
	stringMacro [ebp + 12]	; play again or quit choice
	call	ReadInt			; To-Do: Link this user input to game loop (quit or continue based on choice 1 or 2)

	popad
	pop ebp

	ret 8	
Exit_Blackjack	ENDP

; =============================================================================================
;         Procedure: Display_Card
;		  Receives: ?
;		  Returns: ?
;		  Preconditions: none
;		  Registers changed: none
; =============================================================================================
Display_Card proc
	push		ebp
	mov			ebp, esp
	pushad

	mov		edx, offset card_slice_top
	call	WriteString
	call	Crlf
	mov		edx, offset card_slice_2a
	call	WriteString

	; print ace
	.if			card == 1
		mov			edx, offset ace
		call		WriteString
	.endif

	; print jack
	.if		card == 11
		mov			edx, offset jack
		call		WriteString
	.endif

	; print queen
	.if		card == 12
		mov			edx, offset queen
		call		WriteString
	.endif

	; print king
	.if		card == 13
		mov			edx, offset king
		call		WriteString
	.endif

	; print non-face cards
	.if	(card > 1 && card < 11)
		mov			eax, card
		call		WriteDec
	.endif

	.if		card != 10
		mov		edx, offset spacer
		call	WriteString
	.endif

	mov		edx, offset card_slice_2b
	call	WriteString
	call	Crlf

	mov		edx, offset card_slice_middle
	mov		ecx, 3
	print_middle:
		call	WriteString
		call	Crlf
		loop	print_middle
	mov		edx, offset card_slice_3a
	call	WriteString

	.if		card != 10
		mov		edx, offset spacer
		call	WriteString
	.endif

	; print ace
	.if			card == 1
		mov			edx, offset ace
		call		WriteString
	.endif

	; print jack
	.if		card == 11
		mov			edx, offset jack
		call		WriteString
	.endif

	; print queen
	.if		card == 12
		mov			edx, offset queen
		call		WriteString
	.endif

	; print king
	.if		card == 13
		mov			edx, offset king
		call		WriteString
	.endif

	.if	(card > 1 && card < 11)
		mov			eax, card
		call		WriteDec
	.endif

	mov		edx, offset card_slice_3b
	call	WriteString
	call	Crlf
	mov		edx, offset card_slice_bottom
	call	WriteString
	call	Crlf

	popad
	pop ebp

	ret	
Display_Card ENDP

; =============================================================================================
;         Procedure: Print_Player_Hand
;		  Receives: ?
;		  Returns: ?
;		  Preconditions: ?
;		  Registers changed: ?
; =============================================================================================
Print_Player_Hand	proc
	push		ebp
	mov			ebp, esp
	pushad

	; CARD TOP SLICES (print top sections of cards)
	mov		ecx, player_hand_size
	print_card_top:
		mov		edx, offset card_slice_top
		call	WriteString
		mov		edx, offset spacer
		call	WriteString
		loop	print_card_top

	call	Crlf

	; CARD FIRST NUMBER SLICES (print the second-to-top pieces of cards that show the card value for the first time)
	mov		ecx, player_hand_size
	lea		esi, player_hand
	print_card_slice_2:
		mov		edx, offset card_slice_2a
		call	WriteString
		mov		eax, [esi]				; fetch card value from array
		mov		card, eax				; store card value in card for now
		add		esi, type dword			; move array to next spot

		.if eax > 1 && eax < 11 ; print non-face cards
			call	WriteDec
		.endif

		.if	card == 1					; print ace
			mov			edx, offset ace
			call		WriteString
		.endif

		.if card == 11
			mov			edx, offset jack
			call		WriteString
		.endif

;		.if card == 12
;			mov			edx, offset queen
;			call		WriteString
;		.endif
;		.if card == 13
;			mov			edx, offset king
;			call		WriteString
;		.endif

		.if	card != 10						 ; 10 is the only card to need two-digit offset. other cards get a spacer
			mov		edx, offset spacer
			call	WriteString
		.endif
		
		mov		edx, offset card_slice_2b
		call	WriteString

		mov		edx, offset spacer				 ; Maintain space between cards
		call	WriteString

		loop	print_card_slice_2

	call	Crlf

	; CARD MIDDLE SLICES (print middle sections of cards)
	mov		ecx, 3								  ; Initialize loop counter to print card middle slices
	mov		card_middles, 0						  ; Reset middle counter so that EACH card gets three middle slices
	print_middle:								  ; Outer Loop: loop once per card in hand
		mov		card_middles, 0
		middle_of_each_card:					  ; Inner Loop: loop three times for each card
			mov		edx, offset card_slice_middle ; Print the middle slice
			call	WriteString

			mov		edx, offset spacer			  ; Maintain single space between cards
			call	WriteString

			inc		card_middles				  ; Increment counter once a card middle is printed
			mov		eax, player_hand_size				  ; Bring the variable hand_size into EAX
			cmp		card_middles, eax			  ; Do we have the right number of card middles for # of cards in hand?
			jne		middle_of_each_card			  ; If not, jump back up and print another middle slice

		call	Crlf							  ; Need three newlines total, one for each vertical slice of card middles
		loop	print_middle					  ; Loop until it has gone three times
	
	; CARD SECOND NUMBER (print the second-to-last pieces of cards that show the card value for the second time)
	mov		ecx, player_hand_size
	lea		esi, player_hand
	print_card_slice_3:
		mov		edx, offset card_slice_3a
		call	WriteString
		mov		eax, [esi]						; Fetch card value from array
		mov		card, eax						; Store card value in "card" for now
		add		esi, type dword					; Move array to next spot

		.if eax > 1 && eax < 11 ; print non-face cards
			call	WriteDec
		.endif

		.if	card == 1					; print ace
			mov			edx, offset ace
			call		WriteString
		.endif

		.if card == 11
			mov			edx, offset jack
			call		WriteString
		.endif

;		.if card == 12
;			mov			edx, offset queen
;			call		WriteString
;		.endif
;		.if card == 13
;			mov			edx, offset king
;			call		WriteString
;		.endif

		.if	card != 10						 ; 10 is the only card to need two-digit offset. other cards get a spacer
			mov		edx, offset spacer
			call	WriteString
		.endif

		mov		edx, offset card_slice_3b
		call	WriteString

		mov		edx, offset spacer
		call	WriteString

		loop	print_card_slice_3

	call	Crlf

	; CARD BOTTOM SLICES (print bottom sections of cards)
	mov		ecx, player_hand_size
	print_card_bottom:
		mov		edx, offset card_slice_bottom
		call	WriteString
		mov		edx, offset spacer
		call	WriteString
		loop	print_card_bottom

	call	Crlf

	popad
	pop ebp
	ret
Print_Player_Hand ENDP

; =============================================================================================
;         Procedure: Print_Dealer_Hand
;		  Receives: ?
;		  Returns: ?
;		  Preconditions: ?
;		  Registers changed: ?
; =============================================================================================
Print_Dealer_Hand	proc
	push		ebp
	mov			ebp, esp
	pushad

	; CARD TOP SLICES (print top sections of cards)
	mov		ecx, dealer_hand_size
	print_card_top:
		mov		edx, offset card_slice_top
		call	WriteString
		mov		edx, offset spacer
		call	WriteString
		loop	print_card_top

	call	Crlf

	; CARD FIRST NUMBER SLICES (print the second-to-top pieces of cards that show the card value for the first time)
	mov		ecx, dealer_hand_size
	lea		esi, dealer_hand
	print_card_slice_2:
		mov		edx, offset card_slice_2a
		call	WriteString
		mov		eax, [esi]				; fetch card value from array
		mov		card, eax				; store card value in card for now
		add		esi, type dword			; move array to next spot

		.if eax > 1 && eax < 11 ; print non-face cards
			call	WriteDec
		.endif

		.if	card == 1					; print ace
			mov			edx, offset ace
			call		WriteString
		.endif

		.if card == 11
			mov			edx, offset jack
			call		WriteString
		.endif

		; BUG: Multiple if blocks in a row break even though they work individually. Why?
;		.if card == 12
;			mov			edx, offset queen
;			call		WriteString
;		.endif
;		.if card == 13
;			mov			edx, offset king
;			call		WriteString
;		.endif

		.if	card != 10						 ; 10 is the only card to need two-digit offset. other cards get a spacer
			mov		edx, offset spacer
			call	WriteString
		.endif
		
		mov		edx, offset card_slice_2b
		call	WriteString

		mov		edx, offset spacer				 ; Maintain space between cards
		call	WriteString

		loop	print_card_slice_2

	call	Crlf

	; CARD MIDDLE SLICES (print middle sections of cards)
	mov		ecx, 3								  ; Initialize loop counter to print card middle slices
	mov		card_middles, 0						  ; Reset middle counter so that EACH card gets three middle slices
	print_middle:								  ; Outer Loop: loop once per card in hand
		mov		card_middles, 0
		middle_of_each_card:					  ; Inner Loop: loop three times for each card
			mov		edx, offset card_slice_middle ; Print the middle slice
			call	WriteString

			mov		edx, offset spacer			  ; Maintain single space between cards
			call	WriteString

			inc		card_middles				  ; Increment counter once a card middle is printed
			mov		eax, dealer_hand_size		  ; Bring the variable hand_size into EAX
			cmp		card_middles, eax			  ; Do we have the right number of card middles for # of cards in hand?
			jne		middle_of_each_card			  ; If not, jump back up and print another middle slice

		call	Crlf							  ; Need three newlines total, one for each vertical slice of card middles
		loop	print_middle					  ; Loop until it has gone three times
	
	; CARD SECOND NUMBER (print the second-to-last pieces of cards that show the card value for the second time)
	mov		ecx, dealer_hand_size
	lea		esi, dealer_hand
	print_card_slice_3:
		mov		edx, offset card_slice_3a
		call	WriteString
		mov		eax, [esi]						; Fetch card value from array
		mov		card, eax						; Store card value in "card" for now
		add		esi, type dword					; Move array to next spot

		.if eax > 1 && eax < 11 ; print non-face cards
			call	WriteDec
		.endif

		.if	card == 1					; print ace
			mov			edx, offset ace
			call		WriteString
		.endif

		.if card == 11
			mov			edx, offset jack
			call		WriteString
		.endif

;		.if card == 12
;			mov			edx, offset queen
;			call		WriteString
;		.endif
;		.if card == 13
;			mov			edx, offset king
;			call		WriteString
;		.endif

		.if	card != 10						 ; 10 is the only card to need two-digit offset. other cards get a spacer
			mov		edx, offset spacer
			call	WriteString
		.endif

		mov		edx, offset card_slice_3b
		call	WriteString

		mov		edx, offset spacer
		call	WriteString

		loop	print_card_slice_3

	call	Crlf

	; CARD BOTTOM SLICES (print bottom sections of cards)
	mov		ecx, dealer_hand_size
	print_card_bottom:
		mov		edx, offset card_slice_bottom
		call	WriteString
		mov		edx, offset spacer
		call	WriteString
		loop	print_card_bottom

	call	Crlf

	popad
	pop ebp
	ret
Print_Dealer_Hand ENDP

end main