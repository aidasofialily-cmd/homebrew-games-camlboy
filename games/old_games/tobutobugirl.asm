; ==============================================================================
; File: games/old_games/tobutobugirl.asm
; Description: Retro Arcade Vertical Jumper (x86_64 NASM Assembly + SDL2)
; Assemble: nasm -f elf64 tobutobugirl.asm -o tobutobugirl.o
; Link:     gcc tobutobugirl.o -lSDL2 -no-pie -o tobutobugirl
; ==============================================================================

global main
extern SDL_Init, SDL_CreateWindow, SDL_CreateRenderer, SDL_DestroyRenderer
extern SDL_DestroyWindow, SDL_Quit, SDL_PollEvent, SDL_SetRenderDrawColor
extern SDL_RenderClear, SDL_RenderPresent, SDL_RenderFillRect, SDL_Delay

; --- SDL2 Constants ---
%define SDL_INIT_VIDEO      0x00000020
%define SDL_WINDOWPOS_CENTERED 0x2FFF0000
%define SDL_QUIT_EVENT      0x100
%define SDL_KEYDOWN         0x300

; --- Keycodes ---
%define SDLK_LEFT   0x40000050
%define SDLK_RIGHT  0x4000004F
%define SDLK_SPACE  0x20

section .data
    win_title db "Tobu Tobu Girl (ASM Retro Jumper)", 0
    
    win_w dd 320            ; Retro Game Boy style internal resolution
    win_h dd 400

    ; Player Entity Struct: {x, y, w, h}
    player_rect:
        .x dd 144
        .y dd 300
        .w dd 16
        .h dd 20

    ; Player Physics
    vel_y       dd -12      ; Initial launch impulse
    gravity     dd 1
    move_speed  dd 6

    ; Cloud Platforms (3 static platforms: x, y, w, h)
    plat1: dd 40,  340, 80, 10
    plat2: dd 120, 220, 80, 10
    plat3: dd 200, 100, 80, 10

section .bss
    window   resq 1
    renderer resq 1
    event    resb 56        ; SDL_Event buffer

section .text

main:
    push rbp
    mov rbp, rsp

    ; 1. Initialize SDL2 Video
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
    mov rdx, 2              ; Accelerated renderer
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
    jmp .poll_events

.move_left:
    mov eax, [move_speed]
    sub [player_rect.x], eax
    jmp .poll_events

.move_right:
    mov eax, [move_speed]
    add [player_rect.x], eax
    jmp .poll_events

    ; --- Game Physics Update ---
.update_game:
    ; Apply Gravity
    mov eax, [vel_y]
    add eax, [gravity]
    mov [vel_y], eax
    add [player_rect.y], eax

    ; Check collision with platforms only when falling down (vel_y > 0)
    cmp dword [vel_y], 0
    jle .render_frame

    ; Check Platform 1 Collision
    mov rdi, plat1
    call check_platform_bounce
    
    ; Check Platform 2 Collision
    mov rdi, plat2
    call check_platform_bounce

    ; Check Platform 3 Collision
    mov rdi, plat3
    call check_platform_bounce

    ; Screen Wrap (Left/Right boundaries)
    cmp dword [player_rect.x], -16
    jg .check_right_wrap
    mov dword [player_rect.x], 320
    jmp .render_frame

.check_right_wrap:
    cmp dword [player_rect.x], 320
    jl .render_frame
    mov dword [player_rect.x], -16

    ; --- Rendering Phase ---
.render_frame:
    ; Clear Screen (Retro Pastel Background: R=230, G=245, B=230)
    mov rdi, [renderer]
    mov rsi, 230
    mov rdx, 245
    mov rcx, 230
    mov r8, 255
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    call SDL_RenderClear

    ; Draw Platforms (Green: R=80, G=180, B=100)
    mov rdi, [renderer]
    mov rsi, 80
    mov rdx, 180
    mov rcx, 100
    mov r8, 255
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    mov rsi, plat1
    call SDL_RenderFillRect

    mov rdi, [renderer]
    mov rsi, plat2
    call SDL_RenderFillRect

    mov rdi, [renderer]
    mov rsi, plat3
    call SDL_RenderFillRect

    ; Draw Player (Pastel Pink: R=240, G=110, B=140)
    mov rdi, [renderer]
    mov rsi, 240
    mov rdx, 110
    mov rcx, 140
    mov r8, 255
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    mov rsi, player_rect
    call SDL_RenderFillRect

    ; Present Renderer Buffer
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

; ==============================================================================
; Helper Function: check_platform_bounce
; RDI = Pointer to platform rectangle struct {x, y, w, h}
; ==============================================================================
check_platform_bounce:
    ; Check if player bottom is touching platform top
    mov eax, [player_rect.y]
    add eax, [player_rect.h]        ; player_bottom

    mov ecx, [rdi + 4]              ; platform_y
    cmp eax, ecx
    jl .no_bounce
    
    add ecx, 8                      ; platform_y + tolerance
    cmp eax, ecx
    jg .no_bounce

    ; Check X axis overlap
    mov eax, [player_rect.x]
    add eax, [player_rect.w]
    cmp eax, [rdi]                  ; player_right > platform_left
    jl .no_bounce

    mov eax, [player_rect.x]
    mov ecx, [rdi]
    add ecx, [rdi + 8]              ; platform_right
    cmp eax, ecx                     ; player_left < platform_right
    jg .no_bounce

    ; Bounce Triggered! Reset upward velocity
    mov dword [vel_y], -14

.no_bounce:
    ret
