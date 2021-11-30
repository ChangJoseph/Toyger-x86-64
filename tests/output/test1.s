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
.section .rodata
str0: .string "Hello World!\n"
.text
movl $str0, %r10d
.text
movl $LPRINT1, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
.text
popq %rbp
ret
