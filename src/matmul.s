.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    bge x0 a1 error
    bge x0 a2 error
    bge x0 a4 error
    bge x0 a5 error
    bne a2 a4 error

    # Prologue
    addi sp sp -48
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw s9 36(sp)
    sw s10 40(sp)
    sw s11 44(sp)

    mv s0 a0 # a0: m0 pointer
    mv s1 a1 # a1: m0 height
    mv s2 a2 # a2: m0 width
    mv s3 a3 # a3: m1 pointer
    mv s4 a4 # a4: m1 height
    mv s5 a5 # a5: m1 width
    mv s6 a6 # a6: result pointer
    mv s7 ra
    add s8 x0 x0 # s8: current row index
    mv s10 a1
    mv s11 a5

outer_loop_start:

    bge s8 s10 outer_loop_end
    add s9 x0 x0 # s9: current col offset
    
inner_loop_start:
    bge s9 s5 inner_loop_end
    mv a0 s0
    mv a1 s3
    
    # Adding col offset
    addi t3 x0 4
    mul t4 s9 t3
    add a1 a1 t4
    
    mv a2 s2 # Number of elements cover the entire row
    addi a3 x0 1
    mv a4 s5 # Second array strides by m1 width
    jal dot

    sw a0 0(s6)
    addi s6 s6 4
    addi s9 s9 1
    
    j inner_loop_start

inner_loop_end:

    addi s8 s8 1

    addi t3 x0 4
    mul t4 s2 t3
    add s0 s0 t4

    j outer_loop_start

outer_loop_end:

    mv a6 s6
    mv ra s7
    
    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    lw s9 36(sp)
    lw s10 40(sp)
    lw s11 44(sp)
    addi sp sp 48
    
    jr ra

error: 
    li a0 38
    j exit