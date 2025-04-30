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
    push r12    ;r12=   puntero al nuevo array
    push r11    ; r11 puntero al nuevo array
    push r14    
    push r15
    push rbx    ; Puntero al array de templos
    sub rsp, 16

    

    mov rbx, rdi                    ;rbx= puntero a temploArr
    ;mov rcx, rsi                    ; rcx = tamaño de temploArr
    call cuantosTemplosClasicos     ; rax = cant de templos clasicos
    ;Armamos el tamaño de nuevo array de templos_clasicos
    mov r12d,eax
    mov r8d, OFFSET_TEMPLO    
    ; multiplicamos por el tamaño de la estructura
    mul r8d
    
    mov rdi, rax
    call malloc             ; Tenemos el puntero al nuevo array 
    mov r11,rax             ; r11 =puntero al nuevo array 
    mov [rbp-8],rax
    .ciclo:
        cmp r12d, 0         ; Quedan templos por recorrer?
        je .fin

        movzx r13, byte[rbx + OFFSET_COLUMN_CORTO]
        movzx r14, byte[rbx + OFFSET_COLUMN_LARGO]

        shl r13, 1
        add r13, 1

        cmp r13, r14        ; 2 * N + 1 = M
        jne .siguiente

        ; Agrego el templo clasico al nuevo array
        mov r15b, [rbx + OFFSET_COLUMN_CORTO]       ; r15b = temploArr[rbx]->column_corto
        mov [r11 + OFFSET_COLUMN_CORTO], r15b       ; newArray[r11]->colum_corto = r15b

        mov r15b, [rbx + OFFSET_COLUMN_LARGO]     
        mov [r11 + OFFSET_COLUMN_LARGO], r15b

        ; Reservamos memoria para el nombre    
        mov rdi, [rbx + OFFSET_NOMBRE]         ; rdi= puntero a char a clonar
        
        
        cmp rdi, 0 
        je .strVacio
        
        call strClone                         ; rax = puntero al string 
        
        mov [r11 + OFFSET_NOMBRE], rax

        ;Vamos al siguiente templo

        add r11, OFFSET_TEMPLO
        add rbx, OFFSET_TEMPLO
        dec r12d
        jmp .ciclo

        .siguiente:
            add rbx, OFFSET_TEMPLO
            cmp rbx, 0 
            je .fin

            jmp .ciclo
        
        .strVacio:
            ; No hay string, ponemos NULL
            mov qword[r11 + OFFSET_NOMBRE], 0
            ;Vamos al siguiente templo
            add r11, OFFSET_TEMPLO
            add rbx, OFFSET_TEMPLO
            dec r12d

            jmp .ciclo



 .fin:
    mov rax, [rbp-8]
    add rsp,16
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
push r14  ; ALINEADA
xor rax,rax
mov rbx, rdi
mov r14, rsi
; RECORRO EL ARRAY de TEMPLOS
.ciclo:
    ; el puntero al array es nulo?
    cmp rbx, 0
    je .fin

    
    ; llegamos al final de la lista?
    cmp r14, 0      
    je .fin

    ;verifico que sea un templo clasico
    movzx r12, byte[rbx + OFFSET_COLUMN_CORTO]    ; cargo N columna corta
    movzx r13, byte[rbx + OFFSET_COLUMN_LARGO]    ; cargo M columna larga

    
    shl r12, 1
    add r12 ,1          ; Templo Clasico 2*N + 1

    cmp r12, r13        ; 2*N + 1 = M
    jne .siguiente



    add eax,1
    add rbx, OFFSET_TEMPLO
    dec r14
    jmp .ciclo

    .siguiente:
        add rbx, OFFSET_TEMPLO
        dec r14
        jmp .ciclo 

.fin:
    pop r14
    pop rbx
    pop r13
    pop r12
    pop rbp
    ret



; char* strClone(char* a)
strClone:
 push rbp
 mov rbp, rsp
 push r12						; contador
 push r13						; r13 = len del string 
 push r14						; Muevo el tope de la pila para guardar rdi y 8 bytes + para alinear
 push r15						; puntero a la nueva memoria
 push rbx
 sub rsp,8						; ALINEADO	
 mov r14, rdi					; rbx= el puntero del string 

 ; rdi sigue siendo el puntero
 call strLen						; Obteniene la longitud del string 
 mov r13d, eax							; preserva rax, contiene la longitud del  string 
 add r13d, 1							; Sumamos el caracter nulo
 
 ;Calcula el espacio que tendra la memoria 
 mov edi, r13d						; Son bytes entonces long(a)=espacio_de_mem_en_bytes
 call malloc						; rax= puntero se encuentra 
 

 mov r15, rax						; r15 = puntero a la nueva mem
 mov rbx, rax
; Copia byte a byte
 .ciclo:
	cmp r13, 0
	je .fin

	mov r12b, byte[r14]
	mov byte[r15], r12b
	inc r14
	inc r15
	dec r13
	jmp .ciclo

 .fin:
	mov rax, rbx
	add rsp,8
	pop rbx
 	pop r15
	pop r14
	pop r13
	pop r12
 	pop rbp
	ret


; uint32_t strLen(char* a)
strLen:
 push rbp
 mov rbp, rsp
 push r12
 sub rsp, 8
 xor eax, eax			; inicializo contador
 mov r12, rdi



 .ciclo:
	; Accede rdi al primer caracter
	cmp byte[r12], 0		; Es igual a NULL(0)?
	je .fin					; Si es igual, termino

	inc eax					; incremento el contador
	inc r12					; Incrementa en un Byte, el puntero al proximo caracter

	jmp .ciclo
	 
 .fin:
	add rsp, 8
 	pop r12
 	pop rbp
	ret