section .data
; Vetores de registradores por tamanho
regs_8:  dq D0, D1, D2, D3
regs_16: dq A0, A1
regs_32: dq H0, H1

; Registradores
A0: dw 0    ; 16-bit (0)
A1: dw 0    ; 16-bit (1)
D0: db 0    ; 8-bit  (2)
D1: db 0    ; 8-bit  (3)
D2: db 0    ; 8-bit  (4)
D3: db 0    ; 8-bit  (5)
H0: dd 0    ; 32-bit (6)
H1: dd 0    ; 32-bit (7)

; Flags
zero: db 0
negativo: db 0
carry: db 0

section .text
global executa

executa:
    push rbp
    mov rbp, rsp

    ; Decodifica opcode
    movzx rax, byte [rsi]
    cmp al, 0x17
    ja fim_execucao
    
    ; Multiplica por 8 para índice na tabela
    shl rax, 3
    jmp [tabela_ops + rax]

; PUSH (00)
push_reg:
    mov al, [rsi+1]
    and al, 0x0F
    
    cmp al, 2
    jl push_16
    cmp al, 6
    jl push_8
    jmp push_32

push_8:
    mov cl, [regs_8 + rax - 2]
    push rcx
    add rsi, 2
    jmp next_instruction

push_16:
    mov cx, [regs_16 + rax]
    push rcx
    add rsi, 2
    jmp next_instruction

push_32:
    mov ecx, [regs_32 + rax - 6]
    push rcx
    add rsi, 2
    jmp next_instruction

; POP (01)
pop_reg:
    mov al, [rsi+1]
    and al, 0x0F
    
    cmp al, 2
    jl pop_16
    cmp al, 6
    jl pop_8
    jmp pop_32
pop_8:
    pop rcx
    mov [regs_8 + rax - 2], cl
    add rsi, 2
    jmp next_instruction

pop_16:
    pop rcx
    mov [regs_16 + rax], cx
    add rsi, 2
    jmp next_instruction

pop_32:
    pop rcx
    mov [regs_32 + rax - 6], ecx
    add rsi, 2
    jmp next_instruction

; ADD (08)
add_op:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl add_16
    cmp al, 6
    jl add_8
    jmp add_32

add_8:
    mov cl, [regs_8 + rax - 2]
    add cl, [regs_8 + rbx - 2]
    mov [regs_8 + rax - 2], cl
    pushf
    call set_flags_8
    add rsi, 2
    jmp next_instruction

add_16:
    mov cx, [regs_16 + rax]
    add cx, [regs_16 + rbx]
    mov [regs_16 + rax], cx
    pushf
    call set_flags_16
    add rsi, 2
    jmp next_instruction

add_32:
    mov ecx, [regs_32 + rax - 6]
    add ecx, [regs_32 + rbx - 6]
    mov [regs_32 + rax - 6], ecx
    pushf
    call set_flags_32
    add rsi, 2
    jmp next_instruction
; SUB (09)
sub_op:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl sub_16
    cmp al, 6
    jl sub_8
    jmp sub_32

sub_8:
    mov cl, [regs_8 + rax - 2]
    sub cl, [regs_8 + rbx - 2]
    mov [regs_8 + rax - 2], cl
    pushf
    call set_flags_8
    add rsi, 2
    jmp next_instruction

sub_16:
    mov cx, [regs_16 + rax]
    sub cx, [regs_16 + rbx]
    mov [regs_16 + rax], cx
    pushf
    call set_flags_16
    add rsi, 2
    jmp next_instruction

sub_32:
    mov ecx, [regs_32 + rax - 6]
    sub ecx, [regs_32 + rbx - 6]
    mov [regs_32 + rax - 6], ecx
    pushf
    call set_flags_32
    add rsi, 2
    jmp next_instruction

; AND (0A)
and_op:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl and_16
    cmp al, 6
    jl and_8
    jmp and_32
and_8:
    mov cl, [regs_8 + rax - 2]
    and cl, [regs_8 + rbx - 2]
    mov [regs_8 + rax - 2], cl
    pushf
    call set_flags_8
    add rsi, 2
    jmp next_instruction

and_16:
    mov cx, [regs_16 + rax]
    and cx, [regs_16 + rbx]
    mov [regs_16 + rax], cx
    pushf
    call set_flags_16
    add rsi, 2
    jmp next_instruction

and_32:
    mov ecx, [regs_32 + rax - 6]
    and ecx, [regs_32 + rbx - 6]
    mov [regs_32 + rax - 6], ecx
    pushf
    call set_flags_32
    add rsi, 2
    jmp next_instruction

; OR (0B)
or_op:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl or_16
    cmp al, 6
    jl or_8
    jmp or_32

or_8:
    mov cl, [regs_8 + rax - 2]
    or cl, [regs_8 + rbx - 2]
    mov [regs_8 + rax - 2], cl
    pushf
    call set_flags_8
    add rsi, 2
    jmp next_instruction
or_16:
    mov cx, [regs_16 + rax]
    or cx, [regs_16 + rbx]
    mov [regs_16 + rax], cx
    pushf
    call set_flags_16
    add rsi, 2
    jmp next_instruction

or_32:
    mov ecx, [regs_32 + rax - 6]
    or ecx, [regs_32 + rbx - 6]
    mov [regs_32 + rax - 6], ecx
    pushf
    call set_flags_32
    add rsi, 2
    jmp next_instruction

; XOR (0C)
xor_op:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl xor_16
    cmp al, 6
    jl xor_8
    jmp xor_32

xor_8:
    mov cl, [regs_8 + rax - 2]
    xor cl, [regs_8 + rbx - 2]
    mov [regs_8 + rax - 2], cl
    pushf
    call set_flags_8
    add rsi, 2
    jmp next_instruction

xor_16:
    mov cx, [regs_16 + rax]
    xor cx, [regs_16 + rbx]
    mov [regs_16 + rax], cx
    pushf
    call set_flags_16
    add rsi, 2
    jmp next_instruction

xor_32:
    mov ecx, [regs_32 + rax - 6]
    xor ecx, [regs_32 + rbx - 6]
    mov [regs_32 + rax - 6], ecx
    pushf
    call set_flags_32
    add rsi, 2
    jmp next_instruction
; NOT (0D)
not_op:
    mov al, [rsi+1]
    and al, 0x0F
    
    cmp al, 2
    jl not_16
    cmp al, 6
    jl not_8
    jmp not_32

not_8:
    mov cl, [regs_8 + rax - 2]
    not cl
    mov [regs_8 + rax - 2], cl
    pushf
    call set_flags_8
    add rsi, 2
    jmp next_instruction

not_16:
    mov cx, [regs_16 + rax]
    not cx
    mov [regs_16 + rax], cx
    pushf
    call set_flags_16
    add rsi, 2
    jmp next_instruction

not_32:
    mov ecx, [regs_32 + rax - 6]
    not ecx
    mov [regs_32 + rax - 6], ecx
    pushf
    call set_flags_32
    add rsi, 2
    jmp next_instruction

; CMP (0E)
cmp_op:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl cmp_16
    cmp al, 6
    jl cmp_8
    jmp cmp_32
cmp_8:
    mov cl, [regs_8 + rax - 2]
    cmp cl, [regs_8 + rbx - 2]
    pushf
    call set_flags_8
    add rsi, 2
    jmp next_instruction

cmp_16:
    mov cx, [regs_16 + rax]
    cmp cx, [regs_16 + rbx]
    pushf
    call set_flags_16
    add rsi, 2
    jmp next_instruction

cmp_32:
    mov ecx, [regs_32 + rax - 6]
    cmp ecx, [regs_32 + rbx - 6]
    pushf
    call set_flags_32
    add rsi, 2
    jmp next_instruction

; Jump operations (0F-15)
jmp_op:                      ; 0F
    pop ax
    lea rsi, [memoria + rax]
    jmp next_instruction

jl_op:                       ; 10
    cmp byte [negativo], 1
    jne skip_jump
    pop ax
    lea rsi, [memoria + rax]
    jmp next_instruction

jg_op:                       ; 11
    mov al, [negativo]
    or al, [zero]
    test al, 1
    jnz skip_jump
    pop ax
    lea rsi, [memoria + rax]
    jmp next_instruction
jle_op:                      ; 12
    mov al, [negativo]
    or al, [zero]
    test al, 1
    jz skip_jump
    pop ax
    lea rsi, [memoria + rax]
    jmp next_instruction

jge_op:                      ; 13
    cmp byte [negativo], 0
    jne skip_jump
    pop ax
    lea rsi, [memoria + rax]
    jmp next_instruction

jc_op:                       ; 14
    cmp byte [carry], 1
    jne skip_jump
    pop ax
    lea rsi, [memoria + rax]
    jmp next_instruction

jnc_op:                      ; 15
    cmp byte [carry], 0
    jne skip_jump
    pop ax
    lea rsi, [memoria + rax]
    jmp next_instruction

skip_jump:
    add rsi, 1
    jmp next_instruction

; I/O Operations
in_op:                       ; 16
    mov al, [rsi+1]
    and al, 0x0F
    cmp al, 6                ; Verifica se é registrador D
    jae invalid_reg
    
    push rax
    call read_char
    pop rbx
    mov [regs_8 + rbx - 2], al
    add rsi, 2
    jmp next_instruction

out_op:                      ; 17
    mov al, [rsi+1]
    and al, 0x0F
    cmp al, 6
    jae invalid_reg
    
    mov al, [regs_8 + rax - 2]
    call write_char
    add rsi, 2
    jmp next_instruction
; Rotinas de manipulação de flags
set_flags_8:
    pop rax
    mov byte [zero], 0
    mov byte [negativo], 0
    mov byte [carry], 0
    
    bt rax, 6               ; Zero flag
    jnc not_zero_8
    mov byte [zero], 1
not_zero_8:
    bt rax, 7               ; Sign flag
    jnc not_neg_8
    mov byte [negativo], 1
not_neg_8:
    bt rax, 0               ; Carry flag
    jnc not_carry_8
    mov byte [carry], 1
not_carry_8:
    ret

set_flags_16:
    pop rax
    mov byte [zero], 0
    mov byte [negativo], 0
    mov byte [carry], 0
    
    bt rax, 6
    jnc not_zero_16
    mov byte [zero], 1
not_zero_16:
    bt rax, 7
    jnc not_neg_16
    mov byte [negativo], 1
not_neg_16:
    bt rax, 0
    jnc not_carry_16
    mov byte [carry], 1
not_carry_16:
    ret

set_flags_32:
    pop rax
    mov byte [zero], 0
    mov byte [negativo], 0
    mov byte [carry], 0
    
    bt rax, 6
    jnc not_zero_32
    mov byte [zero], 1
not_zero_32:
    bt rax, 7
    jnc not_neg_32
    mov byte [negativo], 1
not_neg_32:
    bt rax, 0
    jnc not_carry_32
    mov byte [carry], 1
not_carry_32:
    ret
; Funções de suporte para I/O
read_char:
    push rax
    push rdx
    mov rax, 0               ; syscall read
    mov rdi, 0               ; stdin
    mov rsi, rsp             ; buffer na pilha
    mov rdx, 1               ; um byte
    syscall
    pop rax
    pop rdx
    ret

write_char:
    push rax
    push rdx
    mov rdi, 1               ; stdout
    mov rsi, rsp             ; buffer na pilha
    mov rdx, 1               ; um byte
    mov rax, 1               ; syscall write
    syscall
    pop rdx
    pop rax
    ret

; Tabela de despacho de instruções
section .data
tabela_ops:
    dq push_reg      ; 00
    dq pop_reg       ; 01
    dq load_const    ; 02
    dq load_mem      ; 03
    dq load_ind      ; 04
    dq store_mem     ; 05
    dq store_ind     ; 06
    dq halt          ; 07
    dq add_op        ; 08
    dq sub_op        ; 09
    dq and_op        ; 0A
    dq or_op         ; 0B
    dq xor_op        ; 0C
    dq not_op        ; 0D
    dq cmp_op        ; 0E
    dq jmp_op        ; 0F
    dq jl_op         ; 10
    dq jg_op         ; 11
    dq jle_op        ; 12
    dq jge_op        ; 13
    dq jc_op         ; 14
    dq jnc_op        ; 15
    dq in_op         ; 16
    dq out_op        ; 17
; Inicialização e controle de fluxo
section .text
next_instruction:
    test rsi, rsi
    jnz executa
    ret

halt:
    xor rsi, rsi
    jmp next_instruction

invalid_reg:
    mov rsi, 0
    ret

; Load operations
load_const:
    mov al, [rsi+1]          ; Registrador destino
    mov ebx, [rsi+2]         ; Constante
    
    cmp al, 2
    jl load_const_16
    cmp al, 6
    jl load_const_8
    jmp load_const_32

load_const_8:
    mov [regs_8 + rax - 2], bl
    add rsi, 6
    jmp next_instruction

load_const_16:
    mov [regs_16 + rax], bx
    add rsi, 6
    jmp next_instruction

load_const_32:
    mov [regs_32 + rax - 6], ebx
    add rsi, 6
    jmp next_instruction
; Memory load operations
load_mem:
    mov al, [rsi+1]          ; Registrador destino
    mov bx, [rsi+2]          ; Endereço de memória
    
    cmp al, 2
    jl load_mem_16
    cmp al, 6
    jl load_mem_8
    jmp load_mem_32

load_mem_8:
    mov cl, [memoria + rbx]
    mov [regs_8 + rax - 2], cl
    add rsi, 4
    jmp next_instruction

load_mem_16:
    mov cx, [memoria + rbx]
    mov [regs_16 + rax], cx
    add rsi, 4
    jmp next_instruction

load_mem_32:
    mov ecx, [memoria + rbx]
    mov [regs_32 + rax - 6], ecx
    add rsi, 4
    jmp next_instruction

; Memory store operations
store_mem:
    mov al, [rsi+1]          ; Registrador fonte
    mov bx, [rsi+2]          ; Endereço de memória
    
    cmp al, 2
    jl store_mem_16
    cmp al, 6
    jl store_mem_8
    jmp store_mem_32
store_mem_8:
    mov cl, [regs_8 + rax - 2]
    mov [memoria + rbx], cl
    add rsi, 4
    jmp next_instruction

store_mem_16:
    mov cx, [regs_16 + rax]
    mov [memoria + rbx], cx
    add rsi, 4
    jmp next_instruction

store_mem_32:
    mov ecx, [regs_32 + rax - 6]
    mov [memoria + rbx], ecx
    add rsi, 4
    jmp next_instruction

; Indirect memory operations
load_ind:
    mov al, [rsi+1]          ; Registrador destino
    mov bl, [rsi+2]          ; Registrador com endereço
    
    mov cx, [regs_16 + rbx]  ; Obtém endereço da memória
    
    cmp al, 2
    jl load_ind_16
    cmp al, 6
    jl load_ind_8
    jmp load_ind_32

load_ind_8:
    mov dl, [memoria + rcx]
    mov [regs_8 + rax - 2], dl
    add rsi, 3
    jmp next_instruction

load_ind_16:
    mov dx, [memoria + rcx]
    mov [regs_16 + rax], dx
    add rsi, 3
    jmp next_instruction

load_ind_32:
    mov edx, [memoria + rcx]
    mov [regs_32 + rax - 6], edx
    add rsi, 3
    jmp next_instruction
; Indirect store operations
store_ind:
    mov al, [rsi+1]          ; Registrador fonte
    mov bl, [rsi+2]          ; Registrador com endereço
    
    mov cx, [regs_16 + rbx]  ; Obtém endereço da memória
    
    cmp al, 2
    jl store_ind_16
    cmp al, 6
    jl store_ind_8
    jmp store_ind_32

store_ind_8:
    mov dl, [regs_8 + rax - 2]
    mov [memoria + rcx], dl
    add rsi, 3
    jmp next_instruction

store_ind_16:
    mov dx, [regs_16 + rax]
    mov [memoria + rcx], dx
    add rsi, 3
    jmp next_instruction

store_ind_32:
    mov edx, [regs_32 + rax - 6]
    mov [memoria + rcx], edx
    add rsi, 3
    jmp next_instruction

section .bss
memoria: resb 65536          ; 64KB de memória
; Main execution control
executa:
    push rbp
    mov rbp, rsp
    
    ; Initialize flags
    xor rax, rax
    mov [zero], al
    mov [negativo], al
    mov [carry], al
    
    ; Main execution loop
main_loop:
    movzx rax, byte [rsi]    ; Get opcode
    cmp al, 0x17             ; Check instruction limit
    ja exit_exec
    
    ; Multiply by 8 for table index (each entry is 8 bytes)
    shl rax, 3
    call [tabela_ops + rax]
    
next_instruction:
    test rsi, rsi            ; Check for program end
    jnz main_loop

exit_exec:
    mov rsp, rbp
    pop rbp
    ret

section .data
extern read_char
extern write_char
extern memoria

section .text
global executa
; Rotinas de verificação de tamanho de registrador
verify_reg_size:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, bl
    jne invalid_reg_size
    ret

invalid_reg_size:
    mov rsi, 0
    ret

; Rotinas de manipulação de pilha estendidas
push_stack:
    mov [rsp + rax], cl
    sub rsp, 8
    ret

pop_stack:
    add rsp, 8
    mov cl, [rsp + rax]
    ret

; Rotinas de debug e diagnóstico
print_flags:
    push rax
    mov al, [zero]
    call write_char
    mov al, [negativo]
    call write_char
    mov al, [carry]
    call write_char
    pop rax
    ret
; Estruturas de controle adicionais
section .data
reg_map:    db 0,0,2,3,4,5,6,7    ; Mapa de códigos para registradores

section .text
; Load imediato com verificação de tamanho
load_immediate:
    mov al, [rsi+1]
    movzx rbx, byte [reg_map + rax]
    
    cmp al, 2
    jl load_imm_16
    cmp al, 6
    jl load_imm_8
    jmp load_imm_32

load_imm_8:
    mov cl, [rsi+2]
    mov [regs_8 + rbx - 2], cl
    add rsi, 3
    jmp next_instruction

load_imm_16:
    mov cx, [rsi+2]
    mov [regs_16 + rbx], cx
    add rsi, 4
    jmp next_instruction

load_imm_32:
    mov ecx, [rsi+2]
    mov [regs_32 + rbx - 6], ecx
    add rsi, 6
    jmp next_instruction

; Rotinas de manipulação de memória otimizadas
mem_read:
    push rbx
    mov rbx, rcx
    and rbx, 0xFFFF         ; Limita endereço a 64KB
    mov al, [memoria + rbx]
    pop rbx
    ret

mem_write:
    push rbx
    mov rbx, rcx
    and rbx, 0xFFFF
    mov [memoria + rbx], al
    pop rbx
    ret
; Rotinas de tratamento de exceções
handle_overflow:
    mov byte [carry], 1
    ret

handle_invalid_opcode:
    mov rsi, 0              ; Termina execução em caso de opcode inválido
    ret

; Rotinas auxiliares para operações aritméticas
check_zero:
    test al, al
    jz set_zero_flag
    mov byte [zero], 0
    ret
set_zero_flag:
    mov byte [zero], 1
    ret

check_negative:
    test al, 0x80
    jnz set_negative_flag
    mov byte [negativo], 0
    ret
set_negative_flag:
    mov byte [negativo], 1
    ret

; Rotinas de manipulação de registradores estendidas
exchange_regs:
    mov al, [rsi+1]
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl exchange_16
    cmp al, 6
    jl exchange_8
    jmp exchange_32
exchange_8:
    mov cl, [regs_8 + rax - 2]
    mov dl, [regs_8 + rbx - 2]
    mov [regs_8 + rax - 2], dl
    mov [regs_8 + rbx - 2], cl
    add rsi, 2
    jmp next_instruction

exchange_16:
    mov cx, [regs_16 + rax]
    mov dx, [regs_16 + rbx]
    mov [regs_16 + rax], dx
    mov [regs_16 + rbx], cx
    add rsi, 2
    jmp next_instruction

exchange_32:
    mov ecx, [regs_32 + rax - 6]
    mov edx, [regs_32 + rbx - 6]
    mov [regs_32 + rax - 6], edx
    mov [regs_32 + rbx - 6], ecx
    add rsi, 2
    jmp next_instruction

; Rotinas de verificação de limites de memória
check_mem_bounds:
    cmp bx, 0xFFFF
    ja mem_out_of_bounds
    ret

mem_out_of_bounds:
    mov rsi, 0
    ret
; Rotinas de manipulação de flags estendidas
update_flags:
    pushf
    pop rax
    
    ; Atualiza Zero flag
    bt rax, 6
    setc byte [zero]
    
    ; Atualiza Negative flag
    bt rax, 7
    setc byte [negativo]
    
    ; Atualiza Carry flag
    bt rax, 0
    setc byte [carry]
    ret

; Tabela de instruções completa
section .data
instruction_table:
    dq push_reg      ; 00
    dq pop_reg       ; 01
    dq load_const    ; 02
    dq load_mem      ; 03
    dq load_ind      ; 04
    dq store_mem     ; 05
    dq store_ind     ; 06
    dq halt          ; 07
    dq add_op        ; 08
    dq sub_op        ; 09
    dq and_op        ; 0A
    dq or_op         ; 0B
    dq xor_op        ; 0C
    dq not_op        ; 0D
    dq cmp_op        ; 0E
    dq jmp_op        ; 0F
    dq jl_op         ; 10
    dq jg_op         ; 11
    dq jle_op        ; 12
    dq jge_op        ; 13
    dq jc_op         ; 14
    dq jnc_op        ; 15
    dq in_op         ; 16
    dq out_op        ; 17
; Rotinas de depuração e diagnóstico
dump_registers:
    ; Dump registradores de 8 bits
    mov rcx, 4              ; 4 registradores D
dump_8bit:
    mov al, [regs_8 + rcx - 2]
    call write_hex_byte
    loop dump_8bit

    ; Dump registradores de 16 bits
    mov rcx, 2              ; 2 registradores A
dump_16bit:
    mov ax, [regs_16 + rcx * 2 - 2]
    call write_hex_word
    loop dump_16bit

    ; Dump registradores de 32 bits
    mov rcx, 2              ; 2 registradores H
dump_32bit:
    mov eax, [regs_32 + rcx * 4 - 4]
    call write_hex_dword
    loop dump_32bit
    ret

write_hex_byte:
    push rax
    shr al, 4
    call write_hex_digit
    pop rax
    and al, 0x0F
    call write_hex_digit
    ret

write_hex_word:
    push rax
    shr ax, 8
    call write_hex_byte
    pop rax
    call write_hex_byte
    ret

write_hex_dword:
    push rax
    shr eax, 16
    call write_hex_word
    pop rax
    call write_hex_word
    ret
; Rotinas de validação e execução
validate_instruction:
    ; Verifica opcode válido
    cmp byte [rsi], 0x17
    ja invalid_opcode
    
    ; Verifica alinhamento de registradores
    mov al, [rsi+1]
    test al, 0xF0
    jz single_reg_op
    
    ; Verifica compatibilidade de tamanhos para ops com dois regs
    mov bl, al
    shr al, 4
    and bl, 0x0F
    
    cmp al, 2
    jl check_16bit_compat
    cmp al, 6
    jl check_8bit_compat
    jmp check_32bit_compat

check_8bit_compat:
    cmp bl, 2
    jl invalid_reg_combo
    cmp bl, 6
    jae invalid_reg_combo
    ret

check_16bit_compat:
    cmp bl, 2
    jae invalid_reg_combo
    ret

check_32bit_compat:
    cmp bl, 6
    jb invalid_reg_combo
    ret

single_reg_op:
    ret

invalid_reg_combo:
    mov rsi, 0
    ret
; Rotinas de manipulação de memória estendidas
memory_operations:
    ; Operações de cópia de memória
    mov_mem:
        mov al, [rsi+1]
        mov bx, [rsi+2]
        mov cx, [rsi+4]
        
        push rsi
        mov rsi, rbx        ; Endereço fonte
        mov rdi, rcx        ; Endereço destino
        mov rcx, rax        ; Quantidade de bytes
        rep movsb
        pop rsi
        ret

    ; Operações de preenchimento de memória
    fill_mem:
        mov al, [rsi+1]     ; Valor para preencher
        mov bx, [rsi+2]     ; Endereço inicial
        mov cx, [rsi+4]     ; Quantidade
        
        push rdi
        mov rdi, rbx
        rep stosb
        pop rdi
        ret

    ; Busca em memória
    search_mem:
        mov al, [rsi+1]     ; Valor a procurar
        mov bx, [rsi+2]     ; Endereço inicial
        mov cx, [rsi+4]     ; Tamanho da busca
        
        push rdi
        mov rdi, rbx
        repne scasb
        pop rdi
        ret