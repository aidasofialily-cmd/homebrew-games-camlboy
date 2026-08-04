;; ==============================================================================
;; File: games/old_games/fightcat.asm
;; Description: 2D Arcade Cat Fighter Engine (x86_64 NASM + SDL2)
;; ==============================================================================

global main
extern SDL_Init, SDL_CreateWindow, SDL_CreateRenderer, SDL_DestroyRenderer
extern SDL_DestroyWindow, SDL_Quit, SDL_PollEvent, SDL_SetRenderDrawColor
extern SDL_RenderClear, SDL_RenderPresent, SDL_RenderFillRect, SDL_Delay

%define SDL_INIT_VIDEO      0x00000020
%define SDL_WINDOWPOS_CENTER 0x2FFF0000
%define SDL_QUIT_EVENT      0x100
%define SDL_KEYDOWN         0x300

%define SDLK_LEFT   0x40000050
%define SDLK_RIGHT  0x4000004F
%define SDLK_SPACE  0x20

section .data
    title_str db "Fight Cat: Alley Brawler (x86_64 ASM)", 0
    win_w     dd 640
    win_h     dd 400

    ; Player Cat Struct {x, y, w, h}
    cat_rect:
        .x dd 150
        .y dd 280
        .w dd 40
        .h dd 50

    ; Enemy Cat Struct {x, y, w, h}
    enemy_rect:
        .x dd 450
        .y dd 280
        .w dd 40
        .h dd 50

    ; Attack Hitbox Overlay
    hitbox_rect:
        .x dd 0
        .y dd 0
        .w dd 25
        .h dd 15

    is_attacking db 0
    attack_timer db 0

section .bss
    window   resq 1
    renderer resq 1
    event    resb 56

section .text
main:
    push rbp
    mov rbp, rsp

    ; 1. Init SDL2
    mov rdi, SDL_INIT_VIDEO
    call SDL_Init
    test eax, eax
    js .exit

    ; 2. Create Window
    mov rdi, title_str
    mov rsi, SDL_WINDOWPOS_CENTER
    mov rdx, SDL_WINDOWPOS_CENTER
    mov ecx, [win_w]
    mov r8d, [win_h]
    xor r9d, r9d
    call SDL_CreateWindow
    mov [window], rax

    ; 3. Create Renderer
    mov rdi, [window]
    mov rsi, -1
    mov rdx, 2
    call SDL_CreateRenderer
    mov [renderer], rax

.loop:
.events:
    mov rdi, event
    call SDL_PollEvent
    test eax, eax
    jz .update

    mov eax, dword [event]
    cmp eax, SDL_QUIT_EVENT
    je .clean

    cmp eax, SDL_KEYDOWN
    je .key_down
    jmp .events

.key_down:
    mov eax, dword [event + 20]
    cmp eax, SDLK_LEFT
    je .left
    cmp eax, SDLK_RIGHT
    je .right
    cmp eax, SDLK_SPACE
    je .attack
    jmp .events

.left:
    sub dword [cat_rect.x], 10
    jmp .events
.right:
    add dword [cat_rect.x], 10
    jmp .events
.attack:
    mov byte [is_attacking], 1
    mov byte [attack_timer], 10   ; Attack lasts 10 frames
    jmp .events

.update:
    ; Handle attack timer
    cmp byte [is_attacking], 1
    jne .render
    dec byte [attack_timer]
    jnz .render
    mov byte [is_attacking], 0

.render:
    ; Dark Alley Background (R=40, G=40, B=50)
    mov rdi, [renderer]
    mov rsi, 40
    mov rdx, 40
    mov rcx, 50
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    call SDL_RenderClear

    ; Render Player Cat (Orange / Calico: R=240, G=140, B=40)
    mov rdi, [renderer]
    mov rsi, 240
    mov rdx, 140
    mov rcx, 40
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    mov rsi, cat_rect
    call SDL_RenderFillRect

    ; Render Enemy Cat (Dark Gray: R=100, G=100, B=110)
    mov rdi, [renderer]
    mov rsi, 100
    mov rdx, 100
    mov rcx, 110
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    mov rsi, enemy_rect
    call SDL_RenderFillRect

    ; Render Claw Attack Hitbox if attacking
    cmp byte [is_attacking], 1
    jne .present

    mov eax, [cat_rect.x]
    add eax, [cat_rect.w]
    mov [hitbox_rect.x], eax
    mov eax, [cat_rect.y]
    add eax, 15
    mov [hitbox_rect.y], eax

    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 50
    mov rcx, 50
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    mov rsi, hitbox_rect
    call SDL_RenderFillRect

.present:
    mov rdi, [renderer]
    call SDL_RenderPresent

    mov rdi, 16
    call SDL_Delay
    jmp .loop

.clean:
    mov rdi, [renderer]
    call SDL_DestroyRenderer
    mov rdi, [window]
    call SDL_DestroyWindow
    call SDL_Quit
.exit:
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
