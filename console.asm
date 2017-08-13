global console_print
global console_print_nl
global console_read
global console_read_char

segment .data

segment .bss

segment .text

; Print the given string on command line
; Parameters: string, string length (first put length to stack and then the string) 
console_print:
    enter 0, 0
    ;push ebp
    ;mov ebp, esp
    ;sub esp, 16              ; Memory for 4 local valriables on stack 
    pusha

    ; Sub programm

    ; Print to console
    mov edx, [ebp+12]       ; Length of string
    mov ecx, [ebp+8]        ; Adress of string to write
    mov ebx, 1              ; Stdout (print to terminal)
    mov eax, 4              ; Number of system call (4 = sys_write)
    int 0x80                ; Call kernel
    
    popa
    ;mov esp, ebp            ; Free local variables from stack
    ;pop ebp
    leave
    ret

; Print new line
console_print_nl:
    enter 4, 0
    pusha
    
    mov dword [ebp-4], 0xA ; Store new line in local variable
    ; Print to console
    mov edx, 1              ; Length of string
    lea ecx, [ebp-4]       ; Adress of string to write
    mov ebx, 1              ; Stdout (print to terminal)
    mov eax, 4              ; Number of system call (4 = sys_write)
    int 0x80                ; Call kernel
    
    popa
    leave
    ret

; Read from command line and store input into given adress
; Parameters: adress, max input length
console_read:
    ;enter 16, 0
    enter 0, 0
    pusha
    
    mov edx, [ebp+12]       ; Max length of input
    mov ecx, [ebp+8]        ; Address where to store input (Store input in given adress)
    mov ebx, 0              ; Stdin
    mov eax, 3              ; Number of system call (3 = sys_read)
    int 0x80                ; Call kernel
    
    popa
    leave
    ret

; Read a single char from command line and store its ASCII code in EAX register
console_read_char:
    enter 16, 0
    pusha

    mov edx, 1              ; Max length of input
    lea ecx, [ebp-16]       ; Store input on local var on stack
    mov ebx, 0              ; Stdin
    mov eax, 3              ; Number of system call (3 = sys_read)
    int 0x80                ; Call kernel
    
    popa
    mov eax, [ebp-16]       ; Store input in eax
    leave
    ret
