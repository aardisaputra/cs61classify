.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t1 5
    bne a0 t1 arg_error # check arg number
    
    addi sp sp -48
    sw s9 0(sp) # store silent mode toggle
    sw s8 4(sp) # pointer to  h, the result of matmul
    sw s7 8(sp) # s7: pointer to mat input
    sw s6 12(sp) # s6: pointer to row and col count of mat input
    sw s5 16(sp) # s5: pointer to mat 1
    sw s4 20(sp) # s4: pointer to row and col count of mat 1
    sw s3 24(sp) # s3: pointer to mat 0
    sw s2 28(sp) # s2: pointer to row and col count of mat 0
    sw s1 32(sp) # s1: pointer to arg stringS
    sw s0 36(sp) # store argmax result
    sw ra 40(sp)
    sw s10 44(sp) # pointer to o

    mv s1 a1 # s1: stores file pointer to matrix pointers
    mv s9 a2 # s9: stores silent mode argument

    # Malloc space for row and col count of mat 0
    li a0 8
    jal malloc
    beq a0 x0 malloc_error
    mv s2 a0 # s2 is pointer to row count n col count
    
    # read m0
    lw a0 4(s1)
    mv a1 s2
    addi a2 s2 4
    jal read_matrix
    mv s3 a0 # s2: stores pointer to m0

    # Malloc space for row and col count of mat 1
    li a0 8
    jal malloc
    beq a0 x0 malloc_error
    mv s4 a0 # s4 is pointer to row count n col count
    
    # read m1
    lw a0 8(s1)
    mv a1 s4
    addi a2 s4 4
    jal read_matrix
    mv s5 a0 # s5: stores pointer to m1
    
    # Malloc space for row and col count of mat input
    li a0 8
    jal malloc
    beq a0 x0 malloc_error
    mv s6 a0 # s6 is pointer to row count n col count
    
    # read m input
    lw a0 12(s1)
    mv a1 s6
    addi a2 s6 4
    jal read_matrix
    mv s7 a0 # s7: stores pointer to m input

    # malloc for h = matmul(m0, input)
    #get row of m0
    lw a0 0(s2)
    #get col of input
    lw t0 4(s6)
    mul a0 a0 t0
    slli a0 a0 2
    jal malloc
    beq a0 x0 malloc_error
    mv s8 a0
    
    # Compute h = matmul(m0, input)
    mv a0 s3
    #get row and col of m0
    lw a1 0(s2)
    lw a2 4(s2)
    mv a3 s7
    #get row and col of m input
    lw a4 0(s6)
    lw a5 4(s6)
    mv a6 s8
    jal matmul

    # Compute h = relu(h)
    mv a0 s8
    #get row of m0
    lw a1 0(s2)
    #get col of input
    lw t0 4(s6)
    mul a1 a1 t0
    jal relu

    # Malloc o = matmul(m1, h)
    # h row = m0 row, h col = m input col
    #get row of m1
    lw a0 0(s4)
    #get col of h which same as m input
    lw t0 4(s6)
    mul a0 a0 t0
    slli a0 a0 2
    jal malloc
    beq a0 x0 malloc_error
    mv s10 a0
    
    # Compute o = matmul(m1, h)
    mv a0 s5
    #get row and col of m1
    lw a1 0(s4)
    lw a2 4(s4)
    mv a3 s8
    #get row and col of h
    lw a4 0(s2)
    lw a5 4(s6)
    mv a6 s10
    jal matmul


    # Write output matrix o
    lw a0 16(s1) 
    mv a1 s10
    lw a2 0(s4)
    lw a3 4(s6)
    jal write_matrix

    # Compute and return argmax(o)
    mv a0 s10
    lw a1 0(s4)
    lw t0 4(s6)
    mul a1 a1 t0
    jal argmax
    mv s0 a0
    
    # If enabled, print argmax(o) and newline
    mv a0 s8
    jal free
    mv a0 s10
    jal free
    mv a0 s7
    jal free
    mv a0 s6
    jal free
    mv a0 s5
    jal free
    mv a0 s4
    jal free
    mv a0 s3
    jal free
    mv a0 s2
    jal free
    lw a0 16(s1) 
    mv a0 s0
    bne s9 x0 epilogue
    mv a0 s0
    jal print_int
    li a0 '\n'
    jal print_char
    mv a0 s0
    j epilogue

    # Throw corresponding errors
arg_error:
    li a0 31
    j exit

malloc_error:
    li a0 26
    j exit

epilogue:
    lw s9 0(sp)
    lw s8 4(sp)
    lw s7 8(sp)
    lw s6 12(sp)
    lw s5 16(sp)
    lw s4 20(sp)
    lw s3 24(sp)
    lw s2 28(sp)
    lw s1 32(sp)
    lw s0 36(sp)
    lw ra 40(sp)
    lw s10 44(sp)
    addi sp sp 48
    jr ra
