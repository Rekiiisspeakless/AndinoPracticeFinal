%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
int lineCount = 0;
int sourceStart = 0;
int tokenStart = 0;
int lineLength;
char curString[2000];
char tempString[2000];
int pragmaSourceFlag = 1;
int pragmaTokenFlag = 1;
int commentFlag = 0;
%}
key	"void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"
keyFunc "fclose"|"clearerr"|"feof"|"ferror"|"fflush"|"fgetpos"|"fopen"|"fread"|"freopen"|"fseek"|"fsetpos"|"ftell"|"fwrite"|"remove"|"rename"|"rewind"|"setbuf"|"setvbuf"|"tmpfile"|"tmpnam"|"fprintf"|"printf"|"sprintf"|"vfprintf"|"vprintf"|"vsprintf"|"fscanf"|"scanf"|"sscanf"|"fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"|"perror"
op	(\+|\*|-|\/|\%|\+\+|--|<|<=|>|>=|==|!=|=|\&\&|\|\||!|\&)
punc	(:|;|,|\.|\[|\]|\(|\)|\{|\})
double ([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)
integer ([0]|[1-9][0-9]*)
char	('.'|'\\n'|'\\t')
%x	COMMENT
%x	PARSE
%%
.*\n	{
		lineCount++;
		
		if(strcmp(yytext, "#pragma source off\n") == 0){
			pragmaSourceFlag = 0;
			sourceStart = 1;
		}else if(strcmp(yytext, "#pragma source on\n") == 0){
			pragmaSourceFlag = 1;
			sourceStart = 1;
		}
		
		if(strcmp(yytext, "#pragma token off\n") == 0){
			pragmaTokenFlag = 0;
			tokenStart = 1;
		}else if(strcmp(yytext, "#pragma token on\n") == 0){
			pragmaTokenFlag = 1;
			tokenStart = 1;
		}
		
		strcpy(curString, yytext);
		yyless(0);
		if(commentFlag != 1){
			BEGIN PARSE;
		}else if(commentFlag == 1){
			BEGIN COMMENT;
		}
		
		}
<COMMENT>\*\/	{
					if(commentFlag != 1){
						//printf("commentFlag != 1\n");
						REJECT;
					}else{
						commentFlag = 0;
						//printf("comment end\n");
						BEGIN PARSE;
					}
				}
<COMMENT>\n	{
				if(pragmaSourceFlag == 1){
					printf("%d:%s",lineCount , curString);
				}
				BEGIN 0;
			}
<COMMENT>.	{}

			
<PARSE>\n	{
				if(pragmaSourceFlag == 1){
					printf("%d:%s",lineCount , curString);
				}
				
				BEGIN 0;
				
			}
<PARSE>"#pragma source off"
<PARSE>"#pragma source on"
<PARSE>"#pragma token off"
<PARSE>"#pragma token on"
<PARSE>\/\/.*	{}
<PARSE>\/\*.*\*\/	{}
<PARSE>\/\*	{
				commentFlag = 1;
				//printf("comment start\n");
				BEGIN COMMENT;
			}
<PARSE>" "
<PARSE>\t

<PARSE>{key}	{
					if(pragmaTokenFlag == 1){
						printf("#key:%s\n",yytext);
					}
					if(!strcmp(yytext, "void")){
						return KVOID;
					}
					if(!strcmp(yytext, "int")){
						return KINT;
					}
					if(!strcmp(yytext, "double")){
						return KDOUBLE;
					}
					if(!strcmp(yytext, "bool")){
						return KBOOL;
					}
					if(!strcmp(yytext, "void")){
						return KVOID;
					}
					if(!strcmp(yytext, "char")){
						return KCHAR;
					}
					if(!strcmp(yytext, "null")){
						return KNULL;
					}
					if(!strcmp(yytext, "for")){
						return KFOR;
					}
					if(!strcmp(yytext, "while")){
						return KWHILE;
					}
					if(!strcmp(yytext, "do")){
						return KDO;
					}
					if(!strcmp(yytext, "if")){
						return KIF;
					}
					if(!strcmp(yytext, "else")){
						return KELSE;
					}
					if(!strcmp(yytext, "switch")){
						return KSWITCH;
					}
					if(!strcmp(yytext, "return")){
						return KRETURN;
					}
					if(!strcmp(yytext, "break")){
						return KBREAK;
					}
					if(!strcmp(yytext, "continue")){
						return KCONTINUE;
					}
					if(!strcmp(yytext, "const")){
						return KCONST;
					}
					if(!strcmp(yytext, "true")){
						return KTRUE;
					}
					if(!strcmp(yytext, "false")){
						return KFALSE;
					}
					if(!strcmp(yytext, "struct")){
						return KSTRUCT;
					}
					if(!strcmp(yytext, "case")){
						return KCASE;
					}
					if(!strcmp(yytext, "default")){
						return KDEFAULT;
					}
				}
<PARSE>{keyFunc}	{
						if(pragmaTokenFlag == 1){
							printf("#key:%s\n",yytext);
						}
						return ID;
					}
<PARSE>{op}	{
				if(pragmaTokenFlag == 1){
					printf("#op:%s\n",yytext);
				}
				if(!strcmp(yytext, "+")){
					return '+';
				}
				if(!strcmp(yytext, "-")){
					return '-';
				}
				if(!strcmp(yytext, "*")){
					return '*';
				}
				if(!strcmp(yytext, "/")){
					return '/';
				}
				if(!strcmp(yytext, "%")){
					return '%';
				}
				if(!strcmp(yytext, "++")){
					return DOUBLE_PLUS;
				}
				if(!strcmp(yytext, "--")){
					return DOUBLE_MINUS;
				}
				if(!strcmp(yytext, "<")){
					strcpy(yylval.idVal, yytext);
					return COMPARE;
				}
				if(!strcmp(yytext, ">")){
					strcpy(yylval.idVal, yytext);
					return COMPARE;
				}
				if(!strcmp(yytext, "<=")){
					strcpy(yylval.idVal, yytext);
					return COMPARE;
				}
				if(!strcmp(yytext, ">=")){
					strcpy(yylval.idVal, yytext);
					return COMPARE;
				}
				if(!strcmp(yytext, "==")){
					strcpy(yylval.idVal, yytext);
					return COMPARE;
				}
				if(!strcmp(yytext, "!=")){
					strcpy(yylval.idVal, yytext);
					return COMPARE;
				}
				if(!strcmp(yytext, "=")){
					return '=';
				}
				if(!strcmp(yytext, "&&")){
					strcpy(yylval.idVal, yytext);
					return AND;
				}
				if(!strcmp(yytext, "||")){
					strcpy(yylval.idVal, yytext);
					return OR;
				}
				if(!strcmp(yytext, "!")){
					return '!';
				}
			}
<PARSE>{punc}	{
					if(pragmaTokenFlag == 1){
						printf("#punc:%s\n",yytext);
					}
					return yytext[0];
				}
<PARSE>[a-zA-Z_][a-zA-Z_0-9]*	{
									if(pragmaTokenFlag == 1){
										printf("#id:%s\n",yytext);
									}
									if(!strcmp("digitalWrite", yytext)){
										printf("digital write!!\n");
										return DIGIT_WRITE;
									}
									if(!strcmp("HIGH", yytext)){
										printf("HIGH!!\n");
										return HIGH;
									}
									if(!strcmp("LOW", yytext)){
										printf("LOW!!\n");
										return LOW;
									}
									if(!strcmp("delay", yytext)){
										printf("delay!!\n");
										return DELAY;
									}
									strcpy(yylval.idVal, yytext);
									return ID;
								}
<PARSE>[0][0-9]+	{
					fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}
<PARSE>[0-9]+[a-zA-Z]	{
						fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}
<PARSE>{integer}	{
						if(pragmaTokenFlag == 1){
							printf("#integer:%s\n",yytext);
						}
						yylval.intVal = atoi(yytext);
						return INT;
					}
						
<PARSE>{double}	{
					if(pragmaTokenFlag == 1){
						printf("#double:%s\n",yytext);
					}
					return DOUBLE;
				}
<PARSE>([0-9]+|{double})[Ee][+-]?[0-9]+	{
											if(pragmaTokenFlag == 1){
												printf("#sci:%s\n",yytext);
											}
											return DOUBLE;
										}
<PARSE>{char}	{
					if(pragmaTokenFlag == 1){
						printf("#char:%s\n",yytext);
					}
					return CHAR;
				}
<PARSE>\"([^\n"]|\\\")*\"	{
						if(pragmaTokenFlag == 1){
							strncpy(tempString, yytext + 1, yyleng - 2);
							tempString[yyleng - 2] = '\0';
							printf("#string:%s\n",tempString);
						}
						return STRING;
					}
<PARSE>'.*'	{
			fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}
<PARSE>.	{
			fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}	






%%
int yywrap(){
	return 1;
}
