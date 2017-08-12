extern console_print
extern console_print_nl
extern console_read
extern console_read_char

extern utils_number_to_decimal_ascii
extern utils_get_decimal_length

extern debug_print_regs
extern debug_print_arithmethic_flags

extern game_run

global _start

segment .data

segment .bss

segment .text
    _start:
asm_main:
    mov eax, 0x1122BBFF
    call debug_print_regs
    call game_run

; exit
    mov eax, 1
    int 0x80
