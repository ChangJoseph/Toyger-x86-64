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

let_prime : LET             { System.out.print(file_start); System.out.print(main_start); }
          ;
end_prime : END             { System.out.print(main_end); }
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

expr		: expr ADD term     { $$.sval = expr_add_gen($1.ival,$3,ival,$1.sval,$3.sval); $$.ival = $1.ival + $3.ival; }
		| expr MINUS term       { $$.sval = expr_sub_gen($1.ival,$3,ival,$1.sval,$3.sval); $$.ival = $1.ival - $3.ival; }
		| term

term		: term MUL factor   { $$.sval = expr_mul_gen($1.ival,$3,ival,$1.sval,$3.sval); $$.ival = $1.ival * $3.ival; }
		| term DIV factor       { $$ = new Semantic($1.ival / $3.ival); }
		| factor

factor		: LP expr RP      { $$ = $2; }
		| NUMBER 
		| STRING_LITERAL 
		| ID 
		| call_stmt

print_stmt	: PRINTINT LP expr RP       { printf(print_int,     $3.ival); }
  | PRINTSTRING LP expr RP              { printf(print_string,  $3.sval); }

input_stmt	: ID ASSIGN GETINT LP RP

call_stmt	: ID LP RP 
		| ID LP expr_list RP

if_stmt	: IF rel_expr THEN statements END 
		| IF rel_expr THEN statements ELSE statements END

for_stmt	: FOR ID ASSIGN expr TO expr DO statements END

expr_list	: expr_list COMMA expr 
		| expr


%%
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
        
static String main_start = ".text\n.global main\nmain:\npushq %rbp\n";
static String main_end = ".text\npopq %rbp\nret\n";


// --- Output (printint and printstring) ---

/* first %s for str var name, second %s for actual string value */
static String string_declaration = "%s:  .string \"%s\""
// first line has %d or %s for either the int or string to print
static String print_int     = "movl $%d, %%r10d\n" +
                            "movl $LPRINT0, %%edi\n" +
                            "movl %%%s, %%esi\n" + /* %s for new var 1 */
                            "xorl %%eax, %%eax\n" +
                            "call printf\n"
static String print_string  = "movl $%s, %%r10d\n" +
                            "movl $LPRINT1, %%edi\n" +
                            "movl %%%s, %%esi\n" + /* %s for new var 1 */
                            "xorl %%eax, %%eax\n" +
                            "call printf\n"


// --- Arithmetic Expressions ---
// these functions print the correct assembly and return the live mem reg still used

// multiply expression fields/functions
static String expr_mul    = "movl $%i, %%%s\n" + /* %i for x val, %s for new mem 1 */
                            "movl $%i, %%%s\n" + /* %i for y val, %s for new mem 2 */
                            "imull %%%s, %%%s\n" /* two %s for x and y mems */
// returns the register that is still live
public String expr_mul_gen(int val1, int val2) {
  String str1 = null;
  String str2 = null;
  return expr_mul_gen(expr_mul,val1,str1,val2,str2,str1,str2);
}
public String expr_mul_gen(int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    String str1 = new_register();
  }
  if (str2 == null) {
    String str2 = new_register();
  }
  printf(expr_mul,val1,str1,val2,str2,str1,str2);
  old_register(str2);
  return str1;
}

// division expression fields/functions not used in this project

// addition expression fields/functions
static String expr_add    = "movl $%i, %%%s\n" + /* %i for x val, %s for new mem 1 */
                            "movl $%i, %%%s\n" + /* %i for y val, %s for new mem 2 */
                            "idivl %%%s, %%%s\n" /* two %s for x and y mems */
public String expr_add_gen(int val1, int val2) {
  String str1 = null;
  String str2 = null;
  return expr_add_gen(expr_add,val1,str1,val2,str2,str1,str2);
}
public String expr_add_gen(int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    String str1 = new_register();
  }
  if (str2 == null) {
    String str2 = new_register();
  }
  printf(expr_add,val1,str1,val2,str2,str1,str2);
  old_register(str2);
  return str1;
}

// subtraction expression fields/functions
static String expr_sub    = "movl $%i, %%%s\n" + /* %i for x val, %s for new mem 1 */
                            "movl $%i, %%%s\n" + /* %i for y val, %s for new mem 2 */
                            "isubl %%%s, %%%s\n" /* two %s for x and y mems */
public String expr_sub_gen(int val1, int val2) {
  String str1 = null;
  String str2 = null;
  return expr_sub_gen(expr_sub,val1,str1,val2,str2,str1,str2);
}
public String expr_sub_gen(int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    String str1 = new_register();
  }
  if (str2 == null) {
    String str2 = new_register();
  }
  printf(expr_sub,val1,str1,val2,str2,str1,str2);
  old_register(str2);
  return str1;
}


// --- Global Variable and Assignment ---

// global/static allocation fields/functions
static String global_var_init_f     = ".data\nglobal_%s:  .long 0\n" /* %s for the global variable name */
static String global_var_decl_f     = ".text\nmovl $%i, %%%s\n" + /* %i for value, %s for temp mem */
                                      "movl %%%s, global_%s(%%rip)\n" /* %s for above temp var, %s for global var name */
public void global_var_init(String name) {
  printf(global_var_init_f,name);
}
public void global_var_decl(String name, int val) {
  String reg = new_register();
  printf(global_var_decl_f,val,reg,reg,name);
  // TODO do I have to free the reg? find out if reg is only used for setting stack var(%rip) or if used past 
}


// --- Input ---

//static String get_int     = ".section  .rodata\n.LGETINT:\n  .string \"%%d\"\n.data\n"
static String get_int       = "movl $LGETINT, %%edi\n" +
                            "movl $%s, %%esi\n" + /* %s for name of the val to put getint() into */ 
                            "xorl %%eax, %%eax\n" +
                            "call scanf"

// rel expr setup
static String control_comp_setup  = "movl $%i, %%%s\n" + /* %i and %s for the first vars val and name */
                              "movl $%i, %%%s\n" /* %i and %s for the second vars val and name */
static String control_comp_not_equal    = "cmpne %%%s, %%%s\n"
static String control_comp_less         = "cmpl %%%s, %%%s\n" /* the names of the vars to cmpl */
static String control_comp_less_equal   = "cmple %%%s, %%%s\n" /* the names of the vars to cmpl */
static String control_comp_great        = "cmpg %%%s, %%%s\n" /* the names of the vars to cmpl */
static String control_comp_great_equal  = "cmpge %%%s, %%%s\n" /* the names of the vars to cmpl */
// op states: 0 <>, 1 <, 2 <=, 3 >, 4 >=
static void control_comp(int op, int val1, int val2) {
  String str1 = null;
  String str2 = null;
  return control_comp(op, val1, val2, str1, str2);
}
static void control_comp(int op, int val1, int val2, String str1, String str2) {
  if (str1 == null) {
    String str1 = new_register();
  }
  if (str2 == null) {
    String str2 = new_register();
  }
  printf(control_comp_setup,val1,str1,val2,str2) // mov 2 vals into 2 new regs
  switch(op) {
    case 0:
      printf(control_comp_not_equal,str1,str2);
      break;
    case 1:
      printf(control_comp_less,str1,str2);
      break;
    case 2:
      printf(control_comp_less_equal,str1,str2);
      break;
    case 3:
      printf(control_comp_great,str1,str2);
      break;
    case 4:
      printf(control_comp_great_equal,str1,str2);
      break;
    default:
      break;
  }
}

static String control_if  = ""


// helper fields
private ArrayList<String> register_stack = new ArrayList<String>();
private int control_label_count = -1;

// helper methods
// Get a new control statement label for any loop of any if statements
public String control_label() {
  control_label_count++;
  return "L" + control_label_count;
}

// Initialize the register stack with temp registers to be used in the code
public void init_register_stack() {
  for (int i = 15; i >= 10; i--) {
    register_stack.add("r" + i + "d"); // r10d to r15d
  }
}
// Get a new register that is not live
public String new_register() {
  String reg = register_stack.remove(register_stack.size()-1);
  if (reg == null) {
    return new_register_stack();
  }
  return reg;
}
// If no more space in register stack, use frame pointer
public String new_register_stack() {

}
// Set given register as not live and add back to stack of usable registers
public void old_register(String old_reg) {
  register_stack.add(old_register);
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

