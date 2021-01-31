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
        mov     eax, [edi+18]                   ;load width to eax
        mov     esi, 0x3                        ;load 3 to edx
        mul     esi                             ;width*3 (result is in eax)
        mov     esi, eax                        ;store normWidth in esi

        ;padding calculate
        and     eax, 0x3                        ;in eax there was already normWidth
        mov     edx, 0x4                                  
        sub     edx, eax
        mov     cl, dl                          ;store padding in cl

        ;set counters
        mov     edx, [edi+22]                   ;set rowCounter (edx) to height
        mov     ebx, 0                          ;set columnCounter (ebx) to 0

        ;move image pointer to the beginning of the bitmap (by the offset size)
        mov     eax, [edi+10]                   ;load offset to eax
        add     edi, eax                        ;move pointer by the offset value

algorithm:
        mov     al, [edi]                       ;load current pixel to al
        add     eax, -0x80                      ;pixel -= 128
        imul    ch                              ;pixel *= rfactor
        sar     eax, 0x7                        ;pixel /= 128
        add     eax, 0x80                       ;pixel += 128
        mov     byte[edi], al                   ;update pixel in edi
        inc     edi                             ;go to the next pixel

        inc     ebx                             ;columnCounter++
        cmp     esi, ebx                        ;compare normWidth with columnCounter
        jg      algorithm                       ;if (normWidth > columnCounter) continue with algorithm

padding:
        dec     edx                             ;rowCounter--
        mov     al, [edi]                       ;load current pixel to al
        add     al, cl                          ;move image pointer by the number of padding bytes
        mov     ebx, 0                          ;set columnCounter as 0
        cmp     edx, 0                          ;compare rowCounter with 0
        jg      algorithm                       ;if (rowCounter > 0) go to algorithm

exit:  
        pop     esi
        pop     edi
        pop     ebx
        mov     esp, ebp
        pop     ebp

        ret  
