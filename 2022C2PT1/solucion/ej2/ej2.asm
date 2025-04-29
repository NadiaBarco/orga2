extern malloc
global filtro

;########### SECCION DE DATOS
section .data
ALIGN 16
mask_r: dw 0xffff, 0x0000, 0xFFFF, 0x0000, 0xffff, 0x0000, 0xffff, 0x0000
mask_l: dw 0x0000, 0xFFFF, 0x0000, 0xffff, 0x0000, 0xffff, 0x0000,0xffff
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;int16_t* filtro (const int16_t* entrada, unsigned size)
;rdi = const int16_t*
;esi= unsigned size
filtro:
    push rbp
    mov rbp,rsp
    sub rsp,16
    mov [rbp-8], rdi

    ; Asignamos memoria para la slaida del filtro
    movzx rdi, esi
    shl rdi, 2
    add rdi, 1
    call malloc

    mov [rbp-16], rax             ; Guardo el puntero

    ;desempaquetamos el x[n]
    mov rdi, [rbp-8]
    mov xmm0, [rdi]               ;xmm0=L3R3 L2R2 L1R1 L0R0
    mov xmm1, xmm0
    
    movdqa xmm2,[mask_r]
    pand xmm0, xmm2               ; xmm0= 0R3 0R2 0R1 0R0
    
    movdqa xmm2,[mask_l]
    pand xmm1, xmm2               ; xmm1 = L30 L20 L10 L00     

    ; 0R3 0R2 0R1 0R0 0R3 0R2 0R1 0R0
    
    pblendw xmm1, xmm1, 0b
    .fin:
    add rsp,16
    pop rbp


