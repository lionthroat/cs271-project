TITLE BlackjackInSpace.asm
;
;     Authors:    Kingsley Chukwu and Heather DiRuscio
;        Game:    Blackjack in Space
;   Submitted:    March 6, 2020
;
;         For:    CS 271 Final Project in MASM x86,
;			      Game Development Option
;			      Oregon State University,
;			      Winter 2020 Term
;
;      GitHub:    https://github.com/wrongenvelope/cs271-project
;
; Description:	  The game is a simple implementation of blackjack, where the user is
;				  the Player, and you play against the computer, which operates as the
;				  Dealer. As the Player, you can choose to Hit or Stand on each turn.
;				  Hit will result in another card being drawn from the deck of 52, and added
;				  to your hand. The gameboard will then redisplay, showing you all of your
;				  cards and your new hand subtotal. At this point, your hand will also be
;				  evaluated to see if you have achieved Blackjack or gone Bust. Getting
;				  21 points earns you Blackjack and you will get a point, while ending with
;				  22 points or more is Bust and the Dealer will get a point. The cards don't
;				  appear to have suits, but there are four of each card value, like a typical
;				  deck.
;
;				  During gameplay of a hand, you can only see your whole hand and subtotal,
;				  and one of the Dealer's cards will appear to be face down. You do not know
;				  the value of the Dealer's hand. The Dealer has its own set of behaviors, and
;				  will choose whether to Hit or Stand without input from the Player. If you fail
;				  to get 10 points (win 10 hands) before the Dealer does, you will lose the game.
;				  If you manage to get 10 points (win 10 hands) first, you win.
;
; Procedures:
;	1)	Main Procedure	| - drives other procedures
;	2)	Title_Screen	| - displays graphical title screen
;   3)	Start_Game		| - initialize player/dealer points to 0
;	4)  Start_Hand		| - empty player/dealer hands, reset card deck
;	5)  Draw_Card		| - add one card to player or dealer hand
;	6)  Evaluate_Hand	| - evaluate sum of points values for all cards in one hand
;	7)  Show_Game		| - set up "gameboard" display with scorebox
;	8)	Check_Win		| - check for blackjack/bust conditions
;	9)	Print_Hand		| - print out all cards from one hand in a row
;  10)	Face_Cards		| - helper procedure to display value on face cards
;  11)  Card_Spacer		| - helper procedure to space cards from left edge of terminal
;  12)  Player_Turn		| - player can choose to Hit or Stand
;  13)	Dealer_Turn		| - dealer will decide to Hit or Stand
;  14)	Pick_Winner		| - if both player and dealer Stand, see who has more points
;  15)  Game_Over		| - display won or lost game screen
;  16)  Exit_Blackjack	| - prompt player to play again or quit
;
; Known issues:
; 1. The dealer's full hand (including face-down card) is not always revealed at the end
;    of a hand. It works as intended if a player chooses to Stand, but the flags aren't
;    set correctly if they choose Hit.
; 2. In hands with multiple Aces where the value of the Ace would be reduced from 11 to 1,
;	 only one Ace might be counted. (E.g. a hand with A, 2, A would have a value of 3 instead of 4)
; 3. Player hands that bust are frequently evaluated to "30" instead of their actual points value.
;    The determination of whether someone has Bust seems correct, but the ending value displayed is not.
;
; Feature Wishlist:
; 1. A betting system
; 2. More space-themed stuff (the dealer is supposed to be an alien)
; 3. Display things on the screen without scrolling, i.e. clear the screen and redisplay after drawing a card
; 4. Suits to display on cards
; 5. Additional input validation

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
	on_card				DWORD	?
	card_middles		DWORD	?
	divider				BYTE	"         ________________________________________________________________________",13,10,0


	; cards_left initializes a full deck of 52: 4 aces, 4 2's, 4 3's ... 4 Queens, 4 Kings
	cards_left			DWORD    4,   4,   4,   4,   4,   4,   4,   4,   4,   4,    4,   4,   4
	ace					BYTE	"A",0
	jack				BYTE	"J",0
	queen				BYTE	"Q",0
	king				BYTE	"K",0

	; These next 6 title_blocks display the game's name at the beginning of the program. Note that
	; while one BYTE can display multiple lines of text, it seems like they run out of capacity at
	; about 4 lines, and the program breaks. So the main screen has been split into slices.
	title_block1	    BYTE "                      ______ _            _    _            _                       ",13,10,
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

	ship_block1			byte "                                                                                    ",13,10,
							 "      __   __                 *                               *     .--.            ",13,10,0
	ship_block2			byte "      \ \ / ___  _   _                                             / /  `        	* ",13,10,
							 "       \ V / _ \| | | |                                           | |    	          ",13,10,
							 "        | | (_) | |_| |_________________________________/\________ \ \__,___   	  ",13,10,
							 "        |_|\___/ \___.|                +              .'  '.        '--'    |		  ",13,10,0
	ship_block3			byte "             |                                *      /======\      +        |		  ",13,10,
							 "             |    __   *    __          _           ;:.  _   ;       *      |		  ",13,10,             
							 "             |    \ \      / ___ _ __  | |          |:. (_)  |              |		  ",13,10, 
							 "             |     \ \ /\ / / _ \ ' _ \| |          |:.  _   |              |		  ",13,10,0							 
	ship_block4			byte " *           |      \ V  V | (_) | | | |_|   +      |:. (_)  |      *       |		  ",13,10,
							 "             |       \_/\_/ \___/|_| |_(_)          ;:.      ;              |		  ",13,10,
							 "        +    |                                    .' \:.    / `.        +   |		  ",13,10,                                                                             
							 "             |   You get in your rocket ship     / .-'':._.'`-. \           |		  ",13,10,0
	ship_block5			byte "             |   and go explore the stars!       |/    /||\    \|           |		* ",13,10,
							 "             |   Congrats!                     _.|---[/-||-\]---|.._        |		  ",13,10,
							 "             |     *                     _.-'``                    ``'-._   |		  ",13,10,
							 "             |_________________________-'                                '-_|		  ",13,10,0

	lose_block1			byte "                                                                                    ",13,10,
							 "        __   __         *        +                        *                	      ",13,10,0
	lose_block2			byte "        \ \ / ___  _   _                                _____              	*     ",13,10,
							 "         \ V / _ \| | | |                           ___/(0_0)\___         	      ",13,10,
							 "          | | (_) | |_| |__________________________/ - '-----' - \__________ 	      ",13,10,
							 "          |_|\___/ \___.|               +          '--_________--'          |   	  ",13,10,0
	lose_block3			byte "             |                                *       ;=======;     +       |		  ",13,10,
							 "             |     _                 _     _           /     \              |		  ",13,10,             
							 "      +      |    | |    ___  ___  _| |_  | |          /     \              |		  ",13,10, 
							 "             |    | |   / _ \| __||__  _| | |          /     \              |		  ",13,10,0							 
	lose_block4			byte " *           |    | |__| (_) \__ \  | |_  |_|  +       /     \       *      |		  ",13,10,
							 "             |    |_____|___/|___/  |__/  (_)          /     \              |		  ",13,10,
							 "             |                                         / \O/ \              |		  ",13,10,                                                                             
							 "             |   You're abducted by aliens.            /  |  \              |		  ",13,10,0
	lose_block5			byte "             |   Well, that's one way to see           / / \ \              |		* ",13,10,
							 "      *      |   outer space.                  _.\|/-\|-\|/--/-\|/._        |		  ",13,10,
							 "             |     *                     _.-'``                    ``'-._   |		  ",13,10,
							 "             |_________________________-'                                '-_|		  ",13,10,0     

	; This short instructional prompt displays once at the beginning of the game
	begin_game_prompt	BYTE "    	                 ---- Get 10 points before the dealer! ----",13,10,
							 "                              [ PRESS ENTER TO BEGIN GAME ]	        ",0
	begin_hand_prompt	BYTE "                     [ PRESS ENTER TO SHUFFLE CARDS & START NEW HAND ]	        ",0

	; FLAGS
	hand_over_flag		DWORD	?	; When the hand_over_flag is set to 1, one hand of blackjack has been completed
	play_again			DWORD	?
	player_flag			DWORD	1
	dealer_flag			DWORD	0
	player_locked		DWORD	?		; When player stands or busts, their score becomes locked in for that hand
	dealer_locked		DWORD	?		; When dealer stands or busts, their score becomes locked in for that hand
	hit_flag			DWORD	0

	player_points		 DWORD	?
	player_hand_msg		 BYTE	"     Your Hand: ",0
	player_hand			 DWORD	15 DUP(?)
	player_hand_size	 DWORD	?
	player_hand_subtotal DWORD	?

	dealer_points		 DWORD	?
	dealer_hand_msg		 BYTE	"     Dealer's Hand: ",0
	dealer_hand			 DWORD	15 DUP(?) 
	dealer_hand_size	 DWORD	?
	dealer_hand_subtotal DWORD  ?


	score_box_top		BYTE	"                                                         ______________________",13,10,
								"                                                         |     Game Score:    |",13,10,
								"                                                         |  Player  | Dealer  |",13,10,0
	score_box_left		BYTE	"                                                         |     ",0
	score_box_center	BYTE	"    |    ",0
	score_box_right		BYTE	"    |",13,10,0
	score_box_bottom	BYTE	"                                                         |__________|_________|",13,10,0

	hit_or_stand		BYTE    "         1. Hit",13,10,
								"         2. Stand",13,10,
								"         Your choice: ",0

	you_chose_hit		BYTE	"		  You chose to hit!",0
	you_chose_stand		BYTE	"		  You chose to stand!",0
	you_got_blackjack	BYTE	"                            YOU GOT BLACKJACK! You get a point.",0
	you_went_bust		BYTE	"                            YOU WENT BUST! Dealer gets a point.",0
	you_got_more_points	BYTE	"                            You got more points! You win this hand.",0

	dealer_chose_hit	BYTE	"		  The dealer chose to hit!",0
	dealer_chose_stand	BYTE	"		  The dealer chose to stand!",0
	dealer_got_blackjack BYTE	"                      THE DEALER GOT BLACKJACK! Dealer gets a point.",0
	dealer_went_bust	BYTE	"                            DEALER WENT BUST! You get a point",0
	dealer_got_more_points	BYTE	"                        Dealer got more points! You lose this hand.",0
	dealer_tied			BYTE	"                        You tied with the Dealer! You lose this hand.",0
	show_subtotal_1		BYTE	"     (Hand Total: ",0
	show_subtotal_2		BYTE	")",0

	; CARD PICTURE
	card_slice_top		BYTE ".--------.",0                                               
	card_slice_2a		BYTE "|",0
	spacer				BYTE " ",0
	card_slice_2b		BYTE ".--.  |",0
	card_slice_middle	BYTE "|  |  |  |",0     ; need this to print three times in a row to build middle                                              
    card_slice_3a       BYTE "|  '--'",0
	card_slice_3b		BYTE "|",0
	card_slice_bottom	BYTE "`--------'",0
	card_hidden_slice	BYTE "| ****** |",0 
	exit_message		BYTE	"         What would you like to do now?",13,10,
								"         1. Play again				",13,10,
								"         2. Quit						",13,10,
								"         Your choice: ",0


    card_1      byte   "A",0
    card_2     byte   "2",0
    card_3     byte   "3",0
    card_4     byte   "4",0
    card_5     byte   "5",0
    card_6     byte   "6",0
    card_7    byte   "7",0
   card_8     byte   "8",0
   card_9    byte   "9",0
    card_10     byte   "10",0
   card_11    byte   "J",0
   card_12   byte   "Q",0
   card_13    byte   "K",0
   disp_card  dword  13  DUP(?)


.code

; =============================================================================================
;         Procedure: main
;       Description: Calls other procedures to drive the program.
;          Receives: none
;           Returns: none
; Registers Changed: none
; =============================================================================================
main proc
    call Fillcardarray
    call	Randomize						; Sets seed

	initialize_game:
		push	OFFSET title_block5				; 24
		push	OFFSET title_block4				; 20
		push	OFFSET title_block3				; 16
		push	OFFSET title_block2				; 12
		push	OFFSET title_block1				; 8
		call	Title_Screen					; call graphical title screen
	
		push	OFFSET begin_game_prompt		; 8
		call	Start_Game

	game_loop:
		cmp		player_points, 10			; If player has 10 points, they won.
		je		player_won

		cmp		dealer_points, 10			; If dealer got 10 points first, they win.
		je		dealer_won

		hand_loop:
			push	OFFSET cards_left				; 12
			push	OFFSET begin_hand_prompt		;  8
			call	Start_Hand						; Starts new hands for dealer and player with 2 cards each
		
		mov ecx, 2
		deal_starting_cards_to_player:
			push	OFFSET player_hand_size			; 20
			push	OFFSET player_hand_subtotal		; 16
			push	OFFSET cards_left				; 12
			push	OFFSET player_hand				; 8
			call	Draw_Card
			loop	deal_starting_cards_to_player
			
		mov ecx, 2
		deal_starting_cards_to_dealer:
			push	OFFSET dealer_hand_size			; 20
			push	OFFSET dealer_hand_subtotal		; 16
			push	OFFSET cards_left				; 12
			push	OFFSET dealer_hand				; 8
			call	Draw_Card
			loop	deal_starting_cards_to_dealer

		show_gameboard:
			push	dealer_points					; 36
			push	player_points					; 32
			push	OFFSET	score_box_bottom		; 28
			push	OFFSET	score_box_right			; 24
			push	OFFSET	score_box_center		; 20
			push	OFFSET	score_box_left			; 16
			push	OFFSET	score_box_top			; 12
			push	OFFSET	divider					; 8
			call	Show_Game						; Display scores and cards

		evaluate_player_hand:
			push	OFFSET player_locked			; 18
			push	player_hand_size				; 16 push by value
			push	OFFSET player_hand				; 12 - push player hand array by reference
			push	OFFSET player_hand_subtotal		; 8
			call	Evaluate_Hand

		evaluate_dealer_hand:
			push	OFFSET dealer_locked			; 18
			push	dealer_hand_size				; 16 - push by value
			push	OFFSET dealer_hand				; 12 - push player hand array by reference
			push	OFFSET dealer_hand_subtotal		; 8
			call	Evaluate_Hand

		print_player_hand:
			push	player_hand_subtotal			; 80 - push subtotal by value
			push	OFFSET show_subtotal_2			; 76 - push subtotal display slice by reference
			push	OFFSET show_subtotal_1			; 72 - push subtotal display slice by reference
			push	OFFSET card_hidden_slice		; 68 - push card slice by reference
			push	player_flag						; 64 - push by value
			push	player_locked					; 60 - push by value
			push	dealer_locked					; 56 - push by value
			push	OFFSET player_hand_msg			; 52 - push message string by reference
			push	OFFSET spacer					; 48 - push spacer string by reference
			push	OFFSET card_slice_bottom		; 44 - push card slice by reference
			push	OFFSET card_slice_3b			; 40 - push card slice by reference
			push	OFFSET card_slice_3a			; 36 - push card slice by reference
			push	OFFSET card_slice_middle		; 32 - push card slice by reference
			push	OFFSET card_slice_2b			; 28 - push card slice by reference
			push	OFFSET card_slice_2a			; 24 - push card slice by reference
			push	OFFSET card_slice_top			; 20 - push card slice by reference
			push	player_flag						; 16 - flag so no cards are hidden from user
			push	OFFSET player_hand				; 12 - push player hand array by reference
			push	player_hand_size				; 8  - push player hand size (# of cards) by value
			call	Print_Hand

		print_dealer_hand:
			push	dealer_hand_subtotal			; 80 - push subtotal by value
			push	OFFSET show_subtotal_2			; 76 - push subtotal display slice by reference
			push	OFFSET show_subtotal_1			; 72 - push subtotal display slice by reference
			push	OFFSET card_hidden_slice		; 68 - push card slice by reference
			push	dealer_flag						; 64 - push by value
			push	player_locked					; 60 - push by value
			push	dealer_locked					; 56 - push by value
			push	OFFSET dealer_hand_msg			; 52 - push message string by reference
			push	OFFSET spacer					; 48 - push spacer string by reference
			push	OFFSET card_slice_bottom		; 44 - push card slice by reference
			push	OFFSET card_slice_3b			; 40 - push card slice by reference
			push	OFFSET card_slice_3a			; 36 - push card slice by reference
			push	OFFSET card_slice_middle		; 32 - push card slice by reference
			push	OFFSET card_slice_2b			; 28 - push card slice by reference
			push	OFFSET card_slice_2a			; 24 - push card slice by reference
			push	OFFSET card_slice_top			; 20 - push card slice by reference
			push	dealer_flag						; 16 - flag so the first card is hidden from user
			push	OFFSET dealer_hand				; 12 - push dealer hand array by reference
			push	dealer_hand_size				; 8  - push dealer hand size (# of cards) by value
			call	Print_Hand

		check_player:
			push	player_flag						; 20
			push	player_hand_subtotal			; 16 - points pushed by value
			push	OFFSET	you_got_blackjack		; 12
			push	OFFSET	you_went_bust			; 8
			call	Check_Win						; See if player started the game with Blackjack

			cmp		hand_over_flag, 1				; Is the hand over before any player turns?
			je		game_loop						; If so, start new hand.
		
		check_dealer:
			push	dealer_flag
			push	dealer_hand_subtotal			; 16 - points pushed by value
			push	OFFSET	dealer_got_blackjack	; 12
			push	OFFSET	dealer_went_bust		; 8
			call	Check_Win						; See if dealer started the game with Blackjack

			cmp		hand_over_flag, 1				; Is the hand over before any player turns?
			je		game_loop						; If so, start new hand.

		decide_whose_turn:

			cmp		whose_turn, 0
			je		player_goes_next

			jmp		dealer_goes_next

		player_goes_next:
			push	OFFSET	you_chose_stand			; 16
			push	OFFSET	you_chose_hit			; 12
			push	OFFSET	hit_or_stand			; 8
			call	Player_Turn						; Give player option to Hit or Stand

			; If player Hits, draw them a card then reevaluate their hand
			mov eax, hit_flag
			.if eax == 1
				push	OFFSET player_hand_size			; 20
				push	OFFSET player_hand_subtotal		; 16
				push	OFFSET cards_left				; 12
				push	OFFSET player_hand				; 8
				call	Draw_Card

				mov		hit_flag, 0

				push	OFFSET player_locked			; 18
				push	player_hand_size				; 16 push by value
				push	OFFSET player_hand				; 12 - push player hand array by reference
				push	OFFSET player_hand_subtotal		; 8
				call	Evaluate_Hand

				jmp		show_gameboard
	
			.endif

		dealer_goes_next:
			push	OFFSET	dealer_chose_stand		; 12
			push	OFFSET	dealer_chose_hit		; 8
			call	Dealer_Turn						; If dealer's hand subtotal is less than 17, dealer will Hit
			
			; If dealer Hits, draw them a card then reevaluate their hand		
			.if hit_flag == 1
				; Need to Draw a Card
				push	OFFSET dealer_hand_size			; 20
				push	OFFSET dealer_hand_subtotal		; 16
				push	OFFSET cards_left				; 12
				push	OFFSET dealer_hand				; 8
				call	Draw_Card
				
				mov		hit_flag, 0

				push	OFFSET player_locked			; 18
				push	player_hand_size				; 16 push by value
				push	OFFSET player_hand				; 12 - push player hand array by reference
				push	OFFSET player_hand_subtotal		; 8
				call	Evaluate_Hand

				jmp		show_gameboard
			.endif

		; If someone has not Stood / Bust yet, keep playing
		.if player_locked != 1 || dealer_locked != 1
			jmp decide_whose_turn
		.endif

		; Otherwise, pick a hand winner
		pick_a_winner:
			final_eval_player_hand:
				push	OFFSET player_locked			; 18
				push	player_hand_size				; 16 push by value
				push	OFFSET player_hand				; 12 - push player hand array by reference
				push	OFFSET player_hand_subtotal		; 8
				call	Evaluate_Hand

			final_eval_dealer_hand:
				push	OFFSET dealer_locked			; 18
				push	dealer_hand_size				; 16 - push by value
				push	OFFSET dealer_hand				; 12 - push player hand array by reference
				push	OFFSET dealer_hand_subtotal		; 8
				call	Evaluate_Hand

			push	OFFSET dealer_tied				; 24
			push	dealer_hand_subtotal			; 20
			push	player_hand_subtotal			; 16
			push	OFFSET dealer_got_more_points	; 12
			push	OFFSET you_got_more_points		; 8
			call	Pick_Winner

			jmp hand_loop
	
	player_won:									; player got 10 points, program jumps here
		push	OFFSET ship_block5				; 24
		push	OFFSET ship_block4				; 20
		push	OFFSET ship_block3				; 16
		push	OFFSET ship_block2				; 12
		push	OFFSET ship_block1				; 8
		call	Game_Over
		jmp		game_end

	dealer_won:									; dealer got 10 points, program jumps here
		push	OFFSET lose_block5				; 24
		push	OFFSET lose_block4				; 20
		push	OFFSET lose_block3				; 16
		push	OFFSET lose_block2				; 12
		push	OFFSET lose_block1				; 8
		call	Game_Over
		jmp		game_end

	game_end:
		push	OFFSET play_again				; 16
		push	OFFSET exit_message				; 12
		push	OFFSET divider					;  8		
		call	Exit_Blackjack

	cmp		play_again, 1		; If player chooses to play again,
	je		initialize_game		; jump to very beginning of game

	exit

main ENDP

; =============================================================================================
;         Procedure: Title_Screen
;       Description: Display Blackjack in Space title screen
;          Receives: title blocks by reference
;           Returns: none
; Registers Changed: EDX
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
;         Procedure: Start_Game
;       Description: Reset cards and points
;          Receives: player instructions by reference
;           Returns: none
; Registers Changed: EDX, EAX
; =============================================================================================
Start_Game proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	stringMacro [ebp + 8]				; Instruct player to get to 10 points first
	call	ReadInt

	; Reset points and start over game
	mov		dealer_points, 0
	mov		player_points, 0

	popad
	pop ebp

	ret 4
Start_Game ENDP

; =============================================================================================
;         Procedure: Start_Hand
;       Description: Reset cards and points
;          Receives: card array by reference, instructions by reference
;           Returns: the cards array is "shuffled" - 4 of each card type is placed in the array
; Registers Changed: ESI, EBX, ECX, EDX
; =============================================================================================
Start_Hand proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	stringMacro [ebp + 8]				; Instruct player to press enter to start new hand
	call	ReadInt
	
	mov		whose_turn, 0
	mov		hand_over_flag, 0

	; Reset hands
	mov		player_hand_size, 0
	mov		player_hand_subtotal, 0
	mov		dealer_hand_size, 0
	mov		dealer_hand_subtotal, 0

	; No one has gone Bust or chosen to Stand, so scores are not locked in
	mov		player_locked, 0
	mov		dealer_locked, 0

	; Shuffle cards (adds back 4 of each type of card to the deck)
	mov		esi, [ebp + 12]
	mov		ebx, 4
	mov		ecx, 13
	reset_cards:
		mov [esi], ebx
		add esi, type dword
		loop reset_cards

	popad
	pop ebp

	ret 8
Start_Hand ENDP

; =============================================================================================
;         Procedure: Draw_Card
;       Description: Draws a card and places it in hand
;          Receives: hand size by reference, hand array by reference
;           Returns: hand size incremented by 1, hand array with new element (a card index 1-13)
; Registers Changed: EAX, EBX, ECX, EDX, EDI, ESI
; =============================================================================================
Draw_Card proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	try_random_draw:
		mov		eax, 13                 ; Keeps the range 0 - 12
		call	RandomRange
		add		eax, 1					; Add 1 to bump range up to: 1 - 13
		mov		card, eax				; Stash card index for safe-keeping
		mov		ebx, 4
		mul		ebx						; Multiplies the result by 4 to get array address
		mov		edi, eax				; Moves this value into edi to get array value
		cmp		cards_left[edi], 0		; Compare given index of array to 0. The value for each
										; card type is 4 at the start of a hand, representing
										; 4 of each card value in deck, e.g. 4 aces, 4 jacks, etc.
		je		try_random_draw		    ; IF it's 0, there are no more of that card type to draw,
										; and the draw_card subroutine should run again.

		sub		cards_left[edi], 1 		; Card drawn is valid and is removed from deck

	find_spot_for_card:
		mov		ebx, [ebp + 20]			; hand size addr
		mov		ecx, [ebx]				; hand size value
		.if ecx == 0
			mov		esi, [ebp + 8]			; !# load hand addr
			jmp add_card_to_hand
		.else
			mov		esi, [ebp + 8]			; !# load hand addr
			find_open_spot_in_array:
				add		esi, type dword			; Move array address to next available spot
				loop	find_open_spot_in_array
			jmp add_card_to_hand
		.endif

	add_card_to_hand:
		mov		eax, card
		mov		[esi], eax				; Store card value in array

		; Increment Hand Size			;#
		mov		ebx, [ebp + 20]			; !# load hand size addr
		mov		eax, [ebx]				;#
		add		eax, 1					;# Increment player hand size
		mov		[ebx], eax				;# Load the value of the hand size into ecx

	popad
	pop ebp

	ret 16
Draw_Card ENDP

; =============================================================================================
;         Procedure: Evaluate_Hand
;       Description: Called after there are cards in hand to evaluate points. For each card in
;					 the hand, loop through and create a running tally of their points value.
;					 At first pass, Aces are worth 11 points, numbered cards are worth their index,
;					 and face cards are worth 10 points. If a hand ends at over 21 points in value,
;					 the hand is reevaluated to see if Aces need to be reduced to 1 point (their
;					 alternate value).
;          Receives: hand size by value, hand array by reference, points subtotal by reference
;           Returns: Updated points subtotal
; Registers Changed: EAX, EBX, ECX, EDX, EDI, ESI
; =============================================================================================
Evaluate_Hand proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	mov	ecx, [ebp + 16] ; size of hand loop counter
	mov	esi, [ebp + 12] ; hand array address
	mov eax, 0			; what card are we on?
	count_hand:
		mov	edi, [esi]

		.if edi == 1
			add eax, 11  ; ace default value
		.elseif edi > 9
			add eax, 10  ; 10 or face card
		.else
			add eax, edi ; numbered cards
		.endif

		add		esi, type dword			; Move array address to next available spot

		loop	count_hand

	; Record Points
	mov		ebx, [ebp + 8]			; Load the address of the hand subtotal into ebx
	mov		[ebx], eax				; ! Record points

	.if eax > 21				; If hand is now over 21, look for Aces to reduce
		mov	ecx, [ebp + 16]		; size of hand
		mov	esi, [ebp + 12]		; hand array address (resets to beginning of array)
		mov eax, 0

		recount_hand:
			.if edi > 9
				add eax, 10  ; 10 or face card
			.else
				add eax, edi ; numbered cards and aces
			.endif
			
			loop recount_hand
	.endif
	
	mov		ebx, [ebp + 8]			; Load the address of the hand subtotal into ebx
	mov		[ebx], eax				; Record points
	
	popad
	pop ebp

	ret 12
Evaluate_Hand ENDP

; =============================================================================================
;         Procedure: Show_Game
;       Description: Displays current scores and cards, presents player with choices
;          Receives: Score box pieces by references, player and dealer points by value
;           Returns: none
; Registers Changed: EAX, EDX
; =============================================================================================
Show_Game proc
	push		ebp				; Set up the stack frame
	mov			ebp, esp
	pushad

	stringMacro  [ebp + 8]		; divider
	stringMacro	 [ebp + 12]		; score_box_top
	stringMacro	 [ebp + 16]		; score_box_left
	mov		eax, [ebp + 32]		; player points
	call	WriteDec
	stringMacro	 [ebp + 20]		; score_box_center
	mov		eax, [ebp + 36]		; dealer points
	call	WriteDec
	stringMacro	 [ebp + 24]		; score_box_right
	stringMacro	 [ebp + 28]		; score_box_bottom

	popad
	pop ebp

	ret 32
Show_Game ENDP

; =============================================================================================
;         Procedure: Player_Turn
;       Description: Player has the option to Hit (get another card), or Stand (stay with their
;					 current hand). At the beginning of a turn, we check to see if the player's
;					 score is "locked" -- meaning, they went Bust or chose to Stay, but the hand
;					 is ongoing. This prevents them from seeing further options to Hit or Stand,
;					 even if it's technically their turn. If they aren't locked, they can Hit, which
;					 sets the hit_flag to 1 (true), or Stand, which locks them and sets the
;				     hit_flag to 0 (false). At the end of a turn, whose_turn switches to back to 1,
;					 which will give the dealer the next turn.
;          Receives: Strings by reference.
;           Returns: none
; Registers Changed: EAX, EDX
; =============================================================================================
Player_Turn proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	; See if the player's score is locked in. If so, jump to end of turn.
	cmp player_locked, 1
	je End_Turn

	; If player is not locked in, give them the option to hit or stand
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
		mov		hit_flag, 1
		jmp		End_Turn
	Stand:
		call	Crlf
		stringMacro [ebp + 16]
		call	Crlf
		mov		player_locked, 1 		; set stand flag
		mov		hit_flag, 0

		jmp		End_Turn
	End_Turn:
		mov	whose_turn, 1				; The dealer goes next

	popad
	pop ebp

	ret 12
Player_Turn ENDP

; =============================================================================================
;         Procedure: Dealer_Turn
;
;       Description: Dealer decides whether to Hit (get another card), or Stand (stay with their
;					 current hand). At the beginning of a turn, we check to see if the dealer's
;					 score is "locked" -- meaning, they went Bust or chose to Stay, but the hand
;					 is ongoing. This prevents them from making further actions, and helps decide
;					 if a hand is over (if both player and dealer are locked). The dealer behavior
;					 will Hit if their points subtotal is less than 17. This will set the hit_flag
;					 to 1 (true). Otherwise, they can Stand, which locks them. At the end of a turn,
;					 whose_turn switches to back to 1, which gives the player a turn next.
;
;          Receives: Strings by reference.
;           Returns: none
; Registers Changed: EAX, EDX
; =============================================================================================
Dealer_Turn proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	; See if the dealer's score is locked in. If so, jump to end of turn.
	cmp dealer_locked, 1
	je End_Turn

	mov		eax, dealer_hand_subtotal
	cmp		eax, 17
	jle		Hit

	jmp		Stand

	Hit:
		call	Crlf
		stringMacro [ebp + 8]
		call	Crlf
		mov		hit_flag, 1
		jmp		End_Turn
	Stand:
		call	Crlf
		stringMacro [ebp + 12]
		call	Crlf

		mov		dealer_locked, 1
		mov		hit_flag, 0

		jmp		End_Turn

	End_Turn:
		mov		whose_turn, 0	; The player goes next

	popad
	pop ebp

	ret 8
Dealer_Turn ENDP

; =============================================================================================
;         Procedure: Check_Win
;
;       Description: Check for player or dealer Blackjack or Bust. Note that this does not decide
;					 a winner in the event that both Dealer and Player have chosen Stand. That
;					 occurs in Pick_Winner proc. The function receives a player_flag or dealer_flag
;					 at [ebp + 20]. This tells the function who to give points to in the event
;					 that someone got Blackjack or went Bust. If someone wins, they get 1 point.
;
;          Receives: player/dealer flag by value, hand subtotal by value, blackjack and bust strings
;					 by reference
;
;           Returns: none
; Registers Changed: EAX, EBX, EDX
; =============================================================================================
Check_Win proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	mov eax, [ebp + 16] ; give EAX the points
	mov ebx, [ebp + 20] ; give EBX the player or dealer flag
	.if eax > 21
		stringMacro [ebp + 8]		; Inform of going bust
		; GO BUST
		.if ebx == 1		; if this is the player who went bust
			add		dealer_points, 1	; Give dealer 1 point
			mov		dealer_locked, 1
			mov		player_locked, 1
		.else
			add		player_points, 1	; Give dealer 1 point
			mov		dealer_locked, 1
			mov		player_locked, 1
		.endif

		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf
	; BLACKJACK
	.elseif eax == 21
		stringMacro [ebp + 12]		; Tell player they got Blackjack

		.if ebx == 1		; if this is the player who got blackjack
			add		player_points, 1	; Give dealer 1 point
			mov		dealer_locked, 1
			mov		player_locked, 1
		.else
			add		dealer_points, 1	; Give dealer 1 point
			mov		dealer_locked, 1
			mov		player_locked, 1
		.endif

		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf
	.else
		; continue
	.endif

	popad
	pop ebp

	ret 16
Check_Win ENDP

; =============================================================================================
;         Procedure: Pick_Winner
;
;       Description: If both player and dealer Stand, pick a winner based on hand points value.
;					 By standard rules, a tie with the Dealer is counted as a loss, and the
;					 Dealer gets a point. Otherwise, getting more points than the Dealer without
;					 going over 21 is a win for the Player.
;
;          Receives: player and dealer hand subtotals by value, and messaging about who won
;					 a point, by reference.
;
;           Returns: none
; Registers Changed: EAX, EBX, EDX
; =============================================================================================
Pick_Winner proc
	push		ebp						; Set up the stack frame
	mov			ebp, esp
	pushad

	mov		dealer_locked, 1
	mov		player_locked, 1

	mov eax, [ebp + 20]				; dealer's hand subtotal
	mov ebx, [ebp + 16]				; player's hand subtotal

	.if eax > ebx					; if player's hand is more than dealer's
		stringMacro [ebp + 8]		; Player got more points without going over 21! Win a point
		add		player_points, 1	; Give dealer 1 point
		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf

	.elseif ebx > eax				; if dealer's hand is equal to or more than player's
		stringMacro [ebp + 12]		; Dealer got more points without going over 21! They win a point
		add		dealer_points, 1	; Give dealer 1 point
		mov		hand_over_flag, 1	; Set flag that this hand is over
		call	Crlf
	.else							; a tie! dealer wins. :(
		stringMacro [ebp + 24]		; Dealer got more points without going over 21! They win a point
		add		dealer_points, 1	; Give dealer 1 point
		mov		hand_over_flag, 1	; Set flag that this hand is over

		call	Crlf
	.endif

	popad
	pop ebp

	ret 20
Pick_Winner ENDP

; =============================================================================================
;         Procedure: Print_Hand
;
;		Description: This is a generic function that can construct a graphical representation of either
;					 the Dealer's hand of cards, or the Player's hand of cards, depending on what values
;					 are pushed into the stack before the function is called. As long as it is passed
;					 an array with card indices, and is told how many cards are in the hand, it will
;					 build a row of cards in "slices," beginning with the tops, followed by a newline,
;					 then the number line, a newline, then 3 rows of card middles, each with newlines,
;					 then the second number line, a newline, and finally the card bottoms.
;					 It does this from top to bottom so that cards can appear to be next to each other
;					 on a gameboard and the player can see all cards on one screen, rather than a vertical
;					 list that would require scrolling. Additionally, since not being able to see all the
;					 Dealer's cards creates an element of strategy in the game, the Dealer's first card is
;					 depicted as being face-down, and no subtotal of hand points is displayed for the
;					 Dealer. A subtotal of the hand is displayed for the Player. Once the player has
;					 chosen to Stand or has gone Bust, there is no reason to conceal the Dealer's cards,
;					 so the values of all cards are shown normally.
;
;					 It had been our goal to reduce the need for conditional statements by using an
;					 array with card display values as strings (A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K),
;					 but MASM needs null-terminated strings, so this became:
;				     "A", 0, "2", 0, "3", 0, "4", 0, "5", 0, "6", 0, "7", 0, "8", 0, "9", 0, "10", 0, "J", 0, "Q", 0, "K"
;					 This appeared to build correctly, and could be iterated through by advancing by two BYTE types,
;				     (the first to skip over an array value, the second time to skip over the 0), but the BYTE data type
;					 only worked for a portion of the array before seeming to run out of allotted memory and ignoring
;					 the overflow. So, a helper-procedure was created to render face cards.
;
;
;		   Receives: hand_size (by value), hand array (by reference), card display array (by reference),
;					 strings of card slices to construct a picture of a card in terminal (by reference).
;
;		    Returns: N/A
;	  Preconditions: Hand array of either dealer or player must not be empty.
; Registers changed: EAX, EBX, ECX, EDI, ESI
; =============================================================================================
Print_Hand	proc
	push		ebp
	mov			ebp, esp
	pushad

	stringMacro	[ ebp + 52 ]			; Print whose hand is being shown (Your hand or dealer's hand)
	call	Crlf

	; CARD TOP SLICES (print top sections of cards)
	call Card_Spacer
	mov		ecx, [ebp + 8]			; Number of cards in hand moved to ECX loop counter
	
	print_card_top:
		stringMacro [ ebp + 20 ]		; card top
		stringMacro [ ebp + 48 ]		; spacer
		loop	print_card_top

	call	Crlf


	; CARD FIRST NUMBER SLICES (print the second-to-top pieces of cards that show the card value for the first time)
	call Card_Spacer
	mov		ecx, [ ebp + 8 ]			; hand_size in ECX loop counter
	mov		on_card, 0					; what card are we printing now?
	mov		ebx, [ebp + 64]				; player vs. dealer flag
	
	; Card Face-Down? if printing dealer's hand, it's the first card, and player has not Stood/Gone Bust, hide card.
	.if on_card == 0 && ebx == 0 && player_locked == 0
		stringMacro [ebp + 68]			; Face down slice
		stringMacro [ ebp + 48 ]		; Maintain space between cards
		sub		ecx, 1
		inc		on_card
	.endif

	print_card_slice_2:
		stringMacro [ ebp + 24 ]		; card slice 2a

		; get to address where card index is
		mov		esi, [ ebp + 12 ]	; player or dealer hand array
		mov		eax, on_card
		mov		ebx, 4
		mul		ebx
		add		esi, eax
		mov		eax, [esi]
		mov		card, eax

		;.if (card > 1) && (card < 11)
			;call WriteDec
		;.else
		call Face_Cards
		;.endif

		check_for_spacer:
			.if	card != 10						; 10 is the only card to need two-digit offset. other cards get a spacer
				stringMacro [ ebp + 48 ]		; spacer
			.endif
		
		stringMacro [ ebp + 28 ]			; Card slice 2b

		maintain_space_between_cards:
			stringMacro [ ebp + 48 ]			; Maintain space between cards
			inc		on_card
			loop	print_card_slice_2

	call	Crlf

	; CARD MIDDLE SLICES (print middle sections of cards)
	begin_middle_slices:
		mov		ecx, 3							; Initialize loop counter to print card middle slices
		mov		card_middles, 0					; Reset middle counter so that EACH card gets three middle slices
	
	print_middle:								; Outer Loop: loop once per card in hand
		call	Card_Spacer
		mov		card_middles, 0
		mov		on_card, 0							; what card are we printing now?

		middle_of_each_card:					; Inner Loop: loop three times for each card
			mov		ebx, [ebp + 64]				; player vs. dealer flag
			.if on_card == 0 && ebx == 0 && player_locked == 0
				stringMacro [ebp + 68]			; face down card slice
			.else
				stringMacro [ ebp + 32 ]			; Print middle slice
			.endif

			stringMacro [ ebp + 48 ]			; Maintain space between cards

			inc		card_middles				; Increment counter once a card middle is printed
			inc		on_card

			mov		eax, [ ebp + 8 ]			; Bring the variable hand_size into EAX
			cmp		card_middles, eax			; Do we have the right number of card middles for # of cards in hand?
			jne		middle_of_each_card			; If not, jump back up and print another middle slice

		call	Crlf							; Need three newlines total, one for each vertical slice of card middles
		loop	print_middle				    ; Loop until it has gone three times
	

	; CARD SECOND NUMBER (print the second-to-last pieces of cards that show the card value for the second time)
	call Card_Spacer
	mov		ecx, [ ebp + 8 ]			; hand_size in ECX loop counter
	mov		on_card, 0
	mov		ebx, [ebp + 64]				; player vs. dealer flag
	
	; Card Face-Down? if printing dealer's hand, it's the first card, and player has not Stood/Gone Bust, hide card.
	.if on_card == 0 && ebx == 0 && player_locked == 0
		stringMacro [ebp + 68]			; Face down slice
		stringMacro [ ebp + 48 ]		; Maintain space between cards
		sub		ecx, 1
		inc		on_card
	.endif

	print_card_slice_3:
		stringMacro [ ebp + 36 ]				; Card slice 3a
		
		; get to address where card index is
		mov		esi, [ ebp + 12 ]	; player or dealer hand array
		mov		eax, on_card
		mov		ebx, 4
		mul		ebx
		add		esi, eax
		mov		eax, [esi]
		mov		card, eax

		second_card_spacer:
			.if	card != 10						; 10 is the only card to need two-digit offset. other cards get a spacer
				stringMacro [ ebp + 48 ]		; spacer
			.endif

		;.if (card != 1) && (card < 11)
		;	call WriteDec
		;.else
		call Face_Cards
		;.endif

		stringMacro [ ebp + 40 ]		; card slice 3b
		stringMacro [ ebp + 48 ]		; spacer
		inc		on_card
		loop	print_card_slice_3

	call	Crlf

	; CARD BOTTOM SLICES (print bottom sections of cards)
	call Card_Spacer
	mov		ecx, [ ebp + 8 ]			; Move hand size into ECX !
	print_card_bottom:
		stringMacro [ ebp + 44 ]		; card bottom slice
		stringMacro [ ebp + 48 ]		; spacer
		loop	print_card_bottom

	call	Crlf

	; If printing the player's hand, also show their points subtotal
	mov ebx, [ebp + 16]	; player vs. dealer flag
	.if ebx == 1 || (dealer_locked == 1)
		stringMacro [ebp + 72]
		mov		eax, [ebp + 80]
		call	WriteDec
		stringMacro [ebp + 76]
	.endif

	call	Crlf
	call	Crlf

	popad
	pop ebp
	ret 72
Print_Hand ENDP

; =============================================================================================
;         Procedure: Face_Cards
;       Description: As mentioned in the Print_Hand description, this helper procedure was
;					 created to help overcome some technical limitations of rendering cards
;					 in MASM.
;          Receives: none
;           Returns: none
; Registers Changed: EAX, EDX
; =============================================================================================
Face_Cards proc
	push		ebp
	mov			ebp, esp
	pushad

	mov eax, card
	dec eax
	mov ebx, 4
	mul ebx
	mov edx, disp_card[eax]
	call WriteString
	;.if card == 11
	;	mov edx, offset jack
	;	call WriteString

	;.elseif card == 12
	;	mov edx, offset queen
	;	call WriteString

	;.elseif card == 13
	;	mov edx, offset king
	;	call WriteString

	;.else
	;	mov edx, offset ace
	;	call WriteString

	;.endif

	popad
	pop ebp

	ret	
Face_Cards endp

; =============================================================================================
;         Procedure: Card_Spacer
;       Description: The card spacer situates a row of cards on the gameboard so that they are
;					 not all the way at the left edge of the terminal window.
;          Receives: none
;           Returns: none
; Registers Changed: ECX, EDX
; =============================================================================================
Card_Spacer proc
	push		ebp
	mov			ebp, esp
	pushad

	mov edx, offset spacer
	mov ecx, 5
	space_loop:
		call WriteString
		loop space_loop

	popad
	pop ebp

	ret	
Card_Spacer endp

; =============================================================================================
;         Procedure: Game_Over
;       Description: The user has won or lost, inform them of the game's outcome
;          Receives: ship_block or lose_block strings by reference
;           Returns: none
; Registers Changed: EDX
; =============================================================================================
Game_Over proc
	push		ebp
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

	ret 20	
Game_Over	ENDP

; =============================================================================================
;         Procedure: Exit_Blackjack
;       Description: After game ends, player is presented with options to play new game or quit
;          Receives: play_again flag by reference, divider and prompt by reference
;           Returns: none
; Registers Changed: EAX, EDX
; =============================================================================================
Exit_Blackjack proc
	push		ebp
	mov			ebp, esp
	pushad

	call	Crlf	
	stringMacro [ebp + 8]	; divider
	call	Crlf
	stringMacro [ebp + 12]	; prompt user for input about whether to continue or quit
	call	ReadInt			
	mov		ebx, [ebp + 16]
	mov		[ebx], eax		; record user choice

	popad
	pop ebp

	ret 12	
Exit_Blackjack	ENDP

Fillcardarray PROC
  pushad
        mov edx, offset card_1
		mov disp_card[0], edx
		mov edx, offset card_2
		mov disp_card[4], edx
		mov edx, offset card_3
		mov disp_card[8], edx
		mov edx, offset card_4
		mov disp_card[12], edx
		mov edx, offset card_5
		mov disp_card[16], edx
		mov edx, offset card_6
		mov disp_card[20], edx
		mov edx, offset card_7
		mov disp_card[24], edx
		mov edx, offset card_8
		mov disp_card[28], edx
		mov edx, offset card_9
		mov disp_card[32], edx
		mov edx, offset card_10
		mov disp_card[36], edx
		mov edx, offset card_11
		mov disp_card[40], edx
		mov edx, offset card_12
		mov disp_card[44], edx
		mov edx, offset card_13
		mov disp_card[48], edx
   popad
 ret
Fillcardarray ENDP
end main