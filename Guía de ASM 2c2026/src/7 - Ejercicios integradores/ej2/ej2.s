	.file	"ej2.c"
	.intel_syntax noprefix
# GNU C23 (Ubuntu 15.2.0-16ubuntu1) version 15.2.0 (x86_64-linux-gnu)
#	compiled by GNU C version 15.2.0, GMP version 6.3.0, MPFR version 4.2.2, MPC version 1.3.1, isl version isl-0.27-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -U _FORTIFY_SOURCE -masm=intel -mtune=generic -march=x86-64 -Og -fno-asynchronous-unwind-tables -fcf-protection=none -fstack-protector-strong -fstack-clash-protection -fzero-init-padding-bits=all
	.text
	.globl	optimizar
	.type	optimizar, @function
optimizar:
	push	r15	#
	push	r14	#
	push	r13	#
	push	r12	#
	push	rbp	#
	push	rbx	#
	sub	rsp, 24	#,
	mov	r14, rdi	# mapa, mapa
	mov	r12, rsi	# compartida, compartida
	mov	r15, rdx	# fun_hash, fun_hash
# ej2.c:40:     uint32_t compartida_hash = fun_hash(compartida);
	mov	rdi, rsi	#, compartida
	call	rdx	# fun_hash
	mov	DWORD PTR 12[rsp], eax	# %sfp, compartida_hash
# ej2.c:42:     for (size_t i = 0; i < 255; i++){
	mov	r13d, 0	# i,
# ej2.c:42:     for (size_t i = 0; i < 255; i++){
	jmp	.L2	#
.L4:
# ej2.c:52:                         mapa[i][j] = compartida; 
	mov	QWORD PTR 0[rbp+rbx*8], r12	# (*_2)[j_13], compartida
# ej2.c:53:                         compartida->references ++;
	movzx	eax, BYTE PTR 14[r12]	# tmp126, compartida_20(D)->references
	add	eax, 1	# tmp117,
	mov	BYTE PTR 14[r12], al	# compartida_20(D)->references, tmp117
	.p2align 6
.L3:
# ej2.c:43:         for (size_t j = 0; j < 255; j++){
	add	rbx, 1	# j,
.L6:
# ej2.c:43:         for (size_t j = 0; j < 255; j++){
	cmp	rbx, 254	# j,
	ja	.L9	#,
# ej2.c:44:             if (mapa[i][j]){
	imul	rbp, r13, 2040	# _1, i,
	add	rbp, r14	# _2, mapa
# ej2.c:44:             if (mapa[i][j]){
	mov	rdi, QWORD PTR 0[rbp+rbx*8]	# _3, (*_2)[j_13]
# ej2.c:44:             if (mapa[i][j]){
	test	rdi, rdi	# _3
	je	.L3	#,
# ej2.c:45:                 if ((compartida != mapa[i][j]) && compartida_hash == fun_hash(mapa[i][j])){ 
	cmp	rdi, r12	# _3, compartida
	je	.L3	#,
# ej2.c:45:                 if ((compartida != mapa[i][j]) && compartida_hash == fun_hash(mapa[i][j])){ 
	call	r15	# fun_hash
# ej2.c:45:                 if ((compartida != mapa[i][j]) && compartida_hash == fun_hash(mapa[i][j])){ 
	mov	ecx, DWORD PTR 12[rsp]	# compartida_hash, %sfp
	cmp	eax, ecx	# _4, compartida_hash
	jne	.L3	#,
# ej2.c:46:                         mapa[i][j]->references --;
	mov	rdx, QWORD PTR 0[rbp+rbx*8]	# _5, (*_2)[j_13]
# ej2.c:46:                         mapa[i][j]->references --;
	movzx	eax, BYTE PTR 14[rdx]	# tmp125, _5->references
	sub	eax, 1	# tmp116,
	mov	BYTE PTR 14[rdx], al	# _5->references, tmp116
# ej2.c:48:                         if (mapa[i][j]->references == 0){
	mov	rdi, QWORD PTR 0[rbp+rbx*8]	# _8, (*_2)[j_13]
# ej2.c:48:                         if (mapa[i][j]->references == 0){
	cmp	BYTE PTR 14[rdi], 0	# _8->references,
	jne	.L4	#,
# ej2.c:49:                             free(mapa[i][j]);
	call	free@PLT	#
	jmp	.L4	#
.L9:
# ej2.c:42:     for (size_t i = 0; i < 255; i++){
	add	r13, 1	# i,
.L2:
# ej2.c:42:     for (size_t i = 0; i < 255; i++){
	cmp	r13, 254	# i,
	ja	.L10	#,
# ej2.c:43:         for (size_t j = 0; j < 255; j++){
	mov	ebx, 0	# j,
	jmp	.L6	#
.L10:
# ej2.c:58: }
	add	rsp, 24	#,
	pop	rbx	#
	pop	rbp	#
	pop	r12	#
	pop	r13	#
	pop	r14	#
	pop	r15	#
	ret	
	.size	optimizar, .-optimizar
	.globl	contarCombustibleAsignado
	.type	contarCombustibleAsignado, @function
contarCombustibleAsignado:
	push	r15	#
	push	r14	#
	push	r13	#
	push	r12	#
	push	rbp	#
	push	rbx	#
	sub	rsp, 8	#,
	mov	r13, rdi	# mapa, mapa
	mov	r14, rsi	# fun_combustible, fun_combustible
# ej2.c:67:     for (size_t i = 0; i < 255; i++){
	mov	r12d, 0	# i,
# ej2.c:65:     uint32_t combustible_total = 0;
	mov	ebp, 0	# <retval>,
# ej2.c:67:     for (size_t i = 0; i < 255; i++){
	jmp	.L12	#
	.p2align 5
.L13:
# ej2.c:68:         for (size_t j = 0; j < 255; j++){
	add	rbx, 1	# j,
.L15:
# ej2.c:68:         for (size_t j = 0; j < 255; j++){
	cmp	rbx, 254	# j,
	ja	.L18	#,
# ej2.c:69:             if (mapa[i][j]){
	imul	rax, r12, 2040	# _1, i,
	add	rax, r13	# _2, mapa
# ej2.c:69:             if (mapa[i][j]){
	mov	rdi, QWORD PTR [rax+rbx*8]	# _3, (*_2)[j_14]
# ej2.c:69:             if (mapa[i][j]){
	test	rdi, rdi	# _3
	je	.L13	#,
# ej2.c:70:                 combustible_total += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase) ;
	movzx	r15d, WORD PTR 12[rdi]	# _5, _3->combustible
# ej2.c:70:                 combustible_total += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase) ;
	call	r14	# fun_combustible
# ej2.c:70:                 combustible_total += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase) ;
	movzx	eax, ax	# _8, _7
# ej2.c:70:                 combustible_total += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase) ;
	sub	r15d, eax	# _9, _8
# ej2.c:70:                 combustible_total += mapa[i][j]->combustible - fun_combustible(mapa[i][j]->clase) ;
	add	ebp, r15d	# <retval>, _9
	jmp	.L13	#
.L18:
# ej2.c:67:     for (size_t i = 0; i < 255; i++){
	add	r12, 1	# i,
.L12:
# ej2.c:67:     for (size_t i = 0; i < 255; i++){
	cmp	r12, 254	# i,
	ja	.L19	#,
# ej2.c:68:         for (size_t j = 0; j < 255; j++){
	mov	ebx, 0	# j,
	jmp	.L15	#
.L19:
# ej2.c:76: }
	mov	eax, ebp	#, <retval>
	add	rsp, 8	#,
	pop	rbx	#
	pop	rbp	#
	pop	r12	#
	pop	r13	#
	pop	r14	#
	pop	r15	#
	ret	
	.size	contarCombustibleAsignado, .-contarCombustibleAsignado
	.globl	modificarUnidad
	.type	modificarUnidad, @function
modificarUnidad:
	push	r14	#
	push	r13	#
	push	r12	#
	push	rbp	#
	push	rbx	#
# ej2.c:83:     if (mapa[x][y]){
	movzx	esi, sil	# _1, x
	imul	rsi, rsi, 2040	# _2, _1,
	lea	rbx, [rdi+rsi]	# _3,
# ej2.c:83:     if (mapa[x][y]){
	movzx	r12d, dl	# _4, y
	movzx	edx, dl	# _4, y
	mov	rbp, QWORD PTR [rbx+rdx*8]	# _5, (*_3)[_4]
# ej2.c:83:     if (mapa[x][y]){
	test	rbp, rbp	# _5
	je	.L20	#,
	mov	r14, rcx	# fun_modificar, fun_modificar
# ej2.c:84:         if (mapa[x][y]->references > 1){
	cmp	BYTE PTR 14[rbp], 1	# _5->references,
	ja	.L24	#,
# ej2.c:96:             fun_modificar(mapa[x][y]);
	mov	rdi, rbp	#, _5
	call	rcx	# fun_modificar
.L20:
# ej2.c:99: }
	pop	rbx	#
	pop	rbp	#
	pop	r12	#
	pop	r13	#
	pop	r14	#
	ret	
.L24:
# ej2.c:85:             attackunit_t* nueva_unidad = malloc(sizeof(attackunit_t));
	mov	edi, 16	#,
	call	malloc@PLT	#
	mov	r13, rax	# tmp121, tmp130
# ej2.c:87:             strcpy(nueva_unidad->clase, mapa[x][y]->clase),
	mov	rsi, rbp	#, _5
	mov	rdi, rax	#, tmp121
	call	strcpy@PLT	#
# ej2.c:88:             nueva_unidad->combustible = mapa[x][y]->combustible;
	movsxd	r12, r12d	# _4, _4
	mov	rax, QWORD PTR [rbx+r12*8]	# _9, (*_3)[_4]
# ej2.c:88:             nueva_unidad->combustible = mapa[x][y]->combustible;
	movzx	eax, WORD PTR 12[rax]	# _10, _9->combustible
# ej2.c:88:             nueva_unidad->combustible = mapa[x][y]->combustible;
	mov	WORD PTR 12[r13], ax	# nueva_unidad_22->combustible, _10
# ej2.c:89:             nueva_unidad->references = 1;
	mov	BYTE PTR 14[r13], 1	# nueva_unidad_22->references,
# ej2.c:90:             mapa[x][y]->references --;
	mov	rdx, QWORD PTR [rbx+r12*8]	# _11, (*_3)[_4]
# ej2.c:90:             mapa[x][y]->references --;
	movzx	eax, BYTE PTR 14[rdx]	# tmp132, _11->references
	sub	eax, 1	# tmp124,
	mov	BYTE PTR 14[rdx], al	# _11->references, tmp124
# ej2.c:92:             fun_modificar(nueva_unidad);
	mov	rdi, r13	#, tmp121
	call	r14	# fun_modificar
# ej2.c:93:             mapa[x][y] = nueva_unidad;
	mov	QWORD PTR [rbx+r12*8], r13	# (*_3)[_4], tmp121
	jmp	.L20	#
	.size	modificarUnidad, .-modificarUnidad
	.globl	EJERCICIO_2C_HECHO
	.data
	.type	EJERCICIO_2C_HECHO, @object
	.size	EJERCICIO_2C_HECHO, 1
EJERCICIO_2C_HECHO:
	.byte	1
	.globl	EJERCICIO_2B_HECHO
	.type	EJERCICIO_2B_HECHO, @object
	.size	EJERCICIO_2B_HECHO, 1
EJERCICIO_2B_HECHO:
	.byte	1
	.globl	EJERCICIO_2A_HECHO
	.type	EJERCICIO_2A_HECHO, @object
	.size	EJERCICIO_2A_HECHO, 1
EJERCICIO_2A_HECHO:
	.byte	1
	.ident	"GCC: (Ubuntu 15.2.0-16ubuntu1) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
