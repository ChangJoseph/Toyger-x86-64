.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.text
.global main
main:
pushq %rbp
.text
movl $440, %r10d
.text
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
.text
popq %rbp
ret
