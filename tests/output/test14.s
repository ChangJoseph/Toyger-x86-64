.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.data
get10_callee_regs: .zero 40
get10_caller_regs: .zero 64
get10_x: .long 0
.text
get10:
pushq %rbp
movq $get10_callee_regs, %rax
movq %rbx, (%rax)
movq %r12, 8(%rax)
movq %r13, 16(%rax)
movq %r14, 24(%rax)
movq %r15, 32(%rax)

movl $10, %r10d
movl %r10d, get10_x(%rip)
movl get10_x(%rip), %r10d
movl %r10d, %eax

movq $get10_callee_regs, %rdx
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

movq $main_caller_regs, %rbx 
movq %rdi, (%rbx)
movq %rsi, 8(%rbx)
movq %rdx, 16(%rbx)
movq %rcx, 24(%rbx)
movq %r8, 32(%rbx)
movq %r9, 40(%rbx)
movq %r10, 48(%rbx)
movq %r11, 56(%rbx)
call get10
movq (%rbx), %rdi
movq 8(%rbx), %rsi
movq 16(%rbx), %rdx
movq 24(%rbx), %rcx
movq 32(%rbx), %r8
movq 40(%rbx), %r9
movq 48(%rbx), %r10
movq 56(%rbx), %r11

movl %eax, %r10d
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf

popq %rbp
ret
