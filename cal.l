%{
#include <stdlib.h>  /* for atoi()   */
#include <stdio.h>   /* for printf() */
#include <string.h>  /* for strdup() */

extern int line_num; /* line number from cal.tab.c */
%}

%%
[ \t]+          {}
\n              { line_num++; return '\n'; }
"+"|"-"|"*"|"/" { return yytext[0]; }
"("|")"|"="|";" { return yytext[0]; }
"&"|"|"|"^"|"~" { return yytext[0]; }
"<<"            { return LEFT_SHIFT; }
">>"            { return RIGHT_SHIFT; }
"**"            { return POWER; }
[0-9]+\.?[0-9]* { yylval.d = atof(yytext); return NUMBER; }
[a-zA-Z_]+      { yylval.s = strdup(yytext); return VAR; }
.               { printf("lexer error at line %d: " 
                  "illegal token `%s'\n", line_num, yytext);
                  return 0; }
%%
