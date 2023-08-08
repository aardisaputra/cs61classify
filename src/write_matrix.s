.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    
    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)
    sw s4, 20(sp)

    mv s0 a0 # store pointer to filename string
    mv s1 a1 # store pointer to matrix in memory
    mv s2 a2 # number of rows in matrix
    mv s3 a3 # number of cols in matrix

    # open file
    li a1 1    
    jal fopen
    li t1 -1
    beq a0, t1, open_error
    mv s0 a0 # s0 now contains file descriptor
    # Open file end
    
    li a0 8
    jal malloc
    mv s4 a0 #s4 contains array of row and col count
    
    # write row and col count
    sw s2 0(s4)
    sw s3 4(s4)
    
    mv a0 s0
    mv a1 s4
    li a2 2
    li a3 4
    jal ra fwrite
    li t1 2
    bne a0 t1 write_error
    
    mv a0 s4
    jal free

    # write matrx to file
    mv a0 s0
    mv a1 s1
    mul a2 s2 s3
    li a3 4
    jal fwrite
    
    mul a2 s2 s3
    bne a0, a2, write_error 
    # end write to file
    
    #start close
    mv a0 s0
    jal fclose
    blt a0 x0 close_error
    #end close
    j done
    # Epilogue

open_error:
    lw s4 20(sp)
    lw ra 16(sp)
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    addi sp, sp, 24
    li a0 27
    j exit

close_error:
    lw s4 20(sp)
    lw ra 16(sp)
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    addi sp, sp, 24
    li a0 28
    j exit
    
write_error:
    lw s4 20(sp)
    lw ra 16(sp)
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    addi sp, sp, 24
    li a0 30
    j exit
done:
    lw s4 20(sp)
    lw ra 16(sp)
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    addi sp, sp, 24
    jr ra
