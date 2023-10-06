# yacc_code_practice
- basic: 多位十进制数基本运算
- assign: 实现符号表,赋值语句及多位十进制数基本运算
- to_assembly: 将赋值语句及运算语句转化为arm汇编语句,默认符号地址为addr_[symbol_str],默认运算结果保存在对应的addr_[op]_result
- to_postfix: 中缀表达式转后缀

## 符号表
实现一个char*-value的map作为符号表,提供查找和添加两个功能
```c
#define MAX_SIZE 128
int symbol_num = 0;

struct symbol_table_entry
{
    char *id;
    double value;
} symbol_table[MAX_SIZE];

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
```

判定为ID时查找符号表,如果没有结果则添加该符号,如果有结果返回从符号表中查找到的map

## 翻译为汇编语句
char* code保存汇编语句;addr保存ID或NUMBER的地址符号;is_number判断是否为立即数,如果是NUMBER,在翻译为汇编语句时使用MOV将立即数保存到寄存器钟,如果是ID或者计算的中间结果,使用LDR指令
```c
struct code_block
{
    char *code;
    char *addr;
    int is_number;
};
```

```yacc
expr SUB expr { $$ = (struct code_block *)malloc(sizeof(struct code_block));
                $$->addr = (char *)malloc(50 * sizeof(char)); strcpy($$->addr, "addr_sub-result");
                $$->code = (char *)malloc(500 * sizeof(char)); strcpy($$->code, $1->code); strcat($$->code, $3->code);
                if($1->is_number){strcat($$->code, "MOV  R0, "); strcat($$->code, $1->addr); strcat($$->code, "\n");}
                else{strcat($$->code, "LDR  R0, "); strcat($$->code, $1->addr); strcat($$->code, "\n");}
                if($3->is_number){strcat($$->code, "MOV  R1, "); strcat($$->code, $3->addr); strcat($$->code, "\n");}
                else{strcat($$->code, "LDR  R1, "); strcat($$->code, $3->addr); strcat($$->code, "\n");}
                strcat($$->code, "LDR  R2, [R0]\n");
                strcat($$->code, "LDR  R3, [R1]\n");
                strcat($$->code, "SUB  R2, R2, R3\n");
                strcat($$->code, "LDR  R0, "); strcat($$->code, $$->addr); strcat($$->code, "\n");
                strcat($$->code, "STR  R2, [R0]\n");
                $$->is_number = 0; }
```
