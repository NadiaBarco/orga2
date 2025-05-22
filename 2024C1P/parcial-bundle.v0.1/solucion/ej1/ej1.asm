section .text

; typedef struct {
; // Puntero a la función que calcula z (puede ser distinta para cada nodo):
; uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size);
; // Coordenadas del nodo en la escena:
; uint8_t x;
; uint8_t y;
; uint8_t z;
; nodo_display_list_t* siguiente;  Puntero al nodo siguiente
; } nodo_display_list_t;
NODO_DISPLAY_PRIMITIVA EQU 0
NODO_DISPLAY_X EQU 8
NODO_DISPLAY_Y EQU 9
NODO_DISPLAY_Z EQU 10
NODO_DISPLAY_SIGUIENTE EQU 16
NODO_DISPLAY_SIZE EQU 24


; typedef struct {
; uint8_t table_size;
; nodo_ot_t** table;
; } ordering_table_t;
ORDERING_TABLE_TABLE_SIZE EQU 0
ORDERING_TABLE_NODO_OT EQU 8
ORDERING_TABLE_SIZE EQU 16

; typedef struct {
; nodo_display_list_t* display_element;
; nodo_ot_t* siguiente;
; } nodo_ot_t;
NODO_OT_NODO_DISPLAY_LIST EQU 0
NODO_OT_NODO_SIGUIENTE EQU 8
NODO_OT_SIZE EQU 16


global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
inicializar_OT_asm:
 push rbp
 mov rbp, rsp
 push rbx
 push r15


; Armamos la estructura
 movzx r15, dil
 mov rdi, ORDERING_TABLE_SIZE

 call malloc
 mov rbx, rax

 mov byte[rbx + ORDERING_TABLE_TABLE_SIZE], r15b

 cmp r15b, 0
 jnz .init_array

 mov qword[rbx + ORDERING_TABLE_NODO_OT],0
 jmp .fin
 .init_array:
    ; inicializamos el array de tablas
    movzx rdi, r15b
    shl rdi, 3
    call malloc

    mov [rbx + ORDERING_TABLE_NODO_OT], rax

;inicializamos los punteros a null
.ciclo:
    cmp r15b,0
    je .fin

    mov qword[rax], 0
    add rax,8
    dec r15b
    jmp .ciclo
.fin:
 mov rax, rbx
 pop r15
 pop rbx
 pop rbp
 ret

; void calcular_z(nodo_display_list_t* nodo, uint8_t z_size)
calcular_z_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r15
    push r14
    push r13

    mov rbx, rdi
    mov r14b, sil

    ;tomamos la funcion primitiva
    mov r13, [rbx + NODO_DISPLAY_PRIMITIVA]
    mov dil, BYTE[rbx + NODO_DISPLAY_X]
    mov sil, byte[rbx + NODO_DISPLAY_Y]
    mov dl, r14b

    call r13        

    mov byte[rbx + NODO_DISPLAY_Z], al


    pop r13
    pop r14
    pop r15
    pop rbx
    pop rbp
    ret

; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) 
; RDI = ordering_table_t* ot
; RSI = nodo_display_list_t* display_list
ordenar_display_list_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r15
    push r14
    push r13
    push r12


    mov rbx, rdi    ; rbx= ordering_table_t* ot
    mov r15, rsi    ; rdi = nodo_display_list_t* display_list
    mov r14b, byte[rbx + ORDERING_TABLE_TABLE_SIZE] ; tomamos el z_size
    mov r13, [rbx + ORDERING_TABLE_NODO_OT] ; ot->table 
    .ciclo:
        cmp r15, 0
        je .fin
        mov rdi, r15
        mov sil, r14b
        call calcular_z_asm     ; CON Z CALCULADO, LO OBTENEMOS PARA USARLO COMO INDICE


        movzx r8, byte[r15 + NODO_DISPLAY_Z]    ; idx = idx*8

        cmp r8b, r14b           ; Comparar z con z_size
        jae .siguiente          ; Si z >= z_size, saltar este nodo

        ;inicializamos nodo_ot_t
        mov rdi, NODO_OT_SIZE
        call malloc                             ; rax = *nodo_ot_t

        mov [rax + NODO_OT_NODO_DISPLAY_LIST], r15  ; nodo_ot->display_element = display_list
        mov QWORD[rax + NODO_OT_NODO_SIGUIENTE], 0  ; nodo_ot->siguiente = NULL

        mov r12, qword[r13 + 8*r8] 
        cmp r12, 0
        jnz .buscar_ultimo
        mov qword[r13+8*r8], rax                ;ot->table[idx]->nodo_ot
        jmp .siguiente
        .buscar_ultimo:
            
            cmp qword[r12+NODO_OT_NODO_SIGUIENTE], 0
            je .insertar_nodo_ot

            mov r12, [r12 + NODO_OT_NODO_SIGUIENTE]
            jmp .buscar_ultimo

        .insertar_nodo_ot:
            mov [r12 + NODO_OT_NODO_SIGUIENTE], rax
            jmp .siguiente
        
        
        
        ; hacemos lo mismo para los nodos siguientes
        .siguiente:
            mov r15, [r15 + NODO_DISPLAY_SIGUIENTE]
            jmp .ciclo


 .fin:
    xor rax, rax
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbx
    pop rbp
    ret

