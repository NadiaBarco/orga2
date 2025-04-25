extern malloc
extern strDelete
extern free
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

CAPACITY_OFFSET EQU 1 

DATA_OFFSET EQU 8
STR_ARRAY_OFFSET EQU 16  ;TOTAL TAMAÑO DE LA ESTRUCTURA
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; str_array_t* strArrayNew(uint8_t capacity)
; dil= uint8_t capacity
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
    
    movzx rdi, dil 
    shl rdi, 3
    ;Puntero de capacity*8 bytes en rdi
    call malloc                               ; puntero rax para data
    cmp rax, 0                                ; No hay memoria a asignar?
    je .noHayMem                              ; No hay, libero y termino

    ; Inicializamos data
    mov rsi,[rbp-16]                          
    mov [rsi + DATA_OFFSET], rax

    ;Traemos el puntero de la nueva estructura
    mov rax, [rbp-16]
    jmp .fin
    
    .noHayMem:
        mov rdi, [rbp-16]
        call free
        xor rax,rax
        jmp .fin

.fin: 
    add rsp, 16
    pop rbp
    ret



; uint8_t  strArrayGetSize(str_array_t* a)
strArrayGetSize:
    push rbp
    mov rbp,rsp

    cmp rdi,0
    jnz .noEsNull
    xor al, al 
    jmp .fin
    .noEsNull:
        movzx rax, byte[rdi+SIZE_OFFSET]
    

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
    push r12
    mov [rbp-8], rdi                     ; guardo el puntero al struct
    mov [rbp-16], rsi                    ; guardo puntero al string *data
    xor r12,r12

    ;YA ESTABA EN EL ARRAY DATA Y TRATABA DE ACCEDER A LOS OTROS ATRIBUTOS
    ;mov rdi, [rdi + DATA_OFFSET]         ; desrf. el puntero, estoy en strcut
    
    ;rdi no es un puntero vacio?
    mov rcx,[rdi]
    cmp rcx, 0
    je .fin

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

        mov r12, rdi                 

        mov rdi, [rbp-16]
        call strClone           ;se clona el string, en rax tengo el punt. al string clonado

        mov [r12], rax

        ;Incremento size 
        mov rdi,[rbp-8]             
        add byte[rdi+SIZE_OFFSET], 1
        
    .fin:
    pop r12
    add rsp,16
    pop rbp
    ret



; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
; rdi = str_array_t* a
; sil= i
; cl= j
strArraySwap:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    push r11
    push r12
    mov byte[rbp-24], cl
    mov byte[rbp-16], sil
    mov [rbp-8], rdi
    
    ;Tomamos el i-esimo elemento, rdi= str_array_t *a y sil=i
    call strArrayGet                                  
    
    mov [rbp-32], rax               ; en rax esta el punt.i a string

    ; Asumo que rdi esta en la pos. del elemento por como esta hecha la funcion strArrayGet
    mov r11,rdi
    ; Buscamos el j-esimo puntero
    mov rdi, [rbp-8]
    movzx rcx, byte[rbp-16]         

    call strArrayGet                    ; obtenemos es segundo punt.

    mov r12, [rbp-32]

    mov [r11], rax

    mov [rdi],r12
    pop r12
    pop r11
    .fin:
        pop rbp
        ret 

; void  strArrayDelete(str_array_t* a)
;rdi= str_array_t* a
strArrayDelete:
    push rbp
    mov rbp, rsp            ; stack frame armado
    sub rsp, 16
    push r11 
    push r12
    push r13
    ;Lipiamos registros
    xor r13, r13
    xor r12,r12
    xor r11, r11

    mov [rbp-8], rdi
    ;verificamos si el puntero ya es NULL
    mov rsi, [rdi]
    cmp rsi, 0
    je .fin

    ;Vamos a data y eliminamos el array de punteros 
    movzx r11, byte[rdi + SIZE_OFFSET]   ; cant. de iteraciones
    mov rdi, [rdi+DATA_OFFSET]           ; Obtenemos *data, el primer puntero al string
    

    ; r12= contador ^ r11= a->size
    .ciclo:
        cmp r12, r11                    ; Liberamos todos los elementos?
        je .fin                         ; Sin elem, termino

        call strDelete

        inc r12
        add rdi, 8

        jmp .ciclo

    
    ;Eliminamos la estructura
    mov rdi, [rbp-8]
    call free

    
    pop r13
    pop r12
    pop r11
 .fin:
    add rsp, 16
    pop rbp
    ret

    

