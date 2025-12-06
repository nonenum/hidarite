org 0x7C00

;; Video Mode and Video Memory

mov ax, 0x0013
int 0x10

push 0x0A000
pop es

;; Main Game Loop

game_loop:
    mov al, 0x04
    mov cx, 320*200

    xor di, di
    rep stosb

jmp game_loop

game_cleanup:
    cli
    hlt

section boot_section start=0x7DFE

dw 0xAA55
