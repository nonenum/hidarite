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

BARRIER_POS equ 0x1655
BARRIER_X equ 0x06
BARRIER_Y equ 0x55
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

    mov si, enemy_array
    mov bl, ENEMY_COLOR
    mov ax, [si+13]
    cmp byte [si+19], cl

    mov cl, 4
    jg draw_enemy_rutine

    add di, cx

    draw_enemy_rutine:
        pusha
        mov cl, 8

        .check_next:
            pusha

            dec cx
            bt [si], cx
            
            jnc .next_enemy

            mov si, di
            call draw_texture

            .next_enemy:
                popa
                add ah, TEXTURE_WIDTH+4
        loop .check_next
        popa

        add al, TEXTURE_HEIGHT+2
        inc si

    loop draw_enemy_rutine

    lodsb
    push si

    mov si, player
    mov ah, PLAYER_Y
    xchg ah, al
    mov bl, PLAYER_COLOR

    call draw_texture

    mov bl, BARRIER_COLOR
    mov ax, BARRIER_POS

    mov cl, 5
    draw_barrier_rutine:
        pusha
        call draw_texture
        popa

        add ah, 25
        add si, TEXTURE_HEIGHT
    loop draw_barrier_rutine

    pop si

    mov cl, 4
    get_projectile:
        push cx

        lodsw
        cmp al, 0
        jnz check_projectile
        
        next_shot:
            pop cx
    loop get_projectile

    jmp create_enemy_projectiles

    check_projectile:
        call get_screen_position
        mov al, [di]

        cmp al, PLAYER_COLOR
        je game_cleanup

        xor bx, bx

        cmp al, BARRIER_COLOR
        jne .check_enemy_hit

        mov bx, barrier_array
        mov ah, BARRIER_X+TEXTURE_WIDTH 

        .check_barrier_rutine:
            cmp dh, ah
            ja .next_barrier

            sub ah, TEXTURE_HEIGHT
            sub dh, ah

            pusha
            sub dl, BARRIER_Y
            add bl, dl

            mov al, 7
            sub al, dh
            cbw
            btr [bx], ax

            mov byte [si-2], ah
            popa
            jmp next_shot

            .next_barrier:
                add ah, 25
                add bl, TEXTURE_HEIGHT
        jmp .check_barrier_rutine

        .check_enemy_hit:

    create_enemy_projectiles:

    ;; INPUTS: L_SHIFT ALT R_SHIFT

    get_inputs:
        mov si, player_x
        mov ah, 0x02
        int 0x16

        test al, 1
        jz .check_leftshft

        add byte [si], ah

        .check_leftshft:
            test al, 2
            jz .check_alt

            sub byte [si], ah

        .check_alt:
            test al, 8
            jz tick_timer

            lodsb
            xchg ah, al
            add ax, 0x035A
            mov [si], ax

    tick_timer:
        mov ax, [CS:TIMER]
        inc ax

        .timer_func_wait:
            cmp [CS:TIMER], ax
            jl .timer_func_wait

jmp game_loop

game_cleanup:
    cli
    hlt

;; Parameters: si adress, al y, ah x, bl color
draw_texture:
    call get_screen_position
    mov cl, TEXTURE_HEIGHT

    .next_line:
        push cx
        lodsb
        xchg ax, dx
        mov cl, TEXTURE_WIDTH

        .next_px:
            xor ax, ax
            dec cx
            bt dx, cx

            cmovc ax, bx
            mov ah, al

            mov [di+WIDTH], ax
            stosw
        
        jnz .next_px
        add di, WIDTH*2-TEXTURE_WIDTH_PX
        pop cx

    loop .next_line

    ret

;; Parameters: al y, ah x
get_screen_position:
    mov dx, ax
    cbw
    
    imul di, ax, WIDTH*2
    mov al, dh
    shl ax, 1
    add di, ax

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
