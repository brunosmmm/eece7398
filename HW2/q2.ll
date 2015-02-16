
define i32 @StringCompare(i8* %s1, i8* %s2)
{
entry:
	br label %loop.cond

loop.cond:
	%t0 = phi i32 [0,%entry], [%t9,%loop.incr] ;i32 %t0: index
	%t1 = getelementptr i8* %s1, i32 %t0 ;i8* %t1: &(s1[index])
	%t2 = load i8* %t1 ;i8 %t2: s1[index]
	
	%t3 = icmp eq i8 %t2, 0 ;i1 %t3: s1[index] == 0
	br i1 %t3, label %loop.end, label %s2.end

s2.end:
	%t4 = getelementptr i8* %s2, i32 %t0 ;i8* %t4: &(s2[index])
	%t5 = load i8* %t4 ;i8 %t5: s2[index]
	
	%t6 = icmp eq i8 %t5, 0 ;i1 %t6: s2[index] == 0
	br i1 %t6, label %loop.end, label %lt.cond

lt.cond:
	%t7 = icmp slt i8 %t2, %t5 ;i1 %t7: s1[index] < s2[index]
	br i1 %t7, label %s1.lt, label %gt.cond	

s1.lt:
	ret i32 -1

gt.cond:
	%t8 = icmp sgt i8 %t2, %t5 ;i1 %t8: s1[index] > s2[index]
	br i1 %t8, label %s1.gt, label %loop.incr

s1.gt:
	ret i32 1

loop.incr:
	%t9 = add i32 %t0, 1 ;i32 %t9: index + 1
	br label %loop.cond

loop.end:
	ret i32 0

}
