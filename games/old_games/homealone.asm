; ==============================================================================
; File: games/old_games/homealone.asm
; Description: Retro House Trap Evasion Game (x86_64 NASM Assembly + SDL2)
; Assemble: nasm -f elf64 homealone.asm -o homealone.o
; Link:     gcc homealone.o -lSDL2 -no-pie -o homealone
; ==============================================================================

global main
extern SDL_Init, SDL_CreateWindow, SDL_CreateRenderer, SDL_DestroyRenderer
extern SDL_DestroyWindow, SDL_Quit, SDL_PollEvent, SDL_SetRenderDrawColor
extern SDL_RenderClear, SDL_RenderPresent, SDL_RenderFillRect, SDL_Delay

; --- SDL2 Constants ---
%define SDL_INIT_VIDEO          0x00000020
%define SDL_WINDOWPOS_CENTERED 0x2FFF0000
%define SDL_QUIT_EVENT          0x100
%define SDL_KEYDOWN             0x300

; --- Keycodes ---
%define SDLK_LEFT   0x40000050
%define SDLK_RIGHT  0x4000004F
%define SDLK_UP     0x40000052
%define SDLK_DOWN   0x40000051

section .data
    win_title db "Home Alone: Trap Defender (ASM)", 0
    
    win_w dd 480
    win_h dd 360

    ; Player (Kevin): {x, y, w, h}
    player_rect:
        .x dd 220
        .y dd 300
        .w dd 24
        .h dd 32

    ; Hazard 1 (Paint Can): {x, y, w, h}
    hazard1_rect:
        .x dd 100
        .y dd 0
        .w dd 20
        .h dd 20

    ; Hazard 2 (Micro Machines): {x, y, w, h}
    hazard2_rect:
        .x dd 320
        .y dd -100
        .w dd 20
        .h dd 20

    move_speed   dd 8
    hazard_speed dd 5

section .bss
    window   resq 1
    renderer resq 1
    event    resb 56        ; SDL_Event buffer

section .text

main:
    push rbp
    mov rbp, rsp

    ; 1. Initialize SDL2
    mov rdi, SDL_INIT_VIDEO
    call SDL_Init
    test eax, eax
    js .error_exit

    ; 2. Create Window
    mov rdi, win_title
    mov rsi, SDL_WINDOWPOS_CENTERED
    mov rdx, SDL_WINDOWPOS_CENTERED
    mov ecx, [win_w]
    mov r8d, [win_h]
    xor r9d, r9d
    call SDL_CreateWindow
    mov [window], rax
    test rax, rax
    jz .error_exit

    ; 3. Create Renderer
    mov rdi, [window]
    mov rsi, -1
    mov rdx, 2              ; Accelerated
    call SDL_CreateRenderer
    mov [renderer], rax

.game_loop:
    ; --- Event Handling ---
.poll_events:
    mov rdi, event
    call SDL_PollEvent
    test eax, eax
    jz .update_game

    mov eax, dword [event]
    cmp eax, SDL_QUIT_EVENT
    je .clean_exit

    cmp eax, SDL_KEYDOWN
    je .handle_key
    jmp .poll_events

.handle_key:
    mov eax, dword [event + 20] ; Keycode sym
    cmp eax, SDLK_LEFT
    je .move_left
    cmp eax, SDLK_RIGHT
    je .move_right
    cmp eax, SDLK_UP
    je .move_up
    cmp eax, SDLK_DOWN
    je .move_down
    jmp .poll_events

.move_left:
    mov eax, [move_speed]
    sub [player_rect.x], eax
    jmp .poll_events

.move_right:
    mov eax, [move_speed]
    add [player_rect.x], eax
    jmp .poll_events

.move_up:
    mov eax, [move_speed]
    sub [player_rect.y], eax
    jmp .poll_events

.move_down:
    mov eax, [move_speed]
    add [player_rect.y], eax
    jmp .poll_events

    ; --- Game Logic Update ---
.update_game:
    ; Fall Hazard 1
    mov eax, [hazard_speed]
    add [hazard1_rect.y], eax
    cmp dword [hazard1_rect.y], 360
    jl .update_hazard2
    mov dword [hazard1_rect.y], -20 ; Reset to top

.update_hazard2:
    ; Fall Hazard 2
    mov eax, [hazard_speed]
    add [hazard2_rect.y], eax
    cmp dword [hazard2_rect.y], 360
    jl .render_frame
    mov dword [hazard2_rect.y], -40 ; Reset to top

    ; --- Rendering Phase ---
.render_frame:
    ; Background (House Interior Warm Brown: R=80, G=50, B=40)
    mov rdi, [renderer]
    mov rsi, 80
    mov rdx, 50
    mov rcx, 40
    mov r8, 255
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    call SDL_RenderClear

    ; Draw Hazards (Silver/Gray Paint Cans: R=200, G=200, B=210)
    mov rdi, [renderer]
    mov rsi, 200
    mov rdx, 200
    mov rcx, 210
    mov r8, 255
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    mov rsi, hazard1_rect
    call SDL_RenderFillRect

    mov rdi, [renderer]
    mov rsi, hazard2_rect
    call SDL_RenderFillRect

    ; Draw Player (Kevin - Red Sweater: R=220, G=30, B=30)
    mov rdi, [renderer]
    mov rsi, 220
    mov rdx, 30
    mov rcx, 30
    mov r8, 255
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    call SDL_RenderFillRect

    ; Present Render Buffer
    mov rdi, [renderer]
    call SDL_RenderPresent

    ; Cap at ~60 FPS (16 ms delay)
    mov rdi, 16
    call SDL_Delay

    jmp .game_loop

.clean_exit:
    mov rdi, [renderer]
    call SDL_DestroyRenderer
    mov rdi, [window]
    call SDL_DestroyWindow
    call SDL_Quit
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

.error_exit:
    mov eax, 1
    mov rsp, rbp
    pop rbp
    ret
