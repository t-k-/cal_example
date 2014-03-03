%{
#include <stdio.h>  /* for printf() */
#include <stdlib.h> /* for free() */
#include <math.h>   /* for pow() */
#include "common.h" /* for common part */
%}

%union {
	float  d;
	char  *s;
}

%error-verbose
%token <d> NUMBER
%token <s> VAR 
%type  <d> expr factor term assign 
%right '=' 
%left '+' '-' 
%left '*' '/' '&' '|' '^'
%nonassoc '~'
%nonassoc '(' ')'
%left  POWER LEFT_SHIFT RIGHT_SHIFT
%start program

%%
program : 
        | stmt program;

stmt : expr '\n' { printf("= %g\n", $1); }
     | '\n' ;

expr   : expr '+' factor { $$ = $1 + $3; }
       | expr '-' factor { $$ = $1 - $3; }
       | assign { $$ = $1; }
       | factor { $$ = $1; };

factor : factor '*' term { $$ = $1 * $3; }
       | factor '/' term { $$ = $1 / $3; }
       | factor '&' term 
       { $$ = (int)$1 & (int)$3; }
       | factor '|' term 
       { $$ = (int)$1 | (int)$3; }
       | factor '^' term 
       { $$ = (int)$1 ^ (int)$3; }
       | factor POWER term
       { $$ = pow($1, $3); }
       | factor LEFT_SHIFT term 
       { $$ = (int)$1 << (int)$3; }
       | factor RIGHT_SHIFT term 
       { $$ = (int)$1 >> (int)$3; }
       | term { $$ = $1; };

term   : NUMBER   { $$ = $1; }
       | '~' term { $$ = ~(int)$2; }
       | '-' factor { $$ = -$2; }
       | VAR      
       { char err_str[32]; 
         if (var_exist($1))
             $$ = var_val[var_map($1)]; 
         else { 
             sprintf(err_str, 
             "var `%s' is not defined.\n", 
             $1);

             yyerror(err_str); 
             return 0; 
         } 
         free($1);
       }
       | '(' expr ')' { $$ = $2; };

assign : VAR '=' expr  
       { int map = var_map($1); 
         $$ = $3; 
         var_val[map] = $3;
         printf("assign %g to %s\n", 
                 $3, $1); 
         free($1);
       };

%%
