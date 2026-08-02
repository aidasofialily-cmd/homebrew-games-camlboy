INCLUDE "homebrew/include/hardware.inc"

SECTION "Header", ROM0[$100]
    jp Start
    ds $150 - @, 0

Start:
    ; Placeholder Start
    ld a, %11100100
    ld [rBGP], a

MainLoop:
    halt
    jr MainLoop
