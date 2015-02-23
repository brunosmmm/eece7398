%option noyywrap

%{
#include <fstream>
%}

SPACE [ \n\t]

ID [A-Za-z_][A-Za-z0-9_]*

CSTR \".*\"

CTYPE (float|int|char|double)

OPEN_PAR \(
CLOSE_PAR \)

OPEN_SCOPE \{
CLOSE_SCOPE \}

SEMICOLON ;
ASSIGN =
ID_REF &
COMMA ,

ML_COMMENT \/\*.*\*\/
L_COMMENT \/\/.*$

%%

{SPACE} {}

{CTYPE} { std::cout << "<ctype '" << yytext << "'>\n"; }

{ID} { std::cout << "<id, '" << yytext << "'>\n"; }

{OPEN_PAR} { std::cout << "<open_par>\n"; }
{CLOSE_PAR} { std::cout << "<close_par>\n"; }

{OPEN_SCOPE} { std::cout << "<open_scope>\n"; }
{CLOSE_SCOPE} { std::cout << "<close_scope>\n"; }

{CSTR} { std::cout << "<cstr, '" << yytext << "'>\n"; }

{SEMICOLON} { std::cout << "<semicolon>\n"; }
{COMMA}  { std::cout << "<comma>\n"; }
{ASSIGN} { std::cout << "<assign>\n"; }
{ID_REF} { std::cout << "<id_ref>\n"; }

{L_COMMENT} { std::cout << "<comment, '" << yytext << "'>\n"; }
{ML_COMMENT} { std::cout << "<comment, '" << yytext << "'>\n"; }

. { std::cout << "<error, '" << yytext << "'>\n"; }


%%

int main (void)
{
    
    std::ifstream myFile("code.txt");
    yyFlexLexer lexer(&myFile);

    lexer.yylex();

    return 0;

}
