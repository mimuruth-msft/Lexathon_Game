#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				         DATA SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
.data
	matrix:	.asciiz	"\t+---+---+---+\n\t| 0 | 1 | 2 |\n\t+---+---+---+\n\t| 3 | 4 | 5 |\n\t+---+---+---+\n\t| 6 | 7 | 8 |\n\t+---+---+---+\n"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				      TEXT SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
.text

.globl	strCpy
.globl	strCpyNewLine
.globl	strContains
.globl	wordToLowerCase
.globl	strLen
.globl	strLenNull
.globl	wordShuffle
.globl	printMatrix


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					strCpy Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes two addresses, the source address in $a1, and the destination in $a0. 	#
#	The content of the source address is copied, biy by bit, to the destination address. The copy	#
#	process completes when either a new line character (10) or the null character (0) is found.	#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
strCpy:
	addi	$sp, $sp, -12				# Move the stack pointer to allocate space
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	add	$t1, $zero, $a1				# $t1 = Address of Source[0]
	add	$t3, $zero, $a0				# $t3 = Address of Destination[0]
strCpy.Loop:
	lb	$t2, 0($t1)				# $t2 = Source[i]
	beq	$t2, 10, strCpy.End			# if(Source[i]==10) leave loop
	beqz	$t2, strCpy.End				# if(Source[i]==0)  leave loop
	sb	$t2, 0($t3)				# Destination[i] = Source[i]
	addi	$t1, $t1, 1				# Increment Source counter
	addi	$t3, $t3, 1				# Increment Destination counter
	li	$t2, 0					# Clear $t2
	j	strCpy.Loop				# Jump to strCpy.Loop
strCpy.End:
	sb	$zero, 0($t3)				# Destination[i] = 0 (null string terminator)
	
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	addi	$sp, $sp, 12				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					strCpyNewLine Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes two addresses, the source address in $a1, and the destination in $a0. 	#
#	The content of the source address is copied, biy by bit, to the destination address. The copy	#
#	process completes when either a new line character (10) or the null character (0) is found.	#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
strCpyNewLine:
	addi	$sp, $sp, -12				# Move the stack pointer to allocate space
	sw	$a1, 8($sp)				# Store $a1 on the stack
	add	$t1, $zero, $a1				# $t1 = Address of Source[0]
	sw	$a0, 4($sp)				# Store $a0 on the stack
	add	$t3, $zero, $a0				# $t3 = Address of Destination[0]
	sw	$ra, 0($sp)				# Store $ra on the stack
strCpyNewLine.Loop:
	lb	$t2, 0($t1)				# $t2 = Source[i]
	beq	$t2, 10, strCpyNewLine.End		# if(Source[i]==10) leave loop
	beqz	$t2, strCpyNewLine.End			# if(Source[i]==0)  leave loop
	sb	$t2, 0($t3)				# Destination[i] = Source[i]
	addi	$t1, $t1, 1				# Increment Source counter
	addi	$t3, $t3, 1				# Increment Destination counter
	li	$t2, 0					# Clear $t2
	j	strCpyNewLine.Loop			# Jump to strCpyNewLine.Loop
strCpyNewLine.End:
	li	$t2, 10					# $t2 = "\n"
	sb	$t2, 0($t3)				# Destination[i] = 10 (new line character)
	sb	$zero, 1($t3)				# Destination[i+1] = 0 (null character)
	
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	addi	$sp, $sp, 12				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					strContains Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes two addresses, the string address in $a0, and the string array (new line	#
#	delimited) address in $a1. The string is checked for presence in the string array as a sub-	#
#	string. A 1 is returned if the string array contains the string. Othersize, 0 is returned.	#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
strContains:
	addi	$sp, $sp, -16				# Move the stack pointer to allocate space
	sw	$s0, 12($sp)				# Store $s0 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	add	$s0, $zero, $a0				# $s0 = Address of string (original)
	add	$t0, $zero, $a0				# $t0 = Address of string
	add	$t1, $zero, $a1				# $t1 = Address of string array
strContains.Loop.Start:
	lb	$t2, 0($t0)				# $t2 = 0(string[i])
	beq	$t2, 10, strContains.True.Conf		# If(string[i]==10) branch to strContains.True.Conf
	beqz	$t2, strContains.True.Conf		# If(string[i]==0) branch to strContains.True.Conf
	lb	$t3, 0($t1)				# $t3 = 0(string array[i])
	beqz	$t3, strContains.False			# If(string array[i]==0) branch to strContains.False
	bne	$t2, $t3, strContains.Loop.NoMatch	# If(string[i]!=string array[i]) branch to strContains.Loop.NoMatch
strContains.Loop.Match:
	addi	$t0, $t0, 1				# Increment string pointer
	addi	$t1, $t1, 1				# Increment string array pointer
	j	strContains.Loop.Start			# Jump to strContains.Loop.Start
strContains.Loop.NoMatch:
	add	$t0, $zero, $s0				# Reset string pointer
strContains.Loop.ArrayNext:
	addi	$t1, $t1, 1				# Increment string array pointer
	lb	$t3, -1($t1)				# $t3 = -1(string array[i])
	beq	$t3, 10, strContains.Loop.Start		# If(string array[i]==10) branch to strContains.Loop.Start
	beqz	$t3, strContains.False			# If(string array[i]==0) branch to strContains.False
	j	strContains.Loop.ArrayNext		# Jump to strContains.Loop.ArrayNext
strContains.True.Conf:
	lb	$t3, 0($t1)				# $t2 = 0(string array[i])
	ble	$t3, 10, strContains.True		# If(string array[i]<=10) branch to strContains.True
	j	strContains.Loop.NoMatch		# Else jump to strContains.Loop.NoMatch
strContains.True:
	li	$v0, 1					# $v0 = 1 (True)
	j	strContains.End				# Jump to strContains.End
strContains.False:
	li	$v0, 0					# $v0 = 0 (False)
	j	strContains.End				# Jump to strContains.End
strContains.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$s0, 12($sp)				# Restore $s0
	addi	$sp, $sp, 16				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					wordToLowerCase procedure					#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes one address in $a0. The procedure checks each character to see if it falls	#
#	within the range of lower case ascii characters (97 - 122) and adds 32 to any character outside	#
#	of that range. The conversion process completes when either a new line character (10) or	#
#	the null character (0) is found.								#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
wordToLowerCase:
	addi	$sp, $sp, -8				# Move the stack pointer to allocate space
	sw	$a0, 4($sp)				# Store $a0 on the stack
	add	$t0, $a0, $zero				# $t0 = enteredWord
	sw	$ra, 0($sp)				# Store $ra on the stack
wordToLowerCase.Loop:
	lb	$t1, 0($t0)				# $t1 = 0($t0)
	addi	$t0, $t0, 1				# Increment the address pointer
	beqz	$t1, wordToLowerCase.End		# If($t1 ==  0) branch to wordToLowerCase.End
	beq	$t1, 10, wordToLowerCase.End		# If($t1 == 10) branch to wordToLowerCase.End
	bge	$t1, 97, wordToLowerCase.Loop		# If($t1 >= 97) branch to wordToLowerCase.Loop
wordToLowerCase.ToLower:
	addi	$t1, $t1, 32				# Convert upper to lower
	sb	$t1, -1($t0)				# Store the converted character
	j	wordToLowerCase.Loop			# Jump to wordToLowerCase.Loop
wordToLowerCase.End:
	sb	$zero, 0($t0)				# Null string terminator
	
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	addi	$sp, $sp, 8				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					strLen Function							#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This function takes the address of a string in $a0 and iterates through the string to obtain	#
#	length of the string. The function completes when either the new line character (10) or the	#
#	null terminator character (0) is found. The integer length of the string is returned.		#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
strLen:
	addi	$sp, $sp, -8				# Move the stack pointer to allocate space
	sw	$a0, 4($sp)				# Store $a0 on the stack
	add	$t0, $a0, $zero				# $t0 = enteredWord
	sw	$ra, 0($sp)				# Store $ra on the stack
	li	$t2, 0					# Initialize the counter to zero
strLen.Loop:
	lb	$t1, 0($t0)				# Load the next character into t1
	beqz	$t1, strLen.Exit			# Check for the null character
	beq	$t1, 10, strLen.Exit			# Check for the line feed character
	addi	$t0, $t0, 1				# Increment the string pointer
	addi	$t2, $t2, 1				# Increment the counter
	j	strLen.Loop				# Return to the top of the loop
strLen.Exit:
	add	$v0, $t2, $zero				# Move the count to $v0
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	addi	$sp, $sp, 8				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					strLenNull Function						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This function takes the address of a string in $a0 and iterates through the string to obtain	#
#	length of the string. The function completes only when the null terminator character (0) is	#
#	found. The integer length of the string is returned.						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
strLenNull:
	addi	$sp, $sp, -8				# Move the stack pointer to allocate space
	sw	$a0, 4($sp)				# Store $a0 on the stack
	add	$t0, $a0, $zero				# $t0 = enteredWord
	sw	$ra, 0($sp)				# Store $ra on the stack
	li	$t2, 0					# Initialize the counter to zero
strLenNull.Loop:
	lb	$t1, 0($t0)				# Load the next character into t1
	beqz	$t1, strLenNull.Exit			# Check for the null character
	addi	$t0, $t0, 1				# Increment the string pointer
	addi	$t2, $t2, 1				# Increment the counter
	j	strLenNull.Loop				# Return to the top of the loop
strLenNull.Exit:
	add	$v0, $t2, $zero				# Move the count to $v0
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	addi	$sp, $sp, 8				# Restore the stack pointer
	
	jr	$ra					# Set PC = $ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					wordShuffle Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes two addresses, the source address in $a1, and the destination address	#
#	in $a0. The furst character of the source address is stored to the middle (5th) character space	#
#	of the destination address. The remaining characters of the source address are then copied	#
#	randomly, biy by bit, to the destination address. The copy after all nine characters have been	#
#	copied.												#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
wordShuffle:
	addi	$sp, $sp, -28			# Move the stack pointer to allocate space
	sw	$s7, 24($sp)			# Store $s7 on the stack
	sw	$s6, 20($sp)			# Store $s6 on the stack
	sw	$s1, 16($sp)			# Store $s1 on the stack
	sw	$s0, 12($sp)			# Store $s0 on the stack
	sw	$a1, 8($sp)			# Store $a1 on the stack
	sw	$a0, 4($sp)			# Store $a0 on the stack
	sw	$ra, 0($sp)			# Store $ra on the stack
	
	add	$s0, $a0, $zero			# $s0 = Address of shuffledWord
	add	$s1, $a1, $zero			# $s0 = Address of enteredWord
	li	$t0, 1				# $t0 = 1 (counter)
	add	$s6, $a0, $zero			# $s6 = Address of shuffledWord (backup)
	add	$s7, $a1, $zero			# $s7 = Address of enteredWord (backup)
	li	$t1, 9				# $t1 = 9 (max. counter)
wordShuffle.ClearWord:
	sb	$zero, 0($s0)			# shuffledWord = "0?????????"
	sb	$zero, 1($s0)			# shuffledWord = "00????????"
	sb	$zero, 2($s0)			# shuffledWord = "000???????"
	sb	$zero, 3($s0)			# shuffledWord = "0000??????"
	sb	$zero, 4($s0)			# shuffledWord = "00000?????"
	sb	$zero, 5($s0)			# shuffledWord = "000000????"
	sb	$zero, 6($s0)			# shuffledWord = "0000000???"
	sb	$zero, 7($s0)			# shuffledWord = "00000000??"
	sb	$zero, 8($s0)			# shuffledWord = "000000000?"
	sb	$zero, 9($s0)			# shuffledWord = "0000000000"
wordShuffle.WriteWord:
	lb	$t2, 0($s1)			# $t2 = 0(enteredWord)
	sb	$t2, 4($s0)			# 4(shuffledWord) = 0(enteredWord)
	addi	$s1, $s1, 1			# Increment the enteredWord pointer
	lb	$t2, 0($s1)			# Store enteredWord character to $t2
wordShuffle.Shuffle:
	li	$v0, 42				# Load Syscall random int range svc
	li	$a0, 0				# From 0
	li	$a1, 9				# To 8
	syscall					# Execute Syscall
	add	$t4, $a0, $zero			# Store the random int to $t4
	add	$s0, $s0, $t4			# shuffledWord pointer += random int
	lb	$t3, 0($s0)			# $t3 = random int(shuffledWord)
	bnez	$t3, wordShuffle.Shuffle.NoCopy	# If($t3 != 0) branch to wordShuffle.Shuffle.NoCopy
wordShuffle.Shuffle.Copy:			# Else, copy the character to (shuffledWord)
	lb	$t2, 0($s1)			# Store enteredWord character to $t2
	addi	$t0, $t0, 1			# Increment the counter
	sb	$t2, 0($s0)			# Store enteredWord character to 0(shuffledWord)
	addi	$s1, $s1, 1			# Increment the enteredWord pointer
	add	$s0, $s6, $zero			# $s0 = Address of shuffledWord
	bge	$t0, $t1, wordShuffle.End	# If(counter >= max counter) branch to wordShuffle.End
	j	wordShuffle.Shuffle		# Jump to wordShuffle.Shuffle
wordShuffle.Shuffle.NoCopy:
	add	$s0, $s6, $zero			# $s0 = Address of shuffledWord
	j	wordShuffle.Shuffle		# Jump to wordShuffle.Shuffle
wordShuffle.End:
	lw	$ra, 0($sp)			# Restore $ra
	lw	$a0, 4($sp)			# Restore $a0
	lw	$a1, 8($sp)			# Restore $a1
	lw	$s0, 12($sp)			# Restore $s0
	lw	$s1, 16($sp)			# Restore $s1
	lw	$s6, 20($sp)			# Restore $s6
	lw	$s7, 24($sp)			# Restore $s7
	addi	$sp, $sp, 28			# Restore the stack pointer
	
	jr	$ra				# Return to caller
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#					printMatrix Procedure						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure takes one addresses, the shuffled nine-letter word address in $a0. The shuffled
#	word is placed into a grid style matrix and the complete matrix is printed to the console.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#\t+---+---+---+\n\t| 0 | 1 | 2 |\n\t+---+---+---+\n\t| 3 | 4 | 5 |\n\t+---+---+---+\n\t| 6 | 7 | 8 |\n\t+---+---+---+\n
printMatrix:
	addi	$sp, $sp, -16			# Move the stack pointer to allocate space
	sw	$s1, 12($sp)			# Store $s1 on the stack
	sw	$s0, 8($sp)			# Store $s0 on the stack
	sw	$a0, 4($sp)			# Store $a0 on the stack
	sw	$ra, 0($sp)			# Store $ra on the stack
	
	add	$s1, $a0, $zero			# $s1 = Address of shuffledWord
	la	$s0, matrix			# $s0 = Address of matrix
	lb	$t0, 0($s1)			# $t0 = 0(shuffledWord)
	sb	$t0, 18($s0)			# 18(matrix) = 0(shuffledWord)
	lb	$t0, 1($s1)			# $t0 = 1(shuffledWord)
	sb	$t0, 22($s0)			# 22(matrix) = 1(shuffledWord)
	lb	$t0, 2($s1)			# $t0 = 2(shuffledWord)
	sb	$t0, 26($s0)			# 26(matrix) = 2(shuffledWord)
	lb	$t0, 3($s1)			# $t0 = 3(shuffledWord)
	sb	$t0, 48($s0)			# 48(matrix) = 3(shuffledWord)
	lb	$t0, 4($s1)			# $t0 = 4(shuffledWord)
	sb	$t0, 52($s0)			# 52(matrix) = 4(shuffledWord)
	lb	$t0, 5($s1)			# $t0 = 5(shuffledWord)
	sb	$t0, 56($s0)			# 56(matrix) = 5(shuffledWord)
	lb	$t0, 6($s1)			# $t0 = 6(shuffledWord)
	sb	$t0, 78($s0)			# 78(matrix) = 6(shuffledWord)
	lb	$t0, 7($s1)			# $t0 = 7(shuffledWord)
	sb	$t0, 82($s0)			# 82(matrix) = 7(shuffledWord)
	lb	$t0, 8($s1)			# $t0 = 8(shuffledWord)
	sb	$t0, 86($s0)			# 86(matrix) = 8(shuffledWord)
	li	$v0, 4				# Load Syscall print string service
	add	$a0, $s0, $zero			# $a0 = Address of matrix
	syscall					# Execute Syscall
printMatrix.End:
	li	$v0, 0				# Clear $v0
	
	lw	$ra, 0($sp)			# Restore $ra
	lw	$a0, 4($sp)			# Restore $a0
	lw	$s0, 8($sp)			# Restore $s0
	lw	$s1, 12($sp)			# Restore $s1
	addi	$sp, $sp, 16			# Restore the stack pointer
	
	jr	$ra				# Return to caller
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
