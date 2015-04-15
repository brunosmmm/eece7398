#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CFG.h"
#include <iostream>
#include <set>
#include <unordered_map>
#include <string>
namespace
{

  struct BasicBlockInfo
  {
    std::set<std::string> gen;
    std::set<std::string> in;
    std::set<std::string> out;
  };

  bool ExtendSet(std::set<std::string> &set1, std::set<std::string> &set2)
  {
    int last_size = set1.size();
    for (const std::string &s : set2)
      set1.insert(s);
    return set1.size() - last_size;
  }

  void PrintSet(std::set<std::string> &set)
  {
    llvm::errs() << "{";
    for (const std::string &s : set)
      llvm::errs() << ' ' << s;
    llvm::errs() << " }";
  } 

  class PrintPass : public llvm::FunctionPass
  {
  public:
    // Identifier
    static char ID;
    // Constructor. The first argument of the parent constructor is
    // a unique pass identifier.
    PrintPass() : llvm::FunctionPass(ID) { }
    // Virtual function overridden to implement the pass functionality.
    bool runOnFunction(llvm::Function &function) override
    {

      //data storage
      std::unordered_map<std::string, BasicBlockInfo *> basic_block_table;
      bool changed = true;
      int iterations = 0;

      // Print function name
      llvm::errs() << "Pass on function " << function.getName() << '\n';
      // Traverse basic blocks in function
      for (llvm::Function::iterator basic_block = function.begin(),
	     e = function.end();
	   basic_block != e;
	   ++basic_block)
	{
	  
	  //create basic block entries -- all is cleared on constructors
	  basic_block_table.insert(std::make_pair<std::string, BasicBlockInfo *>(basic_block->getName(),new BasicBlockInfo));

	  //generate gen set for all basic blocks
	  for (llvm::BasicBlock::iterator bb_instr = basic_block->begin(); 
	       bb_instr != basic_block->end(); 
	       bb_instr++)
	    {

	      //check if instruction is variable assignment
	      if (!bb_instr->getName().empty())
		{
		  //this is an assignment. record variable name into GEN set
		  basic_block_table[basic_block->getName()]->gen.insert(bb_instr->getName());
		}
	      
	    }

	  //make OUT = gen
	  (void)ExtendSet(basic_block_table[basic_block->getName()]->out,
			  basic_block_table[basic_block->getName()]->gen);

	}

      //print gen sets
      for (std::unordered_map<std::string, BasicBlockInfo *>::iterator myit = basic_block_table.begin(); myit != basic_block_table.end(); myit++)
	{

	  llvm::errs() << "GEN for " << myit->first << " = ";

	  PrintSet(myit->second->gen);

	  llvm::errs() << '\n';

	}
      
      //run while there are changes
      while (changed)
	{
	  
	  changed = false;
	  iterations++;

	  //iterate through blocks to build sets
	  for (llvm::Function::iterator bb = function.begin(); bb != function.end();bb++)
	    {
	      
	      //IN set always rebuilt
	      basic_block_table[bb->getName()]->in.clear();

	      //iterate through block's predecessors to compute union of OUT sets - compute IN set
	      for (llvm::pred_iterator it = pred_begin(bb); 
		   it != llvm::pred_end(bb); 
		   it++)
		{
		  //predecessor
		  llvm::BasicBlock * pred = *it;
		  
		  //do union
		  (void)ExtendSet(basic_block_table[bb->getName()]->in,
				  basic_block_table[pred->getName()]->out);

		}

	      //generate OUT set and verify if it changed
	      if (ExtendSet(basic_block_table[bb->getName()]->out,
			    basic_block_table[bb->getName()]->in)) 
		changed = true;

	    }
	  
	    }

      llvm::errs() << "Algorithm iterations: " << iterations << "\n";

      //finished. print all sets
      for (std::unordered_map<std::string, BasicBlockInfo *>::iterator thelist = basic_block_table.begin(); 
	   thelist != basic_block_table.end(); 
	   thelist++)
	{

	  llvm::errs() << "Block " << thelist->first << ": \n";
	  llvm::errs() << "IN = ";
	  PrintSet(thelist->second->in);
	  llvm::errs() << "\nOUT = ";
	  PrintSet(thelist->second->out);
	  llvm::errs() << "\n";

	}

      // Function was not modified
      return false;
    }
  };
  // Pass identifier
  char PrintPass::ID = 0;
  // Pass registration. Pass will be available as 'print' from the LLVM
  // optimizer tool.
  static llvm::RegisterPass<PrintPass> X("reachingDef",
					 "Reaching definitions pass",
					 false,
					 false);
}
