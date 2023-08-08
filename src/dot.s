.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    
    # Prologue
    bge x0 a2 error1
    bge x0 a3 error2
    bge x0 a4 error2
    
    addi t0 x0 0 # t0 is dot product
    addi t1 x0 4 # t1 is number of bytes for an integer
    
    mul a3 a3 t1 # numbre of bytes to move for array 1
    mul a4 a4 t1
    

loop_start:

    bge x0 a2 loop_end

    lw t3 0(a0) # t3 stores current value of array 1
    lw t4 0(a1) # t4 stores current value of array 2

    mul t5 t4 t3 # t5 stores current product of t3 and t4

    add t0 t0 t5
    
    add a0 a0 a3
    add a1 a1 a4

    addi a2 a2 -1
    j loop_start




loop_end:


    # Epilogue
    addi a0 t0 0

    jr ra


error1:
    li a0 36
    j exit
    
error2:
    li a0 37
    j exit