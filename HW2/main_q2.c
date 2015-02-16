#include <stdio.h>

int StringCompare(char * s1, char * s2);

int main(int argc, char *argv[])
{

  //char t1[] = "ABC";
  //char t2[] = "ABC";
  int r = StringCompare(argv[1], argv[2]);

  printf("1: %s\n2: %s\n",argv[1],argv[2]);

  printf("r = %d\n",r);

  return 0;
}
