#include <iostream> 
#include <fstream>
#include "InputBuffer.h" 
#include "NFA.h" 
#include <string>
#include <map>

/****BASED ON input-buffer-test.cc*****/

//Token priority
#define TOK_RET  1
#define TOK_IF   2
#define TOK_ID   3
#define TOK_NUM  4
#define TOK_OPAR 5
#define TOK_CPAR 6
#define TOK_SPC  7
#define TOK_ISEQ 8
#define TOK_EQ   9
#define TOK_SC  10

//States

#define IF0 7
#define IF1 8
#define IFF 9

#define RET0 10
#define RET1 11
#define RET2 12
#define RET3 13
#define RET4 14
#define RET5 15
#define RETF 16

#define OPAR0 17
#define OPARF 18

#define CPAR0 19
#define CPARF 20

#define EQ0 21
#define EQF 22

#define ISEQ0 23
#define ISEQ1 24
#define ISEQF 25

#define SC0 26
#define SCF 27

std::map<int, std::string> tokenTypes = {{TOK_SPC, "space"}, 
					 {TOK_IF, "if"}, 
					 {TOK_NUM, "number"}, 
					 {TOK_ID, "id"},
					 {TOK_OPAR, "open_par"},
					 {TOK_CPAR, "close_par"},
					 {TOK_RET, "return"},
					 {TOK_EQ, "assign"},
					 {TOK_ISEQ, "isequal"},
					 {TOK_SC, "semicolon"}};
int main() 
{ 
  NFA nfa; 
  // Final states
  nfa.setFinalState(2, TOK_SPC); 
  nfa.setFinalState(4, TOK_ID); 
  nfa.setFinalState(6, TOK_NUM);
  nfa.setFinalState(IFF, TOK_IF);
  nfa.setFinalState(RETF, TOK_RET);
  nfa.setFinalState(EQF, TOK_EQ);
  nfa.setFinalState(ISEQF, TOK_ISEQ);
  nfa.setFinalState(SCF, TOK_SC);
  nfa.setFinalState(OPARF, TOK_OPAR);
  nfa.setFinalState(CPARF, TOK_CPAR);

  //epsilon transitions
  nfa.addTransition(0, 0, 1); 
  nfa.addTransition(0, 0, 3); 
  nfa.addTransition(0, 0, 5);
  nfa.addTransition(0, 0, IF0);
  nfa.addTransition(0, 0, RET0);
  nfa.addTransition(0, 0, OPAR0);
  nfa.addTransition(0, 0, CPAR0);
  nfa.addTransition(0, 0, EQ0);
  nfa.addTransition(0, 0, ISEQ0);
  nfa.addTransition(0, 0, SC0);

  //spaces
  nfa.addTransition(1, ' ', 2); 
  nfa.addTransition(1, '\n', 2); 
  nfa.addTransition(1, '\t', 2);
  nfa.addTransition(2, ' ', 2); 
  nfa.addTransition(2, '\n', 2);
  nfa.addTransition(2, '\t', 2);

  //ID
  nfa.addTransition(3, '_', 4); 
  for (char c = 'a'; c <= 'z'; c++) 
    nfa.addTransition(3, c, 4); 
  for (char c = 'A'; c <= 'Z'; c++) 
    nfa.addTransition(3, c, 4); 
    nfa.addTransition(4, '_', 4); 
  for (char c = 'a'; c <= 'z'; c++) 
    nfa.addTransition(4, c, 4); 
  for (char c = 'A'; c <= 'Z'; c++) 
    nfa.addTransition(4, c, 4); 
  for (char c = '0'; c <= '9'; c++) 
    nfa.addTransition(4, c, 4);
 
  //number 
  for (char c = '0'; c <= '9'; c++) { 
    nfa.addTransition(5, c, 6); 
    nfa.addTransition(6, c, 6); 

  }


  //IF
  nfa.addTransition(IF0, 'i', IF1);
  nfa.addTransition(IF1, 'f', IFF);

  //return
  nfa.addTransition(RET0, 'r', RET1);
  nfa.addTransition(RET1, 'e', RET2);
  nfa.addTransition(RET2, 't', RET3);
  nfa.addTransition(RET3, 'u', RET4);
  nfa.addTransition(RET4, 'r', RET5);
  nfa.addTransition(RET5, 'n', RETF);

  //open_par
  nfa.addTransition(OPAR0, '(', OPARF);

  //close_par
  nfa.addTransition(CPAR0, ')', CPARF);

  //assign
  nfa.addTransition(EQ0, '=', EQF);
  
  //isequal
  nfa.addTransition(ISEQ0, '=', ISEQ1);
  nfa.addTransition(ISEQ1, '=', ISEQF);

  //semicolon
  nfa.addTransition(SC0, ';', SCF);

  //file
  std::ifstream myFile;
  myFile.open("input.txt");

  // Create input buffer 
  InputBuffer input_buffer(myFile); 
  while (true) 
    { 
      std::pair<int, std::string> pair = input_buffer.getToken(nfa); 
      // No more tokens 
      if (!pair.first) 
	break; 
      // Token found 
      std::cout << "Token " << tokenTypes[pair.first] << ": '" 
		<< pair.second << "'\n"; 
    } 
  // Done 
  return 0; 
}
