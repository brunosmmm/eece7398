
#include "UpperCase.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
  int i;

  //make all arguments be capitalized and printed, except argv[0] which is the program name
  for (i = 1; i < argc; i++)
    {
      upper_case(argv[i]);
      printf("%s ",argv[i]);
    }
  
  printf("\n");

}
