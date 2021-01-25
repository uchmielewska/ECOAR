;;;;;;;;;;;;;;;;;;;
;;local variables;;
;;;;;;;;;;;;;;;;;;;
; ebp-12 - counter
; ebp-16 - rfactor
; ebp-24 - actWidth
; ebp-28 - offset
; ebp-32 - actHeight
; ebp-40 - pixel
;;;;;;;;;;;;;;;;;;;;;

;algorithm

;pixel_component -= 128
;pixel_component *= rfactor
;pixel_component /= 128
;pixel_component +=128

;where pixel_component means every component of a pixel, literally: every value of red, green and blue in every pixel

section .text
global _func

_func:
        push    ebp 
        mov     ebp, esp     
        push    ebx 
        push    edi

        mov     ecx, [ebp+12]   ; set counter
        mov ebx, [ebp+16]   ; rfactor to ebx
        mov edi, [ebp+8]    ; img pointer
        mov dl, 128     
        sub dl, bl      ; 128-rfactor

        loop:
        mov al, [edi]  ; current pixel to al
        mul bl      ;
        shr ax, 7   ; byte*rfactor>>7+(128-rfactor)
        add al, dl  ;
        stosb           ; store al, inc edi
        loop loop   

        koniec: 
        pop     edi
        pop     ebx
        mov     esp, ebp    
        pop     ebp
        ret 