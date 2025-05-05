; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data
OFFSET_FIRST EQU 0
OFFSET_LAST EQU 8
SIZE_LISTA EQU 16

OFFSET_NEXT EQU 0
OFFSET_PREVIOUS EQU 8
OFFSET_TYPE EQU 16
OFFSET_HASH EQU 24
SIZE_NODO EQU 32
section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat


string_proc_list_create_asm:
 push rbp
 mov rbp, rsp
 mov rdi, SIZE_LISTA
 call malloc

 mov QWORD[rax + OFFSET_FIRST], 0

 mov QWORD[rax+OFFSET_LAST],0
 pop rbp
 ret


;string_proc_node* string_proc_node_create_asm(uint8_t type, char* hash);
; dil = uint_8 type
; rsi = char* hash
string_proc_node_create_asm:
 push rbp
 mov rbp,rsp
 push r15
 push r14

 mov r14b, dil
 mov r15, rsi 

 mov rdi, SIZE_NODO
 call malloc

 mov QWORD[rax + OFFSET_NEXT], 0
 mov qword[rax + OFFSET_PREVIOUS], 0
 mov byte[rax + OFFSET_TYPE], r14b
 mov [rax + OFFSET_HASH], r15
 pop r14
 pop r15
 pop rbp
 ret

;void string_proc_list_add_node_asm(string_proc_list* list, uint8_t type, char* hash
; rdi = *lista
; sil = type
; rdx = *hash
string_proc_list_add_node_asm:
 push rbp
 mov rbp, rsp
 sub rsp, 8
 push r15
 push r14
 push r13
 push r12
 push rbx
 

 mov r15, rdi
 mov r14b, sil
 mov r13, rdx
 
 cmp rdi, 0
 je .end


; Creamos un nuevo nodo
 mov rdi, rsi
 mov rsi, r13
 call string_proc_node_create_asm
 
; es una lista Vacia?
 cmp qword[r15 +  OFFSET_FIRST], 0
 je .esVacia


 ; Hallamos el ultimo nodo actual
 mov rbx, [r15 + OFFSET_LAST]               ;rbx = lista->last

 ;SWAP
 mov [rax + OFFSET_PREVIOUS], rbx           ;new_nodo->previous = lista->last

 mov rbx, [r15 + OFFSET_LAST]               ;rbx = lista->last 
 mov [rbx + OFFSET_NEXT], rax               ; lista->last->next = new_nodo

 mov [r15 + OFFSET_LAST], rax               ; lista->last= new_nodo
 jmp .end

.esVacia:
    mov qword[r15 + OFFSET_FIRST], rax       ; list->first = nuevo_nodo
    mov qword[r15 + OFFSET_LAST], rax        ; list->last = nuevo_nodo
        

 .end:
    pop rbx
    pop r12
    pop r13
    pop r14
    pop r15
    add rsp, 8
    pop rbp
string_proc_list_concat_asm:
    