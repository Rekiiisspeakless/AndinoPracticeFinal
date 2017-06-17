%{
#include <stdio.h>
#include <stdlib.h>
#include "symbolTable.hpp"
#include "scanner.h"
#include "y.tab.h"
extern int lineCount;
extern char curString[2000];
extern char* yytext;
int function_main_flag = 0;
int top = 0;
int scope = 0;
SymbolTable* table;
FILE* file;
int if_label_count = 0;
int finish_label_count = 0;
%}
%union{
	int intVal;
	char idVal[4096];
}
%token KVOID KINT KDOUBLE KBOOL KCHAR KNULL KFOR KWHILE KDO KIF KELSE KSWITCH KRETURN KBREAK KCONTINUE KCONST KTRUE KFALSE KSTRUCT KCASE KDEFAULT
%token <idVal> ID
%token <intVal> INT
%token DOUBLE
%token CHAR
%token DOUBLE_MINUS DOUBLE_PLUS AND OR
%token <idVal>COMPARE
%token STRING
%token <intVal>HIGH LOW 
%token DIGIT_WRITE
%token DELAY

%type <intVal> hl

%left OR 
%left AND
%nonassoc '!'
%left COMPARE
%left '+' '-'
%left '*' '/' '%'
%left unary
%left DOUBLE_MINUS DOUBLE_PLUS
%left '[' ']'
  
%start program

%%
program: program S
	   | program function {function_main_flag = 1;}
       |
	   ;
function: function_outer{
			scope++;
		} function_inner
		;
function_outer: type ID '(' para ')'
			  | KVOID ID '(' para ')'
			  ;
function_inner:  '{'full_stats '}' 
			  ;
function_var: ID '(' lots_of_expression_var ')'
			| ID '(' ')'
		    ;
			
full_stats: stats full_stats
		  | S full_stats
          | 
		  ;
nf : stats nf
   |
   ;
stats: stat ';' 
	 | if_stat 
	 | for_loop 
	 | while_stat 
	 | do_while_stat 
	 | switch_stat
	 | digit_write ';'
	 | delay ';'
	 ;
digit_write: DIGIT_WRITE '(' INT ',' hl ')'{
				fprintf(file, "movi $r0, %d\n", $3);
				fprintf(file, "movi $r1, %d\n", $5);
				fprintf(file, "bal digitalWrite\n");
		   }
		   ;
delay: DELAY '(' expression ')'{
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		fprintf(file, "bal delay\n");
	 }
     ;
hl: HIGH{
     $$ = 1;
  }
  | LOW{
	$$ = 0;
  }
  ;
stat: ID '=' expression {
		top --;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		fprintf(file, "swi $r0, [$sp + %d]\n", table->lookup($1) * 4);
		printf("%s offset is %d\n", $1, table->lookup($1));
	}
	| ID '[' expression_var ']' stat_element_dim '=' expression 
	| ID '=' function_var 
	| function_var 
	| KBREAK  
	| KCONTINUE 
	| KRETURN expression {
		top --;
	}
	;


switch_stat: KSWITCH '(' ID ')' '{' default_stat '}'
		   | KSWITCH '(' ID ')' '{' non_default_stat '}'
		   ;
default_stat: KCASE const ':' nf default_stat
			| KDEFAULT ':' nf
			;
non_default_stat: KCASE const ':' nf non_default_case_stat 
			    ;
non_default_case_stat: KCASE const ':' nf non_default_case_stat
					 |
					 ;
const: CHAR
     | INT
	 ;

while_stat: KWHILE '(' expression ')' '{' full_stats '}'
		  ;
do_while_stat: KDO '{' full_stats '}' KWHILE '(' expression')' ';'
			 ;
if_stat: if_outer if_inner{
			fprintf(file, ".ELSE%d:\n", if_label_count);
			if_label_count++;
			fprintf(file, ".FIN%d:\n", finish_label_count);
			finish_label_count++;
	   }
	   | if_else_outer if_inner{
			fprintf(file, ".FIN%d:\n", finish_label_count);
			finish_label_count++;
	   } 
       ;
if_outer: KIF '(' expression  ')' {
			top --;
			fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
			fprintf(file, "beqz $r0, .ELSE%d\n", if_label_count);
			scope++;
			table->updateScope(scope);
	    }
		;
if_inner: '{' full_stats '}' {
			fprintf(file, "j .FIN%d\n", finish_label_count);
			int pop_count = table->pop();
			top = top - pop_count;
			scope --;
			table->updateScope(scope);
		}
		; 
if_else_outer: if_outer  if_inner KELSE{
				scope ++;
				fprintf(file, ".ELSE%d:\n", if_label_count);
				if_label_count++;
			 }
			 ;
for_loop: KFOR '('for_loop_para ';' for_loop_para ';' for_loop_para')''{' full_stats '}'
		;
for_loop_para: expression
			 | 
			 ;
stat_element_dim: '[' expression_var ']'
				|
				;
para: para ',' para_style
	| para_style
	|
	;
para_style: type ID
		  | type ID '[' INT ']' dim 
		  ;
S: type lots_of_type  ';'
 | KCONST type lots_of_const_type ';'
 ;
dim: '[' INT ']' dim
   | 
   ;
array_init: '=' '{' array_element '}'
		  |
          ;
array_element: array_element ',' expression
             |
             | expression
			 ;
lots_of_type: lots_of_type ',' type_init
		    | type_init
		    ;
lots_of_const_type: lots_of_const_type ',' const_type_init
				  | const_type_init
				  ;
const_type_init: ID '=' expression
			   ;
type_init: ID{
				table->updateScope(scope);
				table->install($1, top);
				printf("%s is install to %d\n", $1, top);
				printf("%s is install to %d\n", $1, table->lookup($1));
				top ++;
			} '=' expression{
			
			top --;
			fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
			fprintf(file, "swi  $r0, [$sp + %d]\n", table->lookup($1) * 4);
			
		 }
	     | ID{
			table->updateScope(scope);
			table->install($1, top);
			printf("%s is install to %d\n", $1, top);
			printf("%s is install to %d\n", $1, table->lookup($1));
			top++;
		 }
		 | ID '[' INT ']' dim array_init
 	     ;
type: KINT
	| KDOUBLE
	| KCHAR
	| KBOOL
	;
lots_of_expression_var: expression_var ',' lots_of_expression_var
				  | expression_var
				  ;
expression_var: '(' expression_var ')'
		  | expression_var DOUBLE_PLUS
		  | expression_var DOUBLE_MINUS
		  | expression_var '+' expression_var
		  | expression_var '-' expression_var
		  | expression_var '*' expression_var
		  | expression_var '/' expression_var
		  | expression_var '%' expression_var
		  | expression_var COMPARE expression_var
		  | expression_var AND expression_var
		  | expression_var OR expression_var
		  | '!' expression_var
		  | CHAR
          | STRING
		  | KFALSE
		  |	KTRUE
		  | UNUM
		  | ID
		  | ID '['expression_var']' stat_element_dim
		  | function_var
		  ;
expression: '(' expression ')'
		  | ID DOUBLE_PLUS{popStack("++");}
		  | ID DOUBLE_MINUS{popStack("--");}
		  | expression '+' expression{popStack("+");}
		  | expression '-' expression{popStack("-");}
		  | expression '*' expression{popStack("*");}
		  | expression '/' expression{popStack("/");}
		  | expression '%' expression{popStack("%");}
		  | expression COMPARE expression{popStack($2);}
		  | expression AND expression
		  | expression OR expression
		  | '!' expression
		  | CHAR
          | STRING
		  | KFALSE
		  |	KTRUE
		  | UNUM
		  | ID{
			printf("%s offset = %d\n", $1, table->lookup($1));
			fprintf(file, "lwi $r0, [$sp + %d]\n", table->lookup($1) * 4);
			fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
			top++;
		  }
		  ;
UNUM: '+' NUM %prec unary
	| '-' NUM %prec unary
	| NUM
	;
NUM: INT{
		fprintf(file, "movi $r0, %d\n", $1);
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}
   | DOUBLE
   ;
	   
%%
void popStack(const char* op){
	printf("op = %s!!!!!!!!!!!!!!\n", op);
	if(!strcmp(op, "+")){
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		fprintf(file, "add $r0, $r0, $r1\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}else if(!strcmp(op, "-")){
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		fprintf(file, "sub $r0, $r0, $r1\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}else if(!strcmp(op, "*")){
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		
		fprintf(file, "mul $r0, $r0, $r1\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}else if(!strcmp(op, "/")){
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		
		fprintf(file, "divsr $r0, $r2, $r0, $r1\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}else if(!strcmp(op, "%")){
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		
		fprintf(file, "divsr $r0, $r2, $r0, $r1\n");
		fprintf(file, "swi $r2, [$sp + %d]\n", top * 4);
		top++;
	}else if(!strcmp(op, "++")){
		
		
	}else if(!strcmp(op, "--")){
		

	}else if(!strcmp(op, ">")){
		printf("pop!!!!!!!!!!!!\n");
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);

		fprintf(file, "slts $r0, $r1, $r0\n");
		fprintf(file, "zeb $r0, $r0\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top ++;
	}else if(!strcmp(op, ">=")){
		printf("pop!!!!!!!!!!!!\n");
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);

		fprintf(file, "slts $r0, $r1, $r0\n");
		fprintf(file, "xori $r0, $r0, 1\n");
		fprintf(file, "zeb $r0, $r0\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top ++;
	}else if(!strcmp(op, "<")){
		printf("pop!!!!!!!!!!!!\n");
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		
		fprintf(file, "slts $r0, $r1, $r0\n");
		fprintf(file, "zeb $r0, $r0\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top ++;
	}else if(!strcmp(op, "<=")){
		printf("pop!!!!!!!!!!!!\n");
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		
		fprintf(file, "slts $r0, $r1, $r0\n");
		fprintf(file, "xori $r0, $r0, 1\n");
		fprintf(file, "zeb $r0, $r0\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}else if(!strcmp(op, "==")){
		printf("pop!!!!!!!!!!!!\n");
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);
		
		fprintf(file, "xor $r0, $r1, $r0\n");
		fprintf(file, "slti $r0, $r0, 1\n");
		fprintf(file, "zeb $r0, $r0\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}else if(!strcmp(op, "!=")){
		printf("pop!!!!!!!!!!!!\n");
		top--;
		fprintf(file, "lwi $r1, [$sp + %d]\n", top * 4);
		top--;
		fprintf(file, "lwi $r0, [$sp + %d]\n", top * 4);

		fprintf(file, "xor $r0, $r1, $r0\n");
		fprintf(file, "movi $r1, 0\n");
		fprintf(file, "slt $r0, $r1, $r0\n");
		fprintf(file, "zeb $r0, $r0\n");
		fprintf(file, "swi $r0, [$sp + %d]\n", top * 4);
		top++;
	}
}
int yyerror(const char* msg){
	fprintf(stderr, "***Error at line %d: %s\n",lineCount + 1, curString);
	fprintf(stderr,"\n");
	fprintf(stderr, "Unmatched token: %s\n", yytext);
	fprintf(stderr, "***syntax error\n");
	exit(-1);
}
int main(void)
{
	file = fopen("assembly","w");
	table = new SymbolTable();
	yyparse();
	if(function_main_flag == 0){
		curString[0] = '\0';
		printf("No main function!!\n");
		yyerror(" ");
	}
	
	fprintf(stdout, "No syntax error!\n");
	return 0;
}


