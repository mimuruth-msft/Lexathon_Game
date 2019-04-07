#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				         DATA SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
.data
	timer:		.word	0
	startTime:	.word	0
	currentTime:	.word	0

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#				      TEXT SEGMENT      						#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
.text

#
#	This procedure is used to set up the first time read
#	i.e. one would use this at the beginning of the game
#	and any time after the updated time has been displayed
#
setInitialTime:
	addi	$sp, $sp, -16				# Move the stack pointer to allocate space
	sw	$s1, 12($sp)				# Store $s1 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	li	$v0, 30					# This reads in the current time from the CPU clock
	syscall						# Time is stored into $a0, and $a1
	addu	$s0, $a0, $a1				# Use 64-bit addition to get the full time read from $v0, 30
	sw	$s0, startTime				# Store startTime in ms
	
	li	$t0, 60000				# $t0 = 60000 (ms)
	sw	$t0, timer				# timer = 60000 (ms)
	
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$s1, 12($sp)				# Restore $s1
	addi	$sp, $sp, 16				# Restore the stack pointer
	
	jr	$ra					# Return to caller


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure is used to read the time directly after                                          #
#	the user has input a word. We need this second time so                                          #
#	that we can calculate how much time has passed.                                                 #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
setCurrentTime:
	addi	$sp, $sp, -16				# Move the stack pointer to allocate space
	sw	$s0, 12($sp)				# Store $s0 on the stack
	sw	$a1, 8($sp)				# Store $a1 on the stack
	sw	$a0, 4($sp)				# Store $a0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	li	$v0, 30					# This reads in the current time from the CPU clock
	syscall						# Time is stored into $a0, and $a1
	addu	$s0, $a0, $a1				# Add them together with 64-bit addition
	sw	$s0, currentTime			# Store currentTime in ms
	
	lw	$ra, 0($sp)				# Restore $ra
	lw	$a0, 4($sp)				# Restore $a0
	lw	$a1, 8($sp)				# Restore $a1
	lw	$s1, 12($sp)				# Restore $s1
	addi	$sp, $sp, 16				# Restore the stack pointer
	
	jr	$ra

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure calculates how much time has passed since                                        #
#	our initial time reading, then updates the timer. Time remaining                                #
#	in milliseconds is returned.                                                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
getTimeRemaining:
	addi	$sp, $sp, -20				# Move the stack pointer to allocate space
	sw	$s6, 16($sp)				# Store $s6 on the stack
	sw	$s2, 12($sp)				# Store $s2 on the stack
	sw	$s1, 8($sp)				# Store $s1 on the stack
	sw	$s0, 4($sp)				# Store $s0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	jal	setCurrentTime				# Update the currentTime value
	lw	$s6, timer				# $s6 = (timer)
	lw	$s1, currentTime			# $s1 = (currentTime)
	lw	$s0, startTime				# $s0 = (startTime)
	
	subu	$s2, $s1, $s0				# Subtracting the initial time from the current time
	
	sub	$s6, $s6, $s2				# Subtract how much time has passed from the original timer
	add	$v0, $zero, $s6				# $v0 = time remaining in ms
	
	lw	$ra, 0($sp)				# Restore $ra
	lw	$s0, 4($sp)				# Restore $s0
	lw	$s1, 8($sp)				# Restore $s1
	lw	$s2, 12($sp)				# Restore $s2
	lw	$s6, 16($sp)				# Restore $s6
	addi	$sp, $sp, 20				# Restore the stack pointer
	
	jr	$ra					# Return to caller


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#	This procedure is used for when the user inputs a correct                                       #
#	word for the game. Time remaining in milliseconds is returned.                                  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
incrementTimer:
	addi	$sp, $sp, -20				# Move the stack pointer to allocate space
	sw	$s6, 16($sp)				# Store $s6 on the stack
	sw	$s2, 12($sp)				# Store $s2 on the stack
	sw	$s1, 8($sp)				# Store $s1 on the stack
	sw	$s0, 4($sp)				# Store $s0 on the stack
	sw	$ra, 0($sp)				# Store $ra on the stack
	
	jal	setCurrentTime				# Update the currentTime value
	lw	$s6, timer				# $s6 = (timer)
	lw	$s1, currentTime			# $s1 = (currentTime)
	lw	$s0, startTime				# $s0 = (startTime)
	
	sub	$s2, $s1, $s0				# $s2 = elapsed time
	ble	$s6, $s2, incrementTimer.NoTime		# If(timer<=elapsed time) branch to incrementTimer.NoTime
	addi	$s6, $s6, 20000				# timer += 20 seconds
	sw	$s6, timer				# Store new timer value
	sub	$v0, $s6, $s2				# $v0 = timer - time elapsed
	j	incrementTimer.End			# Jump to incrementTimer.End
incrementTimer.NoTime:
	sw	$zero, timer				# Update the timer variable
	li	$v0, 0					# $v0 = 0
incrementTimer.End:
	lw	$ra, 0($sp)				# Restore $ra
	lw	$s0, 4($sp)				# Restore $s0
	lw	$s1, 8($sp)				# Restore $s1
	lw	$s2, 12($sp)				# Restore $s2
	lw	$s6, 16($sp)				# Restore $s6
	addi	$sp, $sp, 20				# Restore the stack pointer
	
	jr	$ra					# Return to caller
