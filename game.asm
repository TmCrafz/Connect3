global game_run

extern console_print
extern console_print_nl

extern debug_print_regs

%define BOARD_ARRAY_ELEMENTS 9

; Game Board
; 1|2|3
; -----
; 4|5|6
; -----
; 7|8|9
; board number:   1        2        3        4        5        6        7        8        9
; Index:          0        1        2        3        4        5        6        7        8  
; C-index:     [0][0] | [0][1] | [0][2] | [1][0] | [1][1] | [1][2] | [2][0] | [2][1] | [2][2]
;

segment .data
    str_game_title:         db 'Connect3', 0xA
    str_game_title_len:     equ $-str_game_title
    str_tmp:                db 'x'
    str_tmp_len:            equ $-str_tmp
    board_row:              db '   |   |   ', 0xA
    board_row_length        equ $-board_row
    board_row_val:          db ' x | x | x ', 0xA
    board_row_seperator:    db '---|---|---', 0xA
    board_row_cnt:          dd 7
segment .bss
board           resb BOARD_ARRAY_ELEMENTS   ; Create Array with elements with a byte size.
                                            ; The Array has BOARD_ARRAY_ELEMENTS elements.

segment .text
; Function console_print. 
; Parameters: string, string length (first put length to stack and then the string) 
game_run:
    enter 0, 0
    pusha
    
    ; Init Array with zeros
    mov ecx, BOARD_ARRAY_ELEMENTS           ; Loop backwards from Array size to 0
.init_board:
    mov byte [board + ecx], 0
    loop .init_board
    
    mov byte [board + 4], 9

    call debugl_print_board_array

    push str_game_title_len
    push str_game_title
    call console_print
    add esp, 8
    
    call game_draw_board

    ; Game

    popa
    leave
    ret

game_draw_board:
    enter 4, 0
    pusha
    ; We have 6 rows to print
    mov dword ecx, [board_row_cnt]
.print_row:
    mov esi, [board_row_cnt]
    sub esi, ecx
    
    mov byte [ebp-4], board_row
    
    cmp esi, 2
    jnz .not2
    mov dword [ebp-4], board_row_seperator
.not2:
    cmp esi, 4
    jnz .not4
    mov dword [ebp-4], board_row_seperator
.not4:
    
    push dword board_row_cnt
    push dword [ebp-4]
    call console_print
    add esp, 8
    loop .print_row

    popa
    leave
    ret

; Debug
debugl_print_board_array:
    enter 0, 0
    pusha
    mov ecx, BOARD_ARRAY_ELEMENTS           ; Loop backwards from Array size to 0
.print_board:
    ; We want to init the array from left to right so the first element we init is element 0
    ; So we access the array with BOARD_ARRAY_ELEMENTS - ecx (actual index).
    mov esi, BOARD_ARRAY_ELEMENTS
    sub esi, ecx
    mov eax, [board + esi]
    ; Make number to ascii
    add eax, 48
    ; Print
    mov [str_tmp], eax
    push str_tmp_len
    push str_tmp
    call console_print
    add esp, 8
    call console_print_nl
    
    loop .print_board
    
    popa
    leave
    ret
