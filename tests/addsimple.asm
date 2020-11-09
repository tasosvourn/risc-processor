        .data
n1:
        .word  1
n15:
        .word  15
n_m5:
        .word  -5
       
        .globl main

        .text
main:   
	la  $t0, n1
	la  $t1, 8($t0)
	add $t2, $t0, $t1
	sw 