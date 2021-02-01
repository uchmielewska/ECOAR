;edi - pointer to image
;ch  - rfactor
;cl  - padding
;esi - normWidth
;ebx - columnCounter
;edx - rowCounter
;eax - temporary register for calculations

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
        push    ebx
        push    edi
        push    esi
        
        mov     edi, [ebp+8]                    ;store pointer to the file in edi
        mov     ch, [ebp+12]                    ;store rfactor in ch

        ;normWidth calculate
        mov     ebx, [edi+18]                   ;load width to eax
        lea     ebx, [ebx + ebx*2]              ;width*3 and store normWidth in esi

        ;padding calculate
        and     bl, 3                           ;in eax there was already normWidth
        mov     cl, 4                                  
        sub     cl, bl                          ;store padding in cl

        ;set counters
        mov     edx, [edi+22]                   ;set rowCounter (edx) to height
        xor     esi, esi                        ;set columnCounter (ebx) to 0

        ;move image pointer to the beginning of the bitmap (by the offset size)
        mov     eax, [edi+10]                   ;load offset to eax
        add     edi, eax                        ;move pointer by the offset value

algorithm:
        mov     al, [edi]                       ;load current pixel to al
        add     eax, -128                       ;pixel -= 128
        imul    ch                              ;pixel *= rfactor
        sar     eax, 7                          ;pixel /= 128
        add     eax, 128                        ;pixel += 128
        mov     byte[edi], al                   ;update pixel in edi
        inc     edi                             ;go to the next pixel

        inc     esi                             ;columnCounter++
        cmp     ebx, esi                        ;compare normWidth with columnCounter
        jg      algorithm                       ;if (normWidth > columnCounter) continue with algorithm

padding:
        dec     edx                             ;rowCounter--
        mov     al, [edi]                       ;load current pixel to al
        add     al, cl                          ;move image pointer by the number of padding bytes
        xor     esi, esi                        ;set columnCounter as 0
        cmp     edx, 0                          ;compare rowCounter with 0
        jg      algorithm                       ;if (rowCounter > 0) go to algorithm

exit:  
        pop     esi
        pop     edi
        pop     ebx
        mov     esp, ebp
        pop     ebp

        ret  
