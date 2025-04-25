extern malloc
extern strLen
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
;dil= uint8_t capacity
strArrayNew:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Creamos la estructura str_array_t
    mov byte[rbp-8], dil                      ; guardamos la capacidad del array de strings  

    mov rdi, STR_ARRAY_OFFSET                 ; Tamaño de la estructura str_array
    
    call malloc                               ;tenemos el puntero de la nueva struc en rax
    cmp rax, 0 
    je .fin

    mov [rbp-16], rax                         ; guardamos el puntero a la struct

    ;Inicializamos str_array 

    mov dil, byte[rbp-8]
    mov byte[rax+SIZE_OFFSET], 0              ; Inicializamos size en 0
    mov byte [rax+CAPACITY_OFFSET], dil       ; inicializamos capacidad 
    
    movzx rdi, byte[rbp-8] 
    shl rdi, 3
    ;Puntero a puntero de capacity en rdi
    call malloc                               ; puntero rax para data

    cmp rax, 0
    je .fin
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
    mov [rbp-16], rsi                    ; guardo puntero al string *data

    ;YA ESTABA EN EL ARRAY DATA Y TRATABA DE ACCEDER A LOS OTROS ATRIBUTOS
    ;mov rdi, [rdi + DATA_OFFSET]         ; desrf. el puntero, estoy en strcut
    
    
    xor rcx,rcx
    
    ;Verificamos si hay capacidad
    movzx rsi, byte[rdi+SIZE_OFFSET]       ; obtenemos size 
    movzx rcx, byte[rdi + CAPACITY_OFFSET]  ; rcx=obtenemos la capacidad total        
    
    ; cmp x1,x2 => x1-x2
    cmp rcx, rsi                           ; Hay capacidad?
    jle .fin                              ; Si no capacidad, termina


    ;Vamos al final disponible

   ;Agregamos el puntero al array
    .Add_array:
        mov rdi, [rbp-8]
        mov rdi, [rdi+DATA_OFFSET]            ; rdi= **data
        
        shl rsi, 3                             
        add rdi, rsi                          ; Posicion del nuevo string
        mov rcx, rdi                 

        mov rdi, [rbp-16]
        call strClone           ;se clona el string, en rax tengo el punt. al string clonado

        mov [rcx], rax

        ;Incremento size 
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
 ;   push rbp
 ;   mov rbp, rsp
 ;   sub rsp, 32
 ;   mov [rbp-24], rsi
 ;   mov [rbp-16], cl
 ;   mov [rbp-8], rdi
 ;   call strArrayGet                    ; en rax esta el punt. a string              
    
 ;   mov [rbp-32], rax

    ; obtenemos el segundo punt
 ;   mov rdi, [rbp-8]
 ;   movzx rcx, byte[rbp-16]

 ;   call strArrayGet                    ; obtenemos es segundo punt.
 ;   push rax

 ;   pop rax

 ;   .fin:
 ;       pop rbp
        ret 

; void  strArrayDelete(str_array_t* a)
strArrayDelete:


