.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    bge x0 a1 error
    addi t0 x0 0 # t0: index to be iterated
    addi t1 x0 0 # t1: max index to be returned
    lw t2 0(a0) # t2: current max value
    
loop_start:
    bge t0 a1 loop_end
    lw t3 0(a0) # t3: current value
    bge t2 t3 loop_continue
    add t1 x0 t0
    add t2 x0 t3

loop_continue:
    addi t0 t0 1
    addi a0 a0 4
    j loop_start

loop_end:
    # Epilogue
    add a0 x0 t1
    jr ra

error:
    li a0 36
    j exit