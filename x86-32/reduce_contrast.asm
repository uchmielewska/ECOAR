;local variables
; ebp-12 - rowCounter
; ebp-16 - width
; ebp-20 - height
; ebp-24 - offset
; ebp-28 - padding
; ebp-32 - columnCounter

;algorithm
;newPixel = (128 - rfactor) + (pixel/128)*rfactor;

;newPixel = pixel;
;newPixel *= rfactor;
;newPixel /= 128;
;newPixel += (128 - rfactor);

section .text
global _reduce_contrast

_reduce_contrast:
        push    ebp 
        mov     ebp, esp     
        
        sub     esp, 36                         ;declare the stack size
        mov     edi, DWORD[ebp+8]               ;save pointer to the file (first argument)

        mov     eax, dword [edi+10]             ;get offset
        mov     dword [ebp-20], eax             ;save offset to [ebp-20]
        mov     eax, dword [edi+18]             ;get width
        mov     dword [ebp-16], eax             ;save width to [ebp-16]
        mov     eax, dword [edi+22]             ;get height
        mov     dword [ebp-20], eax             ;save height to [ebp-20]

        ;move image pointer to the beginning of the bitmap (by offset size)
        mov     eax, dword [edi+10]             ;load offset to eax
        add     edi, eax                        ;move pointer by the offset value

        ;padding calculate
        mov     eax, dword [ebp-16]             ;load width to eax
        lea     edx, [eax + eax*2]              ;width * 3
        and     edx, 3                          ;%4
        mov     eax, 4
        sub     eax, edx
        mov     dword [ebp-28], eax             ;store padding in [ebp-28]

        mov     eax, dword [ebp-20]
        mov     dword [ebp-12], eax             ;set rowCounter as height
        mov     dl, 128                         ;load 128 to dl
        sub     dl, [ebp+12]                    ;128-rfactor

row:
        mov     al, [edi]                       ;load current pixel to al
        mov     bl, [ebp+12]                    ;load rfactor to bl
        mul     bl                              ;newPixel *= rfactor                  
        shr     al, 7                           ;newPixel /= 128
        add     al, dl                          ;newPixel += (128 - rfactor)
        stosb                                   ;increment edi
        inc     dword [ebp-28]                  ;columnCounter++
        mov     eax, dword [ebp-28]             ;load columnCounter to eax
        mov     ebx, dword [ebp-16]             ;load width to ebx
        cmp     eax, ebx                        ;compare columnCounter with width
        jg      padding                         ;if columnCounter > width go to padding
        jmp     row

padding:
        dec     dword [ebp-12]                  ;rowCounter--
        mov     eax, dword [ebp-28]
        add     edi, eax                        ;move image pointer by the number of padding bytes
        mov     dword [ebp-28], 0               ;set columnCounter as 0
        cmp     dword [ebp-12], 0               ;compare rowCounter with 0
        jg      row                             ;if rowCounter > 0 go to row
        jmp     exit

exit:
        leave
        ret  
