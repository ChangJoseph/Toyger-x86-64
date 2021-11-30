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

program		: { System.out.print(file_start); }
  LET decs IN statements END

decs  : dec  decs
      | 

dec : var_dec | function_dec 

var_dec:  VAR ID ASSIGN expr
      | VAR ID COLON type

type: INT_TYPE | STRING_TYPE | VOID

function_dec	: FUNCTION ID LP parameters RP COLON type SEQ local_dec statements END 
  | FUNCTION ID LP RP COLON type SEQ local_dec statements END 

local_dec : LET var_decs IN 
  | 

var_decs: var_decs var_dec
  | 

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

assignment_stmt	: ID ASSIGN expr

return_stmt	: RETURN expr  
    | RETURN

rel_expr		: expr EQ expr 
		| expr NE expr 
		| expr LT expr 
		| expr LE expr 
		| expr GT expr 
		| expr GE expr 
		| LP rel_expr RP

expr		: expr ADD term 
		| expr MINUS term 
		| term

term		: term MUL factor 
		| term DIV factor 
		| factor

factor		: LP expr RP 
		| NUMBER 
		| STRING_LITERAL 
		| ID 
		| call_stmt

print_stmt	: PRINTINT LP expr RP
  | PRINTSTRING LP expr RP

input_stmt	: ID ASSIGN GETINT LP RP

call_stmt	: ID LP RP 
		| ID LP expr_list RP

if_stmt	: IF rel_expr THEN statements END 
		| IF rel_expr THEN statements ELSE statements END

for_stmt	: FOR ID ASSIGN expr TO expr DO statements END

expr_list	: expr_list COMMA expr 
		| expr


%%
static String pass_msg = "Input passed checking\n";
static String syn_err_msg = "Syntax Error: Line %d\n";
static String undefined_err_msg = 
        "Semantic Error: Line %d: ID %s not defined\n";
static String duplicate_err_msg = 
        "Semantic Error: Line %d: ID %s duplicate definition\n";
static String type_err_msg = "Semantic Error: Line %d: ID %s type error\n";

static String file_start = ".section .rodata\n" +
                            "LPRINT0:\n  .string \"%%d\\n\"\n" +
                            "LPRINT1:\n  .string \"%%s\\n\"\n" +
                            "LGETINT:\n  .string \"%%d\"\n"; 
        
static String main_start = ".text\n.global main\nmain:\npushq %rbp\n";
static String main_end = ".text\npopq %rbp\nret\n";

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
   yyparser.yyparse(); 
   System.err.print(pass_msg);

}

