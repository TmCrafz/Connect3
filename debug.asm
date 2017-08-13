global debug_print_regs
global debug_print_arithmethic_flags

extern console_print
extern console_print_nl

segment .data
    str_regs_header:        db 'Registers', 0xA
    str_regs_header_len     equ $-str_regs_header   
    str_reg_title:          db 'xxx = '
    str_reg_title_len:      equ $-str_reg_title
    str_reg_hex:            db 'xxxxxxxx'
    str_reg_hex_len:        equ $-str_reg_hex
    str_aflags_header:      db 'Arithmetic flags', 0xA
    str_aflags_header_len:  equ $-str_aflags_header
    str_aflags:             db 'xx = x'
    str_aflags_len:         equ $-str_aflags

    base_16:    dd 16
segment .bss
    inp_buf:    resd 1
    str_buf:    resd 10
segment .text

debug_print_regs:
    enter 0, 0
    pusha
    
    ; Header Title
    push dword str_regs_header_len
    push dword str_regs_header
    call console_print
    add esp, 8

    ; EAX register
    push dword eax
    push dword 'EAX '
    call debug_create_reg_line
    add esp, 8
    call console_print_nl

    ; EBX register
    push dword ebx
    push dword 'EBX '
    call debug_create_reg_line
    add esp, 8
    call console_print_nl
    
    ; ECX register
    push dword ecx
    push dword 'ECX '
    call debug_create_reg_line
    add esp, 8
    call console_print_nl
    
    ; EDX register
    push dword edx
    push dword 'EDX '
    call debug_create_reg_line
    add esp, 8
    call console_print_nl
    
    ; ESI register
    push dword esi
    push dword 'ESI '
    call debug_create_reg_line
    add esp, 8
    call console_print_nl
    
    ; EDI register
    push dword edi
    push dword 'EDI '
    call debug_create_reg_line
    add esp, 8
    call console_print_nl

    popa
    leave
    ret

; Print the given line
; Parameters: Register name, value
debug_create_reg_line:
    enter 0, 0
    pusha
    
    mov ebx, [ebp+8]
    mov dword [str_reg_title], ebx
    push dword str_reg_title_len
    push dword str_reg_title
    call console_print
    add esp, 8
    
    push dword str_reg_hex
    push dword [ebp+12]
    call debug_number_to_hex_ascii
    add esp, 8
    
    push dword str_reg_hex_len
    push dword str_reg_hex
    call console_print
    add esp, 8
    

    popa
    leave
    ret
; prints if the arithmetic flags CF, PF, ZF, SF and OF are set
debug_print_arithmethic_flags:
    enter 0, 0
    pusha
    
    pushf                               ; We have to save the flags on stack, 
                                        ; so we dont print the changed flags
    ; Header Title
    push dword str_aflags_header_len
    push dword str_aflags_header
    call console_print
    add esp, 8
    popf                                ; Restore the old flags, so we print the right flags

    ; CF Flag
    mov word [str_aflags], 'CF'
    mov eax, str_aflags_len
    mov byte [str_aflags+eax-1], '0'
    jc .cf_set
    jmp .cf_print
.cf_set:
    mov byte [str_aflags+eax-1], '1'
.cf_print:
    pushf
    push dword str_aflags_len
    push dword str_aflags
    call console_print
    add esp, 8
    call console_print_nl
    popf
    
    ; PF Flag
    mov word [str_aflags], 'PF'
    mov eax, str_aflags_len
    mov byte [str_aflags+eax-1], '0'
    jp .pf_set
    jmp .pf_print
.pf_set:
    mov byte [str_aflags+eax-1], '1'
.pf_print:
    pushf
    push dword str_aflags_len
    push dword str_aflags
    call console_print
    add esp, 8
    call console_print_nl
    popf

    ; ZF Flag
    mov word [str_aflags], 'ZF'
    mov eax, str_aflags_len
    mov byte [str_aflags+eax-1], '0'
    jz .zf_set
    jmp .zf_print
.zf_set:
    mov byte [str_aflags+eax-1], '1'
.zf_print:
    pushf
    push dword str_aflags_len
    push dword str_aflags
    call console_print
    add esp, 8
    call console_print_nl
    popf

    ; SF Flag
    mov word [str_aflags], 'SF'
    mov eax, str_aflags_len
    mov byte [str_aflags+eax-1], '0'
    jz .sf_set
    jmp .sf_print
.sf_set:
    mov byte [str_aflags+eax-1], '1'
.sf_print:
    pushf
    push dword str_aflags_len
    push dword str_aflags
    call console_print
    add esp, 8
    call console_print_nl
    popf

    ; OF Flag
    mov word [str_aflags], 'OF'
    mov eax, str_aflags_len
    mov byte [str_aflags+eax-1], '0'
    jo .of_set
    jmp .of_print
.of_set:
    mov byte [str_aflags+eax-1], '1'
.of_print:
    pushf
    push dword str_aflags_len
    push dword str_aflags
    call console_print
    add esp, 8
    call console_print_nl
    popf
    
    popa
    leave
    ret


; Convert a 32 bit hexa number to its ascii representation and store it in given
; adress parameter. The Adress parameter should be 8 bytes long to store the 32 hexa value
; Parameters: value to convert, adress where to store result
debug_number_to_hex_ascii:
    enter 0, 0
    pusha
    ; We create the string backwards. So we first add the last char of the number to the string
    ; and finally the first one.
    mov eax, [ebp+8]            ; Store number which we want to convert in eax
    mov ebx, [ebp+12]
    mov dword [ebx], 0x30303030 ; Fill string with ascii zeros so we have 00000000
    mov ecx, 8                  ; The max length is 8, so we start loop by index 8
.pos_to_string:
    mov edx, 0
    div dword [base_16]         ; Divide number in eax with 10 (Base of dezimal numbers)
    ; In eax is the result of the division and in edx the rest
; IF ELSE BLOCK
    cmp edx, 10
    jc .add_num_char             ; CF = 1 => rest < 10
    ; Else (when edx < 10 )
    add edx, 65                 ; Add 65 because the A is represented by it in ascii table
    sub edx, 10                 ; Sub 10 so we start by 65 for 'A'
    
    jmp .end_if_block
    ; ! Else
.add_num_char:
    ; if edx < 10
    add edx, 48                 ; Add 48 to represent number as ascii number
    ; !edx < 10
.end_if_block:        
; !END IF BLOCK

    mov ebx, [ebp+12]           ; Store Adress of string in ebx
    mov byte [ebx+ecx-1], dl    ; Add the ascii number to the string (String Adress + index - 1)
                                ; We only need one byte so we use dl insted of edx.
    ; If the number is 0 we have finished converting and can leave the loop
    cmp eax, 0
    je .end_loop

    loop .pos_to_string
.end_loop:

    popa
    leave
    ret
