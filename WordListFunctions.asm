#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				         DATA SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
.data
	nineList:		.asciiz	"9List"
	dictionaryName:		.space	2
	magicWord:		.space	10
	magicWordSorted:	.space	10
	magicLetter:		.space	2
	tempWord:		.space	10
	tempWordSorted:		.space	10
	fileDesc:		.word	0
	fileDesc2:		.word	0
	buffer:			.space	500000
	dictionary:		.space	500000
	dictionaryMatches:	.space	500000
	givenMatches:		.space	500000
	charsRead:		.word	0
	wordsRead:		.word	0
	dictionaryWords:	.word	0
	rdmWrdOfst:		.word	0
	
	newLine:		.asciiz	"\n"
	badEntryWordDict:	.asciiz	"\nThis word is not in the list of correct answers. Please try again.\n"
	badEntryWordDupl:	.asciiz	"\nYou've already entered this word. Please try again.\n"
	goodEntryWord:		.asciiz	"\nCorrect word entry!\n"
	scoreS:			.asciiz "Your score is: "
	timeS:			.asciiz "Your time remaining is: "
	outOfTime:		.asciiz	"You are out of time!\n"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				         TEXT SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#	
.text
	.include "TimerFunctions.asm"
	.include "ScoringFunctions.asm"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				  SetupWordFunctions Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes no arguments. The list of nine letter words is loaded to memory. A random 	#
#	integer between zero and the number of words read is selected to determine which word will be	#
#	the key word. The key word and key letter are then saved along with a sorted version of the	#
#	key word for comparison purposes. The key letter is then used to load the matching letter file	#
#	words to memory. The key word and matching letter file are then used to create a list of valid	#
#	word entries.											#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
SetupWordFunctions:
	addi	$sp, $sp, -28				# Move the stack pointer to allocate space
	sw	$s6, 24($sp)				# Store $s6 on the stack
	sw	$s1, 20($sp)				# Store $s1 on the stack
	sw	$s0, 16($sp)				# Store $s0 on the stack
	sw	$a2, 12($sp)				# Store $a2 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
GetNineLetterWords:
	# Open the file
	li	$v0, 13					# Syscall for open file
	la	$a0, nineList				# Load file name address
	li	$a1, 0					# Read Only
	li	$a2, 0					# Mode 0, ignored
	syscall						# Execute Syscall ($v0 = file descriptor)
	sw	$v0, fileDesc				# Store the file descriptor
	
	# Read from the file
	li	$v0, 14					# Syscall for read from file
	lw	$a0, fileDesc				# Load address of the file descriptor
	la	$a1, buffer				# Load address of input buffer
	li	$a2, 500000				# Max number of characters to read
	syscall						# Execute Syscall ($v0 = No. of characters read)
	
	# Count the number of entries.
	sw	$v0, charsRead				# Store the number of characters read
	divu	$v0, $v0, 10				# $v0 = $v0 / 10
	sw	$v0, wordsRead				# Store the number of words read
	
	# Close the file 
	li	$v0, 16					# Syscall for close file
	lw	$a0, fileDesc				# Load address of file descriptor
	syscall						# Execute Syscall

SetupMagicWord:
	# Select a random number: 0 <= number < wordsRead
	li	$v0, 42					# Syscall for bounded, random int
	li	$a0, 0					# Select random generator >= 0
	lw	$a1, wordsRead				# And <= wordsRead
	addi	$a1, $a1, -1				# Decrement $a1
	syscall						# Generate random int (returns in $a0)
	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#			 Use this section to lock the magic word for testing.				#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	li	$a0, 2207				# Sets magicWord = computers			#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	
	# Multiply the random number by 10 for the byte offset
	mul	$a0, $a0, 10				# $a0 = $a0 * 10
	sw	$a0, rdmWrdOfst				# Store random word offset bits
	
	# Store the random word and first letter
	la	$s0, buffer				# $s0 = buffer address
	lw	$s1, rdmWrdOfst				# $s1 = rdmWrdOfst
	add	$s0, $s0, $s1				# $s0 = buffer address + rdmWrdOfst
	li	$s1, 0					# $s1 = 0
	lb	$t0, ($s0)				# $t0 = (buffer address + rdmWrdOfst) letter
	#sb	$t0, magicLetter			# magicLetter = $t0
	
	la	$t1, magicLetter
	sb	$t0, ($t1)				# Set 0($v0) to the letter of the file name
	sb	$0, 1($t1)				# Set 1($t0) to 0
	
	la	$a1, buffer				# $a1 = buffer address
	lw	$s1, rdmWrdOfst				# $s1 = rdmWrdOfst
	add	$a1, $a1, $s1				# $a1 = buffer address + rdmWrdOfst
	li	$s1, 0					# $s1 = 0
	la	$a0, magicWord				# $a0 = magicWord address
	jal	strCpy					# $a0 = magicWord; $a1 = buffer + rdmWrdOfst
	
	# Store a sorted copy of the random word
	la	$a1, magicWord				# $a1 = magicWord address
	la	$a0, magicWordSorted			# $a0 = magicWordSorted
	jal	strCpy					# $a0 = magicWordSorted; $a1 = magicWord
	jal	magicWordSort				# $a0 = magicWordSorted
	
SetupLetterWordList:
	# Open the file
	lb	$v0, magicLetter			# $v0 = magicLetter
	la	$t1, dictionaryName			# Load the file name address into $t1 
	sb	$v0, ($t1)				# Set 0($v0) to the letter of the file name
	sb	$0, 1($t1)				# Set 1($t0) to 0
	
	li	$v0, 13					# Syscall for open file
	la	$a0, dictionaryName			# Load file name address
	li	$a1, 0					# Read Only
	li	$a2, 0					# Mode 0, ignored
	syscall						# Execute Syscall ($v0 = file descriptor)
	sw	$v0, fileDesc2				# Store the file descriptor
	
	# Read from the file
	li	$v0, 14					# Syscall for read from file
	lw	$a0, fileDesc2				# $a0 = fileDesc
	la	$a1, dictionary				# Load address of input buffer
	li	$a2, 500000				# Max number of characters to read
	syscall						# Execute Syscall ($v0 = No. of characters read)
	
	# Close the file
	li	$v0, 16					# Syscall for close file
	lw	$a0, fileDesc2				# $a0 = fileDesc
	syscall						# Execute Syscall

SetupValidWordList:
	# Store correct word entries
	la	$a0, magicWordSorted			# a0 = magicWordSorted;
	la	$a1, dictionary				# $a1 = dictionary;
	la	$a2, dictionaryMatches			# $a2 = dictionaryMatches;
	jal	setupDictionary				# Call setupDictionary procedure
	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#			 Use this section to correct entries for testing.				#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	li	$v0, 4											#
#	la	$a0, dictionaryMatches									#
#	syscall												#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

SetupWordFunctions.End:
	jal	resetScore				# Reset the score to zero
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$a2, 12($sp)				# Restore $a2
	lw	$s0, 16($sp)				# Restore $s0
	lw	$s1, 20($sp)				# Restore $s1
	lw	$s6, 20($sp)				# Restore $s6
	addi	$sp, $sp, 28				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					checkWord Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes the address of the enteredWord in $a0. The word is checked for presence in	#
#	the dictionaryMatches array and it is then checked to ensure that is has not been entered	#
#	via the givenMatches array. Once these conditions are met, a successful entry is then writen to	#
#	the enteredWord array and the score is incremented by the length of the word.			#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
checkWord:
	addi	$sp, $sp, -16				# Move the stack pointer to allocate space
	sw	$s0, 12($sp)				# Store $s0 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	jal	wordToLowerCase				# Call wordToLowerCase procedure
	add	$s0, $zero, $a0				# $s0 = Address of enteredWord
	#Check time remaining
	jal	getTimeRemaining			# Call getTimeRemaining
	blez	$v0, checkWord.OutOfTime		# If(time remaining <= 0) branch to checkWord.OutOfTime
	# Check for word in dictionaryMatches
	la	$a1, dictionaryMatches			# $a1 = Address of dictionaryMatches
	jal	strContains				# Call strContains function
	# If Not in dictionaryMatches
	beq	$v0, 1, checkWord.InDictionary		# If($v0 == 1) branch to checkWord.InDictionary
	#	Show invalid entry message
	li	$v0, 4					# Load syscall print string function
	la	$a0, badEntryWordDict			# Load address of string to print
	syscall						# Execute syscall
	#	get time remaining
	jal	getTimeRemaining			# Call getTimeRemaining
	add	$s4, $v0, $zero				# Same time (ms) remaining
	divu	$s4, $s4, 1000				# Convert time to seconds
	#	Go to Finish
	j	checkWord.ShowInfo			# Jump to checkWord.ShowInfo
checkWord.InDictionary:
	# Check for word not in givenMatches
	la	$a1, givenMatches			# $a1 = Address of givenMatches
	jal	strContains				# Call strContains function
	# Else If not in givenMatches
	beq	$v0, 0, checkWord.NotInEntries		# If($v0 == 0) branch to checkWord.NotInEntries
	#	Show duplicate entry message
	li	$v0, 4					# Load syscall print string function
	la	$a0, badEntryWordDupl			# Load address of string to print
	syscall						# Execute syscall
	#	get time remaining
	jal	getTimeRemaining			# Call getTimeRemaining
	add	$s4, $v0, $zero				# Same time (ms) remaining
	divu	$s4, $s4, 1000				# Convert time to seconds
	#	Go to Finish
	j	checkWord.ShowInfo			# Jump to checkWord.ShowInfo
	# Else
checkWord.NotInEntries:
	#	add word to givenmatches
	la	$a0, givenMatches			# $a0 = Address of givenMatches
	jal	strLenNull				# Call strLenNull function
	add	$a0, $a0, $v0				# Point to end of givenMatches
	add	$a1, $s0, $zero				# $a1 = Address of entered word
	jal	strCpyNewLine				# Call strCpyNewLine
	#	increment timer
	jal	incrementTimer				# Call incrementTimer
	add	$s4, $v0, $zero				# Same time (ms) remaining
	divu	$s4, $s4, 1000				# Convert time to seconds
	#	increment score
	add	$a0, $s0, $zero				# $a0 = word string length
	jal	incrementScore				# Call incrementScore
	#	Show valid entry message
	li	$v0, 4					# Load syscall print string function
	la	$a0, goodEntryWord			# Load address of string to print
	syscall						# Execute syscall
	j	checkWord.ShowInfo			# Jump to checkWord.ShowInfo
checkWord.OutOfTime:
	li	$v0, 4					# Load syscall print string function
	la	$a0, outOfTime				# Load address of string to print
	syscall						# Execute syscall
	j	checkWord.End
checkWord.ShowInfo:
	#	Show current score
	li	$v0, 4					# Load syscall print string function
	la	$a0, scoreS				# Load address of string to print
	syscall						# Execute syscall
	li	$v0, 1					# Load syscall print integer function
	lw	$a0, score				# Load integer to print
	syscall						# Execute syscall
	li	$v0, 4					# Load syscall print string function
	la	$a0, newLine				# Load address of string to print
	syscall						# Execute syscall
	#	Show time remaining
	la	$a0, timeS				# Load address of string to print
	syscall						# Execute syscall
	li	$v0, 1					# Load syscall print integer function
	add	$a0, $s4, $zero				# $a0 = time in seconds
	syscall						# Execute syscall
	li	$v0, 4					# Load syscall print string function
	la	$a0, newLine				# Load address of string to print
	syscall						# Execute syscall
	#	Go to Finish
	j	checkWord.End				# Jump to checkWord.End
checkWord.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$s0, 12($sp)				# Restore $s0
	addi	$sp, $sp, 16				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					magicWordSort Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes one address in $a0. The content of the source address is ordered		#
#	alphabetically, character by character and must be nine characters in length.			#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
magicWordSort:						# a0 = magicWordSorted
	addi	$sp, $sp, -12				# Move the stack pointer to allocate space
	sw	$s0, 8($sp)				# Store $s0 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	li	$s0, 0					# Initialize $s0 to 0 for counter
magicWordSort.Loop:
	add	$t0, $a0, $zero				# $t0 = magicWordSorted
magicWordSort.Inner.Loop.Start:
	lb	$t2, 1($t0)				# $t2 = 1($t0)
	beqz	$t2, magicWordSort.Inner.Loop.End	# If($t2 == 0) branch to magicWordSort.Inner.Loop.End
	lb	$t1, 0($t0)				# $t1 = 0($t0)
	blt	$t2, $t1, magicWordSort.Swap		# If($t2 < $t1) branch to magicWordSort.Swap
magicWordSort.NoSwap:
	addi	$t0, $t0, 1				# Increment the address pointer
	j	magicWordSort.Inner.Loop.Start		# Jump to magicWordSort.Inner.Loop.Start
magicWordSort.Swap:
	sb	$t1, 1($t0)				# Store the greater character second
	sb	$t2, 0($t0)				# Store the lesser character first
	addi	$t0, $t0, 1				# Increment the address pointer
	j	magicWordSort.Inner.Loop.Start		# Jump to magicWordSort.Inner.Loop.Start
magicWordSort.Inner.Loop.End:
	addi	$s0, $s0, 1				# Increment the outer loop counter
	bgt	$s0, 7, magicWordSort.End		# If($s0 > 7) branch to magicWordSort.End
	j	magicWordSort.Loop			# Else Jump to magicWordSort.Loop
magicWordSort.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$s0, 8($sp)				# Restore $s0
	addi	$sp, $sp, 12				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					enteredWordSort Procedure					#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes one address in $a0. The procedure calls the strLen function to obtain the	#
#	character length of the content. The content of the source address is ordered alphabetically,	#
#	character by character, dynamically.								#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
enteredWordSort:					# a0 = enteredWordSorted
	addi	$sp, $sp, -16				# Move the stack pointer to allocate space
	sw	$s1, 12($sp)				# Store $s1 on the stack
	sw	$s0, 8($sp)				# Store $s0 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	li	$s0, 0					# Initialize $s0 to 0 for counter
	jal	strLen					# Call string length function
	add	$s1, $v0, $zero				# $s1 = string length
enteredWordSort.Loop:
	add	$t0, $a0, $zero				# $t0 = enteredWordSorted
enteredWordSort.Inner.Loop.Start:
	lb	$t2, 1($t0)				# $t2 = 1($t0)
	beqz	$t2, enteredWordSort.Inner.Loop.End	# If($t2 == 0) branch to enteredWordSort.Inner.Loop.End
	lb	$t1, 0($t0)				# $t1 = 0($t0)
	blt	$t2, $t1, enteredWordSort.Swap		# If($t2 < $t1) branch to enteredWordSort.Swap
enteredWordSort.NoSwap:
	addi	$t0, $t0, 1				# Increment the address pointer
	j	enteredWordSort.Inner.Loop.Start	# Jump to enteredWordSort.Inner.Loop.Start
enteredWordSort.Swap:
	sb	$t1, 1($t0)				# Store the greater character second
	sb	$t2, 0($t0)				# Store the lesser character first
	addi	$t0, $t0, 1				# Increment the address pointer
	j	enteredWordSort.Inner.Loop.Start	# Jump to enteredWordSort.Inner.Loop.Start
enteredWordSort.Inner.Loop.End:
	addi	$s0, $s0, 1				# Increment the outer loop counter
	bgt	$s0, $s1, enteredWordSort.End		# If($s0 > $s1) branch to enteredWordSort.End
	j	enteredWordSort.Loop			# Else Jump to enteredWordSort.Loop
enteredWordSort.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$s0, 8($sp)				# Restore $s0
	lw	$s1, 12($sp)				# Restore $s1
	addi	$sp, $sp, 16				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					magicLetterCont Function					#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This function takes two addresses, the address of a sorted word in $a0, and the address of a	#
#	key letter in $a1. The function calls the strLen function to obtain the sorted word string	#
#	length and iterates through the sorted word to check for the key letter. A 1 is returned if the	#
#	key letter is found. Otherwise, 0 is returned.							#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
magicLetterCont:					# a0 = enteredWordSorted; $a1 = magicLetter
	addi	$sp, $sp, -28				# Move the stack pointer to allocate space
	sw	$s4, 24($sp)				# Store $s4 on the stack
	sw	$s2, 20($sp)				# Store $s2 on the stack
	sw	$s1, 16($sp)				# Store $s1 on the stack
	sw	$s0, 12($sp)				# Store $s0 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	add	$s0, $a0, $zero				# $s0 = enteredWordSorted
	lb	$s1, 0($a1)				# $s1 = magicLetter
	jal	strLen
	li	$s4, 0					# $s4 = 0 (enteredWordSorted counter)
	add	$s5, $v0, $zero				# $s5 = string length (enteredWordSorted)
	li	$v0, 0					# $v0 = 0
magicLetterCont.Loop:
	lb	$s2, 0($s0)				# $s2 = 0($s0)
	beqz	$s2, magicLetterCont.End		# If($s2 == 0) branch to magicLetterCont.End
	seq	$v0, $s1, $s2				# $v0 = ($s1 == $s2 ? 1 : 0)
	beq	$v0, 1, magicLetterCont.End		# If($v0 == 1) branch to magicLetterCont.End
	addi	$s4, $s4, 1				# $s4++
	addi	$s0, $s0, 1				# $s0++
	j	magicLetterCont.Loop			# Jump to magicLetterCont.Loop
magicLetterCont.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$s0, 12($sp)				# Restore $s0
	lw	$s1, 16($sp)				# Restore $s1
	lw	$s2, 20($sp)				# Restore $s2
	lw	$s4, 24($sp)				# Restore $s4
	addi	$sp, $sp, 28				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					magicWordCont Function						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This function takes two addresses, the address of a sorted word in $a0, and the address of a	#
#	sorted key word in $a1. The function calls the strLen function to obtain the sorted word string	#
#	length and iterates through the sorted word and through the sorted key word to check for all	#
#	letters of the sorted word within the sorted key word. A 1 is returned if all letters in the	#
#	sorted word are found within the sorted key word. Otherwise, 0 is returned.			#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
magicWordCont:						# a0 = enteredWordSorted; $a1 = magicWordSorted
	addi	$sp, $sp, -36				# Move the stack pointer to allocate space
	sw	$s5, 32($sp)				# Store $s5 on the stack
	sw	$s4, 28($sp)				# Store $s4 on the stack
	sw	$s3, 24($sp)				# Store $s3 on the stack
	sw	$s2, 20($sp)				# Store $s2 on the stack
	sw	$s1, 16($sp)				# Store $s1 on the stack
	sw	$s0, 12($sp)				# Store $s0 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	add	$s0, $a0, $zero				# $s0 = enteredWordSorted
	add	$s1, $a1, $zero				# $s1 = magicWordSorted
	jal	strLen
	add	$s4, $v0, $zero				# $s4 = string length (enteredWord)
	li	$s2, 0					# $s2 = 0 (enteredWord counter)
	addi	$s5, $zero, 9				# $s5 = string length (magicWord)
	li	$s3, 0					# $s3 = 0 (magicWord counter)
magicWordCont.Loop:
	lb	$t0, 0($s0)				# $t0 = 0($s0)
	lb	$t1, 0($s1)				# $t1 = 0($s1)
	seq	$v0, $t0, 0				# $v0 = ($t0 == 0 ? 1 : 0)
	beq	$v0, 1, magicWordCont.End		# If($v0 == 1) branch to magicWordCont.End
	beqz	$t1, magicWordCont.End			# If($t1 == 0) branch to magicWordCont.End
	bne	$t0, $t1, magicWordCont.NoLetter	# If($t0 != $t1) branch to magicWordCont.NoLetter
magicWordCont.HasLetter:
	addi	$s0, $s0, 1				# $s0++
	addi	$s1, $s1, 1				# $s1++
	addi	$s2, $s2, 1				# $s2++
	addi	$s3, $s3, 1				# $s3++
	j	magicWordCont.Loop			# Jump to magicWordCont.Loop
magicWordCont.NoLetter:
	addi	$s1, $s1, 1				# $s1++
	addi	$s3, $s3, 1				# $s3++
	j	magicWordCont.Loop			# Jump to magicWordCont.Loop
magicWordCont.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$s0, 12($sp)				# Restore $s0
	lw	$s1, 16($sp)				# Restore $s1
	lw	$s2, 20($sp)				# Restore $s2
	lw	$s3, 24($sp)				# Restore $s3
	lw	$s4, 28($sp)				# Restore $s4
	lw	$s5, 32($sp)				# Restore $s5
	addi	$sp, $sp, 36				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					setupDictionary Procedure					#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes three addresses, the address of magicWordSorted in $a0, the address of	#
#	the complete letter dictionary in $a1, and the address of dictionaryMatches in $a2. The		#
#	procedure checks each word in the letter dictionary to see if it's a match to the magicWord.	#
#	Correct word matches are then moved into dictionaryMatches.					#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
setupDictionary:					# a0 = magicWordSorted; $a1 = dictionary;
							# $a2 = dictionaryMatches;
	addi	$sp, $sp, -32				# Move the stack pointer to allocate space
	sw	$s3, 28($sp)				# Store $s3 on the stack
	sw	$s2, 24($sp)				# Store $s2 on the stack
	sw	$s1, 20($sp)				# Store $s1 on the stack
	sw	$s0, 16($sp)				# Store $s0 on the stack
	sw	$a2, 12($sp)				# Store $a2 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	add	$s0, $a0, $zero				# $s0 = magicWordSorted
	add	$s1, $a1, $zero				# $s1 = dictionary
	add	$s2, $a2, $zero				# $s2 = dictionaryMatches
setupDictionary.Loop:
	lb	$t0, 1($s1)				# $t0 = 1($s1)
	beqz	$t0, setupDictionary.End		# If($t0==0) branch to setupDictionary.End
setupDictionary.Copy:
	la	$a0, tempWord				# $a0 = tempWord
	add	$a1, $s1, $zero				# $a1 = dictionary
	jal	strCpy					# Call strCpy procedure
	jal	strLen					# Call strLen function
	add	$v0, $v0, 1				# $v0++ (for null terminator)
	add	$s1, $s1, $v0				# Increment dictionary pointer
	add	$s3, $v0, $zero				# $s3 = string length
	la	$a0, tempWordSorted			# $a0 = tempWordSorted
	la	$a1, tempWord				# $a1 = tempWord
	jal	strCpy					# Call strCpy procedure
	jal	enteredWordSort				# Call enteredWordSort procedure
	la	$a1, magicLetter			# $a1 = magicLetter
	jal	magicLetterCont				# Call magicLetterCont function
	bne	$v0, 1, setupDictionary.Loop		# If($v0 != 1) branch to setupDictionary.Loop
	la	$a1, magicWordSorted			# $a1 = magicWordSorted
	jal	magicWordCont				# Call magicWordCont function
	bne	$v0, 1, setupDictionary.Loop		# If($v0 != 1) branch to setupDictionary.Loop
	add	$a0, $s2, $zero				# $a0 = dictionaryMatches
	la	$a1, tempWord				# $a1 = tempWord
	jal	strCpyNewLine				# Call strCpyNewLine procedure
	add	$s2, $s2, $s3				# Increment dictionaryMatches pointer
	j	setupDictionary.Loop			# Jump to setupDictionary.Loop
setupDictionary.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$a2, 12($sp)				# Restore $a2
	lw	$s0, 16($sp)				# Restore $s0
	lw	$s1, 20($sp)				# Restore $s1
	lw	$s2, 24($sp)				# Restore $s2
	lw	$s3, 28($sp)				# Restore $s3
	addi	$sp, $sp, 32				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
