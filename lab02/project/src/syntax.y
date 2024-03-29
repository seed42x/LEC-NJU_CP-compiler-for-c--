%locations

%{
    #include<stdio.h>
    #include "general.h"
    #include "data_struct/spt.h"
    #include "lex.yy.c"

    #define YYSTYPE Node*

    extern int pass;
    extern Node* root;
    extern int yyerror(char* msg);
%}

/*7.1.1 declared tokens*/
%token INT FLOAT
%token TYPE STRUCT RETURN IF ELSE WHILE
%token ID
%token ASSIGNOP
%token RELOP
%token PLUS MINUS STAR DIV
%token AND OR NOT
%token LP RP LB RB LC RC
%token SEMI COMMA DOT

/*declared associativity and priority*/
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left LP RP LB RB DOT

%%
/*7.1.2 High-level Definitions*/
Program : ExtDefList                            {$$ = build_syntax_node("Program", @$); add_children(2, $$, $1); root = $$;}
    ;
ExtDefList : ExtDef ExtDefList                  {$$ = build_syntax_node("ExtDefList", @$); add_children(3, $$, $1, $2);}
    |                                           {$$ = build_syntax_node("ExtDefList", @$);}
    ;
ExtDef : Specifier ExtDecList SEMI              {$$ = build_syntax_node("ExtDef", @$); add_children(4, $$, $1, $2, $3);}
    | Specifier SEMI                            {$$ = build_syntax_node("ExtDef", @$); add_children(3, $$, $1, $2);}
    | Specifier FunDec CompSt                   {$$ = build_syntax_node("ExtDef", @$); add_children(4, $$, $1, $2, $3);}
    | Specifier FunDec SEMI                     {$$ = build_syntax_node("ExtDef", @$); add_children(4, $$, $1, $2, $3);}
    | error SEMI
    | Specifier error SEMI
    | error ExtDecList SEMI
    ;
ExtDecList : VarDec                             {$$ = build_syntax_node("ExtDecList", @$); add_children(2, $$, $1);}
    | VarDec COMMA ExtDecList                   {$$ = build_syntax_node("ExtDecList", @$); add_children(4, $$, $1, $2, $3);}
    | error COMMA ExtDecList
    ;

/*7.1.3 Specifiers*/
Specifier : TYPE                                {$$ = build_syntax_node("Specifier", @$); add_children(2, $$, $1);}
    | StructSpecifier                           {$$ = build_syntax_node("Specifier", @$); add_children(2, $$, $1);}
    ;
StructSpecifier : STRUCT OptTag LC DefList RC   {$$ = build_syntax_node("StructSpecifier", @$); add_children(6, $$, $1, $2, $3, $4, $5);}
    | STRUCT Tag                                {$$ = build_syntax_node("StructSpecifier", @$); add_children(3, $$, $1, $2);}
    | STRUCT OptTag LC error RC
    | STRUCT error LC DefList RC
    | STRUCT error LC error RC
    ;
OptTag : ID                                     {$$ = build_syntax_node("OptTag", @$); add_children(2, $$, $1);}
    |                                           {$$ = build_syntax_node("OptTag", @$);}
    ;
Tag : ID                                        {$$ = build_syntax_node("Tag", @$); add_children(2, $$, $1);}
    ;
/*7.1.4 Declarators*/
VarDec : ID                                     {$$ = build_syntax_node("VarDec", @$); add_children(2, $$, $1);}
    | VarDec LB INT RB                          {$$ = build_syntax_node("VarDec", @$); add_children(5, $$, $1, $2, $3, $4);}
    | VarDec LB error RB
    | VarDec error RB
    ;
FunDec : ID LP VarList RP                       {$$ = build_syntax_node("FunDec", @$); add_children(5, $$, $1, $2, $3, $4);}
    | ID LP RP                                  {$$ = build_syntax_node("FunDec", @$); add_children(4, $$, $1, $2, $3);}
    | ID LP error RP
    ;
VarList : ParamDec COMMA VarList                {$$ = build_syntax_node("VarList", @$); add_children(4, $$, $1, $2, $3);}
    | ParamDec                                  {$$ = build_syntax_node("VarList", @$); add_children(2, $$, $1);}
    | error COMMA VarList
    ;
ParamDec : Specifier VarDec                     {$$ = build_syntax_node("ParamDec", @$); add_children(3, $$, $1, $2);}
    ;
/*7.1.5 Statements*/
CompSt : LC DefList StmtList RC                 {$$ = build_syntax_node("CompSt", @$); add_children(5, $$, $1, $2, $3, $4);}
    | LC error RC
    ;
StmtList : Stmt StmtList                        {$$ = build_syntax_node("StmtList", @$); add_children(3, $$, $1, $2);}
    |                                           {$$ = build_syntax_node("StmtList", @$);}
    ;
Stmt : Exp SEMI                                 {$$ = build_syntax_node("Stmt", @$); add_children(3, $$, $1, $2);}
    | CompSt                                    {$$ = build_syntax_node("Stmt", @$); add_children(2, $$, $1);}
    | RETURN Exp SEMI                           {$$ = build_syntax_node("Stmt", @$); add_children(4, $$, $1, $2, $3);}
    | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE   {$$ = build_syntax_node("Stmt", @$); add_children(6, $$, $1, $2, $3, $4, $5);}
    | IF LP Exp RP Stmt ELSE Stmt               {$$ = build_syntax_node("Stmt", @$); add_children(8, $$, $1, $2, $3, $4, $5, $6, $7);}
    | WHILE LP Exp RP Stmt                      {$$ = build_syntax_node("Stmt", @$); add_children(6, $$, $1, $2, $3, $4, $5);}
    | IF LP error RP Stmt ELSE Stmt
    | IF LP error RP Stmt %prec LOWER_THAN_ELSE
    | WHILE LP error RP Stmt
    ;
/*7.1.6 Local Definitions*/
DefList : Def DefList                           {$$ = build_syntax_node("DefList", @$); add_children(3, $$, $1, $2);}
    |                                           {$$ = build_syntax_node("DefList", @$);}
    ;
Def : Specifier DecList SEMI                    {$$ = build_syntax_node("Def", @$); add_children(4, $$, $1, $2, $3);}
    | error SEMI
    ;
DecList : Dec                                   {$$ = build_syntax_node("DecList", @$); add_children(2, $$, $1);}
    | Dec COMMA DecList                         {$$ = build_syntax_node("DecList", @$); add_children(4, $$, $1, $2, $3);}
    ;
Dec : VarDec                                    {$$ = build_syntax_node("Dec", @$); add_children(2, $$, $1);}
    | VarDec ASSIGNOP Exp                       {$$ = build_syntax_node("Dec", @$); add_children(4, $$, $1, $2, $3);}
    ;
/*7.1.7 Expressions*/
Exp : Exp ASSIGNOP Exp                          {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp AND Exp                               {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp OR Exp                                {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp RELOP Exp                             {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp PLUS Exp                              {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp MINUS Exp                             {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp STAR Exp                              {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp DIV Exp                               {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | LP Exp RP                                 {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | MINUS Exp                                 {$$ = build_syntax_node("Exp", @$); add_children(3, $$, $1, $2);}
    | NOT Exp                                   {$$ = build_syntax_node("Exp", @$); add_children(3, $$, $1, $2);}
    | ID LP Args RP                             {$$ = build_syntax_node("Exp", @$); add_children(5, $$, $1, $2, $3, $4);}
    | ID LP RP                                  {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | Exp LB Exp RB                             {$$ = build_syntax_node("Exp", @$); add_children(5, $$, $1, $2, $3, $4);}
    | Exp DOT ID                                {$$ = build_syntax_node("Exp", @$); add_children(4, $$, $1, $2, $3);}
    | ID                                        {$$ = build_syntax_node("Exp", @$); add_children(2, $$, $1);}
    | INT                                       {$$ = build_syntax_node("Exp", @$); add_children(2, $$, $1);}
    | FLOAT                                     {$$ = build_syntax_node("Exp", @$); add_children(2, $$, $1);}
    ;
Args : Exp COMMA Args                           {$$ = build_syntax_node("Args", @$); add_children(4, $$, $1, $2, $3);}
    | Exp                                       {$$ = build_syntax_node("Args", @$); add_children(2, $$, $1);}
    | error COMMA Args
    | COMMA error
    ;
%%

int yyerror(char* msg){
    pass = 0;
    fprintf(stderr, "Error type B at Line %d: %s\n", yylineno, yytext);
}
