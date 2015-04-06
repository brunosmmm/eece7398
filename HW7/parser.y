%{
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Type.h>
#include <vector>
#include <iostream>

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);

llvm::Module *module;
llvm::IRBuilder<> *builder;

%}

%token TokenInt
%token TokenFloat
%token TokenVoid
%token<name> TokenId
%token TokenOpenPar
%token TokenClosePar
%token TokenSemicolon
%token TokenComma

%type<type> Type
%type<types> ArgumentsA
%type<types> ArgumentsB

%union {
char * name;
llvm::Type *type;
std::vector<llvm::Type *> *types;
}

%%

Function:
	 Type TokenId TokenOpenPar ArgumentsA TokenClosePar TokenSemicolon
		{
		    
		    //llvm::ArrayRef<llvm::Type *> argList(*$4);

		    //build functiontype true or false here?
		    llvm::FunctionType * ftype = llvm::FunctionType::get($1,*$4,false);

		    llvm::Constant * constant = module->getOrInsertFunction($2, ftype);

		}
ArgumentsA:
/* empty */
		{ $$ = new std::vector<llvm::Type *>; /*empty vector*/ }
	| ArgumentsB Type TokenId
		{ $$ = new std::vector<llvm::Type *>;
		    //insert current type
		    $$->push_back($2);
		    //append earlier vector
		    $$->insert($$->end(),$1->begin(),$1->end());
		    //get rid of earlier vector
		    delete $1;
		}

ArgumentsB:
/* empty */
		{ $$ = new std::vector<llvm::Type *>; /*empty vector*/ }
	|	ArgumentsB Type TokenId TokenComma
		{ $$ = new std::vector<llvm::Type *>;
		    //insert current type
		    $$->push_back($2);
		    //append earlier vector
		    $$->insert($$->end(),$1->begin(),$1->end());
		    //get rid of vector
		    delete $1;
		}

Type:
		TokenInt
		    { $$ = llvm::Type::getInt32Ty(llvm::getGlobalContext()); }
	|	TokenFloat
		    { $$ = llvm::Type::getFloatTy(llvm::getGlobalContext()); }
	|	TokenVoid
		    { $$ = llvm::Type::getVoidTy(llvm::getGlobalContext()); }

%%

int main(int argc, char **argv)
{

    if (argc != 2)
    {
	exit(1);
    }

    yyin = fopen(argv[1], "r");
    if (!yyin)
    {
	exit(1);
    }

    llvm::LLVMContext &context = llvm::getGlobalContext();
    builder = new llvm::IRBuilder<>(context);
    module = new llvm::Module("FDeclParse",context);

    do
    {
	yyparse();
    } while (!feof(yyin));

    module->dump();
    return 0;

}

void yyerror(const char *s)
{
    std::cerr << s << std::endl;
    exit(1);
}
