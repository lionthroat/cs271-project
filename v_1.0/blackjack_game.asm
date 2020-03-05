; Blackjack (blackjack_game.asm)
; Authors:  Kingsley Chukwu and Heather DiRuscio
; Program:  CS 271 Final Project,
;			Game Development Option
;			Oregon State University,
;			Winter 2020 Term

; Procedures:
;	1)	Main Procedure
;	2)	Title_Screen
;   3)	Start_Game
;	4)  Start_Hand
;	5)  Draw_Card
;	6)  Evaluate_Hand
;	7)  Show_Game
;	8)	Check_Win
;	9)	Print_Hand
;  10)	Face_Cards
;  11)  Card_Spacer
;  12)  Player_Turn
;  13)	Dealer_Turn
;  14)	Pick_Winner
;  15)  Exit_Blackjack
;
; Known issues:
; 1. Sometimes, Ace cards appear with @ symbol or = symbol instead of expected value "A"
; 2. The dealer's full hand (including face-down card) is not always revealed at the end
;    of a hand. It works as intended if a player chooses to Stand, but the flags aren't
;    set correctly if they choose Hit.
; 3. In hands with multiple Aces where the value of the Ace would be reduced from 11 to 1,
;	 only one Ace might be counted. (E.g. a hand with A, 2, A would have a value of 3 instead of 4)
; 4. Player hands that bust are frequently evaluated to "30" instead of their actual points value.
;    The determination of whether someone has Bust seems correct, but the ending value displayed is not.

INCLUDE Irvine32.inc

; =============================================================================================
;         MACRO: stringMacro: write string to terminal that is in given memory location
;		  Receives: memory address
;		  Returns: none
;		  Preconditions: A string's offset has been pushed to a procedure
;		  Registers changed: EDX
; =============================================================================================
;stringMacro	MACRO	mem_addr
;	push	edx
;	
;	mov		edx, mem_addr	; print string at memory location
;	call	WriteString
;
;	pop		edx
;ENDM
;
.data
;	whose_turn			DWORD	0 ; 0 for player turn, 1 for dealer turn
;	card_index			DWORD	?
;	card				DWORD	?
;	on_card				DWORD	?
;	card_middles		DWORD	?
;	divider				BYTE	"         ________________________________________________________________________",13,10,0
;
;
;	; cards_left initializes a full deck of 52: 4 aces, 4 2's, 4 3's ... 4 Queens, 4 Kings
;	cards_left			DWORD    4,   4,   4,   4,   4,   4,   4,   4,   4,   4,    4,   4,   4
;	ace					BYTE	"A",0
;	jack				BYTE	"J",0
;	queen				BYTE	"Q",0
;	king				BYTE	"K",0
;
;	; These next 6 title_blocks display the game's name at the beginning of the program. Note that
;	; while one BYTE can display multiple lines of text, it seems like they run out of capacity at
;	; about 4 lines, and the program breaks. So the main screen has been split into slices.
;	title_block1	    BYTE "                      ______ _            _    _            _                       ",13,10,
;							 "                      | ___ \ |          | |  (_)          | |     *           	  ",13,10,0
;	title_block2		BYTE "                      | |_/ / | __ _  ___| | ___  __ _  ___| | __              	* ",13,10,
;							 "     *        ________| ___ \ |/ _` |/ __| |/ / |/ _` |/ __| |/ /____________ 	  ",13,10,
;							 "             |        | |_/ / | (_| | (__|   <| | (_| | (__|   <            |		  ",13,10,
;							 "             |        \____/|_|\__,_|\___|_|\_\ |\__,_|\___|_|\_\           |		  ",13,10,0
;	title_block3		BYTE "             |                _              _/ |                           |		  ",13,10,
;							 "             |               (_)            |__/                     *      |		  ",13,10,                    
;							 "             |    .------.    _ _ __                                        |		  ",13,10, 
;							 "             |    |K.--. |   | | '_ \      _____                            |		  ",13,10,0  
;	title_block4		BYTE " *          .-----| :/\: |   | | | | |    /  ___|                           |		  ",13,10, 
;							 "            | A.--| :\/: |   |_|_| |_|    \ `--. _ __   __ _  ___ ___       |		  ",13,10,
;							 "            | (\/)| '--'K|                 `--. \ '_ \ / _` |/ __/ _ \      |		  ",13,10,                                                                              
;							 "            | :\/:`------'                /\__/ / |_) | (_| | (_|  __/      |		  ",13,10,0
;	title_block5		BYTE "            | '--'A|                      \____/| .__/ \__,_|\___\___|      |		* ",13,10,
;							 "            `------'                            | |                         |		  ",13,10,
;							 "             |     *                            |_|                         |		  ",13,10,
;							 "             |______________________________________________________________|		  ",13,10,0
;
;	; This short instructional prompt displays once at the beginning of the game
;	begin_game_prompt	BYTE "    	                 ---- Get 10 points before the dealer! ----",13,10,
;							 "                              [ PRESS ENTER TO BEGIN GAME ]	        ",0
;	begin_hand_prompt	BYTE "                     [ PRESS ENTER TO SHUFFLE CARDS & START NEW HAND ]	        ",0
;
;	; FLAGS
;	hand_over_flag		DWORD	?	; When the hand_over_flag is set to 1, one hand of blackjack has been completed
;	game_over_flag		DWORD	? 	; When the game_over_flag is set to 1, one entire game of blackjack has been completed.
;	player_flag			DWORD	1
;	dealer_flag			DWORD	0
;	player_locked		DWORD	?		; When player stands or busts, their score becomes locked in for that hand
;	dealer_locked		DWORD	?		; When dealer stands or busts, their score becomes locked in for that hand
;	hit_flag			DWORD	0
;
;	player_points		 DWORD	?
;	player_hand_msg		 BYTE	"     Your Hand: ",0
;	player_hand			 DWORD	15 DUP(?)
;	player_hand_size	 DWORD	?
;	player_hand_subtotal DWORD	?
;
;	dealer_points		 DWORD	?
;	dealer_hand_msg		 BYTE	"     Dealer's Hand: ",0
;	dealer_hand			 DWORD	15 DUP(?) 
;	dealer_hand_size	 DWORD	?
;	dealer_hand_subtotal DWORD  ?
;
;
;	score_box_top		BYTE	"                                                         ______________________",13,10,
;								"                                                         |     Game Score:    |",13,10,
;								"                                                         |  Player  | Dealer  |",13,10,0
;	score_box_left		BYTE	"                                                         |     ",0
;	score_box_center	BYTE	"    |    ",0
;	score_box_right		BYTE	"    |",13,10,0
;	score_box_bottom	BYTE	"                                                         |__________|_________|",13,10,0
;
;	hit_or_stand		BYTE    "         1. Hit",13,10,
;								"         2. Stand",13,10,
;								"         Your choice: ",0
;
;	you_chose_hit		BYTE	"		  You chose to hit!",0
;	you_chose_stand		BYTE	"		  You chose to stand!",0
;	you_got_blackjack	BYTE	"                            YOU GOT BLACKJACK! You get a point.",0
;	you_went_bust		BYTE	"                            YOU WENT BUST! Dealer gets a point.",0
;	you_got_more_points	BYTE	"                            You got more points! You win this hand.",0
;
;	dealer_chose_hit	BYTE	"		  The dealer chose to hit!",0
;	dealer_chose_stand	BYTE	"		  The dealer chose to stand!",0
;	dealer_got_blackjack BYTE	"                      THE DEALER GOT BLACKJACK! Dealer gets a point.",0
;	dealer_went_bust	BYTE	"                            DEALER WENT BUST! You get a point",0
;	dealer_got_more_points	BYTE	"                        Dealer got more points! You lose this hand.",0
;	dealer_tied			BYTE	"                        You tied with the Dealer! You lose this hand.",0
;	show_subtotal_1		BYTE	"     (Hand Total: ",0
;	show_subtotal_2		BYTE	")",0
;
;	; CARD PICTURE
;	card_slice_top		BYTE ".--------.",0                                               
;	card_slice_2a		BYTE "|",0
;	spacer				BYTE " ",0
;	card_slice_2b		BYTE ".--.  |",0
;	card_slice_middle	BYTE "|  |  |  |",0     ; need this to print three times in a row to build middle                                              
;    card_slice_3a       BYTE "|  '--'",0
;	card_slice_3b		BYTE "|",0
;	card_slice_bottom	BYTE "`--------'",0
;	card_hidden_slice	BYTE "| ****** |",0 
;	exit_message		BYTE	"         What would you like to do now?",13,10,
;								"         1. Play again				",13,10,
;								"         2. Quit						",13,10,
;								"         Your choice: ",0

.code

; =============================================================================================
;         Procedure: main
;       Description: Calls other procedures to drive the program.
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
main proc
;    call	Randomize						; Sets seed

	; Display Game Title Screen
;	push	OFFSET title_block5				; 24
;	push	OFFSET title_block4				; 20
;	push	OFFSET title_block3				; 16
;	push	OFFSET title_block2				; 12
;	push	OFFSET title_block1				; 8
;	call	Title_Screen					; call graphical title screen
;	
;	push	OFFSET begin_game_prompt		; 8
;	call	Start_Game
;
;	game_loop:
;		cmp		game_over_flag, 1
;		je		game_end
;
;		hand_loop:
;			push	OFFSET cards_left				; 12
;			push	OFFSET begin_hand_prompt		;  8
;			call	Start_Hand						; Starts new hands for dealer and player with 2 cards each
;		
;		mov ecx, 2
;		deal_starting_cards_to_player:
;			push	OFFSET player_hand_size			; 20
;			push	OFFSET player_hand_subtotal		; 16
;			push	OFFSET cards_left				; 12
;			push	OFFSET player_hand				; 8
;			call	Draw_Card
;			loop	deal_starting_cards_to_player
;			
;		mov ecx, 2
;		deal_starting_cards_to_dealer:
;			push	OFFSET dealer_hand_size			; 20
;			push	OFFSET dealer_hand_subtotal		; 16
;			push	OFFSET cards_left				; 12
;			push	OFFSET dealer_hand				; 8
;			call	Draw_Card
;			loop	deal_starting_cards_to_dealer
;
;		show_gameboard:
;			push	dealer_points					; 36
;			push	player_points					; 32
;			push	OFFSET	score_box_bottom		; 28
;			push	OFFSET	score_box_right			; 24
;			push	OFFSET	score_box_center		; 20
;			push	OFFSET	score_box_left			; 16
;			push	OFFSET	score_box_top			; 12
;			push	OFFSET	divider					; 8
;			call	Show_Game						; Display scores and cards
;
;		evaluate_player_hand:
;			push	OFFSET player_locked			; 18
;			push	player_hand_size				; 16 push by value
;			push	OFFSET player_hand				; 12 - push player hand array by reference
;			push	OFFSET player_hand_subtotal		; 8
;			call	Evaluate_Hand
;
;		evaluate_dealer_hand:
;			push	OFFSET dealer_locked			; 18
;			push	dealer_hand_size				; 16 - push by value
;			push	OFFSET dealer_hand				; 12 - push player hand array by reference
;			push	OFFSET dealer_hand_subtotal		; 8
;			call	Evaluate_Hand
;
;		print_player_hand:
;			push	player_hand_subtotal			; 80 - push subtotal by value
;			push	OFFSET show_subtotal_2			; 76 - push subtotal display slice by reference
;			push	OFFSET show_subtotal_1			; 72 - push subtotal display slice by reference
;			push	OFFSET card_hidden_slice		; 68 - push card slice by reference
;			push	player_flag						; 64 - push by value
;			push	player_locked					; 60 - push by value
;			push	dealer_locked					; 56 - push by value
;			push	OFFSET player_hand_msg			; 52 - push message string by reference
;			push	OFFSET spacer					; 48 - push spacer string by reference
;			push	OFFSET card_slice_bottom		; 44 - push card slice by reference
;			push	OFFSET card_slice_3b			; 40 - push card slice by reference
;			push	OFFSET card_slice_3a			; 36 - push card slice by reference
;			push	OFFSET card_slice_middle		; 32 - push card slice by reference
;			push	OFFSET card_slice_2b			; 28 - push card slice by reference
;			push	OFFSET card_slice_2a			; 24 - push card slice by reference
;			push	OFFSET card_slice_top			; 20 - push card slice by reference
;			push	player_flag						; 16 - flag so no cards are hidden from user
;			push	OFFSET player_hand				; 12 - push player hand array by reference
;			push	player_hand_size				; 8  - push player hand size (# of cards) by value
;			call	Print_Hand
;
;		print_dealer_hand:
;			push	dealer_hand_subtotal			; 80 - push subtotal by value
;			push	OFFSET show_subtotal_2			; 76 - push subtotal display slice by reference
;			push	OFFSET show_subtotal_1			; 72 - push subtotal display slice by reference
;			push	OFFSET card_hidden_slice		; 68 - push card slice by reference
;			push	dealer_flag						; 64 - push by value
;			push	player_locked					; 60 - push by value
;			push	dealer_locked					; 56 - push by value
;			push	OFFSET dealer_hand_msg			; 52 - push message string by reference
;			push	OFFSET spacer					; 48 - push spacer string by reference
;			push	OFFSET card_slice_bottom		; 44 - push card slice by reference
;			push	OFFSET card_slice_3b			; 40 - push card slice by reference
;			push	OFFSET card_slice_3a			; 36 - push card slice by reference
;			push	OFFSET card_slice_middle		; 32 - push card slice by reference
;			push	OFFSET card_slice_2b			; 28 - push card slice by reference
;			push	OFFSET card_slice_2a			; 24 - push card slice by reference
;			push	OFFSET card_slice_top			; 20 - push card slice by reference
;			push	dealer_flag						; 16 - flag so the first card is hidden from user
;			push	OFFSET dealer_hand				; 12 - push dealer hand array by reference
;			push	dealer_hand_size				; 8  - push dealer hand size (# of cards) by value
;			call	Print_Hand
;
;		check_player:
;			push	player_flag						; 20
;			push	player_hand_subtotal			; 16 - points pushed by value
;			push	OFFSET	you_got_blackjack		; 12
;			push	OFFSET	you_went_bust			; 8
;			call	Check_Win						; See if player started the game with Blackjack
;
;			cmp		hand_over_flag, 1				; Is the hand over before any player turns?
;			je		game_loop						; If so, start new hand.
;		
;		check_dealer:
;			push	dealer_flag
;			push	dealer_hand_subtotal			; 16 - points pushed by value
;			push	OFFSET	dealer_got_blackjack	; 12
;			push	OFFSET	dealer_went_bust		; 8
;			call	Check_Win						; See if dealer started the game with Blackjack
;
;			cmp		hand_over_flag, 1				; Is the hand over before any player turns?
;			je		game_loop						; If so, start new hand.
;
;		decide_whose_turn:
;
;			cmp		whose_turn, 0
;			je		player_goes_next
;
;			jmp		dealer_goes_next
;
;		player_goes_next:
;			push	OFFSET	you_chose_stand			; 16
;			push	OFFSET	you_chose_hit			; 12
;			push	OFFSET	hit_or_stand			; 8
;			call	Player_Turn						; Give player option to Hit or Stand
;
;			; If player Hits, draw them a card then reevaluate their hand
;			mov eax, hit_flag
;			.if eax == 1
;				push	OFFSET player_hand_size			; 20
;				push	OFFSET player_hand_subtotal		; 16
;				push	OFFSET cards_left				; 12
;				push	OFFSET player_hand				; 8
;				call	Draw_Card
;
;				mov		hit_flag, 0
;
;				push	OFFSET player_locked			; 18
;				push	player_hand_size				; 16 push by value
;				push	OFFSET player_hand				; 12 - push player hand array by reference
;				push	OFFSET player_hand_subtotal		; 8
;				call	Evaluate_Hand
;
;				jmp		show_gameboard
;	
;			.endif
;
;		dealer_goes_next:
;			push	OFFSET	dealer_chose_stand		; 12
;			push	OFFSET	dealer_chose_hit		; 8
;			call	Dealer_Turn						; If dealer's hand subtotal is less than 17, dealer will Hit
;			
;			; If dealer Hits, draw them a card then reevaluate their hand		
;			.if hit_flag == 1
;				; Need to Draw a Card
;				push	OFFSET dealer_hand_size			; 20
;				push	OFFSET dealer_hand_subtotal		; 16
;				push	OFFSET cards_left				; 12
;				push	OFFSET dealer_hand				; 8
;				call	Draw_Card
;				
;				mov		hit_flag, 0
;
;				push	OFFSET player_locked			; 18
;				push	player_hand_size				; 16 push by value
;				push	OFFSET player_hand				; 12 - push player hand array by reference
;				push	OFFSET player_hand_subtotal		; 8
;				call	Evaluate_Hand
;
;				jmp		show_gameboard
;			.endif
;
;		; If someone has not Stood / Bust yet, keep playing
;		.if player_locked != 1 || dealer_locked != 1
;			jmp decide_whose_turn
;		.endif
;
;		; Otherwise, pick a hand winner
;		pick_a_winner:
;			final_eval_player_hand:
;				push	OFFSET player_locked			; 18
;				push	player_hand_size				; 16 push by value
;				push	OFFSET player_hand				; 12 - push player hand array by reference
;				push	OFFSET player_hand_subtotal		; 8
;				call	Evaluate_Hand
;
;			final_eval_dealer_hand:
;				push	OFFSET dealer_locked			; 18
;				push	dealer_hand_size				; 16 - push by value
;				push	OFFSET dealer_hand				; 12 - push player hand array by reference
;				push	OFFSET dealer_hand_subtotal		; 8
;				call	Evaluate_Hand
;
;			push	OFFSET dealer_tied				; 24
;			push	dealer_hand_subtotal			; 20
;			push	player_hand_subtotal			; 16
;			push	OFFSET dealer_got_more_points	; 12
;			push	OFFSET you_got_more_points		; 8
;			call	Pick_Winner
;
;			jmp hand_loop
;
;	game_end:
;		push	OFFSET exit_message				; 12
;		push	OFFSET divider					; 8
;		call	Exit_Blackjack

	exit

main ENDP

; =============================================================================================
;         Procedure: Title_Screen
;       Description: Display Blackjack in Space title screen
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Title_Screen proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	call	Crlf	
;	stringMacro [ebp + 8]
;	stringMacro [ebp + 12]
;	stringMacro [ebp + 16]
;	stringMacro [ebp + 20]
;	stringMacro [ebp + 24]
;	call	Crlf
;
;	popad
;	pop ebp
;
;	ret 24								; 6 parameters * 4 BYTEs = return 24
;Title_Screen ENDP

; =============================================================================================
;         Procedure: Start_Game
;       Description: Reset cards and points
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Start_Game proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	stringMacro [ebp + 8]				; Instruct player to get to 10 points first
;	call	ReadInt
;
;	; Reset points and start over game
;	mov		game_over_flag, 0
;	mov		dealer_points, 0
;	mov		player_points, 0
;
;	popad
;	pop ebp
;
;	ret 4
;Start_Game ENDP

; =============================================================================================
;         Procedure: Start_Hand
;       Description: Reset cards and points
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Start_Hand proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	stringMacro [ebp + 8]				; Instruct player to press enter to start new hand
;	call	ReadInt
;	
;	mov		whose_turn, 0
;	mov		hand_over_flag, 0
;
;	; Reset hands
;	mov		player_hand_size, 0
;	mov		player_hand_subtotal, 0
;	mov		dealer_hand_size, 0
;	mov		dealer_hand_subtotal, 0
;
;	; No one has gone Bust or chosen to Stand, so scores are not locked in
;	mov		player_locked, 0
;	mov		dealer_locked, 0
;
;	; Shuffle cards (adds back 4 of each type of card to the deck)
;	mov		esi, [ebp + 12]
;	mov		ebx, 4
;	mov		ecx, 13
;	reset_cards:
;		mov [esi], ebx
;		add esi, type dword
;		loop reset_cards
;
;	popad
;	pop ebp
;
;	ret 8
;Start_Hand ENDP

; =============================================================================================
;         Procedure: Draw_Card
;       Description: Draws a card and places it in hand
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Draw_Card proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	try_random_draw:
;		mov		eax, 13                 ; Keeps the range 0 - 12
;		call	RandomRange
;		add		eax, 1					; Add 1 to bump range up to: 1 - 13
;		mov		card, eax				; Stash card index for safe-keeping
;		mov		ebx, 4
;		mul		ebx						; Multiplies the result by 4 to get array address
;		mov		edi, eax				; Moves this value into edi to get array value
;		cmp		cards_left[edi], 0		; Compare given index of array to 0. The value for each
;										; card type is 4 at the start of a hand, representing
;										; 4 of each card value in deck, e.g. 4 aces, 4 jacks, etc.
;		je		try_random_draw		    ; IF it's 0, there are no more of that card type to draw,
;										; and the draw_card subroutine should run again.
;
;		sub		cards_left[edi], 1 		; Card drawn is valid and is removed from deck
;
;	find_spot_for_card:
;		mov		ebx, [ebp + 20]			; hand size addr
;		mov		ecx, [ebx]				; hand size value
;		.if ecx == 0
;			mov		esi, [ebp + 8]			; !# load hand addr
;			jmp add_card_to_hand
;		.else
;			mov		esi, [ebp + 8]			; !# load hand addr
;			find_open_spot_in_array:
;				add		esi, type dword			; Move array address to next available spot
;				loop	find_open_spot_in_array
;			jmp add_card_to_hand
;		.endif
;
;	add_card_to_hand:
;		mov		eax, card
;		mov		[esi], eax				; Store card value in array
;
;		; Increment Hand Size			;#
;		mov		ebx, [ebp + 20]			; !# load hand size addr
;		mov		eax, [ebx]				;#
;		add		eax, 1					;# Increment player hand size
;		mov		[ebx], eax				;# Load the value of the hand size into ecx
;
;	popad
;	pop ebp
;
;	ret 16
;Draw_Card ENDP

; =============================================================================================
;         Procedure: Evaluate_Hand
;       Description: Called after there are cards in hand to evaluate points
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Evaluate_Hand proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	mov	ecx, [ebp + 16] ; size of hand loop counter
;	mov	esi, [ebp + 12] ; hand array address
;	mov eax, 0			; what card are we on?
;	count_hand:
;		mov	edi, [esi]
;
;		.if edi == 1
;			add eax, 11  ; ace default value
;		.elseif edi > 9
;			add eax, 10  ; 10 or face card
;		.else
;			add eax, edi ; numbered cards
;		.endif
;
;		add		esi, type dword			; Move array address to next available spot
;
;		loop	count_hand
;
;	; Record Points
;	mov		ebx, [ebp + 8]			; Load the address of the hand subtotal into ebx
;	mov		[ebx], eax				; ! Record points
;
;	.if eax > 21				; If hand is now over 21, look for Aces to reduce
;		mov	ecx, [ebp + 16]		; size of hand
;		mov	esi, [ebp + 12]		; hand array address (resets to beginning of array)
;		mov eax, 0
;
;		recount_hand:
;			.if edi > 9
;				add eax, 10  ; 10 or face card
;			.else
;				add eax, edi ; numbered cards and aces
;			.endif
;			
;			loop recount_hand
;	.endif
;	
;	mov		ebx, [ebp + 8]			; Load the address of the hand subtotal into ebx
;	mov		[ebx], eax				; ! Record points
;	
;	popad
;	pop ebp
;
;	ret 12
;Evaluate_Hand ENDP

; =============================================================================================
;         Procedure: Show_Game
;       Description: Displays current scores and cards, presents player with choices
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Show_Game proc
;	push		ebp				; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	stringMacro  [ebp + 8]		; divider
;	stringMacro	 [ebp + 12]		; score_box_top
;	stringMacro	 [ebp + 16]		; score_box_left
;	mov		eax, [ebp + 32]		; player points
;	call	WriteDec
;	stringMacro	 [ebp + 20]		; score_box_center
;	mov		eax, [ebp + 36]		; dealer points
;	call	WriteDec
;	stringMacro	 [ebp + 24]		; score_box_right
;	stringMacro	 [ebp + 28]		; score_box_bottom
;
;	popad
;	pop ebp
;
;	ret 32
;Show_Game ENDP

; =============================================================================================
;         Procedure: Player_Turn
;       Description: Player chooses to do stuff
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Player_Turn proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	; See if the player's score is locked in. If so, jump to end of turn.
;	cmp player_locked, 1
;	je End_Turn
;
;	; If player is not locked in, give them the option to hit or stand
;	stringMacro [ebp + 8]	 ; hit_or_stand
;	call	ReadInt
;
;	cmp		eax, 1			; See if the player chose 1 for Hit
;	je		Hit
;
;	cmp		eax, 2			; See if the player chose 2 for Stand
;	je		Stand
;
;	Hit:
;		call	Crlf
;		stringMacro [ebp + 12]
;		call	Crlf
;		mov		hit_flag, 1
;		jmp		End_Turn
;	Stand:
;		call	Crlf
;		stringMacro [ebp + 16]
;		call	Crlf
;		mov		player_locked, 1 		; set stand flag
;		mov		hit_flag, 0
;
;		jmp		End_Turn
;	End_Turn:
;		mov	whose_turn, 1				; The dealer goes next
;
;	popad
;	pop ebp
;
;	ret 12
;Player_Turn ENDP

; =============================================================================================
;         Procedure: Dealer_Turn
;       Description: Dealer behavior: will hit if hand is 17 or less, stand otherwise
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Dealer_Turn proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	; See if the dealer's score is locked in. If so, jump to end of turn.
;	cmp dealer_locked, 1
;	je End_Turn
;
;	mov		eax, dealer_hand_subtotal
;	cmp		eax, 17
;	jle		Hit
;
;	jmp		Stand
;
;	Hit:
;		call	Crlf
;		stringMacro [ebp + 8]
;		call	Crlf
;		mov		hit_flag, 1
;		jmp		End_Turn
;	Stand:
;		call	Crlf
;		stringMacro [ebp + 12]
;		call	Crlf
;
;		mov		dealer_locked, 1
;		mov		hit_flag, 0
;
;		jmp		End_Turn
;
;	End_Turn:
;		mov		whose_turn, 0	; The player goes next
;
;	popad
;	pop ebp
;
;	ret 8
;Dealer_Turn ENDP

; =============================================================================================
;         Procedure: Check_Win
;       Description: Check for player or dealer blackjack or bust
;          Receives: none
;           Returns: none
; Registers Changed: EAX, EDX
; =============================================================================================
;Check_Win proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	mov eax, [ebp + 16] ; give EAX the points
;	mov ebx, [ebp + 20] ; give EBX the player or dealer flag
;	.if eax > 21
;		stringMacro [ebp + 8]		; Inform of going bust
;		; GO BUST
;		.if ebx == 1		; if this is the player who went bust
;			add		dealer_points, 1	; Give dealer 1 point
;			mov		dealer_locked, 1
;			mov		player_locked, 1
;		.else
;			add		player_points, 1	; Give dealer 1 point
;			mov		dealer_locked, 1
;			mov		player_locked, 1
;		.endif
;
;		mov		hand_over_flag, 1	; Set flag that this hand is over
;		call	Crlf
;	; BLACKJACK
;	.elseif eax == 21
;		stringMacro [ebp + 12]		; Tell player they got Blackjack
;
;		.if ebx == 1		; if this is the player who got blackjack
;			add		player_points, 1	; Give dealer 1 point
;			mov		dealer_locked, 1
;			mov		player_locked, 1
;		.else
;			add		dealer_points, 1	; Give dealer 1 point
;			mov		dealer_locked, 1
;			mov		player_locked, 1
;		.endif
;
;		mov		hand_over_flag, 1	; Set flag that this hand is over
;		call	Crlf
;	.else
;		; continue
;	.endif
;
;	popad
;	pop ebp
;
;	ret 8
;Check_Win ENDP

; =============================================================================================
;         Procedure: Pick_Winner
;       Description: If both player and dealer stand, pick a winner based on hand points value
;          Receives: none
;           Returns: none
; Registers Changed: EAX, EDX
; =============================================================================================
;Pick_Winner proc
;	push		ebp						; Set up the stack frame
;	mov			ebp, esp
;	pushad
;
;	mov		dealer_locked, 1
;	mov		player_locked, 1
;
;	mov eax, [ebp + 20]	; dealer's hand subtotal
;	mov ebx, [ebp + 16] ; player's hand subtotal
;
;	.if eax > ebx ; if player's hand is more than dealer's
;		stringMacro [ebp + 8]		; Player got more points without going over 21! Win a point
;		add		player_points, 1	; Give dealer 1 point
;		mov		hand_over_flag, 1	; Set flag that this hand is over
;		call	Crlf
;
;	.elseif ebx > eax ; if dealer's hand is equal to or more than player's
;		stringMacro [ebp + 12]		; Dealer got more points without going over 21! They win a point
;		add		dealer_points, 1	; Give dealer 1 point
;		mov		hand_over_flag, 1	; Set flag that this hand is over
;		call	Crlf
;	.else ; a tie! dealer wins. :(
;		stringMacro [ebp + 24]		; Dealer got more points without going over 21! They win a point
;		add		dealer_points, 1	; Give dealer 1 point
;		mov		hand_over_flag, 1	; Set flag that this hand is over
;
;		call	Crlf
;	.endif
;
;	popad
;	pop ebp
;
;	ret 20
;Pick_Winner ENDP

; =============================================================================================
;         Procedure: Print_Hand
;		   Receives: hand_size (by value), hand array (by reference), card display array (by reference),
;					 strings of card slices to construct a picture of a card in terminal (by reference)
;		    Returns: N/A
;	  Preconditions: ?
; Registers changed: ?
; =============================================================================================
;Print_Hand	proc
;	push		ebp
;	mov			ebp, esp
;	pushad
;
;	stringMacro	[ ebp + 52 ]			; Print whose hand is being shown (Your hand or dealer's hand)
;	call	Crlf
;
;	; CARD TOP SLICES (print top sections of cards)
;	call Card_Spacer
;	mov		ecx, [ebp + 8]			; Number of cards in hand moved to ECX loop counter
;	
;	print_card_top:
;		stringMacro [ ebp + 20 ]		; card top
;		stringMacro [ ebp + 48 ]		; spacer
;		loop	print_card_top
;
;	call	Crlf
;
;
;	; CARD FIRST NUMBER SLICES (print the second-to-top pieces of cards that show the card value for the first time)
;	call Card_Spacer
;	mov		ecx, [ ebp + 8 ]			; hand_size in ECX loop counter
;	mov		on_card, 0					; what card are we printing now?
;	mov		ebx, [ebp + 64]				; player vs. dealer flag
;	
;	; Card Face-Down? if printing dealer's hand, it's the first card, and player has not Stood/Gone Bust, hide card.
;	.if on_card == 0 && ebx == 0 && player_locked == 0
;		stringMacro [ebp + 68]			; Face down slice
;		stringMacro [ ebp + 48 ]		; Maintain space between cards
;		sub		ecx, 1
;		inc		on_card
;	.endif
;
;	print_card_slice_2:
;		stringMacro [ ebp + 24 ]		; card slice 2a
;
;		; get to address where card index is
;		mov		esi, [ ebp + 12 ]	; player or dealer hand array
;		mov		eax, on_card
;		mov		ebx, 4
;		mul		ebx
;		add		esi, eax
;		mov		eax, [esi]
;		mov		card, eax
;
;		.if (card > 1) && (card < 11)
;			call WriteDec
;		.else
;			call Face_Cards
;		.endif
;
;		check_for_spacer:
;			.if	card != 10						; 10 is the only card to need two-digit offset. other cards get a spacer
;				stringMacro [ ebp + 48 ]		; spacer
;			.endif
;		
;		stringMacro [ ebp + 28 ]			; Card slice 2b
;
;		maintain_space_between_cards:
;			stringMacro [ ebp + 48 ]			; Maintain space between cards
;			inc		on_card
;			loop	print_card_slice_2
;
;	call	Crlf
;
;	; CARD MIDDLE SLICES (print middle sections of cards)
;	begin_middle_slices:
;		mov		ecx, 3							; Initialize loop counter to print card middle slices
;		mov		card_middles, 0					; Reset middle counter so that EACH card gets three middle slices
;	
;	print_middle:								; Outer Loop: loop once per card in hand
;		call	Card_Spacer
;		mov		card_middles, 0
;		mov		on_card, 0							; what card are we printing now?
;
;		middle_of_each_card:					; Inner Loop: loop three times for each card
;			mov		ebx, [ebp + 64]				; player vs. dealer flag
;			.if on_card == 0 && ebx == 0 && player_locked == 0
;				stringMacro [ebp + 68]			; face down card slice
;			.else
;				stringMacro [ ebp + 32 ]			; Print middle slice
;			.endif
;
;			stringMacro [ ebp + 48 ]			; Maintain space between cards
;
;			inc		card_middles				; Increment counter once a card middle is printed
;			inc		on_card
;
;			mov		eax, [ ebp + 8 ]			; Bring the variable hand_size into EAX
;			cmp		card_middles, eax			; Do we have the right number of card middles for # of cards in hand?
;			jne		middle_of_each_card			; If not, jump back up and print another middle slice
;
;		call	Crlf							; Need three newlines total, one for each vertical slice of card middles
;		loop	print_middle				    ; Loop until it has gone three times
;	
;
;	; CARD SECOND NUMBER (print the second-to-last pieces of cards that show the card value for the second time)
;	call Card_Spacer
;	mov		ecx, [ ebp + 8 ]			; hand_size in ECX loop counter
;	mov		on_card, 0
;	mov		ebx, [ebp + 64]				; player vs. dealer flag
;	
;	; Card Face-Down? if printing dealer's hand, it's the first card, and player has not Stood/Gone Bust, hide card.
;	.if on_card == 0 && ebx == 0 && player_locked == 0
;		stringMacro [ebp + 68]			; Face down slice
;		stringMacro [ ebp + 48 ]		; Maintain space between cards
;		sub		ecx, 1
;		inc		on_card
;	.endif
;
;	print_card_slice_3:
;		stringMacro [ ebp + 36 ]				; Card slice 3a
;		
;		; get to address where card index is
;		mov		esi, [ ebp + 12 ]	; player or dealer hand array
;		mov		eax, on_card
;		mov		ebx, 4
;		mul		ebx
;		add		esi, eax
;		mov		eax, [esi]
;		mov		card, eax
;
;		second_card_spacer:
;			.if	card != 10						; 10 is the only card to need two-digit offset. other cards get a spacer
;				stringMacro [ ebp + 48 ]		; spacer
;			.endif
;
;		.if (card != 1) && (card < 11)
;			call WriteDec
;		.else
;			call Face_Cards
;		.endif
;
;		stringMacro [ ebp + 40 ]		; card slice 3b
;		stringMacro [ ebp + 48 ]		; spacer
;		inc		on_card
;		loop	print_card_slice_3
;
;	call	Crlf
;
;	; CARD BOTTOM SLICES (print bottom sections of cards)
;	call Card_Spacer
;	mov		ecx, [ ebp + 8 ]			; Move hand size into ECX !
;	print_card_bottom:
;		stringMacro [ ebp + 44 ]		; card bottom slice
;		stringMacro [ ebp + 48 ]		; spacer
;		loop	print_card_bottom
;
;	call	Crlf
;
;	; If printing the player's hand, also show their points subtotal
;	mov ebx, [ebp + 16]	; player vs. dealer flag
;	.if ebx == 1 || (dealer_locked == 1)
;		stringMacro [ebp + 72]
;		mov		eax, [ebp + 80]
;		call	WriteDec
;		stringMacro [ebp + 76]
;	.endif
;
;	call	Crlf
;	call	Crlf
;
;	popad
;	pop ebp
;	ret 72
;Print_Hand ENDP

; =============================================================================================
;         Procedure: Face_Cards
;       Description: After game ends, player is presented with options to play new game or quit
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Face_Cards proc
;	push		ebp
;	mov			ebp, esp
;	pushad
;
;	mov eax, card
;	.if card == 11
;		mov edx, offset jack
;		call WriteString
;
;	.elseif card == 12
;		mov edx, offset queen
;		call WriteString
;
;	.elseif card == 13
;		mov edx, offset king
;		call WriteString
;
;	.else
;		mov edx, offset ace
;		call WriteString
;
;	.endif
;
;	popad
;	pop ebp
;
;	ret	
;Face_Cards endp

; =============================================================================================
;         Procedure: Card_Spacer
;       Description: After game ends, player is presented with options to play new game or quit
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Card_Spacer proc
;	push		ebp
;	mov			ebp, esp
;	pushad
;
;	mov edx, offset spacer
;	mov ecx, 5
;	space_loop:
;		call WriteString
;		loop space_loop
;
;	popad
;	pop ebp
;
;	ret	
;Card_Spacer endp

; =============================================================================================
;         Procedure: Exit_Blackjack
;       Description: After game ends, player is presented with options to play new game or quit
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
;Exit_Blackjack proc
;	push		ebp
;	mov			ebp, esp
;	pushad
;
;	call	Crlf	
;	stringMacro [ebp + 8]	; divider
;	call	Crlf
;	stringMacro [ebp + 12]	; play again or quit choice
;	call	ReadInt			
;
;	popad
;	pop ebp
;
;	ret 8	
;Exit_Blackjack	ENDP

end main