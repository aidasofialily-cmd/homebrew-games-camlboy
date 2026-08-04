;; ==============================================================================
;; File: games/old_games/kirbyadventure.asm
;; Description: Kirby's Adventure Retro Platformer Engine (x86_64 NASM + SDL2)
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
%define SDLK_UP     0x40000052
%define SDLK_SPACE  0x20

section .data
    title_str db "Kirby's Adventure (x86_64 ASM)", 0
    win_w     dd 512
    win_h     dd 480

    ; Kirby Entity Struct {x, y, w, h}
    kirby_rect:
        .x dd 100
        .y dd 300
        .w dd 32
        .h dd 32

    ; Physics & State
    vel_y       dd 0
    gravity     dd 1
    ground_y    dd 360
    is_hovering db 0

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
    jz .physics

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
    cmp eax, SDLK_UP
    je .float_jump
    jmp .events

.left:
    sub dword [kirby_rect.x], 8
    jmp .events
.right:
    add dword [kirby_rect.x], 8
    jmp .events
.float_jump:
    mov dword [vel_y], -10     ; Float/Inhale Jump
    jmp .events

.physics:
    mov eax, [vel_y]
    add eax, [gravity]
    mov [vel_y], eax
    add [kirby_rect.y], eax

    mov eax, [kirby_rect.y]
    cmp eax, [ground_y]
    jl .render

    mov eax, [ground_y]
    mov [kirby_rect.y], eax
    mov dword [vel_y], 0

.render:
    ; Pink Sky Background (R=255, G=192, B=203)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 192
    mov rcx, 203
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    call SDL_RenderClear

    ; Render Kirby (Hot Pink: R=255, G=105, B=180)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 105
    mov rcx, 180
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    mov rsi, kirby_rect
    call SDL_RenderFillRect

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
