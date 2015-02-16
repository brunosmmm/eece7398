
void upper_case(char* s)
{

  while (*s) //loop condition: loop.cond
    {
      if (*s >= 'a' && *s <= 'z') //capitalize condition: cap.cond1 && cap.cond2
	{
	  *s = *s - 32; //capitalize body: cap.then
	}
      s++; //increment index: loop.incr
    } //gets out: endloop
}
