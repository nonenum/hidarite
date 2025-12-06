org 0x7C00

;; Video Mode and Video Memory

mov ax, 0x0013
int 0x10

push 0x0A000
pop es

;; Main Game Loop

game_loop:
    xor ax, ax
    xor di, di
    mov cx, 320*200

    rep stosb

    ;; TODO: Game Logic

    tick_timer:
        mov ax, [0x046C]
        inc ax

        .timer_func_wait:
            cmp [0x046C], ax
            jl .timer_func_wait

jmp game_loop

game_cleanup:
    cli
    hlt

section boot_section start=0x7DFE

dw 0xAA55
