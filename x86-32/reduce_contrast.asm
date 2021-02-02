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
        lea     ebx, [ebx + ebx*2]              ;width*3 and store normWidth in ebx

        ;padding calculate
        mov     al, bl                          ;in ebx there is normWidth
        and     al, 3                           
        mov     cl, 4                                  
        sub     cl, al                          ;store padding in cl

        ;set counters
        mov     edx, [edi+22]                   ;set rowCounter (edx) to height
        xor     esi, esi                        ;set columnCounter (esi) to 0

        ;move image pointer to the beginning of the bitmap (by the offset size)
        mov     eax, [edi+10]                   ;load offset to eax
        add     edi, eax                        ;move pointer by the offset value

pixel_processing:
        mov     al, [edi]                       ;load current pixel to al
        sub     eax, 128                        ;pixel -= 128
        imul    ch                              ;pixel *= rfactor
        sar     eax, 7                          ;pixel /= 128
        add     eax, 128                        ;pixel += 128
        mov     byte[edi], al                   ;update pixel in edi
        inc     edi                             ;go to the next pixel
        
row_processing:
        inc     esi                             ;columnCounter++
        cmp     ebx, esi                        ;compare normWidth with columnCounter
        jge     pixel_processing                ;if (normWidth > columnCounter) continue with pixel_processing

column_processing:
        xor     esi, esi                        ;set columnCounter as 0
        dec     edx                             ;rowCounter--
        mov     al, [edi]                       ;load current pixel to al
        add     al, cl                          ;move image pointer by the number of padding bytes
        test    edx, edx                        ;compare rowCounter with 0
        jg      pixel_processing                ;if (rowCounter > 0) go to pixel_processing

exit:  
        pop     esi
        pop     edi
        pop     ebx
        mov     esp, ebp
        pop     ebp

        ret  
         
