        .data
n1:
        .word  1
n15:
        .word  15
n_m5:
        .word  -5
v1:
        .word  0   # Should end up equal to -5 n_m5
v2:
        .word  0   # Should end up equal to 0xfe000000.
                   # If I get 0xfe000002, $zero got forwarded
                   # If I get 0x001e0000, double hazard did not work correctly.

        .globl main

        .text
main:   
        la   $t0,   n1             # Internal forwarding between lui and ori produced by la
        lw   $t3,   8($t0)         # -5 = 32'b111...1_1011
        sw   $t3,   12($t0)        # test back to back lw-sw for forwarding/bypassing
        add  $t4,   $t3,    $t0    # Must NOT try to forward t3 from sw, although no harm can be done!
                                   #   It does forward from lw though (from start of WB stage)!

        # Must not forward changes to $zero
        addi $zero, $zero, 1
        lui  $t4,   0x000f     # lui reads $zero, should not bypass 1 for zero! (It forwards t4 from WB)
        lui  $t4,   0xff00     # ditto for 1 stage later.
        add  $t5,   $t4,   $t4 # Test for double hazard problem. Must get 0xfe000000 not 0x001e0000
        sw   $t5,   16($t0)    # Store to mem for checking
        add  $t4,   $t5,   $t5 # Test bypass from WB stage


        # Load - use tests
        lw   $t1,   0($t0)         # 1
        add  $zero, $t0,   $t0     # Dummy.
        add  $t3,   $t1,   $t1     # Should not stall but forward t1
        lw   $t2,   4($t0)         # 15 = 32'b000...0_1111
        add  $t3,   $t2,   $t3     # Stall on t2. result should be 17
        lw   $t1,   0($t0)
        addi $t1,   $zero, 5       # Should not stall. rt-t1 is destination not source
        lw   $zero, 0($t0)         # Loading to $zero, should not stall next instruction
        lui  $t5,   0x1000         # Implicit $zero as rs in lui. should not stall nor forward from load!
        lw   $a0,   0($t0)
        j    here # instruction code: 0x8100016  a0- 4 into "rs" field of jump immediate.
                      # MUST CHANGE THIS ADDRESS OR REGISTER IF I CHANGE THE CODE!!!!!!!!!!!!!
                           # Should not stall!
here:
        # Test stalling for branches
        lw   $t1,   0($t0) 
        add  $zero, $t1,   $t2       # Stall 1 cycle for $t1. Could be smart here and realise I'm not writing anything and not stall!
        beq  $t1,   $zero, nottaken  # Do not stall for $zero as rt
        beq  $zero, $t1,   nottaken  # Do not stall for $zero! as rs and 2 cycles away.
        beq  $t1,   $zero, nottaken  # Do not stall: previous t1 (in rt) is not a destination!
        beq  $t1,   $zero, nottaken  # Do not stall: t1 of beq 2 instr back (in rt) is not a destination!
        add  $t6,   $zero, $t1
        beq  $t6,   $t1,   taken1    # Should stall for 2 cycles to get t6
nottaken:
        j    shouldNeverGetHere
taken1:
        add  $t6,   $zero, $t1
        add  $t7,   $t1,   $zero
        beq  $t6,   $t1,   taken2    # Should stall for 1 cycles to get t6
shouldNeverGetHere:
        li   $v0,  0xBAD0BAD   
        sw   $v0,  0($t0)
taken2:
        # I should test stalling for 2nd register of beq (rt) here!