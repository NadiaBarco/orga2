global templosClasicos
global cuantosTemplosClasicos
extern malloc
section .data
OFFSET_COLUMN_LARGO EQU 0
OFFSET_NOMBRE EQU 8
OFFSET_COLUMN_CORTO EQU 16
OFFSET_TEMPLO EQU 24

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;templo* templosClasicos(templo *temploArr, size_t temploArr_len);
templosClasicos:
    push rbp
    mov rbp, rsp
    push r13
    push r12    ;r12=contador 
    push r11    ; 
    push r14
    push r15
    
    push rbx

    mov rbx, rdi
    call cuantosTemplosClasicos

    mov r12d, eax           ; r12d = cant de templos clasicos 

    ;Armamos el array de templos_clasicos
    mov edi, r12d       
    ; multiplicamos por el tamaño de la estructura
    mul edi, OFFSET_TEMPLO
    call malloc 
    mov r11,rax             ; r11 =puntero al nuevo array 

    .ciclo:
        cmp r12d, 0         ; Quedan templos por recorrer?
        je .fin

        movzx r13, byte[rbx + OFFSET_COLUMN_CORTO]
        movzx r14, byte[rbx + OFFSET_COLUMN_LARGO]

        shl r13, 1
        add r13, 1

        cmp r13, r14
        jne .siguiente

        

         




    pop rbx
    pop r15
    pop r14
    pop r11
    pop r12
    pop r13
    pop rbp
    ret


;uint32_t cuantosTemplosClasicos(templo *temploArr, size_t temploArr_len)
; rdi= templo *temploArr
; rsi = temploArr_len

cuantosTemplosClasicos:
push rbp
mov rbp, rsp

push r12
push r13
push rbx
sub rsp, 8  ; ALINEADA
xor rax,rax
mov rbx, rdi

; RECORRO EL ARRAY
.ciclo:
    ; el puntero al array es nulo?
    cmp rbx, 0
    je .fin


    ; llegamos al final de la lista?
    cmp rsi, 0      
    jmp .fin

    ;verifico que sea un templo clasico
    movzx r12, byte[rbx + OFFSET_COLUMN_CORTO]    ; cargo N columna corta
    movzx r13, byte[rbx + OFFSET_COLUMN_LARGO]    ; cargo M columna larga

    ; Templo Clasico
    shl r12, 1
    add r12 ,1

    cmp r12, r13
    jne .siguiente

    add eax,1
    add rbx, OFFSET_TEMPLO
    dec rsi
    jmp .ciclo

    .siguiente:
        add rbx, OFFSET_TEMPLO
        dec rsi
        jmp .ciclo 

.fin:
    pop rbx
    pop r13
    pop r12
    pop rbp
    ret