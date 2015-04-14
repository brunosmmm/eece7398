%{
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <list>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include "SymbolTable.h"
#include "Type.h"
    extern "C" int yylex();
    extern "C" int yyparse();
    extern "C" FILE *yyin;
    void yyerror(const char *s);
    // Module, function, basic block, and builder
    llvm::Module *module;
    llvm::Function *function;
    llvm::BasicBlock *basic_block;
    llvm::IRBuilder<> *builder;
    // Environment: stack of symbol tables. It is actually implemented as a list
    // to facilitate the traversal of symbol tables.
    std::list<SymbolTable *> environment;
    %}
%token TokenInt
%token TokenFloat
%token TokenVoid
%token TokenStruct
%token<name> TokenId
%token<value> TokenNumber
%token TokenOpenCurly
%token TokenCloseCurly
%token TokenOpenSquare
%token TokenCloseSquare
%token TokenOpenPar
%token TokenClosePar
%token TokenSemicolon
%token TokenEqual
%token TokenPoint
%left TokenPlus TokenMinus
%left TokenMult TokenDiv
%type<type> Type
%type<type> Pointer
%type<indices> Indices
%type<llvalue> Expression
%type<lvalue> LValue
%type<deref> Dereference
%union {
    char *name;
    llvm::Value *llvalue;
    int value;
    Type *type;
    std::list<int> *indices;
    // For LValue
    struct {
	Type *type;
	llvm::Value *lladdress;
	std::vector<llvm::Value *> *llindices;
    } lvalue;
    bool deref;
}
%%
Start:
Declarations Functions
Functions:
{
}
|
TokenVoid TokenId TokenOpenPar TokenClosePar TokenOpenCurly
{
    // Push new local symbol table
    SymbolTable *symbol_table = new SymbolTable(SymbolTable::ScopeLocal);
    environment.push_back(symbol_table);
    // LLVM function
    llvm::Constant *constant = module->getOrInsertFunction($2,
							   llvm::Type::getVoidTy(llvm::getGlobalContext()),
							   nullptr);
    function = llvm::cast<llvm::Function>(constant);
    llvm::BasicBlock *block = llvm::BasicBlock::Create(
						       llvm::getGlobalContext(),
						       "entry",
						       function);
    builder->SetInsertPoint(block);
}
Declarations Statements TokenCloseCurly
{
    // Return statement
    builder->CreateRetVoid();
    // Pop local symbol table
    SymbolTable *symbol_table = environment.back();
    environment.pop_back();
}
Functions
Declarations:
{
}
| Pointer TokenId Indices TokenSemicolon
{
    // Get top symbol table
    SymbolTable *symbol_table = environment.back();
    // Create new symbol
    Symbol *symbol = new Symbol($2);
    symbol->type = $1;
    symbol->index = symbol_table->size();
    // Process indices
    for (int index : *$3)
	{
	    Type *type = new Type(Type::KindArray);
	    type->num_elem = index;
	    type->subtype = symbol->type;
	    type->lltype = llvm::ArrayType::get(symbol->type->lltype, index);
	    symbol->type = type;
	}
    // Symbol in global scope
    if (symbol_table->getScope() == SymbolTable::ScopeGlobal)
	symbol->lladdress = new llvm::GlobalVariable(
						     *module,
						     symbol->type->lltype,
						     false,
						     llvm::GlobalValue::ExternalLinkage,
						     nullptr,
						     symbol->getName());
    // Symbol in local scope
    else if (symbol_table->getScope() == SymbolTable::ScopeLocal)
	symbol->lladdress = builder->CreateAlloca(symbol->type->lltype,
						  nullptr, Symbol::getTemp());
    // Insert in symbol table
    symbol_table->addSymbol(symbol);
}
Declarations
Indices:
{
    $$ = new std::list<int>();
}
| TokenOpenSquare TokenNumber TokenCloseSquare Indices
{
    $$ = $4;
    $$->push_back($2);
}
Pointer:
Type
{
    $$ = $1;
}
| Pointer TokenMult
{
    $$ = new Type(Type::KindPointer);
    $$->subtype = $1;
    $$->lltype = llvm::PointerType::get($1->lltype, 0);
}
Type:
TokenInt
{
    $$ = new Type(Type::KindInt);
    $$->lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
}
| TokenFloat
{
    $$ = new Type(Type::KindFloat);
    $$->lltype = llvm::Type::getFloatTy(llvm::getGlobalContext());
}
| TokenStruct TokenOpenCurly
{
    // Push new symbol table to environment
    SymbolTable *symbol_table = new SymbolTable(SymbolTable::ScopeStruct);
    environment.push_back(symbol_table);
    // Create type
    $<type>$ = new Type(Type::KindStruct);
    $<type>$->symbol_table = symbol_table;
}
Declarations TokenCloseCurly
{
    // Forward type
    $$ = $<type>3;
    // LLVM structure
    SymbolTable *symbol_table = environment.back();
    std::vector<llvm::Type *> lltypes;
    symbol_table->getLLVMTypes(lltypes);
    $$->lltype = llvm::StructType::create(llvm::getGlobalContext(), lltypes);
    // Pop symbol table from environment
    environment.pop_back();
}
Statements:
| Statements Statement
Statement:
LValue TokenEqual Expression TokenSemicolon
{
    llvm::Value *lladdress = $1.llindices->size() > 1 ?
	builder->CreateGEP($1.lladdress,
			   *$1.llindices,
			   Symbol::getTemp()) :
	$1.lladdress;
    builder->CreateStore($3, lladdress);
}
Expression:
LValue
{
    llvm::Value *lladdress = $1.llindices->size() > 1 ?
	builder->CreateGEP($1.lladdress, *$1.llindices,
			   Symbol::getTemp()) :
	$1.lladdress;
    $$ = builder->CreateLoad(lladdress, Symbol::getTemp());
}
| TokenNumber
{
    llvm::Type *lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
    $$ = llvm::ConstantInt::get(lltype, $1);
}
| Expression TokenPlus Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::Add, $1, $3, Symbol::getTemp());
}
| Expression TokenMinus Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::Sub, $1, $3, Symbol::getTemp());
}
| Expression TokenMult Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::Mul, $1, $3, Symbol::getTemp());
}
| Expression TokenDiv Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::SDiv, $1, $3, Symbol::getTemp());
}
| TokenOpenPar Expression TokenClosePar
{
    $$ = $2;
}

Dereference:
{ $$ = false; }
| TokenMult
{ $$ = true; }

LValue:
Dereference TokenId
{
    // Search symbol in environment, from the top to the bottom
    Symbol *symbol = nullptr;
    for (auto it = environment.rbegin();
	 it != environment.rend();
	 ++it)
	{
	    SymbolTable *symbol_table = *it;
	    symbol = symbol_table->getSymbol($2);
	    if (symbol)
		break;
	}
    // Undeclared
    if (!symbol)
	{
	    std::cerr << "Undeclared identifier: " << $2 << '\n';
	    exit(1);
	}

    //if dereferencing, check if type is pointer
    if ($1)
    {
	if (symbol->type->getKind() != Type::Kind::KindPointer)
	    {
		//issue case 2 error
		std::cerr << "Non-pointer variable '" << symbol->getName() << "' used as pointer \n";
		exit(1);
	    }
         else
            {
		//is pointer, so must dereference, load value
		$$.type = symbol->type->subtype;
		$$.lladdress = builder->CreateLoad(symbol->lladdress,Symbol::getTemp());
		
	    }
    }
    else
    {
	// Save info (usual case)
	$$.type = symbol->type;
	$$.lladdress = symbol->lladdress;
    }

    $$.llindices = new std::vector<llvm::Value *>();
    // Add initial index set to 0
    llvm::Type *lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
    llvm::Value *llindex = llvm::ConstantInt::get(lltype, 0);
    $$.llindices->push_back(llindex);
}
| LValue TokenOpenSquare Expression TokenCloseSquare
{
    // Check that L-value is array
    if ($1.type->getKind() != Type::KindArray)
	{
	    std::cerr << "L-value is not an array\n";
	    exit(1);
	}
    // Add index
    $$.llindices = $1.llindices;
    $$.llindices->push_back($3);
    // Type and address
    $$.type = $1.type->subtype;
    $$.lladdress = $1.lladdress;
}
| LValue TokenPoint TokenId
{
    // Check that L-value is a structure
    if ($1.type->getKind() != Type::KindStruct)
	{
	    std::cerr << "L-value is not a struct\n";
	    exit(1);
	}
    // Find symbol in structure
    Symbol *symbol = $1.type->symbol_table->getSymbol($3);
    if (!symbol)
	{
	    std::cerr << "Invalid field: " << $3 << '\n';
	    exit(1);
	}
    // Add index
    llvm::Type *lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
    llvm::Value *llindex = llvm::ConstantInt::get(lltype, symbol->index);
    $$.llindices = $1.llindices;
    $$.llindices->push_back(llindex);
    // Type and address
    $$.type = symbol->type;
    $$.lladdress = $1.lladdress;
}
%%
int main(int argc, char **argv)
{
    // Syntax
    if (argc != 2)
	{
	    std::cerr << "Syntax: ./main <file>\n";
	    exit(1);
	}
    // Open file in 'yyin'
    yyin = fopen(argv[1], "r");
    if (!yyin)
	{
	    std::cerr << "Cannot open file\n";
	    exit(1);
	}
    // LLVM context, builder, and module
    llvm::LLVMContext &context = llvm::getGlobalContext();
    builder = new llvm::IRBuilder<>(context);
    module = new llvm::Module("TestModule", context);
    // Push global symbol table to environment
    SymbolTable *global_symbol_table = new SymbolTable(SymbolTable::ScopeGlobal);
    environment.push_back(global_symbol_table);
    // Parse input until there is no more
    do
	{
	    yyparse();
	} while (!feof(yyin));
    // Dump module
    module->dump();
    return 0;
}
void yyerror(const char *s)
{
    std::cerr << s << std::endl;
    exit(1);
}
