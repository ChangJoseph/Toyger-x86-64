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
.section .rodata
str0: .string "enter an integer:"
.text
movl $str0, %r10d
.text
movl $LPRINT1, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
movl $LGETINT, %edi
movl $global_x, %esi
xorl %eax, %eax
call scanf
movl global_x(%rip), %r10d
movl $3, %r11d
cmpl %r11d, %r10d
setg %al
movzbl %al, %eax
cmpl $0, %eax
je L1
.section .rodata
str1: .string ">3"
.text
movl $str1, %r10d
.text
movl $LPRINT1, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
jmp L2
L1:
.section .rodata
str2: .string "<=3"
.text
movl $str2, %r10d
.text
movl $LPRINT1, %edi
movl %r10d, %esi
xorl %eax, %eax
call printf
L2:
.text
popq %rbp
ret
