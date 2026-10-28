; ModuleID = 'victim_server.cpp'
source_filename = "victim_server.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.std::__n4861::coroutine_handle.0" = type { ptr }
%struct.sockaddr_in = type { i16, i16, %struct.in_addr, [8 x i8] }
%struct.in_addr = type { i32 }
%struct.Task = type { %"struct.std::__n4861::coroutine_handle" }
%"struct.std::__n4861::coroutine_handle" = type { ptr }
%_ZL11worker_coroi.Frame = type { ptr, ptr, %"struct.Task::promise_type", i2, %"struct.std::__n4861::suspend_always", i32 }
%"struct.Task::promise_type" = type { i8 }
%"struct.std::__n4861::suspend_always" = type { i8 }
%_ZL15privileged_corov.Frame = type { ptr, ptr, %"struct.Task::promise_type", i2, %"struct.std::__n4861::suspend_always", %"struct.std::__n4861::suspend_always" }

$_ZN4TaskD2Ev = comdat any

$_ZNSt7__n486116coroutine_handleIvEaSEDn = comdat any

$_ZN4TaskC2EOS_ = comdat any

$_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv = comdat any

$_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv = comdat any

$_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv = comdat any

$_ZN4Task12promise_type17get_return_objectEv = comdat any

$_ZN4Task12promise_type15initial_suspendEv = comdat any

$_ZNKSt7__n486114suspend_always11await_readyEv = comdat any

$_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE = comdat any

$_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv = comdat any

$_ZNKSt7__n486114suspend_always12await_resumeEv = comdat any

$_ZN4Task12promise_type11return_voidEv = comdat any

$_ZN4Task12promise_type13final_suspendEv = comdat any

$_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_promiseERS2_ = comdat any

$__clang_call_terminate = comdat any

$_ZN4TaskC2ENSt7__n486116coroutine_handleINS_12promise_typeEEE = comdat any

$_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEC2Ev = comdat any

$_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEaSEDn = comdat any

$_ZNSt7__n486116coroutine_handleIvE12from_addressEPv = comdat any

$_ZNSt7__n486116coroutine_handleIvEC2Ev = comdat any

$_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv = comdat any

$_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE4doneEv = comdat any

$_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7destroyEv = comdat any

$_ZNKSt7__n486116coroutine_handleIvEcvbEv = comdat any

$_ZNKSt7__n486116coroutine_handleIvE4doneEv = comdat any

$_ZNKSt7__n486116coroutine_handleIvE6resumeEv = comdat any

@stderr = external local_unnamed_addr global ptr, align 8
@.str = private unnamed_addr constant [457 x i8] c"\E2\95\94\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\97\0A\E2\95\91  CFOP Demo \E2\80\94 Victim Server (DELIBERATELY VULNERABLE)        \E2\95\91\0A\E2\95\9A\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\9D\0A\00", align 1
@.str.1 = private unnamed_addr constant [5 x i8] c"bind\00", align 1
@.str.2 = private unnamed_addr constant [45 x i8] c"[VICTIM] Listening on 127.0.0.1:%u  pid=%d\0A\0A\00", align 1
@.str.3 = private unnamed_addr constant [27 x i8] c"[VICTIM] Client connected\0A\00", align 1
@.str.4 = private unnamed_addr constant [31 x i8] c"[VICTIM] Client disconnected\0A\0A\00", align 1
@_ZL8g_worker = internal unnamed_addr global ptr null, align 8
@_ZL6g_priv = internal unnamed_addr global ptr null, align 8
@_ZL21g_redirectable_handle = internal global %"struct.std::__n4861::coroutine_handle.0" zeroinitializer, align 8
@_ZL16g_privileged_ran = internal unnamed_addr global i1 false, align 1
@_ZL13g_scratch_buf = internal global [512 x i8] zeroinitializer, align 16
@.str.5 = private unnamed_addr constant [39 x i8] c"[VICTIM] State reset. worker_frame=%p\0A\00", align 1
@.str.6 = private unnamed_addr constant [56 x i8] c"[VICTIM] Worker-%d: running, suspended at checkpoint A\0A\00", align 1
@.str.7 = private unnamed_addr constant [36 x i8] c"[VICTIM] Worker-%d: resumed past A\0A\00", align 1
@.str.8 = private unnamed_addr constant [31 x i8] c"[VICTIM] Worker-%d: completed\0A\00", align 1
@_ZL14g_is_admin_ptr = internal unnamed_addr global ptr null, align 8
@.str.9 = private unnamed_addr constant [56 x i8] c"[VICTIM] PrivCoro: checking credentials, now suspended\0A\00", align 1
@.str.10 = private unnamed_addr constant [59 x i8] c"[VICTIM] PrivCoro: *** ACCESS GRANTED (is_admin=true) ***\0A\00", align 1
@.str.11 = private unnamed_addr constant [3 x i8] c"id\00", align 1
@.str.12 = private unnamed_addr constant [2 x i8] c"r\00", align 1
@.str.13 = private unnamed_addr constant [41 x i8] c"[VICTIM] PrivCoro:  privileged id \E2\86\92 %s\00", align 1
@.str.14 = private unnamed_addr constant [51 x i8] c"[VICTIM] PrivCoro: access denied (is_admin=false)\0A\00", align 1
@.str.15 = private unnamed_addr constant [2 x i8] c"w\00", align 1
@.str.16 = private unnamed_addr constant [28 x i8] c"READY victim_server pid=%d\0A\00", align 1
@.str.17 = private unnamed_addr constant [3 x i8] c"\0D\0A\00", align 1
@.str.18 = private unnamed_addr constant [19 x i8] c"[VICTIM] \E2\86\90 \22%s\22\0A\00", align 1
@.str.19 = private unnamed_addr constant [5 x i8] c"INFO\00", align 1
@.str.20 = private unnamed_addr constant [134 x i8] c"OK\0Aworker_frame   %p\0Aresume_fn      %p\0Adestroy_fn     %p\0Ahijack_target  %p\0Ais_admin_ptr   %p\0Ascratch_buf    %p\0Ahandle_store   %p\0AEND\0A\00", align 1
@.str.21 = private unnamed_addr constant [7 x i8] c"WRITE \00", align 1
@.str.22 = private unnamed_addr constant [15 x i8] c"%llx %d %1024s\00", align 1
@.str.23 = private unnamed_addr constant [15 x i8] c"ERR bad WRITE\0A\00", align 1
@.str.24 = private unnamed_addr constant [4 x i8] c"%2x\00", align 1
@.str.25 = private unnamed_addr constant [29 x i8] c"OK wrote %d bytes to 0x%llx\0A\00", align 1
@.str.26 = private unnamed_addr constant [35 x i8] c"[VICTIM] Wrote %d bytes to 0x%llx\0A\00", align 1
@.str.27 = private unnamed_addr constant [15 x i8] c"TRIGGER RESUME\00", align 1
@.str.28 = private unnamed_addr constant [17 x i8] c"ERR worker done\0A\00", align 1
@.str.29 = private unnamed_addr constant [4 x i8] c"OK\0A\00", align 1
@.str.30 = private unnamed_addr constant [16 x i8] c"TRIGGER DESTROY\00", align 1
@.str.31 = private unnamed_addr constant [17 x i8] c"ERR null handle\0A\00", align 1
@.str.32 = private unnamed_addr constant [19 x i8] c"TRIGGER PRIVILEGED\00", align 1
@.str.33 = private unnamed_addr constant [15 x i8] c"ERR priv done\0A\00", align 1
@.str.34 = private unnamed_addr constant [22 x i8] c"OK privileged_ran=%s\0A\00", align 1
@.str.35 = private unnamed_addr constant [5 x i8] c"true\00", align 1
@.str.36 = private unnamed_addr constant [6 x i8] c"false\00", align 1
@.str.37 = private unnamed_addr constant [13 x i8] c"TRIGGER FAKE\00", align 1
@.str.38 = private unnamed_addr constant [22 x i8] c"ERR handle null/done\0A\00", align 1
@.str.39 = private unnamed_addr constant [76 x i8] c"[VICTIM] Resuming g_redirectable_handle (may be redirected by attacker)...\0A\00", align 1
@.str.40 = private unnamed_addr constant [6 x i8] c"RESET\00", align 1
@.str.41 = private unnamed_addr constant [5 x i8] c"QUIT\00", align 1
@.str.42 = private unnamed_addr constant [8 x i8] c"OK bye\0A\00", align 1
@.str.43 = private unnamed_addr constant [17 x i8] c"ERR unknown: %s\0A\00", align 1
@.str.44 = private unnamed_addr constant [589 x i8] c"\0A[VICTIM] \E2\95\94\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\97\0A[VICTIM] \E2\95\91  HIJACK_TARGET executing inside victim PID %-4d\E2\95\91\0A[VICTIM] \E2\95\A0\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\A3\0A[VICTIM] \E2\95\91  In a real exploit: execve / ROP chain.     \E2\95\91\0A[VICTIM] \E2\95\9A\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\9D\0A\00", align 1
@.str.45 = private unnamed_addr constant [20 x i8] c"[VICTIM]  id \E2\86\92 %s\00", align 1

; Function Attrs: mustprogress noinline norecurse uwtable
define dso_local noundef i32 @main() local_unnamed_addr #0 {
entry:
  %o = alloca i32, align 4
  %sa = alloca %struct.sockaddr_in, align 4
  %0 = load ptr, ptr @stderr, align 8, !tbaa !5
  %1 = tail call i64 @fwrite(ptr nonnull @.str, i64 456, i64 1, ptr %0) #17
  tail call fastcc void @_ZL11reset_statev()
  %call1 = tail call i32 @socket(i32 noundef 2, i32 noundef 1, i32 noundef 0) #18
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %o) #18
  store i32 1, ptr %o, align 4, !tbaa !9
  %call2 = call i32 @setsockopt(i32 noundef %call1, i32 noundef 1, i32 noundef 2, ptr noundef nonnull %o, i32 noundef 4) #18
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %o) #18
  call void @llvm.lifetime.start.p0(i64 16, ptr nonnull %sa) #18
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(16) %sa, i8 0, i64 16, i1 false)
  store i16 2, ptr %sa, align 4, !tbaa !11
  %sin_addr = getelementptr inbounds %struct.sockaddr_in, ptr %sa, i64 0, i32 2
  store i32 16777343, ptr %sin_addr, align 4, !tbaa !15
  %sin_port = getelementptr inbounds %struct.sockaddr_in, ptr %sa, i64 0, i32 1
  store i16 23569, ptr %sin_port, align 2, !tbaa !16
  %call5 = call i32 @bind(i32 noundef %call1, ptr noundef nonnull %sa, i32 noundef 16) #18
  %cmp = icmp slt i32 %call5, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @perror(ptr noundef nonnull @.str.1) #17
  br label %cleanup19

if.end:                                           ; preds = %entry
  %call6 = call i32 @listen(i32 noundef %call1, i32 noundef 1) #18
  %2 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call7 = call i32 @getpid() #18
  %call8 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %2, ptr noundef nonnull @.str.2, i32 noundef 4444, i32 noundef %call7) #17
  %call927 = call i32 @accept(i32 noundef %call1, ptr noundef null, ptr noundef null)
  %cmp1028 = icmp sgt i32 %call927, -1
  br i1 %cmp1028, label %if.end12, label %for.end

if.end12:                                         ; preds = %if.end, %if.end12
  %call929 = phi i32 [ %call9, %if.end12 ], [ %call927, %if.end ]
  %3 = load ptr, ptr @stderr, align 8, !tbaa !5
  %4 = call i64 @fwrite(ptr nonnull @.str.3, i64 26, i64 1, ptr %3) #17
  call fastcc void @_ZL13handle_clienti(i32 noundef %call929)
  %5 = load ptr, ptr @stderr, align 8, !tbaa !5
  %6 = call i64 @fwrite(ptr nonnull @.str.4, i64 30, i64 1, ptr %5) #17
  call fastcc void @_ZL11reset_statev()
  %call9 = call i32 @accept(i32 noundef %call1, ptr noundef null, ptr noundef null)
  %cmp10 = icmp sgt i32 %call9, -1
  br i1 %cmp10, label %if.end12, label %for.end

for.end:                                          ; preds = %if.end12, %if.end
  %call15 = call i32 @close(i32 noundef %call1)
  %7 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %isnull = icmp eq ptr %7, null
  br i1 %isnull, label %delete.end, label %delete.notnull

delete.notnull:                                   ; preds = %for.end
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %7) #18
  call void @_ZdlPv(ptr noundef %7) #19
  br label %delete.end

delete.end:                                       ; preds = %delete.notnull, %for.end
  %8 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %isnull16 = icmp eq ptr %8, null
  br i1 %isnull16, label %cleanup19, label %delete.notnull17

delete.notnull17:                                 ; preds = %delete.end
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %8) #18
  call void @_ZdlPv(ptr noundef %8) #19
  br label %cleanup19

cleanup19:                                        ; preds = %delete.end, %delete.notnull17, %if.then
  %retval.0 = phi i32 [ 1, %if.then ], [ 0, %delete.notnull17 ], [ 0, %delete.end ]
  call void @llvm.lifetime.end.p0(i64 16, ptr nonnull %sa) #18
  ret i32 %retval.0
}

; Function Attrs: nofree nounwind
declare noundef i32 @fprintf(ptr nocapture noundef, ptr nocapture noundef readonly, ...) local_unnamed_addr #1

; Function Attrs: mustprogress noinline norecurse uwtable
define internal fastcc void @_ZL11reset_statev() unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %tmp = alloca %struct.Task, align 8
  %tmp5 = alloca %struct.Task, align 8
  %0 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %isnull = icmp eq ptr %0, null
  br i1 %isnull, label %delete.end, label %delete.notnull

delete.notnull:                                   ; preds = %entry
  tail call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %0) #18
  tail call void @_ZdlPv(ptr noundef %0) #19
  br label %delete.end

delete.end:                                       ; preds = %delete.notnull, %entry
  store ptr null, ptr @_ZL8g_worker, align 8, !tbaa !5
  %1 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %isnull1 = icmp eq ptr %1, null
  br i1 %isnull1, label %delete.end3, label %delete.notnull2

delete.notnull2:                                  ; preds = %delete.end
  tail call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %1) #18
  tail call void @_ZdlPv(ptr noundef %1) #19
  br label %delete.end3

delete.end3:                                      ; preds = %delete.notnull2, %delete.end
  store ptr null, ptr @_ZL6g_priv, align 8, !tbaa !5
  %call = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIvEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle, ptr null) #18
  store i1 false, ptr @_ZL16g_privileged_ran, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(512) @_ZL13g_scratch_buf, i8 0, i64 512, i1 false)
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %tmp) #18
  call fastcc void @_ZL11worker_coroi(ptr dead_on_unwind nonnull writable sret(%struct.Task) align 8 %tmp, i32 noundef 1)
  %call4 = invoke noalias noundef nonnull dereferenceable(8) ptr @_Znwm(i64 noundef 8) #20
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %delete.end3
  call void @_ZN4TaskC2EOS_(ptr noundef nonnull align 8 dereferenceable(8) %call4, ptr noundef nonnull align 8 dereferenceable(8) %tmp) #18
  store ptr %call4, ptr @_ZL8g_worker, align 8, !tbaa !5
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %tmp) #18
  %2 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %2)
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %tmp5) #18
  call fastcc void @_ZL15privileged_corov(ptr dead_on_unwind nonnull writable sret(%struct.Task) align 8 %tmp5)
  %call8 = invoke noalias noundef nonnull dereferenceable(8) ptr @_Znwm(i64 noundef 8) #20
          to label %invoke.cont7 unwind label %lpad6

invoke.cont7:                                     ; preds = %invoke.cont
  call void @_ZN4TaskC2EOS_(ptr noundef nonnull align 8 dereferenceable(8) %call8, ptr noundef nonnull align 8 dereferenceable(8) %tmp5) #18
  store ptr %call8, ptr @_ZL6g_priv, align 8, !tbaa !5
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp5) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %tmp5) #18
  %3 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %3)
  %4 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %call11 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %4) #18
  store ptr %call11, ptr @_ZL21g_redirectable_handle, align 8, !tbaa.struct !17
  %5 = load ptr, ptr @stderr, align 8, !tbaa !5
  %6 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %call13 = call noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %6) #18
  %call14 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %5, ptr noundef nonnull @.str.5, ptr noundef %call13) #17
  ret void

lpad:                                             ; preds = %delete.end3
  %7 = landingpad { ptr, i32 }
          cleanup
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %tmp) #18
  br label %eh.resume

lpad6:                                            ; preds = %invoke.cont
  %8 = landingpad { ptr, i32 }
          cleanup
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp5) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %tmp5) #18
  br label %eh.resume

eh.resume:                                        ; preds = %lpad6, %lpad
  %.pn = phi { ptr, i32 } [ %8, %lpad6 ], [ %7, %lpad ]
  resume { ptr, i32 } %.pn
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: nounwind
declare i32 @socket(i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #3

; Function Attrs: nounwind
declare i32 @setsockopt(i32 noundef, i32 noundef, i32 noundef, ptr noundef, i32 noundef) local_unnamed_addr #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #4

; Function Attrs: nounwind
declare i32 @bind(i32 noundef, ptr noundef, i32 noundef) local_unnamed_addr #3

; Function Attrs: cold nofree nounwind
declare void @perror(ptr nocapture noundef readonly) local_unnamed_addr #5

; Function Attrs: nounwind
declare i32 @listen(i32 noundef, i32 noundef) local_unnamed_addr #3

; Function Attrs: nounwind
declare i32 @getpid() local_unnamed_addr #3

declare i32 @accept(i32 noundef, ptr noundef, ptr noundef) local_unnamed_addr #6

; Function Attrs: mustprogress noinline norecurse uwtable
define internal fastcc void @_ZL13handle_clienti(i32 noundef %fd) unnamed_addr #0 {
entry:
  %line = alloca [4096 x i8], align 16
  %raw = alloca i64, align 8
  %n = alloca i32, align 4
  %hex = alloca [1025 x i8], align 16
  %data = alloca [512 x i8], align 16
  %v = alloca i32, align 4
  %h = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %call = tail call i32 @dup(i32 noundef %fd) #18
  %call1 = tail call noalias ptr @fdopen(i32 noundef %call, ptr noundef nonnull @.str.12) #18
  %call2 = tail call noalias ptr @fdopen(i32 noundef %fd, ptr noundef nonnull @.str.15) #18
  %tobool = icmp ne ptr %call1, null
  %tobool3 = icmp ne ptr %call2, null
  %or.cond = and i1 %tobool, %tobool3
  br i1 %or.cond, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %call4 = tail call i32 @close(i32 noundef %fd)
  br label %cleanup

if.end:                                           ; preds = %entry
  %call5 = tail call i32 @getpid() #18
  %call6 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef nonnull %call2, ptr noundef nonnull @.str.16, i32 noundef %call5)
  %call7 = tail call i32 @fflush(ptr noundef nonnull %call2)
  call void @llvm.lifetime.start.p0(i64 4096, ptr nonnull %line) #18
  %call8174 = call ptr @fgets(ptr noundef nonnull %line, i32 noundef 4096, ptr noundef nonnull %call1)
  %tobool9.not175 = icmp eq ptr %call8174, null
  br i1 %tobool9.not175, label %while.end, label %while.body.lr.ph

while.body.lr.ph:                                 ; preds = %if.end
  %0 = getelementptr inbounds [1025 x i8], ptr %hex, i64 0, i64 1
  %add.ptr29 = getelementptr inbounds i8, ptr %line, i64 6
  br label %while.body

while.body:                                       ; preds = %while.body.lr.ph, %while.cond.backedge
  %call11 = call i64 @strcspn(ptr noundef nonnull %line, ptr noundef nonnull @.str.17) #21
  %arrayidx = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 %call11
  store i8 0, ptr %arrayidx, align 1, !tbaa !18
  %1 = load i8, ptr %line, align 16, !tbaa !18
  %tobool13.not = icmp eq i8 %1, 0
  br i1 %tobool13.not, label %while.cond.backedge, label %if.end15

if.end15:                                         ; preds = %while.body
  %2 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call17 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %2, ptr noundef nonnull @.str.18, ptr noundef nonnull %line) #17
  %bcmp = call i32 @bcmp(ptr noundef nonnull dereferenceable(5) %line, ptr noundef nonnull dereferenceable(5) @.str.19, i64 5)
  %cmp = icmp eq i32 %bcmp, 0
  br i1 %cmp, label %if.then20, label %if.else

if.then20:                                        ; preds = %if.end15
  %3 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %call21 = call noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %3) #18
  %rfn.0.copyload = load ptr, ptr %call21, align 1
  %add.ptr22 = getelementptr inbounds i8, ptr %call21, i64 8
  %dfn.0.copyload = load ptr, ptr %add.ptr22, align 1
  %4 = load ptr, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %call23 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef nonnull %call2, ptr noundef nonnull @.str.20, ptr noundef nonnull %call21, ptr noundef %rfn.0.copyload, ptr noundef %dfn.0.copyload, ptr noundef nonnull @_ZL13hijack_targetPv, ptr noundef %4, ptr noundef nonnull @_ZL13g_scratch_buf, ptr noundef nonnull @_ZL21g_redirectable_handle)
  br label %if.end131

if.else:                                          ; preds = %if.end15
  %bcmp164 = call i32 @bcmp(ptr noundef nonnull dereferenceable(6) %line, ptr noundef nonnull dereferenceable(6) @.str.21, i64 6)
  %cmp26 = icmp eq i32 %bcmp164, 0
  br i1 %cmp26, label %if.then27, label %if.else47

if.then27:                                        ; preds = %if.else
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %raw) #18
  store i64 0, ptr %raw, align 8, !tbaa !19
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %n) #18
  store i32 0, ptr %n, align 4, !tbaa !9
  call void @llvm.lifetime.start.p0(i64 1025, ptr nonnull %hex) #18
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(1025) %hex, i8 0, i64 1025, i1 false)
  store i8 48, ptr %hex, align 16
  store i8 48, ptr %0, align 1
  %call31 = call i32 (ptr, ptr, ...) @__isoc23_sscanf(ptr noundef nonnull %add.ptr29, ptr noundef nonnull @.str.22, ptr noundef nonnull %raw, ptr noundef nonnull %n, ptr noundef nonnull %hex) #18
  %cmp32 = icmp slt i32 %call31, 2
  br i1 %cmp32, label %if.then33, label %if.else35

if.then33:                                        ; preds = %if.then27
  %5 = call i64 @fwrite(ptr nonnull @.str.23, i64 14, i64 1, ptr nonnull %call2)
  br label %if.end46

if.else35:                                        ; preds = %if.then27
  call void @llvm.lifetime.start.p0(i64 512, ptr nonnull %data) #18
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(512) %data, i8 0, i64 512, i1 false)
  %6 = load i32, ptr %n, align 4, !tbaa !9
  %cmp36172 = icmp sgt i32 %6, 0
  br i1 %cmp36172, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %if.else35
  %.lcssa = phi i32 [ %6, %if.else35 ], [ %16, %for.body ]
  %7 = load i64, ptr %raw, align 8, !tbaa !19
  %8 = inttoptr i64 %7 to ptr
  %conv43 = sext i32 %.lcssa to i64
  call fastcc void @_ZL19vuln_write_anywherePvPKhm(ptr noundef %8, ptr noundef nonnull %data, i64 noundef %conv43)
  %9 = load i32, ptr %n, align 4, !tbaa !9
  %10 = load i64, ptr %raw, align 8, !tbaa !19
  %call44 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef nonnull %call2, ptr noundef nonnull @.str.25, i32 noundef %9, i64 noundef %10)
  %11 = load ptr, ptr @stderr, align 8, !tbaa !5
  %12 = load i32, ptr %n, align 4, !tbaa !9
  %13 = load i64, ptr %raw, align 8, !tbaa !19
  %call45 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %11, ptr noundef nonnull @.str.26, i32 noundef %12, i64 noundef %13) #17
  call void @llvm.lifetime.end.p0(i64 512, ptr nonnull %data) #18
  br label %if.end46

for.body:                                         ; preds = %if.else35, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %if.else35 ]
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %v) #18
  store i32 0, ptr %v, align 4, !tbaa !9
  %14 = shl nuw nsw i64 %indvars.iv, 1
  %add.ptr39 = getelementptr inbounds i8, ptr %hex, i64 %14
  %call40 = call i32 (ptr, ptr, ...) @__isoc23_sscanf(ptr noundef nonnull %add.ptr39, ptr noundef nonnull @.str.24, ptr noundef nonnull %v) #18
  %15 = load i32, ptr %v, align 4, !tbaa !9
  %conv = trunc i32 %15 to i8
  %arrayidx41 = getelementptr inbounds [512 x i8], ptr %data, i64 0, i64 %indvars.iv
  store i8 %conv, ptr %arrayidx41, align 1, !tbaa !18
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %v) #18
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %16 = load i32, ptr %n, align 4, !tbaa !9
  %17 = sext i32 %16 to i64
  %cmp36 = icmp slt i64 %indvars.iv.next, %17
  %cmp37 = icmp ult i64 %indvars.iv, 511
  %18 = and i1 %cmp37, %cmp36
  br i1 %18, label %for.body, label %for.cond.cleanup, !llvm.loop !21

if.end46:                                         ; preds = %for.cond.cleanup, %if.then33
  call void @llvm.lifetime.end.p0(i64 1025, ptr nonnull %hex) #18
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %n) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %raw) #18
  br label %if.end131

if.else47:                                        ; preds = %if.else
  %bcmp165 = call i32 @bcmp(ptr noundef nonnull dereferenceable(15) %line, ptr noundef nonnull dereferenceable(15) @.str.27, i64 15)
  %cmp50 = icmp eq i32 %bcmp165, 0
  br i1 %cmp50, label %if.then51, label %if.else63

if.then51:                                        ; preds = %if.else47
  %19 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %call53 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %19) #18
  br i1 %call53, label %lor.lhs.false54, label %if.then57

lor.lhs.false54:                                  ; preds = %if.then51
  %20 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %call56 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %20) #18
  br i1 %call56, label %if.then57, label %if.else59

if.then57:                                        ; preds = %lor.lhs.false54, %if.then51
  %21 = call i64 @fwrite(ptr nonnull @.str.28, i64 16, i64 1, ptr nonnull %call2)
  br label %if.end131

if.else59:                                        ; preds = %lor.lhs.false54
  %22 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %22)
  %23 = call i64 @fwrite(ptr nonnull @.str.29, i64 3, i64 1, ptr nonnull %call2)
  br label %if.end131

if.else63:                                        ; preds = %if.else47
  %bcmp166 = call i32 @bcmp(ptr noundef nonnull dereferenceable(16) %line, ptr noundef nonnull dereferenceable(16) @.str.30, i64 16)
  %cmp66 = icmp eq i32 %bcmp166, 0
  br i1 %cmp66, label %if.then67, label %if.else78

if.then67:                                        ; preds = %if.else63
  %24 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %call69 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %24) #18
  br i1 %call69, label %if.else72, label %if.then70

if.then70:                                        ; preds = %if.then67
  %25 = call i64 @fwrite(ptr nonnull @.str.31, i64 16, i64 1, ptr nonnull %call2)
  br label %if.end131

if.else72:                                        ; preds = %if.then67
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %h) #18
  %26 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %27 = load i64, ptr %26, align 8, !tbaa !5
  store i64 %27, ptr %h, align 8, !tbaa !5
  %call75 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %26, ptr null) #18
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7destroyEv(ptr noundef nonnull align 8 dereferenceable(8) %h)
  %28 = call i64 @fwrite(ptr nonnull @.str.29, i64 3, i64 1, ptr nonnull %call2)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %h) #18
  br label %if.end131

if.else78:                                        ; preds = %if.else63
  %bcmp167 = call i32 @bcmp(ptr noundef nonnull dereferenceable(19) %line, ptr noundef nonnull dereferenceable(19) @.str.32, i64 19)
  %cmp81 = icmp eq i32 %bcmp167, 0
  br i1 %cmp81, label %if.then82, label %if.else95

if.then82:                                        ; preds = %if.else78
  %29 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %call84 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %29) #18
  br i1 %call84, label %lor.lhs.false85, label %if.then88

lor.lhs.false85:                                  ; preds = %if.then82
  %30 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %call87 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %30) #18
  br i1 %call87, label %if.then88, label %if.else90

if.then88:                                        ; preds = %lor.lhs.false85, %if.then82
  %31 = call i64 @fwrite(ptr nonnull @.str.33, i64 14, i64 1, ptr nonnull %call2)
  br label %if.end131

if.else90:                                        ; preds = %lor.lhs.false85
  %32 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %32)
  %.b171 = load i1, ptr @_ZL16g_privileged_ran, align 1
  %cond = select i1 %.b171, ptr @.str.35, ptr @.str.36
  %call93 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef nonnull %call2, ptr noundef nonnull @.str.34, ptr noundef nonnull %cond)
  br label %if.end131

if.else95:                                        ; preds = %if.else78
  %bcmp168 = call i32 @bcmp(ptr noundef nonnull dereferenceable(13) %line, ptr noundef nonnull dereferenceable(13) @.str.37, i64 13)
  %cmp98 = icmp eq i32 %bcmp168, 0
  br i1 %cmp98, label %if.then99, label %if.else109

if.then99:                                        ; preds = %if.else95
  %call100 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle) #18
  br i1 %call100, label %lor.lhs.false101, label %if.then103

lor.lhs.false101:                                 ; preds = %if.then99
  %call102 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle) #18
  br i1 %call102, label %if.then103, label %if.else105

if.then103:                                       ; preds = %lor.lhs.false101, %if.then99
  %33 = call i64 @fwrite(ptr nonnull @.str.38, i64 21, i64 1, ptr nonnull %call2)
  br label %if.end131

if.else105:                                       ; preds = %lor.lhs.false101
  %34 = load ptr, ptr @stderr, align 8, !tbaa !5
  %35 = call i64 @fwrite(ptr nonnull @.str.39, i64 75, i64 1, ptr %34) #17
  call void @_ZNKSt7__n486116coroutine_handleIvE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle)
  %36 = call i64 @fwrite(ptr nonnull @.str.29, i64 3, i64 1, ptr nonnull %call2)
  br label %if.end131

if.else109:                                       ; preds = %if.else95
  %bcmp169 = call i32 @bcmp(ptr noundef nonnull dereferenceable(6) %line, ptr noundef nonnull dereferenceable(6) @.str.40, i64 6)
  %cmp112 = icmp eq i32 %bcmp169, 0
  br i1 %cmp112, label %if.then113, label %if.else115

if.then113:                                       ; preds = %if.else109
  call fastcc void @_ZL11reset_statev()
  %37 = call i64 @fwrite(ptr nonnull @.str.29, i64 3, i64 1, ptr nonnull %call2)
  br label %if.end131

if.else115:                                       ; preds = %if.else109
  %bcmp170 = call i32 @bcmp(ptr noundef nonnull dereferenceable(5) %line, ptr noundef nonnull dereferenceable(5) @.str.41, i64 5)
  %cmp118 = icmp eq i32 %bcmp170, 0
  br i1 %cmp118, label %if.then119, label %if.else121

if.then119:                                       ; preds = %if.else115
  %38 = call i64 @fwrite(ptr nonnull @.str.42, i64 7, i64 1, ptr nonnull %call2)
  br label %while.end

if.else121:                                       ; preds = %if.else115
  %call123 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef nonnull %call2, ptr noundef nonnull @.str.43, ptr noundef nonnull %line)
  br label %if.end131

if.end131:                                        ; preds = %if.end46, %if.else72, %if.then70, %if.else105, %if.then103, %if.else121, %if.then113, %if.then88, %if.else90, %if.then57, %if.else59, %if.then20
  %call132 = call i32 @fflush(ptr noundef nonnull %call2)
  br label %while.cond.backedge

while.cond.backedge:                              ; preds = %if.end131, %while.body
  %call8 = call ptr @fgets(ptr noundef nonnull %line, i32 noundef 4096, ptr noundef nonnull %call1)
  %tobool9.not = icmp eq ptr %call8, null
  br i1 %tobool9.not, label %while.end, label %while.body, !llvm.loop !24

while.end:                                        ; preds = %while.cond.backedge, %if.end, %if.then119
  %call133 = call i32 @fclose(ptr noundef nonnull %call1)
  %call134 = call i32 @fclose(ptr noundef nonnull %call2)
  call void @llvm.lifetime.end.p0(i64 4096, ptr nonnull %line) #18
  br label %cleanup

cleanup:                                          ; preds = %while.end, %if.then
  ret void
}

declare i32 @close(i32 noundef) local_unnamed_addr #6

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #7 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %call = tail call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #18
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  invoke void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7destroyEv(ptr noundef nonnull align 8 dereferenceable(8) %this)
          to label %if.end unwind label %terminate.lpad

if.end:                                           ; preds = %if.then, %entry
  ret void

terminate.lpad:                                   ; preds = %if.then
  %0 = landingpad { ptr, i32 }
          catch ptr null
  %1 = extractvalue { ptr, i32 } %0, 0
  tail call void @__clang_call_terminate(ptr %1) #22
  unreachable
}

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPv(ptr noundef) local_unnamed_addr #8

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIvEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr %0) local_unnamed_addr #7 comdat align 2 {
entry:
  store ptr null, ptr %this, align 8, !tbaa !25
  ret ptr %this
}

; Function Attrs: mustprogress noinline norecurse uwtable
define internal fastcc void @_ZL11worker_coroi(ptr dead_on_unwind writable sret(%struct.Task) align 8 %agg.result, i32 noundef %id) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %ref.tmp3 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp12 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp26 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp43 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %call = tail call noalias noundef nonnull dereferenceable(24) ptr @_Znwm(i64 noundef 24) #23
  store ptr @_ZL11worker_coroi.resume, ptr %call, align 8
  %destroy.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %call, i64 0, i32 1
  store ptr @_ZL11worker_coroi.destroy, ptr %destroy.addr, align 8
  %ref.tmp.reload.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %call, i64 0, i32 4
  %__promise.reload.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %call, i64 0, i32 2
  %id.spill.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %call, i64 0, i32 5
  store i32 %id, ptr %id.spill.addr, align 4
  tail call void @_ZN4Task12promise_type17get_return_objectEv(ptr dead_on_unwind writable sret(%struct.Task) align 8 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  tail call void @_ZN4Task12promise_type15initial_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  %call2 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call2, label %init.ready, label %CoroSave

CoroSave:                                         ; preds = %entry
  %index.addr83 = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %call, i64 0, i32 3
  store i2 0, ptr %index.addr83, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp3) #18
  %call4 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %call) #18
  store ptr %call4, ptr %ref.tmp3, align 8
  %call5 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp3) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call5) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp3) #18
  br label %AfterCoroEnd

init.ready:                                       ; preds = %entry
  %id.reload = load i32, ptr %id.spill.addr, align 4
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  %0 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call8 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %0, ptr noundef nonnull @.str.6, i32 noundef %id.reload) #17
  %call10 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call10, label %await.ready, label %CoroSave67

CoroSave67:                                       ; preds = %init.ready
  %index.addr84 = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %call, i64 0, i32 3
  store i2 1, ptr %index.addr84, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp12) #18
  %call13 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %call) #18
  store ptr %call13, ptr %ref.tmp12, align 8
  %call15 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp12) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call15) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp12) #18
  br label %AfterCoroEnd

CoroSave75:                                       ; preds = %await2.ready
  store ptr null, ptr %call, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp43) #18
  %call44 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %call) #18
  store ptr %call44, ptr %ref.tmp43, align 8
  %call46 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp43) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call46) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp43) #18
  br label %AfterCoroEnd

await.ready:                                      ; preds = %init.ready
  %id.reload80 = load i32, ptr %id.spill.addr, align 4
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  %1 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call22 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %1, ptr noundef nonnull @.str.7, i32 noundef %id.reload80) #17
  %call24 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call24, label %await2.ready, label %CoroSave71

CoroSave71:                                       ; preds = %await.ready
  %index.addr85 = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %call, i64 0, i32 3
  store i2 -2, ptr %index.addr85, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp26) #18
  %call27 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %call) #18
  store ptr %call27, ptr %ref.tmp26, align 8
  %call29 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp26) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call29) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp26) #18
  br label %AfterCoroEnd

await2.ready:                                     ; preds = %await.ready
  %id.reload82 = load i32, ptr %id.spill.addr, align 4
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  %2 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call36 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %2, ptr noundef nonnull @.str.8, i32 noundef %id.reload82) #17
  tail call void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  tail call void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  %call41 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call41, label %final.ready, label %CoroSave75

final.ready:                                      ; preds = %await2.ready
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  tail call void @_ZdlPv(ptr noundef nonnull %call) #18
  br label %AfterCoroEnd

AfterCoroEnd:                                     ; preds = %CoroSave75, %CoroSave71, %CoroSave67, %CoroSave, %final.ready
  ret void
}

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #9

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4TaskC2EOS_(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr noundef nonnull align 8 dereferenceable(8) %o) unnamed_addr #7 comdat align 2 {
entry:
  %0 = load i64, ptr %o, align 8, !tbaa !5
  store i64 %0, ptr %this, align 8, !tbaa !5
  %call = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %o, ptr null) #18
  ret void
}

; Function Attrs: mustprogress noinline uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #10 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !27
  %1 = load ptr, ptr %0, align 8
  tail call fastcc void %1(ptr nonnull %0)
  ret void
}

; Function Attrs: mustprogress noinline norecurse uwtable
define internal fastcc void @_ZL15privileged_corov(ptr dead_on_unwind writable sret(%struct.Task) align 8 %agg.result) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %ref.tmp2 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp11 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %buf = alloca [128 x i8], align 16
  %ref.tmp47 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %call = tail call noalias noundef nonnull dereferenceable(24) ptr @_Znwm(i64 noundef 24) #23
  store ptr @_ZL15privileged_corov.resume, ptr %call, align 8
  %destroy.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %call, i64 0, i32 1
  store ptr @_ZL15privileged_corov.destroy, ptr %destroy.addr, align 8
  %ref.tmp.reload.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %call, i64 0, i32 4
  %ref.tmp8.reload.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %call, i64 0, i32 5
  %__promise.reload.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %call, i64 0, i32 2
  tail call void @_ZN4Task12promise_type17get_return_objectEv(ptr dead_on_unwind writable sret(%struct.Task) align 8 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  tail call void @_ZN4Task12promise_type15initial_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  %call1 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call1, label %init.ready, label %CoroSave

CoroSave:                                         ; preds = %entry
  %index.addr82 = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %call, i64 0, i32 3
  store i2 0, ptr %index.addr82, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp2) #18
  %call3 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %call) #18
  store ptr %call3, ptr %ref.tmp2, align 8
  %call4 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp2) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call4) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp2) #18
  br label %AfterCoroEnd

init.ready:                                       ; preds = %entry
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  store volatile i8 0, ptr %ref.tmp.reload.addr, align 1, !tbaa !29
  store ptr %ref.tmp.reload.addr, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %0 = load ptr, ptr @stderr, align 8, !tbaa !5
  %1 = tail call i64 @fwrite(ptr nonnull @.str.9, i64 55, i64 1, ptr %0) #17
  %call9 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8.reload.addr) #18
  br i1 %call9, label %await.ready, label %CoroSave73

CoroSave73:                                       ; preds = %init.ready
  %index.addr83 = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %call, i64 0, i32 3
  store i2 1, ptr %index.addr83, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp11) #18
  %call12 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %call) #18
  store ptr %call12, ptr %ref.tmp11, align 8
  %call14 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp11) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8.reload.addr, ptr %call14) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp11) #18
  br label %AfterCoroEnd

await.ready:                                      ; preds = %init.ready
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8.reload.addr) #18
  store ptr null, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %2 = load volatile i8, ptr %ref.tmp.reload.addr, align 1, !tbaa !29, !range !31, !noundef !32
  %tobool.not = icmp eq i8 %2, 0
  %3 = load ptr, ptr @stderr, align 8, !tbaa !5
  br i1 %tobool.not, label %if.else, label %if.then

if.then:                                          ; preds = %await.ready
  %4 = tail call i64 @fwrite(ptr nonnull @.str.10, i64 58, i64 1, ptr %3) #17
  %call24 = tail call noalias ptr @popen(ptr noundef nonnull @.str.11, ptr noundef nonnull @.str.12)
  %tobool25.not = icmp eq ptr %call24, null
  br i1 %tobool25.not, label %if.end, label %if.then26

if.then26:                                        ; preds = %if.then
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %buf) #18
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(128) %buf, i8 0, i64 128, i1 false)
  %call29 = call i64 @fread(ptr noundef nonnull %buf, i64 noundef 1, i64 noundef 127, ptr noundef nonnull %call24)
  %call31 = tail call i32 @pclose(ptr noundef nonnull %call24)
  %5 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call34 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %5, ptr noundef nonnull @.str.13, ptr noundef nonnull %buf) #17
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %buf) #18
  br label %if.end

if.end:                                           ; preds = %if.then26, %if.then
  store i1 true, ptr @_ZL16g_privileged_ran, align 1
  br label %if.end37

if.else:                                          ; preds = %await.ready
  %6 = tail call i64 @fwrite(ptr nonnull @.str.14, i64 50, i64 1, ptr %3) #17
  br label %if.end37

if.end37:                                         ; preds = %if.else, %if.end
  call void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  call void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  %call45 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call45, label %final.ready, label %CoroSave77

CoroSave77:                                       ; preds = %if.end37
  store ptr null, ptr %call, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp47) #18
  %call48 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %call) #18
  store ptr %call48, ptr %ref.tmp47, align 8
  %call50 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp47) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call50) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp47) #18
  br label %AfterCoroEnd

final.ready:                                      ; preds = %if.end37
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  call void @_ZdlPv(ptr noundef nonnull %call) #18
  br label %AfterCoroEnd

AfterCoroEnd:                                     ; preds = %CoroSave77, %CoroSave73, %CoroSave, %final.ready
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  %call = tail call noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #18
  %call2 = tail call ptr @_ZNSt7__n486116coroutine_handleIvE12from_addressEPv(ptr noundef %call) #18
  ret ptr %call2
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #11

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !27
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type17get_return_objectEv(ptr dead_on_unwind noalias writable sret(%struct.Task) align 8 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %this) local_unnamed_addr #7 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %call = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_promiseERS2_(ptr noundef nonnull align 1 dereferenceable(1) %this)
  tail call void @_ZN4TaskC2ENSt7__n486116coroutine_handleINS_12promise_typeEEE(ptr noundef nonnull align 8 dereferenceable(8) %agg.result, ptr %call) #18
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type15initial_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %this, ptr %.coerce) local_unnamed_addr #7 comdat align 2 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %__a) local_unnamed_addr #7 comdat align 2 {
entry:
  %retval = alloca %"struct.std::__n4861::coroutine_handle", align 8
  call void @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %retval) #18
  store ptr %__a, ptr %retval, align 8, !tbaa !27
  ret ptr %__a
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  ret void
}

declare ptr @__cxa_begin_catch(ptr) local_unnamed_addr

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_promiseERS2_(ptr noundef nonnull align 1 dereferenceable(1) %__p) local_unnamed_addr #7 comdat align 2 {
entry:
  %retval = alloca %"struct.std::__n4861::coroutine_handle", align 8
  call void @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %retval) #18
  %0 = getelementptr inbounds i8, ptr %__p, i64 -16
  store ptr %0, ptr %retval, align 8, !tbaa !27
  ret ptr %0
}

; Function Attrs: noinline noreturn nounwind uwtable
define linkonce_odr hidden void @__clang_call_terminate(ptr noundef %0) local_unnamed_addr #12 comdat {
  %2 = tail call ptr @__cxa_begin_catch(ptr %0) #18
  tail call void @_ZSt9terminatev() #22
  unreachable
}

declare void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4TaskC2ENSt7__n486116coroutine_handleINS_12promise_typeEEE(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr %h.coerce) unnamed_addr #7 comdat align 2 {
entry:
  store ptr %h.coerce, ptr %this, align 8, !tbaa.struct !17
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #7 comdat align 2 {
entry:
  store ptr null, ptr %this, align 8, !tbaa !27
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr %0) local_unnamed_addr #7 comdat align 2 {
entry:
  store ptr null, ptr %this, align 8, !tbaa !27
  ret ptr %this
}

; Function Attrs: nofree nounwind
declare noalias noundef ptr @popen(ptr nocapture noundef readonly, ptr nocapture noundef readonly) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare noundef i64 @fread(ptr nocapture noundef, i64 noundef, i64 noundef, ptr nocapture noundef) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare noundef i32 @pclose(ptr nocapture noundef) local_unnamed_addr #1

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNSt7__n486116coroutine_handleIvE12from_addressEPv(ptr noundef %__a) local_unnamed_addr #7 comdat align 2 {
entry:
  %retval = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  call void @_ZNSt7__n486116coroutine_handleIvEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %retval) #18
  store ptr %__a, ptr %retval, align 8, !tbaa !25
  ret ptr %__a
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNSt7__n486116coroutine_handleIvEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #7 comdat align 2 {
entry:
  store ptr null, ptr %this, align 8, !tbaa !25
  ret void
}

; Function Attrs: nofree nounwind
declare noalias noundef ptr @fdopen(i32 noundef, ptr nocapture noundef readonly) local_unnamed_addr #1

; Function Attrs: nounwind
declare i32 @dup(i32 noundef) local_unnamed_addr #3

; Function Attrs: nofree nounwind
declare noundef i32 @fflush(ptr nocapture noundef) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare noundef ptr @fgets(ptr noundef, i32 noundef, ptr nocapture noundef) local_unnamed_addr #1

; Function Attrs: mustprogress nofree nounwind willreturn memory(argmem: read)
declare i64 @strcspn(ptr nocapture noundef, ptr nocapture noundef) local_unnamed_addr #13

; Function Attrs: mustprogress noinline nounwind uwtable
define internal void @_ZL13hijack_targetPv(ptr noundef writeonly %frame) #7 {
entry:
  %buf = alloca [128 x i8], align 16
  %0 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call = tail call i32 @getpid() #18
  %call1 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %0, ptr noundef nonnull @.str.44, i32 noundef %call) #17
  %call2 = tail call noalias ptr @popen(ptr noundef nonnull @.str.11, ptr noundef nonnull @.str.12)
  %tobool.not = icmp eq ptr %call2, null
  br i1 %tobool.not, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %buf) #18
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(128) %buf, i8 0, i64 128, i1 false)
  %call3 = call i64 @fread(ptr noundef nonnull %buf, i64 noundef 1, i64 noundef 127, ptr noundef nonnull %call2)
  %call4 = tail call i32 @pclose(ptr noundef nonnull %call2)
  %1 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call6 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %1, ptr noundef nonnull @.str.45, ptr noundef nonnull %buf) #17
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %buf) #18
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %tobool7.not = icmp eq ptr %frame, null
  br i1 %tobool7.not, label %if.end9, label %if.then8

if.then8:                                         ; preds = %if.end
  store ptr null, ptr %frame, align 1
  br label %if.end9

if.end9:                                          ; preds = %if.then8, %if.end
  ret void
}

; Function Attrs: nounwind
declare i32 @__isoc23_sscanf(ptr noundef, ptr noundef, ...) local_unnamed_addr #3

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define internal fastcc void @_ZL19vuln_write_anywherePvPKhm(ptr nocapture noundef writeonly %dest, ptr nocapture noundef readonly %src, i64 noundef %n) unnamed_addr #14 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %dest, ptr align 1 %src, i64 %n, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !27
  %tobool = icmp ne ptr %0, null
  ret i1 %tobool
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !27
  %1 = load ptr, ptr %0, align 8
  %2 = icmp eq ptr %1, null
  ret i1 %2
}

; Function Attrs: mustprogress noinline uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7destroyEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #10 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !27
  %1 = getelementptr inbounds { ptr, ptr }, ptr %0, i64 0, i32 1
  %2 = load ptr, ptr %1, align 8
  tail call fastcc void %2(ptr %0)
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !25
  %tobool = icmp ne ptr %0, null
  ret i1 %tobool
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #7 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !25
  %1 = load ptr, ptr %0, align 8
  %2 = icmp eq ptr %1, null
  ret i1 %2
}

; Function Attrs: mustprogress noinline uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486116coroutine_handleIvE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %this) local_unnamed_addr #10 comdat align 2 {
entry:
  %0 = load ptr, ptr %this, align 8, !tbaa !25
  %1 = load ptr, ptr %0, align 8
  tail call fastcc void %1(ptr nonnull %0)
  ret void
}

; Function Attrs: nofree nounwind
declare noundef i32 @fclose(ptr nocapture noundef) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare noundef i64 @fwrite(ptr nocapture noundef, i64 noundef, i64 noundef, ptr nocapture noundef) local_unnamed_addr #15

; Function Attrs: nofree nounwind willreturn memory(argmem: read)
declare i32 @bcmp(ptr nocapture, ptr nocapture, i64) local_unnamed_addr #16

; Function Attrs: mustprogress noinline nounwind uwtable
define internal fastcc void @_ZL11worker_coroi.resume(ptr noundef nonnull align 8 dereferenceable(24) %0) #7 personality ptr @__gxx_personality_v0 {
entry.resume:
  %ref.tmp43 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp26 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp12 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp.reload.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %0, i64 0, i32 4
  %__promise.reload.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %0, i64 0, i32 2
  %index.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %0, i64 0, i32 3
  %index = load i2, ptr %index.addr, align 1
  switch i2 %index, label %unreachable [
    i2 0, label %init.ready
    i2 1, label %await.ready
    i2 -2, label %await2.ready
  ]

init.ready:                                       ; preds = %entry.resume
  %id.reload.addr = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %0, i64 0, i32 5
  %id.reload = load i32, ptr %id.reload.addr, align 4
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  %1 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call8 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %1, ptr noundef nonnull @.str.6, i32 noundef %id.reload) #17
  %call10 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call10, label %await.ready, label %CoroSave67

CoroSave67:                                       ; preds = %init.ready
  store i2 1, ptr %index.addr, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp12) #18
  %call13 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %0) #18
  store ptr %call13, ptr %ref.tmp12, align 8
  %call15 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp12) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call15) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp12) #18
  br label %CoroEnd

CoroSave75:                                       ; preds = %await2.ready
  store ptr null, ptr %0, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp43) #18
  %call44 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %0) #18
  store ptr %call44, ptr %ref.tmp43, align 8
  %call46 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp43) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call46) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp43) #18
  br label %CoroEnd

await.ready:                                      ; preds = %entry.resume, %init.ready
  %id.reload.addr79 = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %0, i64 0, i32 5
  %id.reload80 = load i32, ptr %id.reload.addr79, align 4
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  %2 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call22 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %2, ptr noundef nonnull @.str.7, i32 noundef %id.reload80) #17
  %call24 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call24, label %await2.ready, label %CoroSave71

CoroSave71:                                       ; preds = %await.ready
  store i2 -2, ptr %index.addr, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp26) #18
  %call27 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %0) #18
  store ptr %call27, ptr %ref.tmp26, align 8
  %call29 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp26) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call29) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp26) #18
  br label %CoroEnd

await2.ready:                                     ; preds = %entry.resume, %await.ready
  %id.reload.addr81 = getelementptr inbounds %_ZL11worker_coroi.Frame, ptr %0, i64 0, i32 5
  %id.reload82 = load i32, ptr %id.reload.addr81, align 4
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  %3 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call36 = tail call i32 (ptr, ptr, ...) @fprintf(ptr noundef %3, ptr noundef nonnull @.str.8, i32 noundef %id.reload82) #17
  tail call void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  tail call void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  %call41 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call41, label %final.ready, label %CoroSave75

final.ready:                                      ; preds = %await2.ready
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  tail call void @_ZdlPv(ptr noundef nonnull %0) #18
  br label %CoroEnd

CoroEnd:                                          ; preds = %CoroSave71, %CoroSave67, %final.ready, %CoroSave75
  ret void

unreachable:                                      ; preds = %entry.resume
  unreachable
}

; Function Attrs: mustprogress noinline nounwind uwtable
define internal fastcc void @_ZL11worker_coroi.destroy(ptr noundef nonnull align 8 dereferenceable(24) %0) #7 personality ptr @__gxx_personality_v0 {
entry.destroy:
  tail call void @_ZdlPv(ptr noundef nonnull %0) #18
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define internal fastcc void @_ZL15privileged_corov.resume(ptr noundef nonnull align 8 dereferenceable(24) %0) #7 personality ptr @__gxx_personality_v0 {
entry.resume:
  %ref.tmp47 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %buf = alloca [128 x i8], align 16
  %ref.tmp11 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp.reload.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %0, i64 0, i32 4
  %ref.tmp8.reload.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %0, i64 0, i32 5
  %__promise.reload.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %0, i64 0, i32 2
  %index.addr = getelementptr inbounds %_ZL15privileged_corov.Frame, ptr %0, i64 0, i32 3
  %index = load i2, ptr %index.addr, align 1
  %switch.not = icmp eq i2 %index, 0
  br i1 %switch.not, label %init.ready, label %await.ready

init.ready:                                       ; preds = %entry.resume
  tail call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  store volatile i8 0, ptr %ref.tmp.reload.addr, align 2, !tbaa !29
  store ptr %ref.tmp.reload.addr, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %1 = load ptr, ptr @stderr, align 8, !tbaa !5
  %2 = tail call i64 @fwrite(ptr nonnull @.str.9, i64 55, i64 1, ptr %1) #17
  %call9 = tail call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8.reload.addr) #18
  br i1 %call9, label %await.ready, label %CoroSave73

CoroSave73:                                       ; preds = %init.ready
  store i2 1, ptr %index.addr, align 1
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp11) #18
  %call12 = tail call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %0) #18
  store ptr %call12, ptr %ref.tmp11, align 8
  %call14 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp11) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8.reload.addr, ptr %call14) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp11) #18
  br i1 %switch.not, label %CoroEnd, label %await.ready

await.ready:                                      ; preds = %entry.resume, %CoroSave73, %init.ready
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8.reload.addr) #18
  store ptr null, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %3 = load volatile i8, ptr %ref.tmp.reload.addr, align 2, !tbaa !29, !range !31, !noundef !32
  %tobool.not = icmp eq i8 %3, 0
  %4 = load ptr, ptr @stderr, align 8, !tbaa !5
  br i1 %tobool.not, label %if.else, label %if.then

if.then:                                          ; preds = %await.ready
  %5 = call i64 @fwrite(ptr nonnull @.str.10, i64 58, i64 1, ptr %4) #17
  %call24 = call noalias ptr @popen(ptr noundef nonnull @.str.11, ptr noundef nonnull @.str.12)
  %tobool25.not = icmp eq ptr %call24, null
  br i1 %tobool25.not, label %if.end, label %if.then26

if.then26:                                        ; preds = %if.then
  call void @llvm.lifetime.start.p0(i64 128, ptr nonnull %buf) #18
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(128) %buf, i8 0, i64 128, i1 false)
  %call29 = call i64 @fread(ptr noundef nonnull %buf, i64 noundef 1, i64 noundef 127, ptr noundef nonnull %call24)
  %call31 = call i32 @pclose(ptr noundef nonnull %call24)
  %6 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call34 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %6, ptr noundef nonnull @.str.13, ptr noundef nonnull %buf) #17
  call void @llvm.lifetime.end.p0(i64 128, ptr nonnull %buf) #18
  br label %if.end

if.end:                                           ; preds = %if.then26, %if.then
  store i1 true, ptr @_ZL16g_privileged_ran, align 1
  br label %if.end37

if.else:                                          ; preds = %await.ready
  %7 = call i64 @fwrite(ptr nonnull @.str.14, i64 50, i64 1, ptr %4) #17
  br label %if.end37

if.end37:                                         ; preds = %if.else, %if.end
  call void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  call void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise.reload.addr) #18
  %call45 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  br i1 %call45, label %final.ready, label %CoroSave77

CoroSave77:                                       ; preds = %if.end37
  store ptr null, ptr %0, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %ref.tmp47) #18
  %call48 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef nonnull %0) #18
  store ptr %call48, ptr %ref.tmp47, align 8
  %call50 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp47) #18
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr, ptr %call50) #18
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %ref.tmp47) #18
  br label %CoroEnd

final.ready:                                      ; preds = %if.end37
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp.reload.addr) #18
  call void @_ZdlPv(ptr noundef nonnull %0) #18
  br label %CoroEnd

CoroEnd:                                          ; preds = %final.ready, %CoroSave77, %CoroSave73
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define internal fastcc void @_ZL15privileged_corov.destroy(ptr noundef nonnull align 8 dereferenceable(24) %0) #7 personality ptr @__gxx_personality_v0 {
entry.destroy:
  tail call void @_ZdlPv(ptr noundef nonnull %0) #18
  ret void
}

attributes #0 = { mustprogress noinline norecurse uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #5 = { cold nofree nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { mustprogress noinline nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { mustprogress noinline uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #12 = { noinline noreturn nounwind uwtable "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #13 = { mustprogress nofree nounwind willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #14 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #15 = { nofree nounwind }
attributes #16 = { nofree nounwind willreturn memory(argmem: read) }
attributes #17 = { cold }
attributes #18 = { nounwind }
attributes #19 = { builtin nounwind }
attributes #20 = { builtin allocsize(0) }
attributes #21 = { nounwind willreturn memory(read) }
attributes #22 = { noreturn nounwind }
attributes #23 = { allocsize(0) }

!llvm.linker.options = !{}
!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 18.1.8 (https://github.com/llvm/llvm-project.git 3b5b5c1ec4a3095ab096dd780e84d7ab81f3d7ff)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"any pointer", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = !{!10, !10, i64 0}
!10 = !{!"int", !7, i64 0}
!11 = !{!12, !13, i64 0}
!12 = !{!"_ZTS11sockaddr_in", !13, i64 0, !13, i64 2, !14, i64 4, !7, i64 8}
!13 = !{!"short", !7, i64 0}
!14 = !{!"_ZTS7in_addr", !10, i64 0}
!15 = !{!12, !10, i64 4}
!16 = !{!12, !13, i64 2}
!17 = !{i64 0, i64 8, !5}
!18 = !{!7, !7, i64 0}
!19 = !{!20, !20, i64 0}
!20 = !{!"long long", !7, i64 0}
!21 = distinct !{!21, !22, !23}
!22 = !{!"llvm.loop.mustprogress"}
!23 = !{!"llvm.loop.unroll.disable"}
!24 = distinct !{!24, !22, !23}
!25 = !{!26, !6, i64 0}
!26 = !{!"_ZTSNSt7__n486116coroutine_handleIvEE", !6, i64 0}
!27 = !{!28, !6, i64 0}
!28 = !{!"_ZTSNSt7__n486116coroutine_handleIN4Task12promise_typeEEE", !6, i64 0}
!29 = !{!30, !30, i64 0}
!30 = !{!"bool", !7, i64 0}
!31 = !{i8 0, i8 2}
!32 = !{}
