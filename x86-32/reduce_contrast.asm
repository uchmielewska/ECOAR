;local variables
; ebp-12 - rowCounter
; ebp-16 - width
; ebp-20 - height
; ebp-24 - padding
; ebp-28 - columnCounter
; ebp-32 - normWidth

;algorithm
;pixel -= 128;
;pixel *= rfactor;
;pixel /= 128;
;pixel += 128;

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
        mov     dword [ebp-24], eax             ;store padding in [ebp-24]

        mov     eax, dword [ebp-20]
        mov     dword [ebp-12], eax             ;set rowCounter as height
        mov     dword [ebp-28], 0               ;set columnCounter to 0
        mov     cl, [ebp-24]                    ;load num of padding bytes to cl

        mov     eax, dword [ebp-16]
        mov     ebx, 3
        mul     ebx
        mov     dword [ebp-32], eax             ;store normWidth in [ebp-36]

row:
        mov     al, [edi]                       ;load current pixel to al
        mov     ebx, [ebp+12]
        add     eax, -128
        imul    bl
        sar     eax, 7
        add     eax, 128
        mov     byte[edi], al
        inc     edi

        inc     dword [ebp-28]                  ;columnCounter++
        mov     eax, dword [ebp-28]             ;load columnCounter to eax
        mov     ebx, dword [ebp-32]             ;load normWidth to ebx
        cmp     eax, ebx                        ;compare columnCounter with normWidth
        jg      padding                         ;if columnCounter > normWidth go to padding
        jmp     row

padding:
        dec     dword [ebp-12]                  ;rowCounter--
        mov     al, [edi]                       ;load current pixel to al
        add     al, cl                          ;move image pointer by the number of padding bytes
        mov     dword [ebp-28], 0               ;set columnCounter as 0
        cmp     dword [ebp-12], 0               ;compare rowCounter with 0
        jg      row                             ;if rowCounter > 0 go to row
        jmp     exit

exit:
        leave
        ret  
