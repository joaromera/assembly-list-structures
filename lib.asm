section .data

NULL_STRING dw "NULL"

section .rodata

section .text

extern malloc
extern free
extern fprintf

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listRemove
global listRemoveFirst
global listRemoveLast
global listDelete
global listPrint
global n3treeNew
global n3treeAdd
global n3treeRemoveEq
global n3treeDelete
global nTableNew
global nTableAdd
global nTableRemoveSlot
global nTableDeleteSlot
global nTableDelete

strLen:
    push rbp
    mov rbp, rsp

    push rdi
    xor rax, rax

.loop:
    cmp byte [rdi], 0
    je .end
    inc rax
    inc rdi
    jmp .loop

.end:
    pop rdi
    pop rbp
    ret


strClone:
    push rbp
    mov rbp, rsp
    push rdi
    push r12
    push r13
    push r14

    mov r12, rdi
    call strLen
    mov r13, rax

    mov rdi, rax
    inc rdi
    call malloc
    
    xor rcx, rcx
.loop:
    cmp rcx, r13
    je .end
    mov r14b, byte [r12 + rcx]
    mov byte [rax + rcx], r14b
    inc rcx
    jmp .loop

.end:
    mov byte [rax + rcx], 0
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rbp
    ret


strCmp:
    push rbp
    mov rbp, rsp

    xor rax, rax
    xor rcx, rcx

.loop:
    cmp byte [rdi + rcx], 0
    je .rdiMaybeShortest
    mov dl, byte [rdi + rcx]
    cmp byte [rsi + rcx], dl
    jg .rdiShortest
    jl .rsiShortest
    inc rcx
    jmp .loop

.rdiMaybeShortest:
    cmp byte [rsi + rcx], 0
    je .end
    jmp .rdiShortest

.rdiShortest:
    mov rax, 1
    jmp .end

.rsiShortest:
    mov rax, -1
    jmp .end

.end:
    pop rbp
    ret

strConcat:
    push rbp
    mov rbp, rsp



    pop rbp
    ret

strDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret
 
strPrint:
    push rbp
    mov rbp, rsp
    push rdi
    push rsi

    cmp byte [rdi], 0
    je .printNULL

    xchg rdi, rsi
    call fprintf
    jmp .end

.printNULL:
    mov dword rdi, NULL_STRING
    xchg rdi, rsi
    call fprintf

.end:
    pop rsi
    pop rdi
    pop rbp
    ret


listNew:
    ret

listAddFirst:
    ret

listAddLast:
    ret

listAdd:
    ret

listRemove:
    ret

listRemoveFirst:
    ret

listRemoveLast:
    ret

listDelete:
    ret

listPrint:
    ret

n3treeNew:
    ret

n3treeAdd:
    ret

n3treeRemoveEq:
    ret

n3treeDelete:
    ret

nTableNew:
    ret

nTableAdd:
    ret
    
nTableRemoveSlot:
    ret
    
nTableDeleteSlot:
    ret

nTableDelete:
    ret
