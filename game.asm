global console_print
global console_read
global console_read_char

segment .data
    str:        db 'Connect3', 0xA
    str_len:    equ $-str

segment .bss

segment .text
; Function console_print. 
; Parameters: string, string length (first put length to stack and then the string) 
game_run:
    enter 0, 0
    pusha

    ; Game

    popa
    leave
    ret
