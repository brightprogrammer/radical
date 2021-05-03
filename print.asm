;***********************************************************;
;               radical - simple bootloader                 ;
; file      : print.asm                                     ;
; desc      : contains functions for printing on screen     ;
; author    : Siddharth Mishra                              ;
; time      : Mon 3 May, 2021, 19:35                        ;
;***********************************************************;

;*************************************************;
; helper function for printing a string on screen ;
; usage : + push the function to stack            ;
;         + the stack must be 0 terminated        ;
;*************************************************;
print:
    push ebp
    mov ebp, esp
    push esp

    ; clear eax register
    xor eax, eax                        ; this way is much faster for setting eax to 0

    ; load first parameter, +8 because 8 bytes are occupied by information used for calling ret
    mov bx, [ebp+8]

    ; set to printing mode
    mov ah, 0x0e

    ; loot protocol
    .loop:
        cmp [bx], byte 0
        je .exit                        ; if this char is 0 then we reached the end of string
        mov al, [bx]                    ; load character into bx
        int 0x10                        ; print interrupt
        inc bx                          ; get next char
        jmp .loop                       ; go back to loop

    ; exit protocol
    .exit:
        pop esp
        pop ebp
        ret

;*******************************************************************;
; helper function for printing a string on screen with a new line   ;
; usage : + push the function to stack                              ;
;         + the stack must be 0 terminated                          ;
;*******************************************************************;
print_ln:
    ; print message normally
    call print

    ; print newline
    mov al, 0x0a
    int 0x10

    ret