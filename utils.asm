global utils_number_to_decimal_ascii
global utils_get_decimal_length
extern console_print
extern console_print_nl

segment .data
    base_10:    dd 10

segment .bss

segment .text

; Convert a 32 bit unsigned dezimal number to its ascii representation and store it in given
; adress parameter
; The highest value is 4294967295 so the string has a max length of 10
; Parameters: value to convert, length of number, adress where to store result
utils_number_to_decimal_ascii:
    enter 0,0
    pusha
    ; We create the string backwards. So we first add the last char of the number to the string
    ; and finally the first one.
    ; E.g. when we have the number 638 we first add the 8. So we have the string: __8
    ; Then _38 and finally 638 with ascii codes
    mov eax, [ebp+8]            ; Store number which we want to convert in eax
    mov ecx, [ebp+12]           ; Move numbers length in ecx register
    ; We loop as long ecx is not zero, so we execute the code as long as we have covered all
    ; indexes of the number
.pos_to_string:
    mov edx, 0
    div dword [base_10]         ; Divide number in eax with 10 (Base of dezimal numbers)
    ; In eax is the result of the division and in edx the rest
    add edx, 48                 ; Add 48 to make number to its ascii equivalent

    mov ebx, [ebp+16]           ; Store Adress of string in ebx
    mov byte [ebx+ecx-1], dl    ; Add the ascii number to the string (String Adress + index - 1)
                                ; We only need one byte so we use dl insted of edx.
                                ; Edx stores the rest of the division which is our number and
                                ; because the number is between 0 and 9 and we add 48 to get the
                                ; ascii representation one byte is enough to store the rest.
    loop .pos_to_string

    popa
    leave
    ret

; Returns the length of the given decimal number
; Parameters: number
; Returns length in eax register
utils_get_decimal_length:
    enter 4,0
    pusha
    
    ;mov dword [ebp-4], 638
    mov eax, [ebp+8]            ; Move given parameter (decimal number) to eax to work with it
    mov dword [ebp-4], 0        ; The length counter
.count:
    inc dword [ebp-4]           ; Increment length

    mov edx, 0                  ; Reset edx before dividing
    div dword [base_10]         ; Divide number in eax with 10 (Base of dezimal numbers)
    
    cmp dword eax, 0            ; If divided number is zero we have completed counting 
    jnz .count                  ; If number was not zero after dividing loop again
    ; !count
    
    popa
    mov eax, [ebp-4]            ; Return the length (return in eax register)
    leave
    ret
