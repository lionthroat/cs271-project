## CS 271: Computer Architecture and Assembly Language Programming
### Final Project in MASM x86 - Game Development Option

Authors: Kingsley Chukwu and Heather North DiRuscio  
Game: Blackjack in Space  
Oregon State University, Winter 2020 Term  
Submitted: March 6, 2020  

##### Program Description:
The game is a simple implementation of blackjack, where the user is the Player, and you play against the computer, which operates as the Dealer. As the Player, you can choose to Hit or Stand on each turn. Hit will result in another card being drawn from the deck of 52, and added to your hand. The gameboard will then redisplay, showing you all of your cards and your new hand subtotal. At this point, your hand will also be evaluated to see if you have achieved Blackjack or gone Bust. Getting 21 points earns you Blackjack and you will get a point, while ending with 22 points or more is Bust and the Dealer will get a point. The cards don't appear to have suits, but there are four of each card value, like a typical deck.

During gameplay of a hand, you can only see your whole hand and subtotal, and one of the Dealer's cards will appear to be face down. You do not know the value of the Dealer's hand. The Dealer has its own set of behaviors, and will choose whether to Hit or Stand without input from the Player. If you manage to get 10 points (win 10 hands) first, you win, and can take off to explore space! However, if you fail to get 10 points (win 10 hands) before the Dealer does, you will lose the game... and face an uncertain fate.

##### Gameplay Screenshots
Title Screen:  
![Title Screen](https://github.com/wrongenvelope/cs271-project/blob/master/screenshots/title_screen.png)  

Player with starting hand chooses whether to Hit or Stand:  
![Gameplay](https://github.com/wrongenvelope/cs271-project/blob/master/screenshots/gameplay_1.png)  

The Dealer goes Bust:  
![Dealer_Bust](https://github.com/wrongenvelope/cs271-project/blob/master/screenshots/gameplay_2.png)  

Winning the game (and taking off in your rocket ship):    
![You Won](https://github.com/wrongenvelope/cs271-project/blob/master/screenshots/you_won.png)  

Losing the game (and being abducted):  
![You Lost](https://github.com/wrongenvelope/cs271-project/blob/master/screenshots/you_lost.png)  

##### Procedures:
Procedure | Description
------------ | -------------
Main Procedure | drives other procedures
Title_Screen | displays graphical title screen
Start_Game | initialize player/dealer points to 0
Start_Hand | empty player/dealer hands, reset card deck
Draw_Card | add one card to player or dealer hand
Evaluate_Hand | evaluate sum of points values for all cards in one hand
Show_Game | set up "gameboard" display with scorebox
Check_Win | check for blackjack/bust conditions  
Print_Hand | print out all cards from one hand in a row
Face_Cards | helper procedure to display value on face cards
Card_Spacer | helper procedure to space cards from left edge of terminal
Player_Turn | player can choose to Hit or Stand
Dealer_Turn | dealer will decide to Hit or Stand
Pick_Winner | if both player and dealer Stand, see who has more points
Game_Over | display won or lost game screen
Exit_Blackjack | prompt player to play again or quit

##### To Run the Program:
- You will need Visual Studio with the Visual C++ module installed.
- Install the Irvine32 Library: http://www.asmirvine.com/gettingStartedVS2019/index.htm
- Add .asm file to an Irvine Project, which will have the necessary assembler, linker, and libraries.
- Build and run the project.

##### Known issues:
1. Sometimes, Ace cards appear with @ symbol or = symbol instead of expected value "A"
2. The dealer's full hand (including face-down card) is not always revealed at the end of a hand. It works as intended if a player chooses to Stand, but the flags aren't set correctly if they choose Hit.
3. In hands with multiple Aces where the value of the Ace would be reduced from 11 to 1, only one Ace might be counted. (E.g. a hand with A, 2, A would have a value of 3 instead of 4)
4. Player hands that bust are frequently evaluated to "30" instead of their actual points value. The determination of whether someone has Bust seems correct, but the ending value displayed is not.

##### Feature Wishlist:
1. A betting system
2. More space-themed stuff (the dealer is supposed to be an alien)
3. Display things on the screen without scrolling, i.e. clear the screen and redisplay after drawing a card
4. Suits to display on cards
5. Additional input validation
