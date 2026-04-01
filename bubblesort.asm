.model small

.stack 100h

;data definitions
.data
    ; array info
    array dw 16000 dup(?) ; 16bit max size
    array_size dw ?

    ; input info    
    input_size db 'Insert array size : $'
    input_number db 13, 10, 'Insert number : $'
    error_message db 13, 10, 'Invalid input, x>1 and x<16001 $'

    ; output info
    sorted_message db 13, 10, 13, 10, 'Sorted array is : $'
    space db ' $'

    ; buffer definition  
    input_buffer db 7, 0, 7 dup(0)
    buffer db 8 dup(?), '$'
.code

start: 
; the "main" of x86
	mov ax, @data
	mov ds, ax                                              ; initialize data segment

    read_input_size:
	    mov ah, 09h                                         ; ah = 09h for printing a string, 
	    lea dx, input_size                                  ; lea = load effective address of input_size("insert array size : ") into dx
	    int 21h                                             ; call DOS interrupt to print the message

	    mov ah, 0ah                                         ; ah = 0ah for buffered input
	    lea dx, input_buffer                                ; dx -> input_buffer
	    int 21h

	    call string_to_signed_number

	    ; comparison with bounds
	    cmp ax, 2
	    jl invalid_input
	    cmp ax, 16000
	    jg invalid_input

	    ; store the valid input size
	    mov array_size, ax
	    jmp before_read 

    ; exception case - invalid input (x>1 or x<16001)
    invalid_input:
	    xor dx, dx
	    mov ah, 09h
	    lea dx, error_message
	    int 21h

	    jmp read_input_size

    before_read:                                           ; move array_size and set up di for storing input numbers
	    mov cx, array_size
	    lea di, array


    read_loop:
		push cx

	    mov ah, 09h
	    lea dx, input_number
	    int 21h

	    mov ah, 0ah
	    lea dx, input_buffer
        int 21h

	    call string_to_signed_number

	    mov [di], ax
	    add di, 2

	    pop cx
	loop read_loop
	
	mov cx, array_size
	cmp cx, 1
	jle before_output
	dec cx

    outer_loop:                                         ; repeat passes until no swaps occur
	    mov di, 0                                       ; di = swap flag (0 = no swaps, 1 = swaps made)
	    push cx
	    lea si, array
	    mov dx, cx

        swap_elements:
	    	mov ax, [si]
		    mov bx, [si+2]

		    cmp ax, bx
		    jle skip_swap                               ; if ax <= bx, no swap needed

    		mov [si+2], ax                              ; swap: first element to second position
	    	mov [si], bx                                ; swap: second element to first position
		    mov di, 1                                   ; set flag to indicate a swap was made

        skip_swap:
	    	add si, 2
	    	dec dx
		    jnz swap_elements

	    pop cx
	    cmp di, 0
	    je before_output
	loop outer_loop

        before_output:
	        mov ah, 09h
	        lea dx, sorted_message
	        int 21h

	        mov cx, array_size
	        lea si, array

    loop_output:
		push cx

		mov ax, [si]
		call signed_number_to_string
		
		mov ah, 09h
		lea dx, buffer
		int 21h

		mov ah, 09h
		lea dx, space
		int 21h

		pop cx
		add si, 2

	loop loop_output

	mov ah, 4ch
	int 21h

    string_to_signed_number proc                        ; convert ASCII string to signed integer
	    xor ax, ax                                      ; ax = result accumulator
	    xor bx, bx
	    mov bx, 10                                      ; bx = base (decimal)

	    lea si, input_buffer
	    add si, 2                                       ; skip buffer length bytes

	    mov cl, [si]
	    cmp cl, '-'                                     ; check for negative sign

	    jne check_plus
	    inc si
	    jmp string_loop

            check_plus:
	            cmp cl, '+'
	            jne string_loop
	            inc si

            string_loop:
		        mov cl, [si]
	            cmp cl, 0dh                         ; 0dh = carriage return (end of string)
	            je end_string_conv
		
    	        sub cl, '0'                         ; convert ASCII digit to number
	            xor ch, ch
    
    	        push cx
	            imul bx                             ; ax = ax * 10
	            pop cx
	
	            add ax, cx                          ; add current digit to result
	            inc si
            jmp string_loop


                end_string_conv:                    ; used in string_loop
	                cmp [input_buffer + 2], '-'     ; check if number was negative
	                jne return_signed
                    neg ax                          ; negate the result


                    return_signed:                      ; used in end_string_conv
    	                ret
    string_to_signed_number endp

    signed_number_to_string proc                        ; convert signed integer to ASCII string
	    cmp ax, 0
	    jge convert_positive
	    neg ax                                          ; convert to positive for digit extraction
	    mov byte ptr [buffer], '-'                      ; store negative sign
	    lea di, buffer + 1                              ; start digits after sign
	    jmp convert_number

            convert_positive:                           ; used at start of procedure
	            lea di, buffer                          ; start digits at buffer beginning

            convert_number: 
	            xor cx, cx
	            mov bx, 10

        convert_loop_inner:                             ; extract digits in reverse order
	        xor dx, dx
	        div bx                                      ; ax = ax / 10, dx = remainder (digit)
	        add dl, '0'                                 ; convert digit to ASCII
	        push dx                                     ; stack digits in reverse
	        inc cx                                      ; count digits
	        test ax, ax
	    jnz convert_loop_inner

        build_string:                                   ; pop digits and build string in correct order
	        pop ax
	        mov [di], al
	        inc di
	    loop build_string

	    mov byte ptr [di], '$'                          ; DOS string terminator
	    ret
    signed_number_to_string endp

end start