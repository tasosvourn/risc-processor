	.data
n1: 
	.word 1
n2:
	.word 34
	
	.text
main:
        la   $t0,   n1 
	lw   $t3,   4($t0)
	sw   $t3,   12($t0)
	lw   $t2,   12($t0)
	addi $s0, $s0, 4
	addi $s1, $s1, 3
	addi $s2, $s2, 2
	addi $s3, $s3, 1
	add  $t0, $s0, $s1
	add  $t1, $s2, $s3
	sub  $s4, $t0, $t1
equal:
	beq  $s0,$s4, loop
	j finish
loop:	
	add $s2, $s2, $s3
	addi $s1, $s1, 1
	add $s4, $s4, $s0
	j equal

finish:
	addi $v0, $0, 10 
	syscall
	
