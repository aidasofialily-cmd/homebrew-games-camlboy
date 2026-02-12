INCLUDE "homebrew/include/hardware.inc"

SECTION "Header", ROM0[$100]
    jp Start
    ds $150 - @, 0

Start:
    ; 1. Wait for VBlank (Scanline 144)
.waitVBlank:
    ld a, [rLY]
    cp 144
    jr c, .waitVBlank

    ; 2. Initialize Palette (Darkest to Lightest)
    ld a, %11100100 
    ld [rBGP], a

    ; 3. Turn on LCD
    ld a, %10010001
    ld [rLCDC], a

MainLoop:
    ; Just keep the CPU alive
    halt
    jr MainLoop
