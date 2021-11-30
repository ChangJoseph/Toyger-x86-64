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
movl $5, %r10d
movl $3, %r11d
cmpl %r11d,%r10d
setg %al
movzbl %al, %eax
cmpl $0, %eax
je L0
movl $5, %r10d
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
L0:
.text
popq %rbp
ret
