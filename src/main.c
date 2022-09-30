# include<stdio.h>

extern int yyleng;
extern char* yytext;
extern FILE* yyin;
extern int yylex(void);

int main(int argc, char** argv){
    if(argc > 1){
        if(!(yyin = fopen(argv[1], "r"))){
            perror(argv[1]);
            return 1;
        }
    }
    int tmp = 0;
    do{
        tmp = yylex();
        if(tmp == -1) break;
    } while(tmp != 0);
    return 0;
}