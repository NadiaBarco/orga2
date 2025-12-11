; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------
extern malloc
section .data

section .text

; COMPLETAR las definiciones (serán revisadas por ABI enforcer):
; ------------------------
; Contenido
; ------------------------
CONT_NOMBRE_OFFSET      EQU 0        ; char nombre[64]
CONT_VALOR_OFFSET       EQU 64       ; uint32_t valor
CONT_COLOR_OFFSET       EQU 68       ; char color[32]
CONT_ES_TESORO_OFFSET   EQU 100      ; bool es_tesoro
CONT_PESO_OFFSET        EQU 104      ; float peso 
CONT_SIZE               EQU 108      ; sizeof(Contenido) (rounded)

; ------------------------
; Habitacion
; ------------------------
HAB_ID_OFFSET          EQU 0         ; uint32_t id
HAB_VECINOS_OFFSET     EQU 4        ; uint32_t vecinos[ACC_CANT] (4 entradas)
HAB_CONTENIDO_OFFSET   EQU 20      ; Contenido contenido (aligned to 4)
HAB_VISITAS_OFFSET     EQU 128       ; uint32_t visitas
HAB_SIZE               EQU 132       ; sizeof(Habitacion)

; ------------------------
; Mapa
; ------------------------
MAP_HABITACIONES_OFFSET    EQU 0     ; Habitacion *habitaciones  (pointer, 8 bytes)
MAP_N_HABITACIONES_OFFSET  EQU 8     ; uint64_t n_habitaciones       (8 bytes)
MAP_ID_ENTRADA_OFFSET      EQU 16    ; uint32_t id_entrada         (4 bytes)
MAP_SIZE                   EQU 24    ; sizeof(Mapa) (padded to 8)

; ------------------------
; Recorrido
; ------------------------
REC_ACCIONES_OFFSET        EQU 0     ; Accion *acciones  (pointer, 8 bytes)
REC_CANT_ACCIONES_OFFSET   EQU 8     ; uint64_t cant_acciones (8 bytes)
REC_SIZE                  EQU 16     ; sizeof(Recorrido)


; Nos olvidamos que el float es de 4 bytes y para alinear los 
;estructuras es su tamaño pero se alinea con el atributo mas grande

; Notar que el enum aparece como puntero, entonces no afecta los offsets

;Recorrido *invertirRecorridoConDirecciones(const Recorrido *rec, uint64_t len);
; rdi = recorrido
; rsi = len 
global  invertirRecorridoConDirecciones
invertirRecorridoConDirecciones:
    push rbp
    mov rbp, rsp 
    push rbx
    push r15
    push r14
    push r13
    push r12 
    sub rsp, 8

    mov rbx, rdi    ; rbx = recorrido
    mov r15, rsi    ; r15 = len
    xor r12, r12
    ; Armmamos una nueva struct para el output Recorrdio*
    cmp r15, 0
    je .fin

    cmp rbx, 0
    je .fin

    mov rdi, REC_SIZE
    shl rdi, 3
    call malloc ; rax = rcorrido*
    mov r12, rax ; r12 = *Recorrido

    ; ARmamos el array de acciones
    mov rdi, r15
    shl rdi, 2

    call malloc

    ; Unimos la estructura recorrido con el array 
    mov [r12 + REC_ACCIONES_OFFSET], rax    ; r12 = new_recorrido->acciones SON UINT32_T
    mov r10,[rbx + REC_CANT_ACCIONES_OFFSET]
    mov [r12 + REC_CANT_ACCIONES_OFFSET], r10 ; new_recorrido->can_acciones = recorrido->cant_acciones

    ;mov r13,[r12 + REC_ACCIONES_OFFSET] ; R13 = new_recorrido->acciones[i]
    mov r14, [rbx + REC_ACCIONES_OFFSET] ;r14 = recorrido->acciones
    xor r10,r10

    xor r8,r8
    mov r10, r15    ; r10 = len
    sub r10,1
    .loop:
        cmp r8, r15     ; hay camino por recorrer?
        je .fin 

        mov r9d, dword[r14 + r8*4]    ; r9 = recorrido->acciones[i]

        cmp r9d, 0 ; es norte
        je .de_norte_a_sur

        cmp r9d, 1  ; es sur
        je .de_sur_a_norte

        cmp r9d, 2  ; es este
        je .de_este_a_oeste

        ; de_oeste_a_este
        mov dword[rax + r10*4], 2

        .siguiente_paso:
            sub r10, 1
            inc r8
            jmp .loop

        .de_norte_a_sur:

            mov dword[rax + r10*4],1
            jmp .siguiente_paso
        .de_sur_a_norte:

            mov dword[rax + r10*4],0
            jmp .siguiente_paso
        .de_este_a_oeste:

            mov dword[rax + r10*4],3
            jmp .siguiente_paso



 .fin:
    mov rax, r12
    add rsp, 8
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbx 
    pop rbp
    ret
    
    
