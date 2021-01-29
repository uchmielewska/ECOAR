;local variables
; ebp-12 - rowCounter
; ebp-16 - padding
; ebp-20 - columnCounter
; ebp-24 - normWidth

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
        
        sub     esp, 28                         ;declare the stack size
        mov     edi, DWORD[ebp+8]               ;save pointer to the file (first argument)

        ;normWidth calculate
        mov     eax, dword [edi+18]             ;load width to eax
        mov     ebx, 3                          ;load 3 to ebx
        mul     ebx                             ;width*3
        mov     dword [ebp-24], eax             ;store normWidth in [ebp-36]

        ;padding calculate
        and     eax, 3                          ;in eax there was already normWidth
        mov     edx, 4                                  
        sub     edx, eax
        mov     dword [ebp-16], edx             ;store padding in [ebp-24]

        mov     eax, dword [edi+22]             ;load height to eax
        mov     dword [ebp-12], eax             ;set rowCounter as height
        mov     dword [ebp-20], 0               ;set columnCounter to 0
        mov     cl, [ebp-16]                    ;load num of padding bytes to cl

        ;move image pointer to the beginning of the bitmap (by offset size)
        mov     eax, dword [edi+10]             ;load offset to eax
        add     edi, eax                        ;move pointer by the offset value

row:
        mov     al, [edi]                       ;load current pixel to al
        mov     ebx, [ebp+12]                   ;load rfactor to ebx
        add     eax, -128                       ;pixel -= 128
        imul    bl                              ;pixel *= rfactor
        sar     eax, 7                          ;pixel /= 128
        add     eax, 128                        ;pixel += 128
        mov     byte[edi], al                   ;update pixel in edi
        inc     edi                             ;go to the next pixel

        inc     dword [ebp-20]                  ;columnCounter++
        mov     eax, dword [ebp-20]             ;load columnCounter to eax
        mov     ebx, dword [ebp-24]             ;load normWidth to ebx
        cmp     eax, ebx                        ;compare columnCounter with normWidth
        jg      padding                         ;if columnCounter > normWidth go to padding
        jmp     row

padding:
        dec     dword [ebp-12]                  ;rowCounter--
        mov     al, [edi]                       ;load current pixel to al
        add     al, cl                          ;move image pointer by the number of padding bytes
        mov     dword [ebp-20], 0               ;set columnCounter as 0
        cmp     dword [ebp-12], 0               ;compare rowCounter with 0
        jg      row                             ;if rowCounter > 0 go to row
        jmp     exit

exit:
        leave
        ret  
