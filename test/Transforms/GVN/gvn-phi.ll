; RUN: opt -gvn -S < %s | FileCheck %s

@string1 = constant [8 x i8] c"String 1"
@string2 = constant [8 x i8] c"String 2"
@string3 = constant [8 x i8] c"String 3"

declare void @puts(i8*)

define void @test(i1 %a, i1 %b) {
bb1:
  br i1 %a, label %bb2, label %join
bb2:
  br i1 %b, label %bb3, label %join
bb3:
  br label %join
join:
  %phi1 = phi [8 x i8]* [@string1, %bb1], [@string2, %bb2], [@string3, %bb3]
  %phi2 = phi i8 [1, %bb1], [2, %bb2], [3, %bb3]
  %icmp = icmp eq i8 %phi2, 2
  br i1 %icmp, label %cond_true, label %cond_false
cond_true:
  %str = getelementptr [8 x i8]* %phi1, i32 0, i32 0
  call void @puts(i8* %str)
; CHECK: call void @puts(i8* getelementptr inbounds ([8 x i8]* @string2
  ret void
cond_false:
  %foo = getelementptr [8 x i8]* %phi1, i32 0, i32 0
  ret void
}
