;;
;; Original code by | Queso Fuego |
;; [Bootsector Game From Scratch - Space Invaders (x86 asm)]
;;

bits 16
org 0x7C00

;; Variables

textures equ 0x0FA00
alien equ 0x0FA00
alien_var equ 0x0FA04
player equ 0x0FA08
barrier_array equ 0x0FA0C
enemy_array equ 0x0FA20
player_x equ 0x0FA24
projectile_array equ 0x0FA25
enemy_y equ 0x0FA2D
enemy_x equ 0x0FA2E
enemy_remaining equ 0x0FA2F
direction equ 0x0FA30
move_ticks equ 0x0FA31
swap_texture equ 0x0FA33

;; Constants

WIDTH equ 320
HEIGHT equ 200
V_MEMORY equ 0x0A000
TIMER equ 0x046C

BARRIER_START_X equ 22
BARRIER_Y equ 85
PLAYER_Y equ 93

TEXTURE_HEIGHT equ 4
TEXTURE_WIDTH equ 8
TEXTURE_WIDTH_PX equ 16

ENEMY_COLOR equ 0x02
PLAYER_COLOR equ 0x07
BARRIER_COLOR equ 0x27
PLAYER_PROJECTILE equ 0x0B
ENEMY_PROJECTILE equ 0x0E

;; Video Mode and Video Memory

mov ax, 0x0013
int 0x10

push V_MEMORY
pop es

;; Initializing

mov di, textures
mov si, sprite_bmps
mov cl, 6
rep movsw

lodsd
mov cl, 5
rep stosd

mov cl, 5
rep movsb

xor ax, ax
mov cl, 4
rep stosw

mov cl, 7
rep movsb

push es
pop ds

;; Main Game Loop

game_loop:
    xor ax, ax
    xor di, di
    mov cx, WIDTH*HEIGHT

    rep stosb

    ;; TODO: Game Logic

    tick_timer:
        mov ax, [TIMER]
        inc ax

        .timer_func_wait:
            cmp [TIMER], ax
            jl .timer_func_wait

jmp game_loop

game_cleanup:
    cli
    hlt

draw_texture:
    ret

get_screen_position:
    ret

sprite_bmps:
    db 10011001b
    db 01011010b
    db 00111100b
    db 01000010b

    db 00011000b
    db 01011010b
    db 10111101b
    db 00100100b

    db 00011000b
    db 00111100b
    db 00100100b
    db 01100110b

    db 00111100b
    db 01111110b
    db 11100111b
    db 11100111b

    ;; Variables

    dw 0x0FFFF
    dw 0x0FFFF

    db 70

    dw 0x230A
    db 0x20

    db 0x0FB
    
    dw 18
    db 1

section boot_section start=0x7DFE
dw 0xAA55
