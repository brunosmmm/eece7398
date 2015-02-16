/****************************
 *Based on nfa-test.cc
 *
 *
 ****************************/


#include <iostream> 
#include "NFA.h" 

int main(int argc, char **argv) 
{ 
  // Syntax 
  if (argc != 2) 
    { 
      std::cerr << "Syntax: ./nfa-test <string>\n"; 
      return 1; 
    } 

  NFA nfa; 
  nfa.debug = true; 
  nfa.setFinalState(20);
 
  //initial state 
  nfa.addTransition(0, 0, 1);
  nfa.addTransition(0, 0, 3);
  nfa.addTransition(0, 0, 5);

  //N(+)
  nfa.addTransition(1, '+', 2); 
  //N(-)
  nfa.addTransition(3, '-', 4); 
  //N(epsilon)
  nfa.addTransition(5, 0, 6);
 
  //close regex OR
  nfa.addTransition(2, 0, 7);
  nfa.addTransition(4, 0, 7);
  nfa.addTransition(6, 0, 7);

  //N([0-9])
  nfa.addTransition(7, '0', 8);
  nfa.addTransition(7, '1', 8);
  nfa.addTransition(7, '2', 8);
  nfa.addTransition(7, '3', 8);
  nfa.addTransition(7, '4', 8);
  nfa.addTransition(7, '5', 8);
  nfa.addTransition(7, '6', 8);
  nfa.addTransition(7, '7', 8);
  nfa.addTransition(7, '8', 8);
  nfa.addTransition(7, '9', 8);

  //N([0-9]*)
  nfa.addTransition(8, 0, 11);
  nfa.addTransition(8, 0, 9);
  nfa.addTransition(10, 0, 9);
  nfa.addTransition(10, 0, 11);

  nfa.addTransition(9, '0', 10);
  nfa.addTransition(9, '1', 10);
  nfa.addTransition(9, '2', 10);
  nfa.addTransition(9, '3', 10);
  nfa.addTransition(9, '4', 10);
  nfa.addTransition(9, '5', 10);
  nfa.addTransition(9, '6', 10);
  nfa.addTransition(9, '7', 10);
  nfa.addTransition(9, '8', 10);
  nfa.addTransition(9, '9', 10);

  //N(epsilon)
  nfa.addTransition(11, 0, 18);
  nfa.addTransition(18, 0, 19);
  nfa.addTransition(19, 0, 20);

  //N(.)
  nfa.addTransition(11, 0, 12);
  nfa.addTransition(12, '.', 13);
  
  //N([0-9])
  nfa.addTransition(13, '0', 14);
  nfa.addTransition(13, '1', 14);
  nfa.addTransition(13, '2', 14);
  nfa.addTransition(13, '3', 14);
  nfa.addTransition(13, '4', 14);
  nfa.addTransition(13, '5', 14);
  nfa.addTransition(13, '6', 14);
  nfa.addTransition(13, '7', 14);
  nfa.addTransition(13, '8', 14);
  nfa.addTransition(13, '9', 14);

  //N([0-9]*)
  nfa.addTransition(14, 0, 17);
  nfa.addTransition(16, 0, 15);
  nfa.addTransition(14, 0, 15);
  nfa.addTransition(16, 0, 17);

  nfa.addTransition(15, '0', 16);
  nfa.addTransition(15, '1', 16);
  nfa.addTransition(15, '2', 16);
  nfa.addTransition(15, '3', 16);
  nfa.addTransition(15, '4', 16);
  nfa.addTransition(15, '5', 16);
  nfa.addTransition(15, '6', 16);
  nfa.addTransition(15, '7', 16);
  nfa.addTransition(15, '8', 16);
  nfa.addTransition(15, '9', 16);

  nfa.addTransition(17, 0, 20);

  // Parse string 
  bool accepted = nfa.accepts(argv[1]); 
  std::cout << "String " << (accepted ? "accepted" : "rejected") << "\n"; 
  return 0; 
} 
