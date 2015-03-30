%{
#include <iostream>
#include <cstdio>
#include <fstream>
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
void yyerror(const char *s);
%}
%token<value> TokenId
%token<value> TokenType
%token TokenComma
%token TokenParOpen
%token TokenParClose

%union {
int value;
}
%%
Line: Function {
	  //std::cout << "Accepted" << '\n';
}

Function: TokenType TokenId TokenParOpen ArgumentA TokenParClose 
{
}

ArgumentA : %empty 
| TokenType TokenId ArgumentB
{
}

ArgumentB : %empty
| TokenComma TokenType TokenId ArgumentB
{
}
%%
int main(int argc, char **argv)
{
    FILE * myFile;

    myFile = fopen(argv[1], "r");
    yyin = myFile;

    //NO ERROR CHECKING

do {
yyparse();
} while (!feof(yyin));
// Accept
std::cout << "Program accepted\n";
}void yyerror(const char *s)
{
std::cerr << s << std::endl;
exit(1);
}
