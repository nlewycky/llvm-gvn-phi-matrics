; RUN: llc -march=x86-64 -mcpu=core2 -enable-misched -misched=shuffle -misched-bottomup < %s
; XFAIL: *
; ...should pass. See PR12324: misched bringup
;
; Interesting MachineScheduler cases.

declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i32, i1) nounwind

; From oggenc.
; After coalescing, we have a dead superreg (RAX) definition.
;
; CHECK: xorl %esi, %esi
; CHECK: movl $32, %ecx
; CHECK: rep;movsl
define fastcc void @_preextrapolate_helper() nounwind uwtable ssp {
entry:
  br i1 undef, label %for.cond.preheader, label %if.end

for.cond.preheader:                               ; preds = %entry
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* undef, i8* null, i64 128, i32 4, i1 false) nounwind
  unreachable

if.end:                                           ; preds = %entry
  ret void
}
