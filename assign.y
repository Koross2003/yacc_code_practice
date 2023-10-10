%{

#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>

#define MAX_SIZE 128

struct symbol_table_entry
{
    char *id;
    double value;
} symbol_table[MAX_SIZE];

char id_str[32];
int search_sym(char *string);
void add_sym(char *string);
int symbol_num = 0;



int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

%}

%union
{
    double number;
    struct symbol_table_entry *ident;
}

%type <number> assignstmt
%type <number> expr

%token ADD SUB MUL DIV ASSIGN
%token <number> NUMBER
%token <ident> ID

%right ASSIGN
%left ADD SUB
%left MUL DIV
%right UMINUS

%%

lines : lines expr ';' { printf("%f\n", $2); }
      | lines assignstmt ';' { printf("%f\n", $2); }
      | lines ';'
      |
      ;

assignstmt : ID ASSIGN assignstmt { $$ = $1->value = $3; }
           | ID ASSIGN expr { $$ = $1->value = $3; }
           ;

expr : expr ADD expr { $$ = $1 + $3; }
     | expr SUB expr { $$ = $1 - $3; }
     | expr MUL expr { $$ = $1 * $3; }
     | expr DIV expr { $$ = $1 / $3; }
     | '(' expr ')' { $$ = $2; }
     | SUB expr %prec UMINUS { $$ = -$2; }
     | NUMBER { $$ = $1; }
     | ID { $$ = $1->value; }
     ;

%%

int search_sym(char *string)
{
    for(int i = 0; i < symbol_num; i++)
    {
        if(strcmp(symbol_table[i].id, string) == 0)
        {
            return i + 1;
        }
    }
    return 0;
}

void add_sym(char *string)
{
    if(symbol_num >= MAX_SIZE)
    {
        fprintf(stderr, "The symbol table is full\n");
        exit(1);
    }

    symbol_table[symbol_num].id = (char *)malloc(32 * sizeof(char));
    strcpy(symbol_table[symbol_num].id, string);
    symbol_table[symbol_num].value = 0;
    symbol_num++;
}

int yylex()
{
    // place your token retrieving code here
    int t;
    while(1)
    {
        t = getchar();
        if(t == ' ' || t == '\t' || t == '\n')
        {
            //do nothing;
        }
        else if(isdigit(t))
        {
            yylval.number = 0;
            while(isdigit(t))
            {
                yylval.number = yylval.number * 10 + t - '0';
                t = getchar();
            }
            ungetc(t, stdin);
            return NUMBER;
        }
        else if(t >='a' && t <='z' || t >='A' && t <='Z' || t == '_')
        {
			int i = 0;
			while (t >='a' && t <='z' || t >='A' && t <='Z' || t == '_' || t >= '0' && t <= '9')
            {
				id_str[i++] = t;
				t = getchar();
			}
			id_str[i]='\0';
            int exist = search_sym(id_str);
            if(exist == 0)
            {
                add_sym(id_str);
                yylval.ident = &symbol_table[symbol_num - 1];
            }
            else{ yylval.ident = &symbol_table[exist - 1]; }
			ungetc(t, stdin);
			return ID;
		}
        else
        {
            switch(t)
            {
                case '+':
                    return ADD;
                case '-':
                    return SUB;
                case '*':
                    return MUL;
                case '/':
                    return DIV;
                case '=':
                    return ASSIGN;
                default:
                    return t;
            }
        }
    }
}

int main(void)
{
    yyin = stdin;
    struct symbol_table_entry *symbol_table = (struct symbol_table_entry *)malloc(MAX_SIZE * sizeof(struct symbol_table_entry));
    do
    {
        yyparse();
    }
    while(!feof(yyin));
    return 0;
}

void yyerror(const char* s)
{
    fprintf(stderr, "Parse error:%s\n", s);
    exit(1);
}