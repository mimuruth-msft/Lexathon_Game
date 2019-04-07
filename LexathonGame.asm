#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  LEXATHON (MIPS Edition) - Game for enriching vocabulary                                                                                       #
#  MIPS assembly language program                                                                                                                #                                                                                                                      *
#  a) MIPS assembly Lexathon is a is a 9-letter word puzzle game where you discover as many words as possible that contain the central letter.   #
#  b) It's a vocabulary building game that is fun and suitable for all users with any level of English proficiency and for any age.              #
#  c) Test your skills; there is always a 9 letter word to find among the scrambled letters!                                                     #
#  d) Every word you find gets you more time and increases your score!                                                                           #
#  e) The faster you react and the more words you find from the English dictionary.                                                              #                                      
#  f) Once you’ve found as many words as you can, enter '0' (zero) to‘Give up’ to maximize your score                                            #
#  g) Scores are awarded per the number of correct words and the player receives 1 point for every letter                                        #                                                                            *
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				         DATA SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

.data
	start_message1:	.asciiz	"Welcome to LEXATHON (MIPS Edition)!\n"
	start_message2:	.asciiz	"***********************************\n"
	start_message3:	.asciiz	"From a block of 9 letters, find as many English words as possible of 4 or more letters that contain the central letter.\n\n"
	begin_game:	.asciiz	"Enter '1' to start game or '0' for instructions on how to play: "
	
	instruction1:	.asciiz	"\nINSTRUCTIONS:\n"
	instruction2:	.asciiz	"   1. At the start of the game, the player will receive a 9 letters (3x3 grid) from which to form as many words as possible.\n"
	instruction3:	.asciiz	"   2. The player will get the first 60 seconds to find a possible word and receives an additional 20 second for every correct wordfound.\n"
	instruction4:	.asciiz	"   3. Each possible word must contain the central letter and each letter can only be used once.\n"
	instruction5:	.asciiz	"   4. Your round can end in only two ways.\n"
	instruction6:	.asciiz	"      a. First, you can run out of time, if you exceed the allocated time without entering a new word to your ever-growing list.\n"
	instruction7:	.asciiz	"      b. Second, you can simply give up if you are unable to find more new words, but you do not want to simply wait for the time to run out.\n"
	instruction8:	.asciiz	"      c. The game ends when the time reaches ZERO or you enter '0'(zero) to GIVE UP.\n"
	instruction9:	.asciiz	"   5. The game scores you according to number of correct possible words found and the amount of time it took you to play your round.\n"
	instruction10:	.asciiz	"   6. The points are determined by the number of correct words and the player receives 1 point for every letter.\n\n"

	end_game1:	.asciiz	"*******************************************************************\n"
	end_game2:	.asciiz	"*            Thank you for playing. Program is ending             *\n"
	end_game3:	.asciiz	"*******************************************************************\n"
	game_loading:	.asciiz	"Please wait while the game loads...\n\n"
	
	shuffledWord:	.space	10
	magicWordS:	.asciiz	"The magic word was: "
	
	playersWord:	.space	11
	prompt:		.asciiz	"Enter a valid word or type '0' to Give Up: "
	
	game_over1:	.asciiz	"\n************************** GAME  OVER!! ***************************\n"
	game_over2:	.asciiz "*                          GAME SUMMARY                           *\n"
	game_over3:	.asciiz "*******************************************************************\n"
	final_score:	.asciiz	"Your final score: "


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				         TEXT SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

.text
	.globl main
	
	.include "WordListFunctions.asm"

main:
	li	$v0, 4				# Load syscall print string service
	la	$a0, game_loading		# Load address of string to print
	syscall					# Execute syscall
	jal 	SetupWordFunctions		# Call SetupWordFunctions
	jal 	setup				# Call setup
	la	$a0, shuffledWord		# $a0 = Address of shuffledWord
	la	$a1, magicWord			# $a1 = Address of magicWord
	jal	wordShuffle			# Call wordShuffle
	li	$v0, 4				# Load syscall print string service
	la	$a0, newLine			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, timeS			# Load address of string to print
	syscall					# Execute syscall
	li	$v0, 1				# Load syscall print integer service
	li	$a0, 60				# $a0 = 60
	syscall					# Execute syscall
	jal	setInitialTime			# Call setInitialTime

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Loop to keep showing the board, and to ask user for input to see                                #
#       if their word is correct.				                                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

main.Loop:
	li	$v0, 4				# Load syscall print string service
	la	$a0, newLine			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, shuffledWord		# $a0 = Address of shuffledWord
	jal	printMatrix			# Call printMatrix
	li	$v0, 4				# Load syscall print string service
	la	$a0, newLine			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, prompt			# Load address of string to print
	syscall					# Execute syscall
	li	$v0, 8				# Load syscall read string service
	la	$a0, playersWord		# $a0 = Address of playersWord
	li	$a1, 10				# Read ten characters
	syscall					# Execute syscall
	la	$a0, playersWord		# $a0 = Address of playersWord
	lb	$t1, 0($a0)			# $t1 = 0(playersWord)
	beq	$t1, 48, main.End		# If($t1==0) branch to main.End
	jal	checkWord			# Call checkWord
	jal	getTimeRemaining		# Call getTimeRemaining
	move	$t0, $v0			# $t0 = time remaining
	blt	$t0, 0, main.End		# If(time remaining < 0) branch to main.End
	j	main.Loop			# Else, jump to main.Loop

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Code used to display the final "Game Over" screen.                                              #
#       Displays final score				                                                #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

main.End:
	li	$v0, 4				# Load syscall print string service
	la	$a0, game_over1			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, game_over2			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, game_over3			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, final_score		# Load address of string to print
	syscall					# Execute syscall
	jal	getScore			# Call getScore
	add	$a0, $v0, $zero			# $a0 = score
	li	$v0, 1				# Load syscall print integer service
	syscall					# Execute syscall
	li	$v0, 4				# Load syscall print string service
	la	$a0, newLine			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, magicWordS			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, magicWord			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, newLine			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, end_game1			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, end_game2			# Load address of string to print
	syscall					# Execute syscall
	la	$a0, end_game3			# Load address of string to print
	syscall					# Execute syscall
	
	li	$v0, 10				# Load syscall exit service
	syscall					# Execute syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       Used to display the instructions                                                                #
#       and ask if the player wants to start the game.				                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

setup:
	li	$v0, 4				# Load syscall print string service
	la	$a0, start_message1		# Load address of string to print
	syscall					# Execute syscall
	la	$a0, start_message2		# Load address of string to print
	syscall					# Execute syscall
	la	$a0, start_message3		# Load address of string to print
	syscall					# Execute syscall
request_input:
	## prompt the player to enter '1' to start game or '0' for instruction on how to play
	li	$v0, 4				# Load syscall print string service
	la	$a0, begin_game			# Load address of string to print
	syscall					# Execute syscall
		
	## read the players's input
	li	$v0, 5				# Load syscall read integer service
	syscall					# Execute syscall
		
	## if player enters '0', proceed to instructions on how to play
	beqz	$v0, instructions 		# If($v0==0) branch to instructions
	jr	$ra				# Return to caller
	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				  print instructions      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

instructions:
	li	$v0, 4				# Load syscall print string service
	la	$a0, instruction1		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction2		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction3		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction4		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction5		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction6		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction7		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction8		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction9		# Load address of string to print
	syscall					# Execute syscall
	#
	la	$a0, instruction10		# Load address of string to print
	syscall					# Execute syscall
	j	request_input			# Jump to request_input

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#