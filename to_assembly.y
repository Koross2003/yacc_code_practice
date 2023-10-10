%{

#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#define MAX_SIZE 128

struct symbol_table_entry
{
    char *id;
    char *addr;
} symbol_table[MAX_SIZE];

struct code_block
{
    char *code;
    char *addr;
    int is_number;
};

char id_str[50];
char num_str[50];
int search_sym(char *string);
int add_sym(char *string);
int symbol_num = 0;


int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

%}

%union
{
    struct code_block *assembly;
    struct symbol_table_entry *ident;
}

%type <assembly> assignstmt
%type <assembly> expr

%token ADD SUB MUL DIV ASSIGN
%token <assembly> NUMBER
%token <ident> ID

%right ASSIGN
%left ADD SUB
%left MUL DIV
%right UMINUS

%%

lines : lines expr ';' { printf("%s", $2->code); }
      | lines assignstmt ';' { printf("%s", $2->code); }
      | lines ';'
      |
      ;

assignstmt : ID ASSIGN assignstmt { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                                    $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, $3->addr);
                                    $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $3->code);
                                    strcat($$->code, "LDR  R1, ="); strcat($$->code, $1->addr); strcat($$->code, "\n");
                                    strcat($$->code, "STR  R2, [R1]\n");
                                    $$->is_number = 0; }

           | ID ASSIGN expr { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                              $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, $3->addr);
                              $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $3->code);
                              if($3->is_number){strcat($$->code, "MOV  R2, #"); strcat($$->code, $3->addr); strcat($$->code, "\n");}
                              else{strcat($$->code, "LDR  R0, ="); strcat($$->code, $3->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R2, [R0]\n");}
                              strcat($$->code, "LDR  R1, ="); strcat($$->code, $1->addr); strcat($$->code, "\n");
                              strcat($$->code, "STR  R2, [R1]\n");
                              $$->is_number = 0; }
           ;

expr : expr ADD expr { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                       $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, "addr_add_result");
                       $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $1->code); strcat($$->code, $3->code);
                       if($1->is_number){strcat($$->code, "MOV  R2, #"); strcat($$->code, $1->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R0, ="); strcat($$->code, $1->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R2, [R0]\n");}
                       if($3->is_number){strcat($$->code, "MOV  R3, #"); strcat($$->code, $3->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R1, ="); strcat($$->code, $3->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R3, [R1]\n");}
                       strcat($$->code, "ADD  R2, R2, R3\n");
                       strcat($$->code, "LDR  R0, "); strcat($$->code, $$->addr); strcat($$->code, "\n");
                       strcat($$->code, "STR  R2, [R0]\n");
                       $$->is_number = 0; }

     | expr SUB expr { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                       $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, "addr_sub_result");
                       $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $1->code); strcat($$->code, $3->code);
                       if($1->is_number){strcat($$->code, "MOV  R2, #"); strcat($$->code, $1->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R0, ="); strcat($$->code, $1->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R2, [R0]\n");}
                       if($3->is_number){strcat($$->code, "MOV  R3, #"); strcat($$->code, $3->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R1, ="); strcat($$->code, $3->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R3, [R1]\n");}
                       strcat($$->code, "LDR  R2, [R0]\n");
                       strcat($$->code, "LDR  R3, [R1]\n");
                       strcat($$->code, "SUB  R2, R2, R3\n");
                       strcat($$->code, "LDR  R0, "); strcat($$->code, $$->addr); strcat($$->code, "\n");
                       strcat($$->code, "STR  R2, [R0]\n");
                       $$->is_number = 0; }

     | expr MUL expr { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                       $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, "addr_mul_result");
                       $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $1->code); strcat($$->code, $3->code);
                       if($1->is_number){strcat($$->code, "MOV  R2, #"); strcat($$->code, $1->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R0, ="); strcat($$->code, $1->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R2, [R0]\n");}
                       if($3->is_number){strcat($$->code, "MOV  R3, #"); strcat($$->code, $3->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R1, ="); strcat($$->code, $3->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R3, [R1]\n");}
                       strcat($$->code, "LDR  R2, [R0]\n");
                       strcat($$->code, "LDR  R3, [R1]\n");
                       strcat($$->code, "MUL  R2, R2, R3\n");
                       strcat($$->code, "LDR  R0, "); strcat($$->code, $$->addr); strcat($$->code, "\n");
                       strcat($$->code, "STR  R2, [R0]\n");
                       $$->is_number = 0; }

     | expr DIV expr { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                       $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, "addr_div_result");
                       $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $1->code); strcat($$->code, $3->code);
                       if($1->is_number){strcat($$->code, "MOV  R2, #"); strcat($$->code, $1->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R0, ="); strcat($$->code, $1->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R2, [R0]\n");}
                       if($3->is_number){strcat($$->code, "MOV  R3, #"); strcat($$->code, $3->addr); strcat($$->code, "\n");}
                       else{strcat($$->code, "LDR  R1, ="); strcat($$->code, $3->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R3, [R1]\n");}
                       strcat($$->code, "LDR  R2, [R0]\n");
                       strcat($$->code, "LDR  R3, [R1]\n");
                       strcat($$->code, "SDIV R2, R2, R3\n");
                       strcat($$->code, "LDR  R0, "); strcat($$->code, $$->addr); strcat($$->code, "\n");
                       strcat($$->code, "STR  R2, [R0]\n");
                       $$->is_number = 0; }

     | '(' expr ')' { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                      $$->addr = $2->addr;
                      $$->code = $2->code;
                      $$->is_number = 0; }

     | SUB expr %prec UMINUS { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                               $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, "addr_uminus_result");
                               $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $2->code);
                               if($2->is_number){strcat($$->code, "MOV  R1, #"); strcat($$->code, $2->addr); strcat($$->code, "\n");}
                               else{strcat($$->code, "LDR  R0, ="); strcat($$->code, $2->addr); strcat($$->code, "\n");strcat($$->code, "LDR  R1, [R0]\n");}
                               strcat($$->code, "MOV  R2, #0x00\n");
                               strcat($$->code, "SUB  R1, R2, R1\n"); 
                               strcat($$->code, "LDR  R0, ="); strcat($$->code, $$->addr); strcat($$->code, "\n");
                               strcat($$->code, "STR  R2, [R0]\n");
                               $$->is_number = 0; }
     
     | NUMBER { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, $1->addr);
                $$->code = (char *)malloc(50 * sizeof(char)); strcpy($$->code, ""); 
                $$->is_number = 1; }

     | ID { $$ = (struct code_block *)malloc(sizeof(struct code_block));
            $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, $1->addr);
            $$->code = (char *)malloc(50 * sizeof(char)); strcpy($$->code, ""); 
            $$->is_number = 0; }
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

int add_sym(char *string)
{
    if(symbol_num >= MAX_SIZE)
    {
        fprintf(stderr, "The number of symbols exceeds 128!\n");
        exit(1);
    }

    symbol_table[symbol_num].id = (char *)malloc(50 * sizeof(char)); 
    strcpy(symbol_table[symbol_num].id, string);

    symbol_table[symbol_num].addr = (char *)malloc(50 * sizeof(char)); 
    strcpy(symbol_table[symbol_num].addr, "addr_");
    strcat(symbol_table[symbol_num].addr, string);

    symbol_num++;
    return symbol_num;
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
        else if (t >= '0' && t <= '9')
        {
			int ti = 0;
			while (t >= '0' && t <= '9')
            {
				num_str[ti] = t;
				t = getchar();
				ti++;
			}
			num_str[ti] = '\0';
            yylval.assembly = (struct code_block *)malloc(sizeof(struct code_block));
            yylval.assembly->addr = (char *)malloc(50 * sizeof(char)); 
            strcat(yylval.assembly->addr, num_str);
            yylval.assembly->code = "";
			ungetc(t, stdin);
			return NUMBER;
		}
        else if(t >='a' && t <='z' || t >='A' && t <='Z' || t == '_')
        {
			int ti = 0;
			while (t >='a' && t <='z' || t >='A' && t <='Z' || t == '_' || t >= '0' && t <= '9')
            {
				id_str[ti] = t;
				ti++;
				t = getchar();
			}
			id_str[ti]='\0';
            int no = search_sym(id_str);
            if(no == 0)
            {
                no = add_sym(id_str);
            }
            yylval.ident = &symbol_table[no - 1];
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