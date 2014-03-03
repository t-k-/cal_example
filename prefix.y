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
%type  <d> expr term assign 
%right '=' 
%left '+' '-' '*' '/' '&' '|' '^'
%nonassoc '~'
%nonassoc '(' ')'
%left POWER LEFT_SHIFT RIGHT_SHIFT
%start program

%%
program : 
        | program stmt;

stmt : expr '\n' { printf("= %g\n", $1); }
     | '\n' ;

expr : '+' expr expr { $$ = $2 + $3; }
     | '-' expr expr { $$ = $2 - $3; }
     | '*' expr expr { $$ = $2 * $3; }
     | '/' expr expr { $$ = $2 / $3; }
     | '&' expr expr
     { $$ = (int)$2 & (int)$3; }
     | '|' expr expr 
     { $$ = (int)$2 | (int)$3; }
     | '^' expr expr 
     { $$ = (int)$2 ^ (int)$3; }
     | POWER expr expr 
     { $$ = pow($2, $3); }
     | LEFT_SHIFT expr expr  
     { $$ = (int)$2 << (int)$3; }
     | RIGHT_SHIFT expr expr  
     { $$ = (int)$2 >> (int)$3; }
     | term { $$ = $1; };

term : NUMBER   { $$ = $1; }
     | assign   { $$ = $1; }
     | '~' term { $$ = ~(int)$2; }
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

assign : '=' VAR expr  
       { int map = var_map($2); 
         $$ = $3; 
         var_val[map] = $3;
         printf("assign %g to %s\n", 
                 $3, $2); 
         free($2);
       };

%%
