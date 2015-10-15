!=================================================================
! General conventions:
!   1) Stack grows from high addresses to low addresses, and the
!      top of the stack points to valid data
!
!   2) Register usage is as implied by assembler names and manual
!
!   3) Function Calling Convention:
!
!       Setup)
!       * Immediately upon entering a function, push the RA on the stack.
!       * Next, push all the registers used by the function on the stack.
!
!       Teardown)
!       * Load the return value in $v0.
!       * Pop any saved registers from the stack back into the registers.
!       * Pop the RA back into $ra.
!       * Return by executing jalr $ra, $zero.
!=================================================================

!vector table
vector0:    .fill 0x00000000 !0
            .fill 0x00000000 !1
            .fill 0x00000000 !2
            .fill 0x00000000
            .fill 0x00000000 !4
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000 !8
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000 !15
!end vector table

main:           la $sp, stack           ! Initialize stack pointer
                lw $sp, 0($sp)          
                
                ! Install timer interrupt handler into vector tabl
                la $s0, ti_inthandler   ! load interrupt handler to $s0
                sw $s0, 0x1($zero)      ! save $so to 0x00000001
                ei                      ! Don't forget to enable interrupts...

                la $at, factorial       ! load address of factorial label into $at
                addi $a0, $zero, 5      ! $a0 = 5, the number to factorialize
                jalr $at, $ra           ! jump to factorial, set $ra to return addr
                la $a1, seconds
                lw $a1, 0x0($a1)
                lw $a1, 0x0($a1)
                la $a2, minutes
                lw $a2, 0x0($a2)
                lw $a2, 0x0($a2)
                la $a3, hours
                lw $a3, 0x0($a3)
                lw $a3, 0x0($a3)
                halt                    ! when we return, just halt

factorial:      addi    $sp, $sp, -1    ! push RA
                sw      $ra, 0($sp)
                addi    $sp, $sp, -1    ! push a0
                sw      $a0, 0($sp)
                addi    $sp, $sp, -1    ! push s0
                sw      $s0, 0($sp)
                addi    $sp, $sp, -1    ! push s1
                sw      $s1, 0($sp)

                beq     $a0, $zero, base_zero
                addi    $s1, $zero, 1
                beq     $a0, $s1, base_one
                beq     $zero, $zero, recurse
                
    base_zero:  addi    $v0, $zero, 1   ! 0! = 1
                beq     $zero, $zero, done

    base_one:   addi    $v0, $zero, 1   ! 1! = 1
                beq     $zero, $zero, done

    recurse:    add     $s1, $a0, $zero     ! save n in s1
                addi    $a0, $a0, -1        ! n! = n * (n-1)!
                la      $at, factorial
                jalr    $at, $ra

                add     $s0, $v0, $zero     ! use s0 to store (n-1)!
                add     $v0, $zero, $zero   ! use v0 as sum register
        mul:    beq     $s1, $zero, done    ! use s1 as counter (from n to 0)
                add     $v0, $v0, $s0
                addi    $s1, $s1, -1
                beq     $zero, $zero, mul

    done:       lw      $s1, 0($sp)     ! pop s1
                addi    $sp, $sp, 1
                lw      $s0, 0($sp)     ! pop s0
                addi    $sp, $sp, 1
                lw      $a0, 0($sp)     ! pop a0
                addi    $sp, $sp, 1
                lw      $ra, 0($sp)     ! pop RA
                addi    $sp, $sp, 1
                jalr    $ra, $zero

ti_inthandler: 
                boni $fp,$sp,-1
                boni $at,$sp,-1
                boni $v0,$sp,-1
                boni $a0,$sp,-1
                boni $a1,$sp,-1
                boni $a2,$sp,-1
                boni $a3,$sp,-1
                boni $a4,$sp,-1
                boni $s0,$sp,-1
                boni $s1,$sp,-1
                boni $s2,$sp,-1
                boni $s3,$sp,-1
                boni $k0,$sp,-1
                boni $ra,$sp,-1
       
                
                ei
                
                la $s0, seconds
                lw $s0, 0x0($s0)
                lw $s1, 0x0($s0)

                addi $s1, $s1, 1
                addi $a0, $zero, 60
                bonr $a0, $s1, $a0
                beq $zero, $a0, secFull
                sw $s1, 0x0($s0)
                beq $zero, $zero, restore
                
secFull:        sw $zero, 0x0($s0)
                la $s0, minutes
                lw $s0, 0x0($s0)
                lw $s1, 0x0($s0)
                addi $s1, $s1, 1
                addi $a0, $zero, 60
                bonr $a0, $s1, $a0
                beq $zero, $a0, minFull
                sw $s1, 0x0($s0)
                beq $zero, $zero, restore
minFull:        sw $zero, 0x0($s0)
                la $s0, hours
                lw $s0, 0x0($s0)
                lw $s1, 0x0($s0)
                addi $s1, $s1, 1
                sw $s1, 0x0($s0)
                beq $zero, $zero, restore
               
restore:        addi $sp,$sp,14
                lw $fp,-1($sp)
                lw $at,-2($sp)
                lw $v0,-3($sp)
                lw $a0,-4($sp)
                lw $a1,-5($sp)
                lw $a2,-6($sp)
                lw $a3,-7($sp)
                lw $a4,-8($sp)
                lw $s0,-9($sp)
                lw $s1,-10($sp)
                lw $s2,-11($sp)
                lw $s3,-12($sp)
                
                lw $ra,-14($sp)
                
                di
                lw $k0,-13($sp)
                reti
                
stack:      .fill 0xA00000
seconds:    .fill 0xFFFFFC
minutes:    .fill 0xFFFFFD
hours:      .fill 0xFFFFFE
