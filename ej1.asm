
global strArrayNew
global strArrayGetSize
global strArrayGet
global strArrayRemove
global strArrayDelete
extern malloc
extern free
;########### SECCION DE DATOS
section .data
SIZE_OFFSET EQU 0
CAPACITY_OFFSET EQU 1
DATA_OFFSET EQU 8
STR_ARRAY_OFFSET EQU 16
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; str_array_t* strArrayNew(uint8_t capacity)
; di = capacity
strArrayNew:
 push rbp
 mov rbp, rsp
 push rbx
 push r12

 xor rax,rax
 movzx r12, dil
 cmp r12, 0
 je .fin
 ; Pedidmos memoria para la estructura
 mov rdi, STR_ARRAY_OFFSET
 call malloc 
 cmp rax, 0 
 je .eliminar
 
 ;Puntero en de la estructura
 mov rbx, rax 
 ; inicializamos los atributos
 mov byte[rbx + SIZE_OFFSET], 0       ; uint8_t size
 mov byte[rbx + CAPACITY_OFFSET], r12b     ; uint8_t capacity
 ;mov QWORD[rbx + DATA_OFFSET], puntero

 ; Pedimos memoria para el nuevo array
 movzx rdi, r12b 
 shl rdi, 3             ; size * 8 => array de punteros/ array de 8 bytes por elemento
 cmp rdi, 0
 je .eliminar
 call malloc
 cmp rax, 0
 je .eliminar
 mov r10,rax
 ; Puntero al array 
 mov QWORD[rbx + DATA_OFFSET], r10

 ; devolvemos el puntero a la estructura
 mov rax, rbx
 jmp .fin

 .eliminar:
    mov rdi, rbx
    call free
    xor rax, rax
.fin:
  pop r12
  pop rbx
  pop rbp
  ret


; uint8_t  strArrayGetSize(str_array_t* a)
; rdi = a
strArrayGetSize:
 push rbp
 mov rbp, rsp
 push rbx
 push r12
 xor rax,rax
 mov rbx, rdi 
 cmp rbx, 0 
 je .fin 
 mov al, byte[rbx + SIZE_OFFSET]
 
 .fin:
  pop r12
  pop rbx
  pop rbp
  ret

; char* strArrayGet(str_array_t* a, uint8_t i)
; rdi = a
; sil = i
strArrayGet:
 push rbp 
 mov rbp, rsp     ; ---> base frame armado

 push rbx 
 push r12
 push r13
 sub rsp, 16

 ; Asignaciones
 mov r13, rdi   ; r13 = a
 movzx r12, sil ; r12 = i

 ; obtenemos el array de la estructura
 mov rbx, qword[r13 + DATA_OFFSET]  ;rbx = a.data
 mov r9b, byte[r13 + SIZE_OFFSET] ; r8 = a.capacity

 cmp sil, r9b    ; long_actual < i?
 jge .fuera_de_rango

 mov rax, qword[rbx + 8*r12]
 jmp .fin
  .fuera_de_rango:
    mov rax,0
 
 .fin:
  add rsp, 16
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret

; char* strArrayRemove(str_array_t* a, uint8_t i)
strArrayRemove:
 push rbp
 mov rbp, rsp

 push rbx
 push r12
 push r13
 push r14
 push r15
 sub rsp, 16
  ; tenemos que manejar 4 casos
  ; 1. Esta fuera de rango 
  ; 2.1 el elemento a borrar es unico => idem 2.3
  ; 2.2   el elemento a borrar es el primero de la lista => desplazamiento a la izquierda and decrece el size
  ; 2.3   el elemento a borrar es el ultimo en la lista => solo decremento el size, luego se sobreescribira
  ; 2.4   el elemento a borrar esta contenida dentro del rango (primero,ultimo) => idem 2.2

  ;Asignaciones
  mov   r12, rdi                    ; r12 = str_array_t* a
  mov r13b, sil                    ; r13 = i

  mov rbx, [r12 + DATA_OFFSET]      ; rbx = a.data

  ; obtenemos el elemento a borrar
  mov rdi, r12
  mov sil, r13b
  call strArrayGet  
  mov r15, rax                     ; Lo preservamos
  
  cmp rax, 0                        ; Esta fuera de rango?
  je .fin

  ;el elemento a borrar es el ultimo en la lista
  mov r10b, byte[r12 + SIZE_OFFSET]
  dec r10b
  cmp r13b, r10b
  je .borrar

  ;el elemento a borrar esta contenida dentro del rango (primero,ultimo)
  .borrar:
    mov r10b, byte[r12 + SIZE_OFFSET]
    dec byte[r12 + SIZE_OFFSET]
    mov r8, r13                 ; r8 = i
    sub r10b,1
    .ciclo:
      cmp r8b, r10b  ; i < a.size? seguimos acomodando
      jge .fin 

      mov r9, qword[rbx + (r8+1)*8]         ; r9 = a.data[i+1]
      mov qword[rbx  + r8*8], r9            ; a.data[i]= a.data[i+1]

      add r8, 1
      jmp .ciclo

 .fin:
    mov rax, r15
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; void  strArrayDelete(str_array_t* a)
; rdi = a
strArrayDelete:
 push rbp
 mov rbp, rsp
 push rbx
 push r12
 push r13
 push r14
 
; Asignaciones
; r12 = a
; rbx = a.data
; r13 = a.capacity
 mov r12, rdi
 mov rbx, QWORD[r12 + DATA_OFFSET]
 movzx r13, byte[r12 + SIZE_OFFSET] 

 xor r8,r8
 .ciclo:
    cmp r8, r13
    jge .deleteStruct
    mov rdi, [rbx + r8*8]
    call strDelete 

    ;add rbx, 8
    add r8, 1
    jmp .ciclo
 
 .deleteStruct:
  mov rdi, rbx
  call free
  mov rdi, r12
  call free

 .fin:
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret
strDelete:
    push rbp
    mov rbp, rsp
    
    ; Check if pointer is NULL
    cmp rdi, 0
    je .fin
    
    ; Just free the original pointer once
    call free
  .fin:
    pop rbp
    ret
