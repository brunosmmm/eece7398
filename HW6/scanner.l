%{
#include <iostream>
#include "parser.h"
#define YY_DECL extern "C" int yylex()
using namespace std;
%}
%option noyywrap
%%
float {
return TokenType;
}
int {
return TokenType;
}
void {
return TokenType;
}
[a-zA-Z_][a-zA-Z0-9_]* {
return TokenId;
}
"(" {
return TokenParOpen;
}
")" {
return TokenParClose;
}
"," {
return TokenComma;
}
[ \t\n]+ {
// Skip spaces, tabs, and newlines
}
. {
std::cout << "Invalid token: " << yytext << "\n";
}
%%
