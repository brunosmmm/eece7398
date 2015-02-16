
define void @upper_case(i8* %s) {
entry:
	%t0 = alloca i32 ;i32 %t0: index in %s
	store i32 0, i32* %t0 ;zeroes index
	br label %loop.cond
loop.cond:
	%t1 = load i32* %t0 ;i32 %t1: index
	%t2 = getelementptr i8* %s, i32 %t1 ;i8* %t2: &s[idx]
	%t3 = load i8* %t2 ;i8 %t3: s[idx]
	%t4 = icmp eq i8 %t3, 0 ;i1 %t4: s[idx] == 0
	br i1 %t4, label %endloop, label %cap.cond1
cap.cond1:
	%t5 = icmp sge i8 %t3, 97 ;i1 %t5: s[idx] >= 97
	br i1 %t5, label %cap.cond2, label %loop.incr
cap.cond2: 
	%t6 = icmp sle i8 %t3, 122 ;i1 %t6: s[idx] <= 122
	br i1 %t6, label %cap.then, label %loop.incr
cap.then:
	%t7 = sub i8 %t3, 32 ;i8 %t7: s[idx] - 32
	store i8 %t7, i8* %t2 ;s[idx] = s[idx] - 32
	br label %loop.incr
loop.incr:
	%t8 = add i32 %t1, 1 ;i32 %t8: idx + 1
	store i32 %t8, i32* %t0 ;idx = idx + 1
	br label %loop.cond
endloop:
	ret void
}