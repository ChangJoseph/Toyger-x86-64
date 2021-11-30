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
.text
movl $5,%r10d
movl $8,%r11d
imull %r11d, %r10d 
movl $3, %r11d
movl $2, %r12d
imull %r12d, %r11d 
subl %r11d, %r10d
movl %r10d, global_x(%rip)
movl global_x(%rip), %r10d
movl $LPRINT0, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
.text
popq %rbp
ret
