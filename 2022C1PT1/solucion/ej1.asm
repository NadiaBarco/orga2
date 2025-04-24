extern malloc
extern strClone
extern strArrayGet
global strArrayNew
global strArrayGetSize
global strArrayAddLast
global strArraySwap
global strArrayDelete

;########### SECCION DE DATOS
section .data
SIZE_OFFSET EQU 0

CAPACITY_OFFSET EQU 8 

DATA_OFFSET EQU 16
STR_ARRAY_OFFSET EQU 24  ;TOTAL TAMAÑO DE LA ESTRUCTURA
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; str_array_t* strArrayNew(uint8_t capacity)
strArrayNew:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Creamos la estructura str_array_t
    mov byte[rbp-8], dil                      ; guardamos la capacidad del array de strings  

    mov rdi, STR_ARRAY_OFFSET                 ; Tamaño de la estructura str_array
    
    call malloc                               ;tenemos el puntero de la nueva struc en rax


    mov [rbp-16], rax                         ; guardamos el puntero a la struct

    ;Inicializamos str_array 
    mov rdi,0
    mov dil, byte[rbp-8]
    mov byte[rax+SIZE_OFFSET], 0              ; Inicializamos size en 0
    mov byte [rax+CAPACITY_OFFSET], dil       ; inicializamos capacidad
    
    movzx rdi, byte[rbp-8] 
    shl rdi, 3
    ;Puntero a puntero de capacidad en rdi
    call malloc                               ; puntero rax para data

    ; Inicializamos data
    mov rsi,[rbp-16]                          
    mov [rsi + DATA_OFFSET], rax

    ;Traemos el puntero de la nueva estructura
    mov rax, [rbp-16]
.fin:
    add rsp, 16
    pop rbp
    ret



; uint8_t  strArrayGetSize(str_array_t* a)
strArrayGetSize:
    push rbp
    mov rbp,rsp

    mov al, byte[rdi+SIZE_OFFSET]

    .fin:
        pop rbp
        ret


; void  strArrayAddLast(str_array_t* a, char* data)
; rdi = str_array_t* a
; rsi= char *data
strArrayAddLast:
    push rbp
    mov rbp,rsp                          ; stack frame armado
    sub rsp, 16
    mov [rbp-8], rdi                     ; guardo el puntero al struct
    mov rdi, [rdi + DATA_OFFSET]         ; desrf. el puntero, estoy en strcut
    
    ;Verificamos si hay capacidad
    movzx rsi, byte[rdi+SIZE_OFFSET]       ; obtenemos size 
    movzx rcx, byte[rdi + CAPACITY_OFFSET]  ; obtenemos la capacidad total        
    
    ; cmp x1,x2 => x1-x2
    cmp rsi, rcx                          ; Hay capacidad?
    jz .fin                              ; Si no capacidad, termina

    ;Vamos al final disponible
    .ciclo:
        cmp rsi,0
        je .Add_array

        ; No llegamos a un puntero disponible
        dec rsi 
        add rdi,8           
        jmp .ciclo
    
    .Add_array:
        mov rcx, rdi
        mov rdi,rsi
        call strClone
    
    mov rdi,[rbp-8]
    add byte[rdi+SIZE_OFFSET], 1

    .fin:
    add rsp,16
    pop rbp
    ret
; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
; rdi = str_array_t* a
; sil= i
;  cl= j
strArraySwap:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp-24], rsi
    mov [rbp-16], cl
    mov [rbp-8], rdi
    call strArrayGet                    ; en rax esta el punt. a string              
    
    mov [rbp-32], rax

    ; obtenemos el segundo punt
    mov rdi, [rbp-8]
    movzx rcx, byte[rbp-16]

    call strArrayGet                    ; obtenemos es segundo punt.
    push rax

    pop rax

    .fin:
        pop rbp
        ret 

; void  strArrayDelete(str_array_t* a)
strArrayDelete:


