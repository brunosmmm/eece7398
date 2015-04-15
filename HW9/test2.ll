; ModuleID = 'TestModule'

define void @f() {
L0:
  %t0 = alloca i32
  %t1 = alloca i32
  %t2 = alloca i32
  %t3 = load i32* %t0
  %t4 = icmp sgt i32 %t3, 2
  br i1 %t4, label %L1, label %L2

L1:                                               ; preds = %L0
  %t5 = load i32* %t0
  %t6 = add i32 %t5, 1
  store i32 %t6, i32* %t1
  br label %L3

L2:                                               ; preds = %L0
  %t7 = load i32* %t2
  %t8 = icmp eq i32 %t7, 0
  br i1 %t8, label %L4, label %L5

L3:                                               ; preds = %L5, %L1
  store i32 1, i32* %t2
  ret void

L4:                                               ; preds = %L2
  store i32 0, i32* %t1
  br label %L5

L5:                                               ; preds = %L4, %L2
  br label %L3
}

