.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.text
f:
pushq %rbp
pushq %rbx
pushq %r12
pushq %r13
pushq %r14
pushq %r15
subq $128, %rsp

movl %edi, %r10d
movl $40, %r11d
addl %r11d, %r10d
movl %r10d, %eax

addq $128, %rsp
popq %r15
popq %r14
popq %r13
popq %r12
popq %rbp 
popq %rbx
ret

.text
.global main
main:
pushq %rbp
subq $128, %rsp

movl $200, %r10d
movq %rdi, 64(%rsp)
movq %rsi, 72(%rsp)
movq %rdx, 80(%rsp)
movq %rcx, 88(%rsp)
movq %r8, 96(%rsp)
movq %r9, 104(%rsp)
movq %r10, 112(%rsp)
movq %r11, 120(%rsp)
movl %r10d, %edi
call f
movq 64(%rsp), %rdi
movq 72(%rsp), %rsi
movq 80(%rsp), %rdx
movq 88(%rsp), %rcx
movq 96(%rsp), %r8
movq 104(%rsp), %r9
movq 112(%rsp), %r10
movq 120(%rsp), %r11

movl %eax, %r10d
movl $200, %r11d
addl %r11d, %r10d
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf


addq $128, %rsp
popq %rbp
ret
