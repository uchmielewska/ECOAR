	.globl main
	.data
size:			.space 4	#bmp file size
width:			.space 4	#file width 
height:			.space 4	#file height 
offset:			.space 4	#offset - beginning of bits addresses in pixel array
temp:			.space 4	#temp buffer
beginning:		.space 4	#address of the beginning of the line
padding:		.space 1	

x_coordinate:		.word 4
y_coordinate:		.word 4
R:			.word 4
G:			.word 4
B:			.word 4

ask_input_file:		.asciiz "Input file name:\n"
ask_x_coordinate:	.asciiz "Input starting x pixel coordinate:\n"
ask_y_coordinate:	.asciiz "Input starting y pixel coordinate:\n"
ask_color_RGB:		.asciiz "Input fill color in RGB (0 - 255):\n"
ask_color_R:		.asciiz "R:\n"
ask_color_G:		.asciiz "G:\n"
ask_color_B:		.asciiz "B:\n"
input:			.space 20

hello:			.asciiz	"Flood fill\n"
output:			.asciiz "out.bmp"
outfile_error:		.asciiz "Error in output file\n"
coordinate_error:	.asciiz "Wrong coordinate!\n"
color_error:		.asciiz "Wrong number! Input colors again\n"
file_error:		.asciiz "Error in input file\n"
	
	.text
main:	
	#print hello message
	la $a0, hello				
	li $v0, 4				#syscall 4 = print string
	syscall		
	
read_file:
	#print ask_input_file message
	la	$a0, ask_input_file
	li	$v0, 4				#syscall 4 = print string
	syscall
	
	#read input file name
	la	$a0, input			#store read string in input_file
	li	$a1, 20
	li	$v0, 8				#syscall 8 = read string
	syscall

	#remove a new line from the user input string
	li 	$s0, 0        			#set index to 0
	
remove:
    	lb 	$a3, input($s0)    		#load character at index
    	addi 	$s0, $s0, 1      		#increment index
   	bnez 	$a3, remove     		#loop until the end of string is reached
    	beq 	$a1, $s0, skip   		#do not remove \n when string = maxlength
    	subiu 	$s0, $s0, 2    			#if above not true, Backtrack index to '\n'
    	sb 	$0, input($s0)   		#add the terminating character in its place

skip:
	la	$a0, input			#read name of the input file to open
	li 	$a1, 0				#flag 0
	li 	$a2, 0				#mode 0
	li 	$v0, 13				#syscall 13 = open file
	syscall					#open file, descriptor in $v0
	
	move 	$t0, $v0			#copy descriptor to $t0
	
	bltz 	$t0, inputFileErrorHandler	#go to inputFileErrorHandler if error in file opening 
	
coordinate:			
	#print ask_x_coordinate message
	li 	$v0, 4				#syscall 4 = print string
	la	$a0, ask_x_coordinate
	syscall
	
	#read x coordinate
	li	$v0, 5				#syscall 5 = read integer
	syscall
	
	#check correctness of the input number
	move	$t3, $v0
	li	$t2, 0
	blt	$t3, $t2, coordinateErrorHandler
	
	#store x coordinate in x_coordinate
	sw	$v0, x_coordinate  	
	
	#print ask_y_coordinate message
	li 	$v0, 4				#syscall 4 = print string
	la	$a0, ask_y_coordinate
	syscall	
	
	#read y coordinate
	li	$v0, 5				#syscall 5 = read integer
	syscall
	
	#check correctness of the input number
	move	$t3, $v0
	li	$t2, 0
	blt	$t3, $t2, coordinateErrorHandler
	
	#store y coordinate in y_coordinate
	sw	$v0, y_coordinate

color:	
	#print ask_color message
	li 	$v0, 4				#syscall 4 = print string
	la	$a0, ask_color_RGB
	syscall
	
	#print ask_color_R message
	li 	$v0, 4				#syscall 4 = print string
	la	$a0, ask_color_R
	syscall
	
	#read R
	li	$v0, 5				#syscall 5 = read integer
	syscall
	
	#check correctness of the input number
	move	$t3, $v0
	li	$t1, 255
	li	$t2, 0
	bgt	$t3, $t1, RGBErrorHandler
	blt	$t3, $t2, RGBErrorHandler
	
	#store R	
	sw	$v0, R

	#print ask_color_G message
	li 	$v0, 4				#syscall 4 = print string
	la	$a0, ask_color_G
	syscall
	
	#read G
	li	$v0, 5				#syscall 5 = read integer
	syscall
	
	#check correctness of the input number
	move	$t3, $v0
	li	$t1, 255
	li	$t2, 0
	bgt	$t3, $t1, RGBErrorHandler
	blt	$t3, $t2, RGBErrorHandler
	
	#store G
	sw	$v0, G
	
	#print ask_color_B message
	li 	$v0, 4				#syscall 4 = print string
	la	$a0, ask_color_B
	syscall
	
	#read B
	li	$v0, 5				#syscall 5 = read integer
	syscall
	
	#check correctness of the input number
	move	$t3, $v0
	li	$t1, 255
	li	$t2, 0
	bgt	$t3, $t1, RGBErrorHandler
	blt	$t3, $t2, RGBErrorHandler
	
	#store B
	sw	$v0, B

read_file_continue:	
	#read from file
	move 	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, temp			#read to temp buffer
	li 	$a2, 2				#read first two bytes (BM)
	li 	$v0, 14				#syscall 14 = read from file
	syscall		
	
	#read from file
	move 	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, size			#read to temp buffer
	li 	$a2, 4				#read 4 bytes
	li 	$v0, 14				#syscall 14 = read from file
	syscall		
	
	lw 	$t7, size			#load file size to $t7
	
	#allocate memory
	move 	$a0, $t7			#move file size $t7 to $a0
	li 	$v0, 9				#syscall 9 = allocate memory
	syscall		
	
	move 	$t1, $v0			#copy address of the allocaed memory to $t1
	
	#read from file
	move 	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, temp			#read to temp buffer
	li 	$a2, 4				#read 4 bytes
	li 	$v0, 14				#syscall 14 = read from file
	syscall		
	
	#read from file
	move 	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, offset			#read to offset buffer
	li 	$a2, 4				#read 4 bytes
	li 	$v0, 14				#syscall 14 = read from file
	syscall			
	
	#read from file
	move	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, temp			#read to temp buffer
	li 	$a2, 4				#read 4 bytes
	li 	$v0, 14				#syscall 14 = read from file
	syscall		
	
	#read from file
	move 	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, width			#read to width buffer
	li 	$a2, 4				#read 4 bytes
	li 	$v0, 14				#syscall 14 = read from file
	syscall		
	
	lw 	$t2, width			#load width file to $t2
	
	#read from file
	move	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, height			#read to height buffer
	li 	$a2, 4				#read 4 bytes
	li 	$v0, 14				#syscall 14 = read from file
	syscall	
	
	lw 	$t3, height			#load height file to $t3
	
	#close input file
	move 	$a0, $t0			#move descriptor $t0 to $a0
	li 	$v0, 16				#syscall 16 = close file
	syscall		
	
alocate_file:
	#open file
	la	$a0, input			#load addres of the file to read
	li 	$a1, 0 				#flaf 0 
	li 	$a2, 0				#mode 0
	li 	$v0, 13				#syscall 13 = open file
	syscall		
	
	move 	$t0, $v0			#copy descriptor to $t0
	
	bltz 	$t0, inputFileErrorHandler	#if error in opening file go to inputFileErrorHandler
	
	move 	$a0, $t0			#move descriptor $t0 to $a0
	la 	$a1, ($t1)			#load the address of previously allocated memory 
	la 	$a2, ($t7)			#read number of bytes which has file
	li 	$v0, 14				#syscall 14 = read from file
	syscall	
	
	lw 	$t7, size			#again load file size to $t7

	move 	$a0, $t0			#move descriptor $t0 to $a0
	li 	$v0, 16				#syscall 16 = close file
	syscall		

padding_check:
	lw 	$t9, offset			#load offset to $t9
	addu 	$t9, $t9, $t1			#move to the beginning of the pixel map
	  
	li 	$t6, 4				#load 4 to $t6
	divu 	$t2, $t6			#divide $t2 by $t6, reminder in HI 
	mfhi 	$t6				#copy HI to $t6
		
	li 	$s7, 1				#initiate pixel counter in a row to 1 in $s7
	
	mul 	$t8, $t2, $t3			#multiply width*height, result in $t8
	mul	$t8, $t8, 3			#multiply $t8 by 3 (3 bytes per pixel), so $t8 = width*height*3

	beq 	$t6, 0, padding_0		#reminder = 0, no padding
	beq 	$t6, 1, padding_1		#reminder = 1, padding 1 byte per line
	beq 	$t6, 2, padding_2		#reminder = 2, padding 2 bytes per line
	beq 	$t6, 3, padding_3		#reminder = 3, padding 3 bytes per line

padding_0:
	addu 	$t8, $t8, $t1			#add memory
	lw 	$t6, offset			#load offset
	addu 	$t8, $t8, $t6			#in $t8 there is address of the end of file 
	li 	$t6, 0				#$t6 is 0
	b start

padding_1:
	mul 	$t6, $t3, 1			#in $t6 there is height multiplied by the number of padding bytes
	addu 	$t8, $t8, $t6			#add padding 
	addu 	$t8, $t8, $t1			#add memory index
	lw 	$t6, offset			#load offset (add offset) to %t6
	addu 	$t8, $t8, $t6			#in $t8 there is address of the end of file 
	mul 	$t6, $t3, 1			#in $t6 there is height multiplied by the number of padding bytes
	li 	$t6, 1				#set $t6 to num of padding bytes
	b start
	
padding_2:
	mul 	$t6, $t3, 2			#in $t6 there is height multiplied by the number of padding bytes
	addu 	$t8, $t8, $t6			#add padding 
	addu 	$t8, $t8, $t1			#add memory index
	lw 	$t6, offset			#load offset (add offset) to %t6
	addu 	$t8, $t8, $t6			#in $t8 there is address of the end of file 
	mul 	$t6, $t3, 2			#in $t6 there is height multiplied by the number of padding bytes
	li 	$t6, 2				#set $t6 to num of padding bytes
	b start
	
padding_3:
	mul 	$t6, $t3, 3			#in $t6 there is height multiplied by the number of padding bytes
	addu 	$t8, $t8, $t6			#add padding
	addu 	$t8, $t8, $t1			#add memory index
	lw 	$t6, offset			#load offset (add offset) to %t6
	addu 	$t8, $t8, $t6			#in $t8 there is address of the end of file 
	mul 	$t6, $t3, 3			#in $t6 there is height multiplied by the number of padding bytes
	li 	$t6, 3				#set $t6 to num of padding bytes
	b start
	
start:
	sw 	$t6, padding			#store contects of $t6 in padding
	sw 	$t9, beginning			#store contents of $t9 in beginning
	
#$t0 - file descriptor
#$t1 - allocated memory
#$t2 - width
#$t3 - height
#$t4 - x_coordinate
#$t5 - y_coordinate
#$t6 - num of padding bytes
#$t7 - file size 
#$t8 - address of the end of file
#$t9 - beginning of the pixel map/ in flood_fill used as current pixel
	
	lb 	$t4, x_coordinate
	lb 	$t5, y_coordinate 
	
	jal flood_fill
	
save_file:
	la 	$a0, output			# wczytanie nazwy pliku do otwarcia
	li 	$a1, 1				# flagi otwarcia
	li 	$a2, 0				# tryb otwarcia
	li 	$v0, 13				# ustawienie syscall na otwieranie pliku
	syscall					# otwarcie pliku, zostawienie w $v0 jego deskryptora
	
	move 	$v0, $t0			# przekopiowanie deskryptora do rejestru t0
	lw 	$t7, size
	
	bltz 	$t0, outputFileErrorHandler		# przeskocz do outputFileErrorHandler jesli wczytywanie sie nie powiodlo
	
	move 	$a0, $t0			# przekopiowanie deskryptora do a0
	la 	$a1, ($t1)			# wskazanie wczesniej zaalokowanej pamieci jako danych do zapisania
	la 	$a2, ($t7)			# ustawienie zapisu tylu bajtow ile ma plik
	li 	$v0, 15				# ustawienie syscall na zapis do pliku
	syscall					# wczytanie wysokosci bitmapy
	
	j close_file				# zamknij plik
	
close_file:
	move 	$a0, $t0			#copy file descriptor to $a0
	li 	$v0, 16				#syscall 16 = close file
	syscall					

exit:	li	$v0, 10				#syscall 10 = terminate program
	syscall					

inputFileErrorHandler:
	la	$a0, file_error
	li 	$v0, 4
	syscall
	j exit
	
outputFileErrorHandler:
	la 	$a0, outfile_error
	li 	$v0, 4
	syscall
	j exit

coordinateErrorHandler:
	li	$v0, 4				#syscall 4 = print string
	la 	$a0, coordinate_error		#print the message
	syscall
	j	exit
	
RGBErrorHandler:
	li	$v0, 4				#syscall 4 = print string
	la 	$a0, color_error		#print the message
	syscall
	j	exit
	
flood_fill:
#$t4 = x
#$t5 = y
#if row less than 0 OR row greater than height -> exit
#if column less than 0 OR column greater than width -> exit
	
	#save to the stack
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s6, 4($sp)
	sw	$s7, 8($sp)
	
	add	$s6, $t4, $zero
	add	$s7, $t5, $zero
	
	#exit if coordinates exceed the frame size
	blt	$t4, 0, exit_ff
	blt	$t5, 0, exit_ff
	bgt	$t4, $t2, exit_ff
	bgt	$t5, $t3, exit_ff
	
#$s3 - normalized width
#$s4 - normalized x offset 
#$s5 - normalized y offset
	
	#calculate pixel addres with current coordinates
	move 	$s3, $t2
	mul 	$s3,  $s3, 3	
	add 	$s3, $s3, $t6
	
	mul 	$s4, $t4, 3
	
	mul 	$s5, $s3, $t5
	
	lw 	$t9, beginning
	add 	$t9, $t9, $s4
	add 	$t9, $t9, $s5
	
	#check if pixel is white
	lbu 	$s0, ($t9)			#read blue pixel value to $s0
	addiu 	$t9, $t9, 1

	lbu 	$s1, ($t9)			#read green pixel value to $s1
	addiu	$t9, $t9, 1
	
	lbu 	$s2, ($t9)			#read red pixel value to $s2
	
	subiu 	$t9, $t9, 2
	
	#exit if pixel is not white
	bne 	$s0, 255, exit_ff
	bne 	$s1, 255, exit_ff
	bne 	$s2, 255, exit_ff
	
	#set new color
	lb 	$a2, B				#load B to $a2
	sb 	$a2, ($t9)			#store B
	lb 	$a2, G				#load G to $a2
	sb 	$a2, 1($t9)			#store G
	lb 	$a2, R				#load R to $a2
	sb 	$a2, 2($t9)			#store R
	
	#move_left
	subu 	$t4, $t4, 1
	jal flood_fill
	
	#move_right
	addu 	$t4, $t4, 1
	jal flood_fill
	
	#move_up
	addu 	$t5, $t5, 1
	jal flood_fill
	
	#move_down
	subu 	$t5, $t5, 1
	jal flood_fill
	
	j exit_ff
	
exit_ff:
	lw	$ra, 0($sp)
	lw	$s6, 4($sp)
	lw	$s7, 8($sp)

	move 	$t4, $s6
	move 	$t5, $s7
		
	addi	$sp, $sp, 12
	
	jr $ra
