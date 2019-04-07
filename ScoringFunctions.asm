#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				         DATA SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

.data
	score:			.word 	0	# Variable to hold the player's score

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				      TEXT SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
.text


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure sets the score to 0 again, in case 	                                        #
#	the player wants to keep playing the game after                                         	#
#	they had a game over.	                                                                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
resetScore:
	sw	$zero, score			# Store 0 into the score variable
	jr	$ra				# Return to caller.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure returns the score for ease of use                                                #
#	in the interface.                                                                               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
getScore:
	lw	$v0, score			# Load from the Score variable
	jr	$ra				# Return to caller.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure is used for when the player inputs                                              #
#	a correct answer; it will increase their score                                                 #
#	based off how long their word is. i.e: 4-letter word                                           #
#	gives 4 points, etc.                                                                           #
#	It also makes use of the strLen function located in                                            #
#	StringFunctions.asm.                                                                           #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
incrementScore:
	addi	$sp, $sp, -8			# Move the stack pointer to allocate space
	sw	$a0, 4($sp)			# Store $a0 on the stack
	sw	$ra, 0($sp)			# Store $ra on the stack
	
	add	$t0, $a0, $zero			# $t0 = Address of enteredWord
	jal	strLen				# Call the length function
	
	lw	$t1, score			# Load what is in the score variable
	add	$t2, $v0, $zero			# Move the strLen return into $t2
	add	$t1, $t1, $t2			# Add length of string to current score
	sw	$t1, score			# Store new score into score variable
	
	lw	$ra, 0($sp)			# Restore $ra
	lw	$a0, 4($sp)			# Restore $a0
	addi	$sp, $sp, 8			# Restore the stack pointer
	
	jr	$ra				# Return to caller

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#