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
popq %rbp
ret
