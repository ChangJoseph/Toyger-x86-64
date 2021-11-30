.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.data
f_callee_regs: .zero 40
f_caller_regs: .zero 64

.text
f:
pushq %rbp
movq $f_callee_regs, %rax
movq %rbx, (%rax)
movq %r12, 8(%rax)
movq %r13, 16(%rax)
movq %r14, 24(%rax)
movq %r15, 32(%rax)
movl $1, %r10d
movq $f_caller_regs, %rbx 
movq %rdi, (%rbx)
movq %rsi, 8(%rbx)
movq %rdx, 16(%rbx)
movq %rcx, 24(%rbx)
movq %r8, 32(%rbx)
movq %r9, 40(%rbx)
movq %r10, 48(%rbx)
movq %r11, 56(%rbx)
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
movq (%rbx), %rdi
movq 8(%rbx), %rsi
movq 16(%rbx), %rdx
movq 24(%rbx), %rcx
movq 32(%rbx), %r8
movq 40(%rbx), %r9
movq 48(%rbx), %r10
movq 56(%rbx), %r11
movq $f_callee_regs, %rdx
movq (%rdx), %rbx
movq 8(%rdx), %r12
movq 16(%rdx), %r13
movq 24(%rdx), %r14
movq 32(%rdx), %r15
popq %rbp
ret

.text
.global main
main:
.data
main_caller_regs:.zero 64
.text
pushq %rbp

movl $0, %r10d
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf

movq $main_caller_regs, %rbx 
movq %rdi, (%rbx)
movq %rsi, 8(%rbx)
movq %rdx, 16(%rbx)
movq %rcx, 24(%rbx)
movq %r8, 32(%rbx)
movq %r9, 40(%rbx)
movq %r10, 48(%rbx)
movq %r11, 56(%rbx)
call f
movq (%rbx), %rdi
movq 8(%rbx), %rsi
movq 16(%rbx), %rdx
movq 24(%rbx), %rcx
movq 32(%rbx), %r8
movq 40(%rbx), %r9
movq 48(%rbx), %r10
movq 56(%rbx), %r11

popq %rbp
ret
