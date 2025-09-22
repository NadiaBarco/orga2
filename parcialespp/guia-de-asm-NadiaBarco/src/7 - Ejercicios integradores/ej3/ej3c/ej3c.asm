;########### SECCION DE DATOS
section .data
extern malloc
extern strncmp
str_CLT : db "CLT",0
str_RBO : db "RBO",0
str_KSC : db "KSC",0
str_KDT : db "KDT",0

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7
global calcular_estadisticas

;void calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id)
calcular_estadisticas:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; Asignaciones 
    mov rbx , rdi       ; rbx = arreglo_casos
    mov r14d, esi       ; r14d = largo
    mov r12d, edx       ; usuario_id
    xor r13, r13        ; struct estadisticas_t

    ; Armamos estadisticas_t
    mov rdi, ESTADISTICAS_SIZE
    call malloc
    mov r13, rax

    cmp r12d, 0
    je .loop

; EJMPLO OTRA MANERA
; Para usar índice multiplicado:
;mov rax, r8
;imul rax, CASO_SIZE
;mov r15, [rbx + rax + CASO_USUARIO_OFFSET]


    ; solo contamos las estadisticas de usuario_id
    mov rax, r12
    imul rax, CASO_SIZE
    lea rdi, [rbx + rax]      ; obtenemos el caso[usuario_id]
    mov rsi, r13
    call cantidad_de_casos
    jmp .fin 

    ;contamos las estadisticas de todos los usuarios
    xor r8,r8
    .loop:
        cmp r8d, r14d
        je .fin
        mov rax, r8
        imul rax, CASO_SIZE
        lea r15, [rbx + rax] 
        mov rsi, r13
        call cantidad_de_casos
        inc r8d
        jmp .loop

    
 .fin:
    mov rax, r13
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;void cantidad_de_casos(caso_t* caso, estadisticas_t* total)

cantidad_de_casos:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov rbx, rdi         ; rbx = caso
    mov r13, rsi        ; r12 = estadisticas

    mov rbx, CASO_ESTADO_OFFSET
    mov r8w, bx
    cmp r8w, 0
    je .estado0 
    cmp r8w, 1
    je .estado1

    ; Es de estado 2
    inc byte[r13 + 6]
    jmp .categorias
    .estado0:
        inc byte[r13 + 4]
        jmp .categorias

    .estado1: 
        inc byte[r13 +5]
        ;;

    ; COMPARAMOS CATEORIAS
    .categorias:
        lea rdi, [rbx + CASO_CATEGORIA_OFFSET]
        mov rsi, str_CLT
        mov edx, 4
        call strncmp

        cmp eax, 0
        je .esCLT 


            lea rdi, [rbx + CASO_CATEGORIA_OFFSET]
            mov rsi, str_RBO
            mov edx, 4
            call strncmp

            cmp eax, 0
            je .esRBO 

            lea rdi, [rbx + CASO_CATEGORIA_OFFSET]
            mov rsi, str_KSC
            mov edx, 4
            call strncmp

            cmp eax, 0
            je .esKSC

            lea rdi, [rbx + CASO_CATEGORIA_OFFSET]
            mov rsi, str_KDT
            mov edx, 4
            call strncmp

            cmp eax, 0
            je .esKDT

        .esCLT:
            inc byte[r13]
            jmp .fin

        .esRBO:
            inc byte[r13 + 1]
            jmp .fin 

        .esKSC:
            inc byte[r13 +2]
            jmp .fin 

        .esKDT:
            inc byte[r13 +3]
    .fin:         
        add rsp, 8
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret