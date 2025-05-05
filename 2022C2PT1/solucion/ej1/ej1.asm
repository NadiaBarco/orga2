global agrupar
extern strcat
extern realloc
extern malloc
;########### SECCION DE DATOS
section .data
MAX_TAGS EQU 4
TEXT_OFFSET EQU 0
TEXT_LEN_OFFSET EQU 8
TAG_OFFSET EQU 16
MSG_T_OFFSET EQU 24
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;char** agrupar(msg_t *msgArr, size_t msgArr_len);
;rdi= msg_t *msgArr
;esi = msgArr_len
agrupar:
    push rbp
    mov rbp,rsp         ;stack grame armado
    sub rsp, 16
    mov [rbp-8], rdi
    push r12

    push r13
    push r14

    xor r12,r12
    xor r11,r11
    xor r13,r13

    mov r14, rdi
    ;Es un array vacio
    cmp rdi,0
    je .fin
    ;Armamos el array de tamaño MAX_TAGS
    mov rax, MAX_TAGS
    shl rax,3

    mov rdi, rax
    call malloc         ; tenemos en rax= char**

    mov [rbp-16], rax   ; guardamos el puntero del nuevo array


    ;calculamos el len de cada text


















    ; Armemos los string

    .ciclo:
        cmp r13d, esi    ;Hay mas strcuts por recorrer?
        je .fin         ; No, termina

        mov r14, [rbp-8]   ;puntero del array
        mov r12d, dword[r14 + TAG_OFFSET]     ; 

        ;A que tag pertenece?
        cmp r12d, 0
        je .tag0

        cmp r12d, 1
        je .tag1

        cmp r12d, 2
        je .tag2

        cmp r12d, 3
        je .tag3


        .tag0:
            mov r11, [r14+TEXT_OFFSET]

    
 .fin:
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
