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
%glr-parser
%expect 2

%token <d> NUMBER
%token <s> VAR 
%type  <d> expr term assign
%right '=' 
%left '+' '-' '*' '/' '&' '|' '^'
%nonassoc '~' 
%nonassoc '(' ')'
%left POWER LEFT_SHIFT RIGHT_SHIFT
%start program

%%
program : 
        |program stmt;

stmt : expr '\n' { printf("= %g\n", $1); }
     | '\n' ;

expr : expr expr '+' { $$ = $1 + $2; }
     | expr expr '-' { $$ = $1 - $2; }
     | expr expr '*' { $$ = $1 * $2; }
     | expr expr '/' { $$ = $1 / $2; }
     | expr expr '&'
     { $$ = (int)$1 & (int)$2; }
     | expr expr '|' 
     { $$ = (int)$1 | (int)$2; }
     | expr expr '^' 
     { $$ = (int)$1 ^ (int)$2; }
     | expr expr POWER 
     { $$ = pow($1, $2); }
     | expr expr LEFT_SHIFT 
     { $$ = (int)$1 << (int)$2; }
     | expr expr RIGHT_SHIFT 
     { $$ = (int)$1 >> (int)$2; }
     | term { $$ = $1; };

term : NUMBER   { $$ = $1; }
     | assign   { $$ = $1; }
     | term '~' { $$ = ~(int)$1; }
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
      };

assign : VAR expr '=' 
       { int map = var_map($1); 
         $$ = $2; 
         var_val[map] = $2;
         printf("assign %g to %s\n", 
                 $2, $1); 
         free($1);
       };

%%
