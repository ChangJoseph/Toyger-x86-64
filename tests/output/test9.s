.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.data
global_i: .long 0
global_p: .long 0
.text
.global main
main:
pushq %rbp
.text
movl $1, %r10d
movl %r10d, global_p(%rip)
movl $1, %r10d
movl $5, %r11d
movl %r10d, global_i(%rip)
L0:
cmpl %r11d, %r10d
jg L1
movl global_p(%rip), %r12d
movl global_i(%rip), %r13d
imull %r13d, %r12d
movl %r12d, global_p(%rip)
incl %r10d
movl %r10d, global_i(%rip)
jmp L0
L1:
movl global_p(%rip), %r10d
.text
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
.text
popq %rbp
ret
