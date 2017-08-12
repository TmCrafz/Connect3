global game_run

extern console_print
extern console_print_nl

extern utils_number_to_decimal_ascii

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
    str_player1:            db 'Player 1. Which field?', 0xA
    str_player2:            db 'Player 2. Which field?', 0xA
segment .bss
    board               resb BOARD_ARRAY_ELEMENTS   ; Create Array with elements with a byte size.
                                                    ; The Array has BOARD_ARRAY_ELEMENTS elements.
    input_buffer        resd 1
    str_buffer          resb 1
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

    push str_game_title_len
    push str_game_title
    call console_print
    add esp, 8


    
    call game_draw_board

    ; Game

    popa
    leave
    ret



; Draw the actual game board
game_draw_board:
    enter 0, 0
    pusha
    ; We have 6 rows to print
    mov dword ecx, BOARD_ARRAY_ELEMENTS
.print_row:
    mov esi, BOARD_ARRAY_ELEMENTS
    sub esi, ecx
    
    mov eax, [board + esi]
    add eax, 48
    mov [str_buffer], eax

    push dword 1
    push dword str_buffer
    call console_print
    add esp, 8

    mov edx, 0              ; Set edx 0 for dividing
    mov eax, esi            ; We want to divide the current index
    inc eax                 ; We add 0 so we start by 1
    mov ebx, 3              ; We want to divide with 3
    div dword ebx           ; Divide current index with 3
    cmp edx, 0              ; When the rest is 0 we print a new line
    jnz .no_nl
    call console_print_nl
.no_nl:

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
    ;mov [str_tmp], eax
    ;push str_tmp_len
    ;push str_tmp
    ;call console_print
    ;add esp, 8
    call console_print_nl
    
    loop .print_board
    
    popa
    leave
    ret
