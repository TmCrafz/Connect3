global game_run

extern console_print
extern console_print_nl
extern console_read_char

extern utils_number_to_decimal_ascii
extern utils_are_three_equals

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
    str_player_choose:      db 'Player x. Which field?', 0xA
    str_player_choose_len:  equ $-str_player_choose
    player_choose_num_pos:  dd 7
    unset_field_num:        db 9
    str_player_wins:       db 'Player x wins!', 0xA
    str_player_wins_len:  equ $-str_player_wins
    player_wins_num_pos:  dd 7
    ;str_player2:            db 'Player 2. Which field?', 0xA
segment .bss
    board               resb BOARD_ARRAY_ELEMENTS   ; Create Array with elements with a byte size.
                                                    ; The Array has BOARD_ARRAY_ELEMENTS elements.
    str_buffer          resb 1
segment .text
; Function console_print. 
; Parameters: string, string length (first put length to stack and then the string) 
game_run:
    enter 0, 0
    pusha
    
    ; Init Array with 9s, so a unset field have a 9
    mov ecx, BOARD_ARRAY_ELEMENTS           ; Loop backwards from Array size to 0
.init_board:
    mov al, [unset_field_num]
    mov byte [board + ecx - 1], al
    loop .init_board

    call game_draw_board
    ; Game loop
    mov ecx, BOARD_ARRAY_ELEMENTS           ; The count of Elements in the array is the max
                                            ; amount of rounds, too.

.run:
    ; Divide actual index so we can determine which players round it is by dividing with 2
    mov eax, ecx
    mov ebx, 2
    mov edx, 0
    div ebx
    ; Increment rest by one so we get 1 for player 1 and 2 for player 2
    inc edx

    push dword edx
    call game_handle_input
    add esp, 4

    ;push dword 4
    ;call game_is_winner
    ;add esp, 4

    call game_draw_board
    call game_get_winner
    cmp eax, 0
    jnz .there_is_a_winner
    jmp .after_winner
.there_is_a_winner:
    add al, 48                      ; Get winner number as ascii
    mov esi, [player_wins_num_pos]  ; Get pos of player number in string and store it in esi
    mov [str_player_wins + esi], al ; Save ascii player number at the right pos in string
    ; Print winner string
    push str_player_wins_len
    push str_player_wins
    call console_print
    add esp, 8
    ; End game
    jmp .end_game
.after_winner:
    loop .run
.end_game:                      ; label for debug purpose

    popa
    leave
    ret

; Ask user which field he want to set and set the field in board
; Parameters: actual player number (1 or 2)
game_handle_input:
    enter 0, 0
    pusha
    
    ; Make given palyer num to ascii (by adding 48) and put the char to the right pos in the string
    mov esi, [player_choose_num_pos]           ; The pos of the player char num in string
    mov bl, [ebp+8]
    add bl, 48
    mov byte [str_player_choose + esi], bl

    jmp .next
    ; Determine which player gives the input and show the right text
    mov esi , [player_choose_num_pos]           ; The pos of the player char num in string
    cmp dword [ebp+8], 1
    jz .thenblock
.elseblock:
    mov byte [str_player_choose + esi], '2'
    jmp .next
.thenblock:
    mov byte [str_player_choose + esi], '1'
.next:    

.end_str_choose:
    ; Print text which explains whichs players input it is
    push str_player_choose_len
    push str_player_choose
    call console_print
    add esp, 8

    ; Ask player for input
.ask_for_input:
    call console_read_char
    sub eax, 48                 ; Make input from ascii char to number
    mov esi, eax                ; Store selection in esi
    dec esi                     ; Decrement by one because the array index is lower then the shown
    mov cl, [board + esi]
    
    cmp esi, BOARD_ARRAY_ELEMENTS ; Check if choosen num is in array 
    jae .ask_for_input          ; If index is not in array, we ask again

    cmp cl, [unset_field_num]   ; Check if the field is already set
    jne .ask_for_input          ; Ask again if field was already set
    
    ; Store in board which field player has choosen
    mov byte bh, [ebp+8]
    mov byte [board + esi], bh

    popa
    leave
    ret

; Returns 0 in eax when there is no winner. Returns 1 when player 1 wins and 2 when player 2 wins
game_get_winner:
    enter 4, 0                      ; Save return value temporary in local var
    pusha
    mov dword [ebp-4], 0            ; Set return value to 0 by default
    
    ; Check fields 0, 1, 2
    ; Set Fields of player 1 have number 1, so if the sum off the thee is 3 Player 1 wins.
    ; If the sum is 6 Player 2 wins (2+2+2).
    ; Unset fields have the number 9 so if one of the fields is unset the sum is min 9.
    xor eax, eax
    add  al, [board+0]
    add  al, [board+1]
    add  al, [board+2]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2
    
    ; Check fields 3, 4, 5
    xor eax, eax
    add al, [board+3]
    add al, [board+4]
    add al, [board+5]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2
    
    ; Check fields 6, 7, 8
    xor eax, eax
    add al, [board+6]
    add al, [board+7]
    add al, [board+8]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2

    ; Check fields 0, 3, 6
    xor eax, eax
    add al, [board+0]
    add al, [board+3]
    add al, [board+6]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2
    
    ; Check fields 1, 4, 7
    xor eax, eax
    add al, [board+1]
    add al, [board+4]
    add al, [board+7]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2
    
    ; Check fields 2, 5, 8
    xor eax, eax
    add al, [board+2]
    add al, [board+5]
    add al, [board+8]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2

    ; Check fields 0, 4, 8
    xor eax, eax
    add al, [board+0]
    add al, [board+4]
    add al, [board+8]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2

    ; Check fields 2, 4, 6
    xor eax, eax
    add al, [board+2]
    add al, [board+4]
    add al, [board+6]
    cmp al, 3
    jz .set_winner_player1
    cmp al, 6
    jz .set_winner_player2


    jmp .ret
.set_winner_player1:
    mov dword [ebp-4], 1
    jmp .ret
.set_winner_player2:
    mov dword [ebp-4], 2
    jmp .ret
.ret:

    popa
    mov eax, [ebp-4]
    leave
    ret

; Draw the actual game board
game_draw_board:
    enter 0, 0
    pusha
    ; Draw title
    push str_game_title_len
    push str_game_title
    call console_print
    add esp, 8
    
    
    
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
