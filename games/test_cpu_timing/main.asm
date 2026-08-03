;; ==============================================================================
;; File: games/test_cpu_timing/main.asm
;; Description: x86_64 CPU Instruction Timing & Cycle Count Test Utility
;; ==============================================================================

global _start

section .data
    msg_header  db "=== x86_64 CPU Timing Test ===", 10, 0
    header_len  equ $ - msg_header
    msg_result  db "CPU Cycles Elapsed: Completed successfully.", 10, 0
    result_len  equ $ - msg_result

section .bss
    start_tsc   resq 1
    end_tsc     resq 1
    elapsed_tsc resq 1

section .text
_start:
    ; 1. Print Test Header
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg_header
    mov rdx, header_len
    syscall

    ; 2. Serialize CPU & Read Start Time-Stamp Counter
    cpuid               ; Serialize instruction pipeline
    rdtsc               ; Read Time-Stamp Counter into EDX:EAX
    shl rdx, 32
    or  rax, rdx
    mov [start_tsc], rax

    ; 3. Target Instructions to Benchmark (CPU Timing Loop)
    mov ecx, 1000000    ; 1,000,000 iterations
.benchmark_loop:
    nop
    add rax, 1
    sub rax, 1
    dec ecx
    jnz .benchmark_loop

    ; 4. Read End Time-Stamp Counter
    rdtscp              ; Read Time-Stamp Counter & Serialize
    shl rdx, 32
    or  rax, rdx
    mov [end_tsc], rax
    pop rcx             ; Clean up IA32_TSC_AUX from rdtscp

    ; 5. Calculate Delta (Elapsed Cycles)
    mov rax, [end_tsc]
    sub rax, [start_tsc]
    mov [elapsed_tsc], rax

    ; 6. Print Completion Message
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg_result
    mov rdx, result_len
    syscall

    ; 7. Exit cleanly (sys_exit)
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; status = 0
    syscall
