;local variables
; ebp-12 - counter
; ebp-16 - width +
; ebp-20 - offset +
; ebp-24 - pixel
; ebp-28 - newPixel
; ebp-32 - padding +
; ebp-36 - loopWidth

;algorithm
;newPixel = (128 - rfactor) + (pixel/128)*rfactor;

;newPixel = pixel;
;newPixel *= rfactor;
;newPixel /= 128;
;newPixel += 128;
;newPixel -= rfactor;

section .text
global _reduce_contrast

_reduce_contrast:
        push    ebp 
        mov     ebp, esp     
        
        sub     esp, 40                         ;declare the stack size
        mov     edi, DWORD[ebp+8]               ;save pointer to the file (first argument)

        mov     eax, dword [edi+10]             ;get offset
        mov     dword [ebp-20], eax             ;save offset to [ebp-20]
        mov     eax, dword [edi+18]             ;get width
        mov     dword [ebp-16], eax             ;save width to [ebp-16]

        ;padding check
        mov     eax, dword [ebp-18]             ;load width to eax
        lea     edx, [eax + eax*2]
        and     edx, 3
        mov     eax, 4
        sub     eax, edx
        mov     dword [ebp-32], eax             ;store padding in [ebp-32]

row:
        mov     dword [ebp-36], 0               ;set loopWidth as 0

