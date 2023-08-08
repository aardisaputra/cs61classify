.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    addi sp, sp, -20
    sw s1, 0(sp) # store pointer to matrix
    sw s0, 4(sp) # store file descriptor
    sw a1, 8(sp) # stores pointer to number of rows
    sw a2, 12(sp) # stores pointer to number of columns
    sw ra, 16(sp) # store return address
    
    # Prologue
    # Open file start
    li a1 0     
    jal fopen
    blt a0, x0, open_error
    # Open file end
    
    mv s0, a0 # this is to store file descriptor

    # fread rows start
    addi a2, x0, 4
    lw a1, 8(sp)
    jal fread # read number of rows
    
    li a2 4
    bne a0 a2 read_error
    # fread rows end
    
    # fread col start
    mv a0, s0 # a0 has file descriptor
    addi a2, x0, 4
    lw a1, 12(sp)
    jal fread # read number of columns
    
    li a2 4
    bne a0 a2 read_error
    # fread col end
    
    #get number of columns n rows
    lw a1, 12(sp)
    lw t2, 0(a1) # num of columns
    lw a1, 8(sp)
    lw t3, 0(a1) # num of rows
    
    mul t2 t2 t3 # rows * columns
    slli t2 t2 2 # x4 for bytes
    
    addi a0 t2 0
    sw t2, 8(sp) # now 8(sp) has number of bytes
    jal malloc # allocate space for matrix    
    beq a0 x0 malloc_error
    
    # s1 has pointer to matrix!
    addi a1 a0 0
    mv s1, a1 # store pointer to matrix
    
    lw t2, 8(sp)
    
    #a0 now has file descriptor
    mv a0, s0
    #a2 has number of bytes
    mv a2 t2
    mv a1 s1
    jal fread # read matrix
    lw t2, 8(sp)
    bne a0 t2 read_error
    
    #a0 has file desc
    mv a0, s0
    jal fclose
    blt a0 x0 close_error
    
    mv a0, s1
    j done

    # Epilogue
malloc_error:
    lw ra 16(sp)
    lw s0 4(sp)
    lw s1 0(sp)
    addi sp, sp, 20

    li a0 26
    j exit
    
open_error:
    lw ra 16(sp)
    lw s0 4(sp)
    lw s1 0(sp)
    addi sp, sp, 20
    
    li a0 27
    j exit

close_error:
    lw ra 16(sp)
    lw s0 4(sp)
    lw s1 0(sp)
    addi sp, sp, 20
    
    li a0 28
    j exit
    
read_error:
    lw ra 16(sp)
    lw s0 4(sp)
    lw s1 0(sp)
    addi sp, sp, 20
    
    li a0 29
    j exit
done:
    lw ra 16(sp)
    lw s0 4(sp)
    lw s1 0(sp)
    addi sp, sp, 20
    jr ra
