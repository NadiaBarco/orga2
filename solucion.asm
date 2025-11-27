; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
carta.SIZE     EQU 18

; typedef struct carta {
; 	bool en_juego;    
; 	char nombre[12];  
; 	uint16_t vida;    
; 	uint8_t jugador;  
; } carta_t;  



; typedef struct tablero {
; 	carta_t* mano_jugador_rojo;
; 	carta_t* mano_jugador_azul;
; 	carta_t* campo[ALTO_CAMPO][ANCHO_CAMPO];
; } tablero_t;
tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 416

; typedef struct accion {
; 	accion_fn_t* invocar;
; 	carta_t* destino;
; 	struct accion* siguiente;
; } accion_t;
accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
; RDI = accion_t* accion
; RSI = char* nombre
global hay_accion_que_toque
hay_accion_que_toque:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = accion_t*  accion
	; r/m64 = char*      nombre
	push rbp
	mov rbp, rsp ; stack frame armado
	push rbx
	push r15
	push r14
	push r13	; preservo registros no volatiles

	mov rbx, rdi	; preservamos el puntero al array de accione_t
	mov r13, rsi	; preservamos el nombre

	.ciclo:
	;accedemos a la accion 
		cmp rbx, 0
		je .no_hay_nombre

		mov r15, [rbx + accion.destino]		; r15 = accion
		lea r8, [r15+carta.nombre]		; r8 = accion[idx].nombre
		; obtenemos el nombre
		mov rdi, r8
		mov rsi, r13
		call strcmp  

		cmp rax, 0
		je .encontrado

		mov rbx, [rbx + accion.siguiente]
		
		jmp .ciclo

		.no_hay_nombre:
			mov rax, 0
			jmp .fin
		.encontrado:
			mov rax, 1
 .fin:
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret

; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar esaccion_fn_t* invocar; la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
invocar_acciones:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = accion_t*  accion
	; rsi = tablero_t* tablero
	push rbp
	mov rbp, rsp		;<--- stack frame armadoo
	push rbx
	push r15
	push r14
	push r13

	mov rbx, rdi
	mov r13, rsi 

	.ciclo:
		cmp rbx, 0
		je .fin						; ya no hay mas cartas por recorrer
		;accedemos a la carta destino
		mov r15, [rbx + accion.destino]	; carta = accion->destino

		;vericamos que este en juego
		cmp byte[r15 + carta.en_juego], 0
		je .no_esta_en_juego

		; ESTA EN JUEGO

		;verificamos que tenga vida>0
		;cmp word[r15 + carta.vida], 0
		;jle .no_esta_en_juego
		; ESTA EN JUEGO 
		mov rax, [rbx + accion.invocar]	; accion->invocar
		mov rdi, r13
		mov rsi, r15
		call rax 

		; VERIFICAMOS SI ES 0 Y LO SACAMOS DE JUEGO 
		cmp word[r15 + carta.vida], 0
		jne .no_esta_en_juego

		; es 0, lo sacamos de juego
		mov byte[r15 + carta.en_juego], 0
		; seguimos

		.no_esta_en_juego:
			; vamos a la proxima carta
			mov rbx, [rbx + accion.siguiente]
			jmp .ciclo
	
		


  .fin:
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret

; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
contar_cartas:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = tablero_t* tablero
	; rsi = uint32_t*  cant_rojas
	; rdx = uint32_t*  cant_azules
	push rbp
	mov rbp, rsp
	push rbx
	push r15
	push r14
	push r13

	mov rbx, rdi
	mov r14, rsi	; jugador_rojo
	mov r13, rdx	; jugador_azul


	mov dword[r13],0
	mov dword[r14],0
	; obtenemos el tamaño de la matriz
	lea r15, [rbx + tablero.campo]	; tablero->campo
	mov rax, tablero.ANCHO
	imul rax,tablero.ALTO
	.ciclo:       
		cmp rax, 0
		je .fin

		mov rbx, [r15]  
		cmp rbx, 0                          ; ¿Es NULL?
		je .sigo

		movzx r8, byte [rbx + carta.jugador] ; Ahora sí accede a la carta

		; entramos al tablero
		;mov r8b, byte[rbx + carta.jugador]			; carta->jugador
		
		cmp r8, JUGADOR_AZUL
		je .jugador_azul 

		cmp r8, JUGADOR_ROJO
		je .jugador_rojo 

		.sigo:
			; ES UN NPC, sigo
			add r15, 8
			sub rax, 1
			jmp .ciclo

		.jugador_azul:
			add dword[r13], 1
			jmp .sigo

		.jugador_rojo:
			add dword[r14], 1
			jmp .sigo

		

 .fin:
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret