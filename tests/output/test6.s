.section .rodata
LPRINT0:
  .string "%d\n"
LPRINT1:
  .string "%s\n"
LGETINT:
  .string "%d"
.data
global_x: .long 0
global_y: .long 0
.text
.global main
main:
pushq %rbp
.text
movl $5,%r10d
movl %r10d, global_x(%rip)
movl global_x(%rip), %r10d
movl $2, %r11d
imull %r11d, %r10d 
movl %r10d, global_y(%rip)
movl global_y(%rip), %r10d
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
.text
popq %rbp
ret
