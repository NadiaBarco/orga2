;########### LISTA DE FUNCIONES IMPORTADAS
extern strPrint
extern strDelete
extern strClone

extern malloc
extern free
extern fprintf

global countVowels
global createLettersQuantityArray
global getMaxVowels
;########### SECCION DE DATOS
section .data
OFFSET_CONSONANTS_QTY EQU 0
OFFSET_WORD EQU 8
OFFSET_VOWELS_QTY EQU 16

OFFSET_LETTERS_QUANTITY EQU 24
;########### SECCION DE TEXTO (PROGRAMA)
section .text


%define LQ_SIZE 24

%define LETTER_A 0x61
%define LETTER_E 0x65
%define LETTER_I 0x69
%define LETTER_O 0x6F
%define LETTER_U 0x75
; rdi, rsi, rdx, rcx, r8, and r9.

; uint8_t countVowels(char* word);
countVowels:
    push rbp
    mov rbp,rsp
    xor al,al
    .ciclo:
        mov dl, byte[rdi]
        cmp dl, 0
        je .fin

        cmp dl, LETTER_A      ; ¿Es 'a'?
        je .es_vocal
        cmp dl, LETTER_E      ; ¿Es 'e'?
        je .es_vocal
        cmp dl, LETTER_I      ; ¿Es 'i'?
        je .es_vocal
        cmp dl, LETTER_O      ; ¿Es 'o'?
        je .es_vocal
        cmp dl, LETTER_U      ; ¿Es 'u'?
        je .es_vocal

        jmp .sigo             ; No es vocal, continuar
        
    .es_vocal:
        inc al                ; Incrementar contador de vocales

    .sigo:
        inc rdi
        jmp .ciclo
        

.fin:
    pop rbp
    ret


;letters_quantity_t* createLettersQuantityArray(uint8_t size);
createLettersQuantityArray:
    push rbp
    mov rbp,rsp
    sub rsp,16
    mov byte[rbp-8], dil
    push r12

    movzx r12, dil
    mov rax, OFFSET_LETTERS_QUANTITY
    mul dil
    mov rdi, rax

    call malloc 
    cmp rax, 0          ;hay memoria?
    je .fin             ; No hay memoria, termina
    
    
    mov [rbp-16], rax        ;Guardamos el puntero al array

    .ciclo:
        cmp r12, 0      ;Inicializamos todas las structs?
        je  .fin            ; Si, termina

        ; Inicializamos letters_quantity_t
        mov byte[rax + OFFSET_CONSONANTS_QTY], 0
        mov qword[rax + OFFSET_WORD],0
        mov byte[rax + OFFSET_VOWELS_QTY], 0 

        ; Vamo a la siguiente posiscion 
        add rax, OFFSET_LETTERS_QUANTITY
        dec r12
        jmp .ciclo


    .fin:
        mov rax, [rbp-16]
        pop r12
        add rsp, 16
        pop rbp
        ret

; char* getMaxVowels(letters_quantity_t* wq_array, uint8_t array_size);
;rdi= *wq_array
;sil = array_size
getMaxVowels:
    push rbp
    mov rbp,rsp
    sub rsp,16
    push r11
    push r12

    xor r12,r12
    xor r11,r11

    movzx r9, sil 

    mov r11, rdi          ; r11= estoy en el struc
    cmp r11, 0              ;Es un puntero nulo?
    je .fin                 ; Si lo es no hago nada
    
    mov [rbp-8],rdi
    add r11, [r11+OFFSET_VOWELS_QTY] ; accedemos al vowels_qty
    
    ;Tomamos el prox elem a comparar
    add rdi, OFFSET_LETTERS_QUANTITY
    mov r12, [rdi + OFFSET_VOWELS_QTY]

    sub r9,2
    .ciclo:
        cmp r9, 0           ;Llegue al final de arreglo?
        je .fin 

        cmp r11, r12
        jle .esMenor

        ;mov [rbp-8], rdi     ;Puntero a la estructura
        add rdi, OFFSET_LETTERS_QUANTITY
        movzx r12, byte[rdi + OFFSET_VOWELS_QTY]
        dec r9
        jmp .ciclo

        .esMenor:
            mov r11,r12
            dec r9
            ;add rdi, OFFSET_LETTERS_QUANTITY
            mov [rbp-8], rdi
            movzx r12, byte[rdi + OFFSET_VOWELS_QTY]
            jmp .ciclo


 .fin:
    mov rax, [rbp-8]
    add rsp,16
    pop r12
    pop r11
    pop rbp
    
