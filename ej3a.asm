;########### SECCION DE DATOS
section .data
extern malloc
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

;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24         ; espacio para contadores [nivel0, nivel1, nivel2]
    
    mov rbx, rdi        ; rbx = arreglo_casos
    mov r12, rsi        ; r12 = largo
    
    ; 1. Contar casos por nivel
    mov rdi, 24         ; 3 contadores * 8 bytes
    call malloc
    mov r13, rax        ; r13 = array de contadores
    
    ; Inicializar contadores
    mov qword [r13], 0      ; contador nivel 0
    mov qword [r13+8], 0    ; contador nivel 1  
    mov qword [r13+16], 0   ; contador nivel 2
    
    ; Contar
    mov r14, 0          ; índice
.contar:
    cmp r14, r12
    jge .asignar_memoria
    
    mov rax, r14
    imul rax, CASO_SIZE
    mov r15, [rbx + rax + CASO_USUARIO_OFFSET]    ; usuario*
    mov eax, [r15 + USUARIO_NIVEL_OFFSET]         ; nivel
    inc qword [r13 + rax*8]                ; incrementar contador
    
    inc r14
    jmp .contar
    
.asignar_memoria:
    ; 2. Crear segmentacion_t
    mov rdi, 24         ; 3 punteros
    call malloc
    mov r14, rax        ; r14 = segmentacion_t*
    
    ; Asignar arrays para cada nivel
    mov r15, 0          ; índice de nivel
.asignar_loop:
    cmp r15, 3
    jge .llenar_arrays
    
    mov rdi, [r13 + r15*8]      ; cantidad del nivel
    imul rdi, CASO_SIZE         ; bytes necesarios
    call malloc
    mov [r14 + r15*8], rax      ; guardar puntero en segmentacion_t
    
    inc r15
    jmp .asignar_loop
    
.llenar_arrays:
    ; 3. Resetear contadores para usar como índices
    mov qword [r13], 0
    mov qword [r13+8], 0
    mov qword [r13+16], 0
    
    ; Llenar arrays
    mov r15, 0          ; índice en arreglo original
.llenar_loop:
    cmp r15, r12
    jge .fin
    
    ; Obtener caso actual
    mov rax, r15
    imul rax, CASO_SIZE
    lea rsi, [rbx + rax]        ; rsi = &caso_actual
    
    ; Obtener nivel
    mov r11, [rsi + CASO_USUARIO_OFFSET]
    mov eax, [r11 + USUARIO_NIVEL_OFFSET]
    
    ; Calcular destino
    mov rdi, [r14 + rax*8]      ; array del nivel
    mov rcx, [r13 + rax*8]      ; índice actual en ese array
    imul rcx, CASO_SIZE
    add rdi, rcx                ; destino = array + índice*tamaño
    
    ; Copiar caso (puedes usar movs o loop manual)
    mov rcx, CASO_SIZE        ; copiar en chunks de 8 bytes
    rep movsb
    
    ; Incrementar contador del nivel
    inc qword [r13 + rax*8]
    
    inc r15
    jmp .llenar_loop
    
.fin:
    mov rax, r14        ; retornar segmentacion_t*
    
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;int contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int nivel)
; rdi = arreglo_casos
; esi = largo
; edx = nivel

;NO FUNCIONAAA
contar_casos_por_nivel:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Asignaciones
    mov rbx, rdi    ; rbx = errerglo_casos
    mov r12d, esi   ; r12d = largo
    mov r13d, edx   ; r13d = nivel
    xor r8, r8      ; contador/ indice

    .ciclo:
        cmp r8d, r12d   ; revisamos todo el arreglo?
        je .fin
        mov r14,[rbx + CASO_USUARIO_OFFSET] ; R14 = arreglo_casos[i]
        mov r9d, dword[r14 + USUARIO_NIVEL_OFFSET] ; r9d = arreglo_casos[i]->nivel

        ;comparamos si son del mismo nivel
        cmp r9d, r13d
        jne .sigo 

        ;Son iguales-> incremento
        inc eax 
        .sigo:
            add rbx, CASO_SIZE
            inc r8d
            jmp .ciclo
    .fin:
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret
