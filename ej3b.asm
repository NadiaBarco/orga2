;########### SECCION DE DATOS
section .data
str_CLT : db "CLT",0
str_RBO : db "RBO",0
extern malloc
extern strncmp
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

global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
; rdi = funcion
; rsi = arreglo_casos
; rdx = casos_A_revissar
; rcx = largo
resolver_automaticamente:
    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14

    ; asignaciones
    mov rbx, rsi        ; rbx = arreglo_casos
    mov r12, rdi        ; r12 = funcion
    mov r13, rdx        ; r13 = casos_a_revisar
    mov r14d, ecx        ; r14 = largo
    mov r15, rbx 
    .loop:
        cmp r14d,0
        je .fin
    ; OBTENEMOS EL elemento de arreglo_casos
        ;mov r15, rbx    ; r15 = arreglo_casos
        mov r8, [r15 + CASO_USUARIO_OFFSET] ; ENTRAMOS AL usuario, r15=arreglo_casos[i]
        ; accedemos a su nivel
        mov r9d, dword[r8 + USUARIO_NIVEL_OFFSET] ; arreglo_casos[i]->usuario.nivel
        ; BUSCAMOS EL NIVEL DE USUARIO

        ; Verifcamos el nivel
        cmp r9d, 0           ; es un caso de nivel 0?
        je .revisar_caso     ; NO ES POSIBLE CERRAR AUTOMATICAMENTE

        ; es un caso de nivel 1 o 2
        ; Llamamos a funcion
        mov rdi, r15
        call r12

        cmp eax, 1  
        je .cambio_estado1

        ; EAX = 0 cierro caso desfavorable
        ; chequeamos categoria 

        lea r8, [r15 + CASO_CATEGORIA_OFFSET] ; 
        mov rdi, r8                           ; rdi = &arreglo_casos[i].categoria
        lea rsi, str_CLT
        mov rdx, 4
        call strncmp
        cmp eax, 0
        je .cambio_estado



        lea r8, [r15 + CASO_CATEGORIA_OFFSET]
        mov rdi, r8
        lea rsi, str_RBO
        mov rdx, 4
        call strncmp

        cmp eax, 0
        je .cambio_estado

    ; no es igual a CLT o RBO -> se van a casos_arevisar
    
        .revisar_caso:
            mov r10d,[r15+CASO_CATEGORIA_OFFSET] ; pasamos 4 bytes para la alineacion categoria ==char[3]
            mov  [r13+CASO_CATEGORIA_OFFSET], r10d      ;casos_a_revisar[i] = arrerglo_casos[j] 
            mov r10w,word[r15 + CASO_ESTADO_OFFSET]
            mov  word[r13 + CASO_ESTADO_OFFSET],r10w
            mov r10, qword[r15 + CASO_USUARIO_OFFSET]
            mov qword[r13 + CASO_USUARIO_OFFSET],r10
            add r13 , CASO_SIZE
            jmp .sigo
        .cierro_caso:
            jmp .sigo 
        .cambio_estado:
            mov word[r15 + CASO_ESTADO_OFFSET], 2
            jmp .sigo
        .cambio_estado1:
            mov word[r15 + CASO_ESTADO_OFFSET], 1
            jmp .sigo
        .sigo:    
            add r15, CASO_SIZE
            sub r14d,1
            jmp .loop
    .fin:
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret
