extern malloc
extern free
extern strcpy
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text


; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142
TUIT_ID_AUTOR_OFFSET EQU 144
TUIT_SIZE EQU 152

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0
USUARIO_SEGUIDORES_OFFSET EQU 8
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16
USUARIO_SEGUIDOS_OFFSET EQU 24
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32
USUARIO_BLOQUEADOS_OFFSET EQU 40
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48
USUARIO_ID_OFFSET EQU 52 
USUARIO_SIZE EQU 56

; tuit_t **trendingTopic(usuario_t *usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
; rdi = usuario
; rsi = funcion sobresaliente
global trendingTopic 
trendingTopic:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp,16
    
    ;Asignaciones
    mov rbx, rdi            ; rbx = usuario
    mov r12, rsi            ; r12 = funcion_sobresaliente
    xor rax,rax
    ;obtenemos el feed de nuestro usuario
    mov rdi, qword[rbx + USUARIO_FEED_OFFSET]

    ; Pasamos el id de nuestro usuario
    mov esi, dword[rbx + USUARIO_ID_OFFSET]
    mov r13d, dword[rbx + USUARIO_ID_OFFSET]
    ; Pasamos la funcion sobresaliente
    mov rdx, r12
    call tuits_sobresalientes
    ; se reservo memoria?
    cmp eax, 0
    je .devuelvo_nulo
    ; sumamos 1 para el puntero null
    mov edi, eax
    add edi,1
    shl edi, 3
    call malloc

    ; se reservo memoria?
    ;cmp rax, 1      ;
    ;je .fin2

    mov r14, rax    ; puntero a tuit_t** trending
    mov r15, [rbx + USUARIO_FEED_OFFSET] ; r15 = usuario->feed
    mov r15, [r15 + FEED_FIRST_OFFSET]   ; R15 = usuario->feed->first
    xor r8,r8 ; incializo contador/indice
    .ciclo:
        cmp r15, 0
        je .fin2
        ;chequeamos que el tuit actual es de nuetsro autor
        mov r11, [r15 + PUBLICACION_VALUE_OFFSET] ; usuario->feed->first->value
        mov r9d, DWORD[r11 + TUIT_ID_AUTOR_OFFSET]

        cmp r9d, r13d
        jne .sigo 
        ;chequeamos si es un tuit sobresaliente
        mov rdi, r11
        call r12        

        cmp al, 0
        je .sigo 
        ;agregamos el tuit sobresaliente
        
        mov qword[r14 + r8*8], r11
        add r8d,1
        .sigo:
            mov r15, QWORD[r15+PUBLICACION_NEXT_OFFSET]
            jmp .ciclo

    .fin2:    
        mov qword[r14 + r8*8],0
        mov rax, r14
        jmp .fin
    .devuelvo_nulo:
        mov rax,0
    .fin:
        add rsp,16
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret


;tuit_t** update_trends(tuit_t** trends, funcion_sobresaliente, uint32_t longitud, uint32_t id)



;uint32_t tuits_sobresalientes(feed_t publicaciones, uint32_t id_autor, funcion* es_sobresaliente)
; RDI = publicaciones
; esi = id_autor
; rdx = es_sobresaliente
tuits_sobresalientes:
    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16

    ;Asignaciones
    mov rbx, rdi    ; rbx = publicaciones
    mov r12d, esi   ; r12d = id
    mov r13, rdx    ; r13 = funcion es_sobresaliente 
    xor rax,rax
    ; Obtenemos el primer puntero de las publicaciones
    mov rbx,[rbx + FEED_FIRST_OFFSET]; feed->first 
    xor r14, r14
    cmp rbx, 0      ; tiene publicaciones en el feed?
    je .fin 
    
    .ciclo:
        cmp rbx, 0  ; Hay mas publicaciones
        je .fin 
        
        ;Obtenemos el id del autor actual del tuit
        mov r15,[rbx + PUBLICACION_VALUE_OFFSET]    ; feed->first->value
        mov r8d, dword[r15 + TUIT_ID_AUTOR_OFFSET]
        
        cmp r8d, r12d       ; es el mismo autor?
        jne .sigo   

        mov rdi, r15
        call r13        ; es un tuit sobresaliente?
        cmp al, 1
        jne .sigo 
        
        ;Es un tuit sobresaliente
        inc r14d
        .sigo:
            mov rbx, [rbx + PUBLICACION_NEXT_OFFSET]
            jmp .ciclo 

    .fin: 
        mov eax, r14d
        add rsp, 16
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret
    
