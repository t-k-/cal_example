#include <string.h> /* for strdup() */
#include <stdio.h>  /* for printf() */
#include <stdlib.h> /* for free() */
#include "common.h"

int          line_num = 1;

int          var_val[VAR_NAMES_NUM];
static char *var_names[VAR_NAMES_NUM];
static int   var_names_tail = 0;

void yyerror(const char *ps) 
{ 
	printf("[yyerror @ %d] %s\n", line_num, ps);
}

int var_map(char *name)
{
	int i;
	for (i = 0; i < var_names_tail; i ++)
		if (strcmp(name, var_names[i]) == 0)
			return i;

	var_names[var_names_tail] = strdup(name);
	return var_names_tail ++;
}

int var_exist(char *name)
{
	int i;
	for (i = 0; i < var_names_tail; i ++)
		if (strcmp(name, var_names[i]) == 0)
			return 1;

	return 0;
}

int main() 
{
	int i;
	yyparse();

	for (i = 0; i < var_names_tail; i ++)
		free(var_names[i]);

	return 0;
}
