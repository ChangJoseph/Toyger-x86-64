%{
import java.io.*;
import java.util.*;

%}
 
%token ADD MINUS MUL DIV EQ LT LE GT GE ASSIGN NE
%token LET IN END VAR FUNCTION IF THEN ELSE FOR TO DO PRINTINT GETINT PRINTSTRING RETURN INT_TYPE STRING_TYPE VOID
%token LP RP COLON COMMA SEQ SEMICOLON
%token NUMBER STRING_LITERAL COMMENT
%token ID

%%

program		: let_prime decs IN statements end_prime
          ;

let_prime : LET             { file_start(); main_start(); }
          ;
end_prime : END             { main_end(); }
          ;

decs  : dec  decs
      | /*epsilon*/
      ;

dec : var_dec | function_dec  ;

var_dec:  VAR ID ASSIGN expr  { global_var_decl($2.sval,$4.ival); }
      | VAR ID COLON type     { global_var_init($2.sval); /* Assuming type is always int */}
      ;

type: INT_TYPE | STRING_TYPE | VOID

function_dec	: FUNCTION ID LP parameters RP COLON type SEQ local_dec statements END 
  | FUNCTION ID LP RP COLON type SEQ local_dec statements END 

local_dec : LET var_decs IN 
  | /*epsilon*/
      ;

var_decs: var_decs var_dec
  | /*epsilon*/
      ;

parameters	: parameters COMMA parameter 
    | parameter

parameter : ID COLON type

statements	: statements SEMICOLON statement 
		| statement

statement	: assignment_stmt 
		| print_stmt 
		| input_stmt 
		| if_stmt 
		| for_stmt 
		| call_stmt 
		| return_stmt

assignment_stmt	: ID ASSIGN expr    { var_decl($1.sval,$3.ival); /* try global first; else try local stack */}

return_stmt	: RETURN expr  
    | RETURN

rel_expr		: expr EQ expr 
		| expr NE expr          { control_comp(0,$1.ival,$3.ival,$1.sval,$3.sval); }
		| expr LT expr          { control_comp(1,$1.ival,$3.ival,$1.sval,$3.sval); }
		| expr LE expr          { control_comp(2,$1.ival,$3.ival,$1.sval,$3.sval); }
		| expr GT expr          { control_comp(3,$1.ival,$3.ival,$1.sval,$3.sval); }
		| expr GE expr          { control_comp(4,$1.ival,$3.ival,$1.sval,$3.sval); }
		| LP rel_expr RP        { $$ = $2; }

expr		: expr ADD term     { $$ = new Semantic($1.ival+$3.ival, expr_add_gen($1.ival,$3.ival,$1.sval,$3.sval)); }
		| expr MINUS term       { $$ = new Semantic($1.ival-$3.ival, expr_sub_gen($1.ival,$3.ival,$1.sval,$3.sval)); }
		| term

term		: term MUL factor   { $$ = new Semantic($1.ival*$3.ival, expr_mul_gen($1.ival,$3.ival,$1.sval,$3.sval)); }
		| term DIV factor       { $$ = new Semantic($1.ival / $3.ival); }
		| factor

factor		: LP expr RP      { $$ = $2; }
		| NUMBER                { $$ = new Semantic($1); }
		| STRING_LITERAL        { $$ = new Semantic($1); }
		| ID                    { $$ = new Semantic($1); }
		| call_stmt

print_stmt	: PRINTINT LP expr RP       { print_int($3.ival); }
  | PRINTSTRING LP expr RP              { print_string($3.sval); }

input_stmt	: ID ASSIGN GETINT LP RP    { get_int($1.sval); }

call_stmt	: ID LP RP 
		| ID LP expr_list RP

if_stmt	: IF rel_expr THEN statements END 
		| IF rel_expr THEN statements ELSE statements END

for_stmt	: FOR ID ASSIGN expr TO expr DO statements END

expr_list	: expr_list COMMA expr 
		| expr


%%
// New definition for attributes non-terminals hold
static final class Semantic {
   public Integer ival;
   public String sval;
   public Semantic(Semantic sem) {
      this.ival = sem.ival;
      this.sval = sem.sval;
   }
   public Semantic(Integer ival, String sval) {
      this.ival = ival;
      this.sval = sval;
   }
   public Semantic(Integer ival) {
      this.ival = ival;
   }
   public Semantic(String sval) {
      this.sval = sval;
   }
   public Semantic() {
      this.ival = null;
      this.sval = null;
   }
}

// --- Basic Fields ---
static String pass_msg = "Input passed checking\n";
static String syn_err_msg = "Syntax Error: Line %d\n";
static String undefined_err_msg = 
        "Semantic Error: Line %d: ID %s not defined\n";
static String duplicate_err_msg = 
        "Semantic Error: Line %d: ID %s duplicate definition\n";
static String type_err_msg = "Semantic Error: Line %d: ID %s type error\n";

// --- File Start and End ---

static String file_start = ".section .rodata\n" +
                            "LPRINT0:\n  .string \"%%d\\n\"\n" +
                            "LPRINT1:\n  .string \"%%s\\n\"\n" +
                            "LGETINT:\n  .string \"%%d\"\n"; 
static void file_start() {
  System.out.printf(file_start);
}
        
static String main_start = ".text\n.global main\nmain:\npushq %%rbp\n";
static void main_start() {
  System.out.printf(main_start);
}
static String main_end = ".text\npopq %%rbp\nret\n";
static void main_end() {
  System.out.printf(main_end);
}


// --- Output (printint and printstring) ---


// first line has %d or %s for either the int or string to print
static String print_int     = "movl $%d, %%%s\n" + /* %d is the val to print, %s for new var 1 */
                            "movl $LPRINT0, %%edi\n" +
                            "movl %%%s, %%esi\n" + /* %s for new var 1 */
                            "xorl %%eax, %%eax\n" +
                            "call printf\n";
static void print_int(int val) {
  String reg = new_register();
  System.out.printf(print_int,val,reg,reg);
  old_register(reg);
}
static int str_num = -1;
static String print_string= "%s:  .string \"%s\"\n" +
                            "movl $%s, %%%s\n" + /* %s is the val to print, %s for new var 1 */
                            "movl $LPRINT1, %%edi\n" +
                            "movl %%%s, %%esi\n" + /* %s for new var 1 */
                            "xorl %%eax, %%eax\n" +
                            "call printf\n";
static void print_string(String str) {
  String reg = new_register();
  String label = "str" + ++str_num;
  System.out.printf(print_string,label,str,label,reg,reg);
  old_register(reg);
}

// --- Arithmetic Expressions ---
// these functions print the correct assembly and return the live mem reg still used

// multiply expression fields/functions
static String expr_mul    = "movl $%i, %%%s\n" + /* %i for x val, %s for new mem 1 */
                            "movl $%i, %%%s\n" + /* %i for y val, %s for new mem 2 */
                            "imull %%%s, %%%s\n"; /* two %s for x and y mems */
// returns the register that is still live
static String expr_mul_gen(int val1, int val2) {
  String str1 = null;
  String str2 = null;
  return expr_mul_gen(val1,val2,str1,str2);
}
static String expr_mul_gen(int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    str1 = new_register();
  }
  if (str2 == null) {
    str2 = new_register();
  }
  System.out.printf(expr_mul,val1,str1,val2,str2,str1,str2);
  old_register(str2);
  return str1;
}

// division expression fields/functions not used in this project

// addition expression fields/functions
static String expr_add    = "movl $%i, %%%s\n" + /* %i for x val, %s for new mem 1 */
                            "movl $%i, %%%s\n" + /* %i for y val, %s for new mem 2 */
                            "idivl %%%s, %%%s\n"; /* two %s for x and y mems */
static String expr_add_gen(int val1, int val2) {
  String str1 = null;
  String str2 = null;
  return expr_add_gen(val1,val2,str1,str2);
}
static String expr_add_gen(int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    str1 = new_register();
  }
  if (str2 == null) {
    str2 = new_register();
  }
  System.out.printf(expr_add,val1,str1,val2,str2,str1,str2);
  old_register(str2);
  return str1;
}

// subtraction expression fields/functions
static String expr_sub    = "movl $%i, %%%s\n" + /* %i for x val, %s for new mem 1 */
                            "movl $%i, %%%s\n" + /* %i for y val, %s for new mem 2 */
                            "isubl %%%s, %%%s\n"; /* two %s for x and y mems */
static String expr_sub_gen(int val1, int val2) {
  String str1 = null;
  String str2 = null;
  return expr_sub_gen(val1,val2,str1,str2);
}
static String expr_sub_gen(int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    str1 = new_register();
  }
  if (str2 == null) {
    str2 = new_register();
  }
  System.out.printf(expr_sub,val1,str1,val2,str2,str1,str2);
  old_register(str2);
  return str1;
}


// --- Global Variable and Assignment ---

// global/static allocation fields/functions
static ArrayList<String> global_vars = new ArrayList<String>();

static String global_var_init_f     = ".data\nglobal_%s:  .long 0\n"; /* %s for the global variable name */
static String global_var_decl_f     = ".text\nmovl $%i, %%%s\n" + /* %i for value, %s for temp mem */
                                      "movl %%%s, global_%s(%%rip)\n"; /* %s for above temp var, %s for global var name */
static void global_var_init(String name) {
  global_vars.add(name);
  System.out.printf(global_var_init_f,name);
}
// Returns the reg that contains the var value
static String global_var_decl(String name, int val) {
  if (!global_vars.contains(name)) global_vars.add(name);
  String reg = new_register();
  System.out.printf(global_var_decl_f,val,reg,reg,name);
  return reg;
  // TODO do I have to free the reg? find out if reg is only used for setting stack var(%rip) or if used past 
}


// --- Local Variable and Assignment ---

static String local_var_decl_f      = ".text\nmovl $%i, %%%s\n"; /* %i for value, %s for reg to store in */
// returns reg with the var value
static String var_decl(String name, int val) {
  if (global_vars.contains(name)) {
    global_var_decl(name, val);
  }
  else {
    String reg = new_register();
    System.out.printf(local_var_decl_f,val,reg);
    return reg;
  }
  return null;
}


// --- Input ---

static String get_int_f     = "movl $LGETINT, %%edi\n" +
                            "movl $%s, %%esi\n" + /* %s for name of the val to put getint() into */ 
                            "xorl %%eax, %%eax\n" +
                            "call scanf";
static void get_int(String name) {
  System.out.printf(get_int_f,name);
}
// TODO ************ check if i need to change $var for if global or local
// maybe change global vars so that "global_" is in the name
// Also probably have to free the reg in global var declarations because it is a label


// --- Control Flow ---

// rel expr setup
static String control_comp_setup        = "movl $%i, %%%s\n" + /* %i and %s for the first vars val and name */
                                          "movl $%i, %%%s\n"; /* %i and %s for the second vars val and name */
static String control_comp_not_equal    = "cmpl %%%s, %%%s\n" +
                                          "setne %%al\n" +
                                          "movzbl %%al, $$eax\n" +
                                          "cmpl $0, %%eax\n" +
                                          "je L%i\n"; /* %i for the next label */
static String control_comp_less         = "cmpl %%%s, %%%s\n" +
                                          "setl %%al\n" +
                                          "movzbl %%al, $$eax\n" +
                                          "cmpl $0, %%eax\n" +
                                          "je L%i\n"; /* the names of the vars to cmpl */
static String control_comp_less_equal   = "cmpl %%%s, %%%s\n" +
                                          "setle %%al\n" +
                                          "movzbl %%al, $$eax\n" +
                                          "cmpl $0, %%eax\n" +
                                          "je L%i\n"; /* the names of the vars to cmpl */
static String control_comp_great        = "cmpl %%%s, %%%s\n" +
                                          "setg %%al\n" +
                                          "movzbl %%al, $$eax\n" +
                                          "cmpl $0, %%eax\n" +
                                          "je L%i\n"; /* the names of the vars to cmpl */
static String control_comp_great_equal  = "cmpl %%%s, %%%s\n" +
                                          "setge %%al\n" +
                                          "movzbl %%al, $$eax\n" +
                                          "cmpl $0, %%eax\n" +
                                          "je L%i\n"; /* the names of the vars to cmpl */
static String control_comp_for          = "movl %%%s, global_%s(%%rip)\n" +
                                          "L%i:\n" + /* %i for the next label */
                                          "cmpl %%%s, %%%s\n" +
                                          "setne %%al\n" +
                                          "movzbl %%al, $$eax\n" +
                                          "cmpl $0, %%eax\n" +
                                          "je L%i\n";
// op states: 0 <>, 1 <, 2 <=, 3 >, 4 >=
static void control_comp(int op, int val1, int val2) {
  String str1 = null;
  String str2 = null;
  control_comp(op, val1, val2, str1, str2);
}
static void control_comp(int op, int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    str1 = new_register();
  }
  if (str2 == null) {
    str2 = new_register();
  }
  System.out.printf(control_comp_setup,val1,str1,val2,str2); // mov 2 vals into 2 new regs
  switch(op) {
    case 0:
      System.out.printf(control_comp_not_equal,str1,str2);
      break;
    case 1:
      System.out.printf(control_comp_less,str1,str2);
      break;
    case 2:
      System.out.printf(control_comp_less_equal,str1,str2);
      break;
    case 3:
      System.out.printf(control_comp_great,str1,str2);
      break;
    case 4:
      System.out.printf(control_comp_great_equal,str1,str2);
      break;
    default:
      break;
  }
}

static String control_if  = "";


// -- Procedure Call/Return ---

static String proc_init     = ".data\nf_callee_regs:.zero 40\nf_caller_regs:.zero 64\n";
// Callee
static String proc_prologue = "pushq %%rbp\n" +
                              "movq $f_callee_regs, %%rax\n" +
                              "movq %%rbx, (%%rax)\n" +
                              "movq %%r12, 8(%%rax)\n" +
                              "movq %%r13, 16(%%rax)\n" +
                              "movq %%r14, 24(%%rax)\n" +
                              "movq %%r15, 32(%%rax)\n";
static String proc_epilogue = "movq $f_callee_regs, %%rdx\n" +
                              "movq (%%rdx), %%rbx\n" +
                              "movq 8(%%rdx), %%r12\n" +
                              "movq 16(%%rdx), %%r13\n" +
                              "movq 24(%%rdx), %%r14\n" +
                              "movq 32(%%rdx), %%r15\n" +
                              "popq %%rbp\n" +
                              "ret\n";
// Caller (must call function between the pre/post calls)
static String proc_pre_call = "movq $f_caller_regs, %%rbx\n" +
                              "movq %%rdi, (%%rbx)\n" +
                              "movq %%rsi, 8(%%rbx)\n" +
                              "movq %%rdx, 16(%%rbx)\n" +
                              "movq %%rcx, 24(%%rbx)\n" +
                              "movq %%r8, 32(%%rbx)\n" +
                              "movq %%r9, 40(%%rbx)\n" +
                              "movq %%r10, 48(%%rbx)\n" +
                              "movq %%r11, 56(%%rbx)\n";
static String proc_post_call = "movq (%%rdx), %%rdi\n" +
                              "movq 8(%%rdx), %%rsi\n" +
                              "movq 16(%%rdx), %%rdx\n" +
                              "movq 24(%%rdx), %%rcx\n" +
                              "movq 32(%%rdx), %%r8\n" +
                              "movq 40(%%rdx), %%r9\n" +
                              "movq 48(%%rdx), %%r10\n" +
                              "movq 56(%%rdx), %%r11\n";

// helper fields
static ArrayList<String> register_stack = new ArrayList<String>();
static int control_label_count = -1;

// helper methods
// Get a new control statement label for any loop of any if statements
static String control_label() {
  control_label_count++;
  return "L" + control_label_count;
}

// Initialize the register stack with temp registers to be used in the code
static void init_register_stack() {
  for (int i = 15; i >= 10; i--) {
    register_stack.add("r" + i + "d"); // r10d to r15d
  }
}
// Get a new register that is not live
static String new_register() {
  if (register_stack.size() <= 0) {
    return new_register_stack();
  }
  String reg = register_stack.remove(register_stack.size()-1);
  return reg;
}
// If no more space in register stack, use frame pointer
static String new_register_stack() {
  return null;
}
// Set given register as not live and add back to stack of usable registers
static void old_register(String old_reg) {
  register_stack.add(old_reg);
}


private lexer scanner; 
private int yylex() {
  int retVal = -1;

  try { 
     retVal = scanner.yylex(); 
  } catch (IOException e) { 
     System.err.println("IO Error:" + e); 
  } 
  return retVal; 
}

public void yyerror (String error) {
  System.err.format(syn_err_msg, scanner.getLine()+1); 
  System.exit(-1);
}

public p4_java (Reader r) { 
   scanner = new lexer (r, this); 
} 

public static void main (String [] args) throws IOException {
   p4_java yyparser = new p4_java(new InputStreamReader(System.in));

  init_register_stack();

   yyparser.yyparse(); 
   System.err.print(pass_msg);

}

