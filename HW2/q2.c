
int StringCompare(char * s1, char * s2)
{
  
  //entry: allocate & initialize
  int index = 0;

  while(s1[index]) //loop.cond
    {
      
      if (s2[index] == 0) //s2.end
	break; //branch to loop.end

      if (s1[index] < s2[index]) //lt.cond
	{
	  return -1; //s1.lt
	}
      else if (s1[index] > s2[index]) //gt.cond
	{
	  return 1; //s1.gt
	}

      index++; //loop.incr

    } //loop.end

  return 0;

}
