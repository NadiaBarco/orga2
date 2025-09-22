extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = item_t**     inventario
	; rsi = uint16_t*    indice
	;  dx = uint16_t     tamanio
	; rcx = comparador_t comparador
	push rbp
	mov rbp,rsp

	push rbx ; inventario
	push r12 ; indices
	push r14 ; comparador
	push r15 ; contador 
	push r13
	sub rsp,8

	; asignaciones
	mov rbx, rdi  ; rbx = inventario
	mov r12, rsi  ; r12 = array de indices
	movzx r15, dx ; contador r15= tamanio
	mov r14, rcx  ; r14 = comparador dos a dos
	
	xor r13,r13
	;movzx r8, word[r12]		; r8 = indice[0]	
	;movzx r9, word[r12 + 2]	; r9 = indice[1]
	;add r12, 2			; r12 = *indice[i+1]
	;sub r15,1
	mov eax,0
	cmp r15, 2
	jl .fin 

	.loop:
		movzx r8, word[r12 + 2*r13]		; r8 = indice[0]	
		; Antes de incrementar verificamos que no este fuera de order
		; probar con longitades pares e impares
		add r13,1
		cmp r13, r15
		jge .fin_ordenado 
		
		movzx r9, word[r12 + 2*r13]	; r9 = indice[1]
		;add r12, 2			; r12 = *indice[i+1]

		; tomamos los elementos i e i+1 del inventario
		mov rdi, [rbx + r8*8]	; inventario[indice[i]]
		mov rsi, [rbx + r9*8]	; inventario[indice[i+1]]

		call r14 ; Comparamos items

		cmp eax, 0			; no estan ordenados
		je .fin 
		;mov r8,r9
		;add r13, 1

		; seguimos verificando el orden
		jmp .loop
		

		.fin_ordenado:
			mov eax, 1
 .fin:
	
	add rsp,8
	pop r13
	pop r15
	pop r14
	pop r12
	pop rbx
	pop rbp
	ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/rdi  = item_t**  inventario
	; r/rsi = uint16_t* indice
	; r/dx = uint16_t  tamanio

	push rbp
	mov rbp, rsp 	; --> armamos el base frame
	push rbx 		; nueva vista
	push r12 		; inventario
	push r13		; indices
	push r14		; tamanio
	push r15		; contador/ indice
	sub rsp,8
	
	; Asignaciones
	mov r12, rdi	; r12 = **inventario
	mov r13, rsi	; r13 = *indices
	movzx r14, dx 	; r14 = tamanio
	
	; creamos el nuevo inventario
	mov rdi, r14
	shl rdi, 3
	
	call malloc
	mov rbx, rax 	; puntero al array de punteros
	xor r15,r15
	.loop:
		cmp r15, r14
		jge .fin
	;rbx =[,,,,]
		; usamos el indice, indices[i]
		movzx r8, word[r13 + 2*r15]	; r8 = indices[i]

		; nuevo_inventario[i] = inventario[indice[i]]
		mov r9, qword[r12 + r8*8]
		mov qword[rbx + 8*r15], r9 
		inc r15
		jmp .loop


	.fin:
	mov rax, rbx
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
