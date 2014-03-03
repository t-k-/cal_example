#define      VAR_NAMES_NUM 1024

extern int line_num;
extern int var_val[VAR_NAMES_NUM];

int var_map(char *);
int var_exist(char *);

void yyerror(const char *);
