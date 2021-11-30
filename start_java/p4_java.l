import java.io.*; 

 /* lex comments: cannot start with the leftmost location of a line */
 /* addtional imports/ declarations here */

%% 

%class lexer
%unicode 
%byaccj
%line

%eofval{
	return 0; //returns zero for EOF
%eofval}

%{ 

static String token_err_msg = "Lexical Error: line %d\n";

private p4_java yyparser;
public lexer (java.io.Reader r, p4_java yyparser) {
    this (r); 
    this.yyparser = yyparser; 
} 

public int getLine() { return yyline; }
 /* additional definitions here */

%} 

 /* regular definitions */
number = 0|[1-9][0-9]*
id = [a-zA-Z][a-zA-Z_0-9]*
string = \"(\\\"|[^\"\n])*\"
comment = "//"[^\n]*


%%

 /* keywords */
let 	{ return(p4_java.LET); }
in 	{ return(p4_java.IN); }
end 	{ return(p4_java.END); }
var 	{ return(p4_java.VAR); }
function	{ return(p4_java.FUNCTION); }
printint 	{ return(p4_java.PRINTINT); }
printstring 	{ return(p4_java.PRINTSTRING); }
getint {return(p4_java.GETINT); }
return 	{ return(p4_java.RETURN); }
if 	{ return(p4_java.IF); }
then { return(p4_java.THEN); }
else 	{ return(p4_java.ELSE); }
for { return(p4_java.FOR); }
to 	{ return(p4_java.TO); }
do 	{ return(p4_java.DO); }
void { return(p4_java.VOID); }
int { return(p4_java.INT_TYPE); }
string { return(p4_java.STRING_TYPE);}

 /* operators */
\+ 	{ return(p4_java.ADD); }
-	{ return(p4_java.MINUS); }
\* 	{ return(p4_java.MUL); }
\/ 	{ return(p4_java.DIV); }
== 	{ return(p4_java.EQ); }
\< 	{ return(p4_java.LT); }
\<= 	{ return(p4_java.LE); }
\> 	{ return(p4_java.GT); }
\>= 	{ return(p4_java.GE); }
:= 	{ return(p4_java.ASSIGN); }
\<\> 	{ return(p4_java.NE); }

 /* punctuations */
\( 	{ return(p4_java.LP); }
\) 	{ return(p4_java.RP); }
: 	{ return(p4_java.COLON); }
, 	{ return(p4_java.COMMA); }
=   { return(p4_java.SEQ); }
;   { return(p4_java.SEMICOLON); }

{id}	{  
     return(p4_java.ID); }

{number} { return(p4_java.NUMBER); } 
{string} { 
        return(p4_java.STRING_LITERAL); }
{comment} { ; }
[ \t\n]  { ; }

. 	{ 
 	  System.err.format(token_err_msg, yyline+1); 
    System.exit(-1);
	}


 
	/* compiled with --legacydot so that . matches [^\n] instead of
		[^\n\r\u000B\u000C\u0085\u2028\u2029] */
 

