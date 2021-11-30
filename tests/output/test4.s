.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.data
global_x: .long 0
.text
.global main
main:
pushq %rbp
.section .rodata
str0: .string "enter an integer:"
.text
movl $str0, %r10d
.text
movl $LPRINT1, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
.text
movl $LGETINT, %edi
movl $global_x, %esi
xorl %eax, %eax
call scanf
.text
movl global_x(%rip), %r10d
.text
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
.text
movl global_x(%rip), %r10d
.text
movl %r10d, %eax
.text
popq %rbp
ret
