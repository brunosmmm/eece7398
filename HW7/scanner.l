%{
#include <vector>
#include <iostream>
#include <cstring>
#include <llvm/IR/Type.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h> 
#include "parser.h"

#define YY_DECL extern "C" int yylex()

using namespace std;
%}

%option noyywrap

%%

int {
return TokenInt;
}

void {
return TokenVoid;
}

float {
return TokenFloat;
}

"(" {
return TokenOpenPar;
}

")" {
return TokenClosePar;
}

";" {
return TokenSemicolon;
}

"," {
return TokenComma;
}

[a-zA-Z_][a-zA-Z0-9_]* {
yylval.name = strdup(yytext);
return TokenId;
}

[\t\n]+ {
}

. {
//invalid token
}

%%
