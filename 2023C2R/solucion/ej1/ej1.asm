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
OFFSET_TYPE EQU 17
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
string_proc_list_add_node_asm:

string_proc_list_concat_asm:
