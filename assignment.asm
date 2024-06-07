	# AT HORIZONTAL CHECK: need stop condition.
	# WINNING CONDITION ALGORITHM.
.data
		.align 2
	arr:	.word 95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95
	column:	.asciiz "|" 
	newline:.asciiz "\n"
	select:	.asciiz "who will go first(x | o): "
	turn:	.asciiz " turn: "
	again:	.asciiz "Are you sure about that (1 | 0---->yes | no)? "
	noslot:	.asciiz "No slot, go again please. \n"
	spacebar:.asciiz " "
	board1: .asciiz "   0  1  2  3  4  5  6 \n"
	winning:.asciiz " IS WINNER "
	preboard:.asciiz "   0  1  2  3  4  5  6\n0 |_||_||_||_||_||_||_|\n1 |_||_||_||_||_||_||_|\n2 |_||_||_||_||_||_||_|\n3 |_||_||_||_||_||_||_|\n4 |_||_||_||_||_||_||_|\n5 |_||_||_||_||_||_||_|\n"
	draw:	.asciiz "TIE MATCH!"
	timesofreturn: .asciiz "Number of times to return left: "
	wrongnumber:  .asciiz "That's a wrong number, input number from 0 to 6 only please. \n"
.text
	main:
		li $v0,4	# ask who will go first
		la $a0,select	# print out message
		syscall		# call service
		
		li $v0,12	# read char from user
		syscall		# call service
		move $s0,$v0	# store data to $s0
		
		li $v0,4	# print new line
		la $a0,newline	# load address of newline
		syscall		# call service
		
		li $v0,4	# print preboard
		la $a0,preboard	# load address of newline
		syscall		# call service
		
		li $t8,4	# count for times to re-turn
	TURN:
		addi $t8,$t8,-1
		li $v0,4
		la $a0,timesofreturn
		syscall
		
		li $v0,1
		move $a0,$t8
		syscall
		
		li $v0,4
		la $a0,newline
		syscall
		
		li $v0,11	# print whose turn;
		move $a0,$s0	# load symbol address
		syscall		# call service
		
		li $v0,4	# print string "turn"
		la $a0,turn	# load address of turn
		syscall		# call service
		
		li $v0,5	#read player position
		syscall		#call service
		sgt $s1,$v0,6	# if input larger than 6 let's player go again
		beq $s1,1,SIKE
		li $t0,6	# initalize t0 for SET FUNTION
		j SET		# find postion in board to set symbol
	SIKE:
		li $v0,4
		la $a0, wrongnumber
		syscall
		li $t8,4
		j TURN
#PROCESS OF SET:										#-> true, go back and put symbol to array 
	# read turn form TURN -> jump to SET to calculate coordinate -> jump to AGAIN to ask for sure							->jump to PrintTable
												#-> flase , go back to TURN function to read input again
		# PrintTable include: -> Print out number for board: load board1.
		#		      -> Print out number for column ->Print out data->endline after print 7 column.

#data map for SET_FUNCTION:
	#v0	vo= column to go				# can be used in another function without affect
	#a0	a0= used as intitalize coefficent		# can be used in another function without affect
	#a1	a1= row to go					# can be used in another function without affect
	#a2	a2= intersection of row and column		# can be used in another function without affect
	SET:
		subi $t0,$t0,1		# initialize t0;
		beq $t0,-1,NO_SLOT	# return if there are no more space to put symbol
		j POSITION
	POSITION:
		li $a0,28	# $a0=28
		mult $a0,$t0	# a0xt0(n-th row)
		mflo $a1	# return result to $a1
		
		li $a0,4	# $a0=4
		mult $a0,$v0	# $aox$v0
		mflo $a2	# return result to $a2
		add $a2,$a1,$a2	# add a2=a1+a2 intersection of row and column
		lw $v1,arr($a2)
		bne $v1,95,SET	# if not empty go again
		jal AGAIN	# if empty ask for sure?
		sw $s0,arr($a2)	# store symbol to board
		addi $t7,$t7,1	# count number of turn has been taken sofar
		j PrintTable	# print out updated board
	AGAIN:
		beq $t8,0,RETURN
		li $v0,4	# print out message to ask again
		la $a0,again	# load address of again
		syscall		# call service
			
		li $v0,12	# read decision
		syscall		# call service
		move $a1,$v0
		
		li $v0,4	# end line
		la $a0,newline	# load address of endline
		syscall		# call service
		
		beq $a1,48,TURN	# if 0 not sure go again
		
		jr $ra		# if 1 continue process
	NO_SLOT:
		addi $t9,$t9,1
		beq $t9,3,ILLEGAL
		li $v0,4
		la $a0,noslot
		syscall
		j TURN
#data map for PRINTTABLE_FUNCTION:
	#t0	t0=i;		can be used in another function after print table
	#t1	t1=j;		can be used in another function after print table
	#t2	t2=arr[i][j]	can be used in another function after print table
	#a0	a0=28 uses as coefficent
	PrintTable:
		li $t0,0	# initialize i,j to 0 before print
		li $t1,0	
		
		li $v0,4	# print number for column
		la $a0,board1	# load address of board
		syscall		# call service
		j FOR_i		# go to i loop
	new_line:
		li $v0,4	# enlinde after row
		la $a0,newline	# load address of endline code
		syscall		#call for service
		j FOR_i
	FOR_i:
		beq $t0,6,CHECK_WINNING# if i=6 stop (maximum 6 row)
		
		li $v0,1	# print number for row
		move $a0,$t0	# move $t0 to $a0 to print
		syscall		# call service
		
		li $v0,4	# space after print 
		la $a0,spacebar # load address of space
		syscall		# syscall
		
		li $t1,0	# set up j
		li $a0,28	# coefficent to move to next row
		mult $t0,$a0	# multiply n-th row with coefficient $a0
		mflo $a0	# store result to $a0
		##########	
		la $t2,arr($a0)	# load address of first cell to $t2
		addi $t0,$t0,1	# increase i
		j FOR_j		# go to j loop
	FOR_j:
		beq $t1,7,new_line	# if j=8 stop (maximum 7 column)
		
		li $v0,4	# print column bar
		la $a0,column	
		syscall
		
		li $v0,11	# print arr[i][j]
		lb $a0,0($t2)	# uses code 11 because we want to see character,not number
		syscall		# call service
		
		li $v0,4	# print column bar
		la $a0,column
		syscall
		
		addi $t2,$t2,4	# load address of next cell to $t2
		addi $t1,$t1,1	# increase j
		j FOR_j		# go back to the top of function FOR_j
	switch:
		li $a0,231	# 231-x=0 vice versa
		sub $s0,$a0,$s0	
		li $t8,4
		li $t9,0
		j TURN
#data map for check HORIZONTAL winning condition:
	# t3 for counting 
	# t5 for j loop for column (0->3)
	# t2 to traverse array
	# t4 to traverse row i
	# t6 to load data and compare data
#PROCESS OF CHECKING:
	# load data of first cell of row 6 to $s6 and compare to player who just played
	# if true increase count
	# if not reset count and move to next cell to load $s6
	# if false happened at column greater than 3 we move to check vertical because 4,5,6 only has less than 4 column which will not satisfy horizontal condition
	CHECK_WINNING:
		sgt $s7,$t7,6	# if number of turn has been taken less than 7 there is absolutely nothing to check
		bne $s7,1,switch
		li $t3,0	# Pre-set for Horizontal check
		li $t4,6
		li $t5,0
		jal HORIZONTAL_i
		li $t3,0	# Pre-set for vertical check
		li $t4,5
		li $t5,-1
		jal VERTICAL_i
		li $t3,0
		li $t4,-1
		li $t5,0
		jal UP_DOWN_i
		li $t3,0
		li $t4,6
		li $t5,0
		jal DOWN_UP_i
		beq  $t7,42,DRAW
		j switch
	HORIZONTAL_i:
		beq $t4,-1,RETURN
		addi $t4,$t4,-1	# reduced ($t4) prepare to go to next row
		li $t5,0
		j HORIZONTAL	# go inside loop
	HORIZONTAL:
		beq $t5,4,HORIZONTAL_i	# if i=4 stop(4+4=8 > 7 row)-> illegal
		
		la $a0,28	# load coefficent for $a0
		mult $a0,$t4	# multiply $a0 with 4 to get to first cell of $t4-th row
		mflo $a0	# return result to $a0
		
		la $a1,4	# load coefficent for $a1
		mult $a1,$t5	# multiply with $t5
		mflo $a1	# return result to $a1
		
		add $a0,$a0,$a1	# add two result together
		
		la $t2,arr($a0)
		j H_CHECK
	H_CHECK:
		lw $t6,0($t2)		# load data to $t6 to compare
		bne $t6,$s0,RESET_COUNT_H	# if $t6 not equal to player who just go then we reset count and then go to check VERTICAL
		addi $t3,$t3,1		# else if $t6 euqual to that of player increase count by 1
		beq $t3,4,RESULT	# if $t3=4 A player is win
		addi $t2,$t2,4		# move to next column to check
		j H_CHECK
	RESET_COUNT_H:
		li $t3,0		# reset count 
		addi $t5,$t5,1		# check from next column to column+3
		j HORIZONTAL
	RETURN:
		jr $ra
	RESULT:
		li $v0,11
		move $a0,$s0
		syscall
		
		li $v0,4
		la $a0,winning
		syscall
		j exit
#data map for check HORIZONTAL winning condition:
	# t3 for counting 
	# t5 for i loop for column (0->3)
	# t2 to traverse array
	# t4 for j to traverse column row
	# t6 to load data and compare data
	VERTICAL_i:
		beq $t5,4,RETURN	# if i=7 stop (maximum 7 column)
		addi $t5,$t5,1		# increase i
		li $t4,5
		j VERTICAL
	VERTICAL:
		beq $t4,2,VERTICAL_i
		
		la $a0,28	# load coefficent for $a0
		mult $a0,$t4	# multiply $a0 with 4 to get to first cell of $t4-th row
		mflo $a0	# return result to $a0
		
		la $a1,4	# load coefficent for $a1
		mult $a1,$t5	# multiply a1 with $t5 to get to $t5-th column
		mflo $a1	# return result to $a1
		
		add $a0,$a0,$a1	# add $a0 ,$a1 together we get exact coordinate
		
		la $t2,arr($a0)		# load cell address
		j V_CHECK
	V_CHECK:
		lw $t6,0($t2)		# load data to $t6 to compare
		bne $t6,$s0,RESET_COUNT_V	# if $t6 not equal to player who just go then we reset count and then go to check VERTICAL_i
		addi $t3,$t3,1		# else if $t6 euqual to that of player increase count by 1
		beq $t3,4,RESULT	# if $t3=4 A player is win
		addi $t2,$t2,-28	# move to next row to check
		j V_CHECK		# go inside loop
	RESET_COUNT_V:
		li $t3,0
		addi $t4,$t4,-1
		#sle $a0,$t4,2
		#beq $a0,1,VERTICAL_i
		j VERTICAL
#data map for check HORIZONTAL winning condition:
	# t3 for counting 
	# t5 for j loop for column (1->6)
	# t2 to traverse array
	# t4 for i to traverse column row
	# t6 to load data and compare data
	UP_DOWN_i:
		beq $t4,3,RETURN	#(if load 4 column it'll be like 4,5,6,7 to get enough 4 but maximum of row is 7 from 0->6)
		addi $t4,$t4,1
		li $t5,0
		j UP_DOWN
	UP_DOWN:
		beq $t5,4,UP_DOWN_i		# traverse horizontal then vertical if j reach 4 stop
		
		la $a0,28			# load coefficent to traverse row
		mult $a0,$t4			# converse to address by multiplied  with $t4
		mflo $a0			# return result to $a0
		
		la $a1,4			# load coefficent to traverse column
		mult $a1,$t5			# converse to address by multiplied with $t5
		mflo $a1			# return result to $a1
		add $a0,$a0,$a1			# add 2 result together and store in $a0
		
		la $t2,arr($a0)
	UD_CHECK:
		lw $t6,0($t2)			# load data t0 $t6 to compare
		bne $t6,$s0,RESET_COUNT_UD	# check condition if not reset count increase j($t5)
		addi $t3,$t3,1			# if equal increase count
		beq $t3,4,RESULT		# if count equal 4 , one player is win
		addi $t2,$t2,32			# move diagonally by move 8 cell forward
		j UD_CHECK			# come back to UD_CHECK
	RESET_COUNT_UD:
		li $t3,0			# reset count
		addi $t5,$t5,1			# increase j
		j UP_DOWN			# back to UPDOWN
#data map for check HORIZONTAL winning condition:
	# t3 for counting 
	# t5 for j loop for column (1->6)
	# t2 to traverse array
	# t4 for i to traverse row
	# t6 to load data and compare data
	DOWN_UP_i:
		beq $t4,2,RETURN	#(if load 4 column it'll be like 4,5,6,7 to get enough 4 but maximum of row is 7 from 0->6)
		addi $t4,$t4,-1
		li $t5,0
		j DOWN_UP
	DOWN_UP:
		beq $t5,4,DOWN_UP_i		# traverse horizontal then vertical if j reach 4 stop
		
		la $a0,28			# load coefficent to traverse row
		mult $a0,$t4			# converse to address by multiplied  with $t4
		mflo $a0			# return result to $a0
		
		la $a1,4			# load coefficent to traverse column
		mult $a1,$t5			# converse to address by multiplied with $t5
		mflo $a1			# return result to $a1
		add $a0,$a0,$a1			# add 2 result together and store in $a0
		
		la $t2,arr($a0)
	DU_CHECK:
		lw $t6,0($t2)			# load data to $t6 to compare
		bne $t6,$s0,RESET_COUNT_DU	# check condition as UP_DOWN 
		addi $t3,$t3,1
		beq $t3,4,RESULT
		addi $t2,$t2,-24
		j DU_CHECK
	RESET_COUNT_DU:
		li $t3,0
		addi $t5,$t5,1
		j DOWN_UP
	DRAW:
		li $v0,4
		la $a0,draw
		syscall
		j exit
	ILLEGAL:
		li $a0,231	# 231-x=0 vice versa
		sub $s0,$a0,$s0	
		
		li $v0,11
		move $a0,$s0
		syscall
		
		li $v0,4
		la $a0,winning
		syscall
		j exit
	exit:
		li $v0,10
		syscall
