.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.data
my_print_callee_regs: .zero 40
my_print_caller_regs: .zero 64
.text
my_print:
.text
pushq %rbp
movq $my_print_callee_regs, %rax
movq %rbx, (%rax)
movq %r12, 8(%rax)
movq %r13, 16(%rax)
movq %r14, 24(%rax)
movq %r15, 32(%rax)

movl %edi, %r10d
movl $40, %r11d
addl %r11d, %r10d
movq $my_print_caller_regs, %rbx 
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

movl %edi, %r10d
movl $40, %r11d
subl %r11d, %r10d
movq $my_print_caller_regs, %rbx 
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

movq $my_print_callee_regs, %rdx
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

movl $400, %r10d
movq $main_caller_regs, %rbx 
movq %rdi, (%rbx)
movq %rsi, 8(%rbx)
movq %rdx, 16(%rbx)
movq %rcx, 24(%rbx)
movq %r8, 32(%rbx)
movq %r9, 40(%rbx)
movq %r10, 48(%rbx)
movq %r11, 56(%rbx)
movl %r10d, %edi
call my_print
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
