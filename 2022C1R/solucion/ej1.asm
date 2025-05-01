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
    xor rax,rax
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
        inc rax               ; Incrementar contador de vocales

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
    push r12
    push r13

    movzx r12, dil
    mov rax, OFFSET_LETTERS_QUANTITY
    mul r12
    mov rdi, rax

    call malloc 
    ;cmp rax, 0          ;hay memoria?
    ;je .fin             ; No hay memoria, termina
    
    
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
    pop r13
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
    push r15
    push r14
    push r13
    push r12

    movzx r9, sil 

    ; Chequeamos que no sea un puntero null
    cmp rdi, 0              ;Es un puntero nulo?
    je .fin                 ; Si lo es, no hago nada
    
    mov r14, rdi
    movzx r13, byte[r14+OFFSET_VOWELS_QTY] ; accedemos al vowels_qty
    mov r15, [r14 + OFFSET_WORD]           ; Guardamos el puntero a word
    sub r9,1
    .ciclo:
        cmp r9, 0           ;Llegue al final de arreglo?
        je .copia_string 

        ;Tomamos el prox elem a comparar
        add r14, OFFSET_LETTERS_QUANTITY
        movzx r12, byte[r14 + OFFSET_VOWELS_QTY]

        ; max_vowels > wq_array[r14].vowels_qty
        cmp r13, r12
        jge .siguiente

        mov r13,r12         ; r13 = con mayor consonantes
        dec r9              ; r9= len(array) - 1
            
        mov r15, r14        ; reemplazo la dirr por la estructura mayor

        jmp .ciclo

        .siguiente:
            dec r9
            jmp .ciclo




        .copia_string:
            mov rdi, [r15 + OFFSET_WORD]
            call strClone
 .fin:
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret
    
