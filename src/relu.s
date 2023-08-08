.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi t0 x0 1 # t0 is length check
    blt a1 t0 error
    
    addi t1 x0 0 # t1 is index check
loop_start:
    bge t1 a1 loop_end
    lw t2 0(a0) # t2 is current value
    bge t2 x0 loop_continue
    sw x0 0(a0)
    

loop_continue:
    addi a0 a0 4
    addi t1 t1 1
    j loop_start


loop_end:
    jr ra

    # Epilogue
error:
    li a0 36
    j exit

    
    

