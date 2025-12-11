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

global  encontrarTesoroEnMapa

;bool encontrarTesoroEnMapa(Mapa *mapa, Recorrido *rec, uint64_t *acciones_ejecutadas)
; rdi = mapa
; rsi = recorrido
; rdx = acciones_ejecutadas 
encontrarTesoroEnMapa:
    push rbp
    mov rbp, rsp
    push rbx
    push r15
    push r14
    push r13
    push r12
    sub rsp, 16
    
    xor rax,rax
    mov rbx, rdi ; rbx = mapa 
    mov r15, rsi ; r15 = recorrido
    mov r14, rdx ; r14 = acciones_ejecutadas
    mov qword[rsp], 0
; 1. Chekeamos si el primer id de entrada, no contiene el tesoro
    mov r12d, dword[rbx + MAP_ID_ENTRADA_OFFSET] ; r12 = mapa.id_entrada

    mov r13, [rbx + MAP_HABITACIONES_OFFSET] ; R13 = mapa.habitaciones
    mov rax, r12
    imul rax, HAB_SIZE ; id_entrada*HAB_SIZE
    add rax, r13 ; RAX = mapa.habitaciones + id_entrada*HAB_SIZE

    mov al, byte[rax + HAB_CONTENIDO_OFFSET  + CONT_ES_TESORO_OFFSET] ; mapa.habitaciones[i].contenido.es_tesoro    
    cmp al, 0 
    jne .fin_encontrado

    xor r10,r10
    ; Chequeamos los vecinos
    mov r8, [r15 + REC_CANT_ACCIONES_OFFSET] ; r8 = recorrido.cant_acciones
    mov rsi, [r15 + REC_ACCIONES_OFFSET] ; rsi = recorrido.acciones
    
    .loop:
        cmp r10, r8
        je .no_encontrado

        mov rax, r12              ; hab_actual
        imul rax, HAB_SIZE         
        add rax, r13               ; RAX = hab_actual* HAB_SIZE + 

        mov r9d, dword[rsi + 4*r10] ; r9d = recorrido.acciones[i]
        mov ecx, [rax + HAB_VECINOS_OFFSET + r9*4] ; ECX = mapa.habitaciones[id_entrada].vecinos[j]


        cmp ecx, 99
        je .no_encontrado ; si mapa.habitaciones[id_entrada].vecinos[j] == 99 -> no hay tesoro

        inc qword[rsp]
        ; Vecino ahora es id
        mov rax, rcx
        imul rax, HAB_SIZE
        add rax, r13        ; rax = mapa.habitacion + id_vecino*HAB_SIZE

        mov al, byte[rax + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET]

        cmp al, 1
        je .fin_encontrado

        inc r10
        mov r12d, ecx
        jmp .loop

        .fin_encontrado:
            mov rax, 1
            jmp .fin

        .no_encontrado:
            xor rax,rax


    .fin:
    mov rsi, qword[rsp]
    mov [r14], rsi
    add rsp, 16
    pop r12
    pop r13 
    pop r14 
    pop r15
    pop rbx
    pop rbp
    ret






; /*

; typedef struct {
;     Habitacion *habitaciones;   // Puntero a un array
;     uint64_t n_habitaciones;
;     uint32_t id_entrada;
; } Mapa;
; ```

; **¿Qué es `habitaciones`?**

; Es un **puntero a un array de estructuras `Habitacion`**, NO un array de punteros.

; ### Visualización en memoria:
; ```
; Mapa en memoria:
; ┌──────────────┐
; │ habitaciones │ → apunta a → ┌─────────────────┐
; │              │              │ Habitacion [0]  │ ← 132 bytes
; │              │              │   id: 0         │
; │              │              │   vecinos[4]    │
; │              │              │   contenido     │
; │              │              │   visitas       │
; ├──────────────┤              ├─────────────────┤
; │n_habitaciones│              │ Habitacion [1]  │ ← 132 bytes
; ├──────────────┤              │   id: 1         │
; │  id_entrada  │              │   vecinos[4]    │
; └──────────────┘              │   contenido     │
;                               │   visitas       │
;                               ├─────────────────┤
;                               │ Habitacion [2]  │ ← 132 bytes
;                               │   ...           │
;                               └─────────────────┘


; ------------------------------------------------

; typedef struct {
;     Habitacion **habitaciones;  // Array de punteros ← ¡Nota los dos asteriscos!
;     uint64_t n_habitaciones;
;     uint32_t id_entrada;
; } MapaConPunteros;
; ```

; ### Visualización en memoria:
; ```
; MapaConPunteros en memoria:
; ┌──────────────┐
; │ habitaciones │ → apunta a → ┌─────────┐
; │              │              │puntero 0│ → ┌─────────────┐
; │              │              ├─────────┤   │Habitacion 0 │
; │              │              │puntero 1│   └─────────────┘
; ├──────────────┤              ├─────────┤      
; │n_habitaciones│              │puntero 2│ → ┌─────────────┐
; ├──────────────┤              └─────────┘   │Habitacion 2 │
; │  id_entrada  │                             └─────────────┘
; └──────────────┘






; */