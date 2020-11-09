	.data
n1: 
	.word 5
n2:
	.word 34
	
	.text
main:
	
	addi $s0, $s0, 4
	addi $s1, $s1, 3
	addi $s2, $s2, 2
	addi $s3, $s3, 1
	addi $a2, $a2, 5
	add  $t0, $s0, $s1
	add  $t1, $s2, $s3
	sub  $s4, $t0, $t1
	beq  $s0,$s4, else
	add  $s0, $s4, 3
else:
	sw  $s4, n1
loop:	
	add $s2, $s2, $s3
	addi $s1, $s1, 1 
	lw $s3, n1
	sub $s4, $s4, $s2
	addi $v0, $0, 10 
	syscall
	
