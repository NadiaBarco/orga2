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

; Notar que el enum aparece como puntero, entonces no afecta los offsets

global  sumarTesoros

sumarTesoros:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; ════════════════════════════════════════
    ; Guardar parámetros en registros callee-saved
    ; ════════════════════════════════════════
    mov rbx, rdi                ; rbx = mapa
    mov r12d, esi               ; r12d = actual (¡NO uses eax!)
    mov r15, rdx                ; r15 = visitado
    
    ; ════════════════════════════════════════
    ; CASO BASE 1: Verificar índice válido
    ; ════════════════════════════════════════
    mov rax, [rbx + MAP_N_HABITACIONES_OFFSET] ;rax = mapa->n_habitaciones
    cmp r12, rax
    jae .retornar_cero          ; Si actual >= n_habitaciones
    
    ; ════════════════════════════════════════
    ; CASO BASE 2: Verificar si ya visitada
    ; ════════════════════════════════════════
    movzx eax, byte [r15 + r12]     ; eax = visitado[actual]
    test al, al
    jnz .retornar_cero          ; Si visitado[actual] != 0
    
    ; ════════════════════════════════════════
    ; Marcar como visitada
    ; ════════════════════════════════════════
    mov byte [r15 + r12], 1
    
    ; ════════════════════════════════════════
    ; Calcular dirección de habitaciones[actual]
    ; ════════════════════════════════════════
    mov r14, [rbx + MAP_HABITACIONES_OFFSET]    ; r14 = mapa->habitaciones
    mov rax, r12                ; Copiar actual a rax
    imul rax, HAB_SIZE
    add rax, r14                ; rax = &habitaciones[actual] = mapa->habitaciones + actual*HAB_SIZE
    
    ; ════════════════════════════════════════
    ; Inicializar suma = 0
    ; ════════════════════════════════════════
    xor r13d, r13d              ; r13d = suma = 0
    
    ; ════════════════════════════════════════
    ; Verificar si tiene tesoro
    ; ════════════════════════════════════════
    movzx ecx, byte [rax + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET];ecx = mapa->habitacion[actual].contenido.es_tesoro
    test cl, cl
    jz .loop_vecinos            ; Si no tiene tesoro, ir al loop
    
    ; Tiene tesoro, leer valor
    mov r13d, [rax + HAB_CONTENIDO_OFFSET + CONT_VALOR_OFFSET]
    
.loop_vecinos:
    ; ════════════════════════════════════════
    ; Recorrer los 4 vecinos
    ; ════════════════════════════════════════
    xor r8, r8                  ; r8 = i = 0
    
.loop:
    cmp r8, 4                   ; i < 4
    jge .fin
    
    ; Calcular dirección de habitaciones[actual] otra vez
    ; (porque RAX se modifica en cada iteración)
    mov rax, r12
    imul rax, HAB_SIZE
    add rax, r14                ; rax = &habitaciones[actual]
    
    ; Leer vecinos[i]
    mov r9d, [rax + HAB_VECINOS_OFFSET + r8*4]
    
    ; Verificar si es válido
    cmp r9d, 99
    je .siguiente
    
    ; ════════════════════════════════════════
    ; LLAMADA RECURSIVA
    ; ════════════════════════════════════════
    mov rdi, rbx                ; arg1: mapa
    mov esi, r9d                ; arg2: vecino
    mov rdx, r15                ; arg3: visitado
    call sumarTesoros
    
    ; Acumular resultado
    add r13d, eax               ; suma += resultado
    
.siguiente:
    inc r8
    jmp .loop
    
.fin:
    ; ════════════════════════════════════════
    ; Retornar suma acumulada
    ; ════════════════════════════════════════
    mov eax, r13d               ; return suma
    jmp .salir
    
.retornar_cero:
    xor eax, eax                ; return 0
    
.salir:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

