; ModuleID = 'victim_server.cpp'
source_filename = "victim_server.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.std::__n4861::coroutine_handle.0" = type { ptr }
%struct.sockaddr_in = type { i16, i16, %struct.in_addr, [8 x i8] }
%struct.in_addr = type { i32 }
%struct.Task = type { %"struct.std::__n4861::coroutine_handle" }
%"struct.std::__n4861::coroutine_handle" = type { ptr }
%"struct.Task::promise_type" = type { i8 }
%"struct.std::__n4861::suspend_always" = type { i8 }

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

$_ZN4Task12promise_type19unhandled_exceptionEv = comdat any

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

@stderr = external global ptr, align 8
@.str = private unnamed_addr constant [457 x i8] c"\E2\95\94\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\97\0A\E2\95\91  CFOP Demo \E2\80\94 Victim Server (DELIBERATELY VULNERABLE)        \E2\95\91\0A\E2\95\9A\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\90\E2\95\9D\0A\00", align 1
@.str.1 = private unnamed_addr constant [5 x i8] c"bind\00", align 1
@.str.2 = private unnamed_addr constant [45 x i8] c"[VICTIM] Listening on 127.0.0.1:%u  pid=%d\0A\0A\00", align 1
@.str.3 = private unnamed_addr constant [27 x i8] c"[VICTIM] Client connected\0A\00", align 1
@.str.4 = private unnamed_addr constant [31 x i8] c"[VICTIM] Client disconnected\0A\0A\00", align 1
@_ZL8g_worker = internal global ptr null, align 8
@_ZL6g_priv = internal global ptr null, align 8
@_ZL21g_redirectable_handle = internal global %"struct.std::__n4861::coroutine_handle.0" zeroinitializer, align 8
@_ZL16g_privileged_ran = internal global i8 0, align 1
@_ZL13g_scratch_buf = internal global [512 x i8] zeroinitializer, align 16
@.str.5 = private unnamed_addr constant [39 x i8] c"[VICTIM] State reset. worker_frame=%p\0A\00", align 1
@.str.6 = private unnamed_addr constant [56 x i8] c"[VICTIM] Worker-%d: running, suspended at checkpoint A\0A\00", align 1
@.str.7 = private unnamed_addr constant [36 x i8] c"[VICTIM] Worker-%d: resumed past A\0A\00", align 1
@.str.8 = private unnamed_addr constant [31 x i8] c"[VICTIM] Worker-%d: completed\0A\00", align 1
@_ZL14g_is_admin_ptr = internal global ptr null, align 8
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
define dso_local noundef i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %srv = alloca i32, align 4
  %o = alloca i32, align 4
  %sa = alloca %struct.sockaddr_in, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %fd = alloca i32, align 4
  store i32 0, ptr %retval, align 4
  %0 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %0, ptr noundef @.str)
  call void @_ZL11reset_statev()
  call void @llvm.lifetime.start.p0(i64 4, ptr %srv) #13
  %call1 = call i32 @socket(i32 noundef 2, i32 noundef 1, i32 noundef 0) #13
  store i32 %call1, ptr %srv, align 4, !tbaa !9
  call void @llvm.lifetime.start.p0(i64 4, ptr %o) #13
  store i32 1, ptr %o, align 4, !tbaa !9
  %1 = load i32, ptr %srv, align 4, !tbaa !9
  %call2 = call i32 @setsockopt(i32 noundef %1, i32 noundef 1, i32 noundef 2, ptr noundef %o, i32 noundef 4) #13
  call void @llvm.lifetime.end.p0(i64 4, ptr %o) #13
  call void @llvm.lifetime.start.p0(i64 16, ptr %sa) #13
  call void @llvm.memset.p0.i64(ptr align 4 %sa, i8 0, i64 16, i1 false)
  %sin_family = getelementptr inbounds %struct.sockaddr_in, ptr %sa, i32 0, i32 0
  store i16 2, ptr %sin_family, align 4, !tbaa !11
  %call3 = call noundef i32 @_ZL10__bswap_32j(i32 noundef 2130706433)
  %sin_addr = getelementptr inbounds %struct.sockaddr_in, ptr %sa, i32 0, i32 2
  %s_addr = getelementptr inbounds %struct.in_addr, ptr %sin_addr, i32 0, i32 0
  store i32 %call3, ptr %s_addr, align 4, !tbaa !15
  %call4 = call noundef zeroext i16 @_ZL10__bswap_16t(i16 noundef zeroext 4444)
  %sin_port = getelementptr inbounds %struct.sockaddr_in, ptr %sa, i32 0, i32 1
  store i16 %call4, ptr %sin_port, align 2, !tbaa !16
  %2 = load i32, ptr %srv, align 4, !tbaa !9
  %call5 = call i32 @bind(i32 noundef %2, ptr noundef %sa, i32 noundef 16) #13
  %cmp = icmp slt i32 %call5, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @perror(ptr noundef @.str.1) #20
  store i32 1, ptr %retval, align 4
  store i32 1, ptr %cleanup.dest.slot, align 4
  br label %cleanup19

if.end:                                           ; preds = %entry
  %3 = load i32, ptr %srv, align 4, !tbaa !9
  %call6 = call i32 @listen(i32 noundef %3, i32 noundef 1) #13
  %4 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call7 = call i32 @getpid() #13
  %call8 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %4, ptr noundef @.str.2, i32 noundef 4444, i32 noundef %call7)
  br label %for.cond

for.cond:                                         ; preds = %cleanup.cont, %if.end
  call void @llvm.lifetime.start.p0(i64 4, ptr %fd) #13
  %5 = load i32, ptr %srv, align 4, !tbaa !9
  %call9 = call i32 @accept(i32 noundef %5, ptr noundef null, ptr noundef null)
  store i32 %call9, ptr %fd, align 4, !tbaa !9
  %6 = load i32, ptr %fd, align 4, !tbaa !9
  %cmp10 = icmp slt i32 %6, 0
  br i1 %cmp10, label %if.then11, label %if.end12

if.then11:                                        ; preds = %for.cond
  store i32 2, ptr %cleanup.dest.slot, align 4
  br label %cleanup

if.end12:                                         ; preds = %for.cond
  %7 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call13 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %7, ptr noundef @.str.3)
  %8 = load i32, ptr %fd, align 4, !tbaa !9
  call void @_ZL13handle_clienti(i32 noundef %8)
  %9 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call14 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %9, ptr noundef @.str.4)
  call void @_ZL11reset_statev()
  store i32 0, ptr %cleanup.dest.slot, align 4
  br label %cleanup

cleanup:                                          ; preds = %if.end12, %if.then11
  call void @llvm.lifetime.end.p0(i64 4, ptr %fd) #13
  %cleanup.dest = load i32, ptr %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable [
    i32 0, label %cleanup.cont
    i32 2, label %for.end
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %for.cond, !llvm.loop !17

for.end:                                          ; preds = %cleanup
  %10 = load i32, ptr %srv, align 4, !tbaa !9
  %call15 = call i32 @close(i32 noundef %10)
  %11 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %isnull = icmp eq ptr %11, null
  br i1 %isnull, label %delete.end, label %delete.notnull

delete.notnull:                                   ; preds = %for.end
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %11) #13
  call void @_ZdlPv(ptr noundef %11) #21
  br label %delete.end

delete.end:                                       ; preds = %delete.notnull, %for.end
  %12 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %isnull16 = icmp eq ptr %12, null
  br i1 %isnull16, label %delete.end18, label %delete.notnull17

delete.notnull17:                                 ; preds = %delete.end
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %12) #13
  call void @_ZdlPv(ptr noundef %12) #21
  br label %delete.end18

delete.end18:                                     ; preds = %delete.notnull17, %delete.end
  store i32 0, ptr %retval, align 4
  store i32 1, ptr %cleanup.dest.slot, align 4
  br label %cleanup19

cleanup19:                                        ; preds = %delete.end18, %if.then
  call void @llvm.lifetime.end.p0(i64 16, ptr %sa) #13
  call void @llvm.lifetime.end.p0(i64 4, ptr %srv) #13
  %13 = load i32, ptr %retval, align 4
  ret i32 %13

unreachable:                                      ; preds = %cleanup
  unreachable
}

declare i32 @fprintf(ptr noundef, ptr noundef, ...) #1

; Function Attrs: mustprogress noinline uwtable
define internal void @_ZL11reset_statev() #2 personality ptr @__gxx_personality_v0 {
entry:
  %tmp = alloca %struct.Task, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %tmp5 = alloca %struct.Task, align 8
  %ref.tmp = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %0 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %isnull = icmp eq ptr %0, null
  br i1 %isnull, label %delete.end, label %delete.notnull

delete.notnull:                                   ; preds = %entry
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %0) #13
  call void @_ZdlPv(ptr noundef %0) #21
  br label %delete.end

delete.end:                                       ; preds = %delete.notnull, %entry
  store ptr null, ptr @_ZL8g_worker, align 8, !tbaa !5
  %1 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %isnull1 = icmp eq ptr %1, null
  br i1 %isnull1, label %delete.end3, label %delete.notnull2

delete.notnull2:                                  ; preds = %delete.end
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %1) #13
  call void @_ZdlPv(ptr noundef %1) #21
  br label %delete.end3

delete.end3:                                      ; preds = %delete.notnull2, %delete.end
  store ptr null, ptr @_ZL6g_priv, align 8, !tbaa !5
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIvEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle, ptr null) #13
  store i8 0, ptr @_ZL16g_privileged_ran, align 1, !tbaa !20
  call void @llvm.memset.p0.i64(ptr align 16 @_ZL13g_scratch_buf, i8 0, i64 512, i1 false)
  call void @llvm.lifetime.start.p0(i64 8, ptr %tmp) #13
  call void @_ZL11worker_coroi(ptr dead_on_unwind writable sret(%struct.Task) align 8 %tmp, i32 noundef 1)
  %call4 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef 8) #22
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %delete.end3
  call void @_ZN4TaskC2EOS_(ptr noundef nonnull align 8 dereferenceable(8) %call4, ptr noundef nonnull align 8 dereferenceable(8) %tmp) #13
  store ptr %call4, ptr @_ZL8g_worker, align 8, !tbaa !5
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %tmp) #13
  %2 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle = getelementptr inbounds %struct.Task, ptr %2, i32 0, i32 0
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %handle)
  call void @llvm.lifetime.start.p0(i64 8, ptr %tmp5) #13
  call void @_ZL15privileged_corov(ptr dead_on_unwind writable sret(%struct.Task) align 8 %tmp5)
  %call8 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef 8) #22
          to label %invoke.cont7 unwind label %lpad6

invoke.cont7:                                     ; preds = %invoke.cont
  call void @_ZN4TaskC2EOS_(ptr noundef nonnull align 8 dereferenceable(8) %call8, ptr noundef nonnull align 8 dereferenceable(8) %tmp5) #13
  store ptr %call8, ptr @_ZL6g_priv, align 8, !tbaa !5
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp5) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %tmp5) #13
  %3 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %handle9 = getelementptr inbounds %struct.Task, ptr %3, i32 0, i32 0
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %handle9)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp) #13
  %4 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle10 = getelementptr inbounds %struct.Task, ptr %4, i32 0, i32 0
  %call11 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %handle10) #13
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %ref.tmp, i32 0, i32 0
  store ptr %call11, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 @_ZL21g_redirectable_handle, ptr align 8 %ref.tmp, i64 8, i1 false), !tbaa.struct !22
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp) #13
  %5 = load ptr, ptr @stderr, align 8, !tbaa !5
  %6 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle12 = getelementptr inbounds %struct.Task, ptr %6, i32 0, i32 0
  %call13 = call noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %handle12) #13
  %call14 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %5, ptr noundef @.str.5, ptr noundef %call13)
  ret void

lpad:                                             ; preds = %delete.end3
  %7 = landingpad { ptr, i32 }
          cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  store ptr %8, ptr %exn.slot, align 8
  %9 = extractvalue { ptr, i32 } %7, 1
  store i32 %9, ptr %ehselector.slot, align 4
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %tmp) #13
  br label %eh.resume

lpad6:                                            ; preds = %invoke.cont
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  store ptr %11, ptr %exn.slot, align 8
  %12 = extractvalue { ptr, i32 } %10, 1
  store i32 %12, ptr %ehselector.slot, align 4
  call void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %tmp5) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %tmp5) #13
  br label %eh.resume

eh.resume:                                        ; preds = %lpad6, %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val15 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val15
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #3

; Function Attrs: nounwind
declare i32 @socket(i32 noundef, i32 noundef, i32 noundef) #4

; Function Attrs: nounwind
declare i32 @setsockopt(i32 noundef, i32 noundef, i32 noundef, ptr noundef, i32 noundef) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #3

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #5

; Function Attrs: mustprogress noinline nounwind uwtable
define internal noundef i32 @_ZL10__bswap_32j(i32 noundef %__bsx) #6 {
entry:
  %__bsx.addr = alloca i32, align 4
  store i32 %__bsx, ptr %__bsx.addr, align 4, !tbaa !9
  %0 = load i32, ptr %__bsx.addr, align 4, !tbaa !9
  %and = and i32 %0, -16777216
  %shr = lshr i32 %and, 24
  %1 = load i32, ptr %__bsx.addr, align 4, !tbaa !9
  %and1 = and i32 %1, 16711680
  %shr2 = lshr i32 %and1, 8
  %or = or i32 %shr, %shr2
  %2 = load i32, ptr %__bsx.addr, align 4, !tbaa !9
  %and3 = and i32 %2, 65280
  %shl = shl i32 %and3, 8
  %or4 = or i32 %or, %shl
  %3 = load i32, ptr %__bsx.addr, align 4, !tbaa !9
  %and5 = and i32 %3, 255
  %shl6 = shl i32 %and5, 24
  %or7 = or i32 %or4, %shl6
  ret i32 %or7
}

; Function Attrs: mustprogress noinline nounwind uwtable
define internal noundef zeroext i16 @_ZL10__bswap_16t(i16 noundef zeroext %__bsx) #6 {
entry:
  %__bsx.addr = alloca i16, align 2
  store i16 %__bsx, ptr %__bsx.addr, align 2, !tbaa !23
  %0 = load i16, ptr %__bsx.addr, align 2, !tbaa !23
  %conv = zext i16 %0 to i32
  %shr = ashr i32 %conv, 8
  %and = and i32 %shr, 255
  %1 = load i16, ptr %__bsx.addr, align 2, !tbaa !23
  %conv1 = zext i16 %1 to i32
  %and2 = and i32 %conv1, 255
  %shl = shl i32 %and2, 8
  %or = or i32 %and, %shl
  %conv3 = trunc i32 %or to i16
  ret i16 %conv3
}

; Function Attrs: nounwind
declare i32 @bind(i32 noundef, ptr noundef, i32 noundef) #4

; Function Attrs: cold
declare void @perror(ptr noundef) #7

; Function Attrs: nounwind
declare i32 @listen(i32 noundef, i32 noundef) #4

; Function Attrs: nounwind
declare i32 @getpid() #4

declare i32 @accept(i32 noundef, ptr noundef, ptr noundef) #1

; Function Attrs: mustprogress noinline uwtable
define internal void @_ZL13handle_clienti(i32 noundef %fd) #2 {
entry:
  %fd.addr = alloca i32, align 4
  %rx = alloca ptr, align 8
  %tx = alloca ptr, align 8
  %cleanup.dest.slot = alloca i32, align 4
  %line = alloca [4096 x i8], align 16
  %wf = alloca ptr, align 8
  %rfn = alloca ptr, align 8
  %dfn = alloca ptr, align 8
  %raw = alloca i64, align 8
  %n = alloca i32, align 4
  %hex = alloca [1025 x i8], align 16
  %got = alloca i32, align 4
  %data = alloca [512 x i8], align 16
  %i = alloca i32, align 4
  %v = alloca i32, align 4
  %h = alloca %"struct.std::__n4861::coroutine_handle", align 8
  store i32 %fd, ptr %fd.addr, align 4, !tbaa !9
  call void @llvm.lifetime.start.p0(i64 8, ptr %rx) #13
  %0 = load i32, ptr %fd.addr, align 4, !tbaa !9
  %call = call i32 @dup(i32 noundef %0) #13
  %call1 = call noalias ptr @fdopen(i32 noundef %call, ptr noundef @.str.12) #13
  store ptr %call1, ptr %rx, align 8, !tbaa !5
  call void @llvm.lifetime.start.p0(i64 8, ptr %tx) #13
  %1 = load i32, ptr %fd.addr, align 4, !tbaa !9
  %call2 = call noalias ptr @fdopen(i32 noundef %1, ptr noundef @.str.15) #13
  store ptr %call2, ptr %tx, align 8, !tbaa !5
  %2 = load ptr, ptr %rx, align 8, !tbaa !5
  %tobool = icmp ne ptr %2, null
  br i1 %tobool, label %lor.lhs.false, label %if.then

lor.lhs.false:                                    ; preds = %entry
  %3 = load ptr, ptr %tx, align 8, !tbaa !5
  %tobool3 = icmp ne ptr %3, null
  br i1 %tobool3, label %if.end, label %if.then

if.then:                                          ; preds = %lor.lhs.false, %entry
  %4 = load i32, ptr %fd.addr, align 4, !tbaa !9
  %call4 = call i32 @close(i32 noundef %4)
  store i32 1, ptr %cleanup.dest.slot, align 4
  br label %cleanup

if.end:                                           ; preds = %lor.lhs.false
  %5 = load ptr, ptr %tx, align 8, !tbaa !5
  %call5 = call i32 @getpid() #13
  %call6 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %5, ptr noundef @.str.16, i32 noundef %call5)
  %6 = load ptr, ptr %tx, align 8, !tbaa !5
  %call7 = call i32 @fflush(ptr noundef %6)
  call void @llvm.lifetime.start.p0(i64 4096, ptr %line) #13
  br label %while.cond

while.cond:                                       ; preds = %if.end131, %if.then14, %if.end
  %arraydecay = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %7 = load ptr, ptr %rx, align 8, !tbaa !5
  %call8 = call ptr @fgets(ptr noundef %arraydecay, i32 noundef 4096, ptr noundef %7)
  %tobool9 = icmp ne ptr %call8, null
  br i1 %tobool9, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %arraydecay10 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call11 = call i64 @strcspn(ptr noundef %arraydecay10, ptr noundef @.str.17) #23
  %arrayidx = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 %call11
  store i8 0, ptr %arrayidx, align 1, !tbaa !24
  %arrayidx12 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %8 = load i8, ptr %arrayidx12, align 16, !tbaa !24
  %tobool13 = icmp ne i8 %8, 0
  br i1 %tobool13, label %if.end15, label %if.then14

if.then14:                                        ; preds = %while.body
  br label %while.cond, !llvm.loop !25

if.end15:                                         ; preds = %while.body
  %9 = load ptr, ptr @stderr, align 8, !tbaa !5
  %arraydecay16 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call17 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %9, ptr noundef @.str.18, ptr noundef %arraydecay16)
  %arraydecay18 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call19 = call i32 @strcmp(ptr noundef %arraydecay18, ptr noundef @.str.19) #23
  %cmp = icmp eq i32 %call19, 0
  br i1 %cmp, label %if.then20, label %if.else

if.then20:                                        ; preds = %if.end15
  call void @llvm.lifetime.start.p0(i64 8, ptr %wf) #13
  %10 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle = getelementptr inbounds %struct.Task, ptr %10, i32 0, i32 0
  %call21 = call noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %handle) #13
  store ptr %call21, ptr %wf, align 8, !tbaa !5
  call void @llvm.lifetime.start.p0(i64 8, ptr %rfn) #13
  store ptr null, ptr %rfn, align 8, !tbaa !5
  call void @llvm.lifetime.start.p0(i64 8, ptr %dfn) #13
  store ptr null, ptr %dfn, align 8, !tbaa !5
  %11 = load ptr, ptr %wf, align 8, !tbaa !5
  %add.ptr = getelementptr inbounds i8, ptr %11, i64 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %rfn, ptr align 1 %add.ptr, i64 8, i1 false)
  %12 = load ptr, ptr %wf, align 8, !tbaa !5
  %add.ptr22 = getelementptr inbounds i8, ptr %12, i64 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dfn, ptr align 1 %add.ptr22, i64 8, i1 false)
  %13 = load ptr, ptr %tx, align 8, !tbaa !5
  %14 = load ptr, ptr %wf, align 8, !tbaa !5
  %15 = load ptr, ptr %rfn, align 8, !tbaa !5
  %16 = load ptr, ptr %dfn, align 8, !tbaa !5
  %17 = load ptr, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %call23 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %13, ptr noundef @.str.20, ptr noundef %14, ptr noundef %15, ptr noundef %16, ptr noundef @_ZL13hijack_targetPv, ptr noundef %17, ptr noundef @_ZL13g_scratch_buf, ptr noundef @_ZL21g_redirectable_handle)
  call void @llvm.lifetime.end.p0(i64 8, ptr %dfn) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %rfn) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %wf) #13
  br label %if.end131

if.else:                                          ; preds = %if.end15
  %arraydecay24 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call25 = call i32 @strncmp(ptr noundef %arraydecay24, ptr noundef @.str.21, i64 noundef 6) #23
  %cmp26 = icmp eq i32 %call25, 0
  br i1 %cmp26, label %if.then27, label %if.else47

if.then27:                                        ; preds = %if.else
  call void @llvm.lifetime.start.p0(i64 8, ptr %raw) #13
  store i64 0, ptr %raw, align 8, !tbaa !26
  call void @llvm.lifetime.start.p0(i64 4, ptr %n) #13
  store i32 0, ptr %n, align 4, !tbaa !9
  call void @llvm.lifetime.start.p0(i64 1025, ptr %hex) #13
  call void @llvm.memset.p0.i64(ptr align 16 %hex, i8 0, i64 1025, i1 false)
  %18 = getelementptr inbounds [1025 x i8], ptr %hex, i32 0, i32 0
  store i8 48, ptr %18, align 16
  %19 = getelementptr inbounds [1025 x i8], ptr %hex, i32 0, i32 1
  store i8 48, ptr %19, align 1
  call void @llvm.lifetime.start.p0(i64 4, ptr %got) #13
  %arraydecay28 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %add.ptr29 = getelementptr inbounds i8, ptr %arraydecay28, i64 6
  %arraydecay30 = getelementptr inbounds [1025 x i8], ptr %hex, i64 0, i64 0
  %call31 = call i32 (ptr, ptr, ...) @__isoc23_sscanf(ptr noundef %add.ptr29, ptr noundef @.str.22, ptr noundef %raw, ptr noundef %n, ptr noundef %arraydecay30) #13
  store i32 %call31, ptr %got, align 4, !tbaa !9
  %20 = load i32, ptr %got, align 4, !tbaa !9
  %cmp32 = icmp slt i32 %20, 2
  br i1 %cmp32, label %if.then33, label %if.else35

if.then33:                                        ; preds = %if.then27
  %21 = load ptr, ptr %tx, align 8, !tbaa !5
  %call34 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %21, ptr noundef @.str.23)
  br label %if.end46

if.else35:                                        ; preds = %if.then27
  call void @llvm.lifetime.start.p0(i64 512, ptr %data) #13
  call void @llvm.memset.p0.i64(ptr align 16 %data, i8 0, i64 512, i1 false)
  call void @llvm.lifetime.start.p0(i64 4, ptr %i) #13
  store i32 0, ptr %i, align 4, !tbaa !9
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.else35
  %22 = load i32, ptr %i, align 4, !tbaa !9
  %23 = load i32, ptr %n, align 4, !tbaa !9
  %cmp36 = icmp slt i32 %22, %23
  br i1 %cmp36, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %for.cond
  %24 = load i32, ptr %i, align 4, !tbaa !9
  %cmp37 = icmp slt i32 %24, 512
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %25 = phi i1 [ false, %for.cond ], [ %cmp37, %land.rhs ]
  br i1 %25, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %land.end
  store i32 4, ptr %cleanup.dest.slot, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr %i) #13
  br label %for.end

for.body:                                         ; preds = %land.end
  call void @llvm.lifetime.start.p0(i64 4, ptr %v) #13
  store i32 0, ptr %v, align 4, !tbaa !9
  %arraydecay38 = getelementptr inbounds [1025 x i8], ptr %hex, i64 0, i64 0
  %26 = load i32, ptr %i, align 4, !tbaa !9
  %mul = mul nsw i32 %26, 2
  %idx.ext = sext i32 %mul to i64
  %add.ptr39 = getelementptr inbounds i8, ptr %arraydecay38, i64 %idx.ext
  %call40 = call i32 (ptr, ptr, ...) @__isoc23_sscanf(ptr noundef %add.ptr39, ptr noundef @.str.24, ptr noundef %v) #13
  %27 = load i32, ptr %v, align 4, !tbaa !9
  %conv = trunc i32 %27 to i8
  %28 = load i32, ptr %i, align 4, !tbaa !9
  %idxprom = sext i32 %28 to i64
  %arrayidx41 = getelementptr inbounds [512 x i8], ptr %data, i64 0, i64 %idxprom
  store i8 %conv, ptr %arrayidx41, align 1, !tbaa !24
  call void @llvm.lifetime.end.p0(i64 4, ptr %v) #13
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %29 = load i32, ptr %i, align 4, !tbaa !9
  %inc = add nsw i32 %29, 1
  store i32 %inc, ptr %i, align 4, !tbaa !9
  br label %for.cond, !llvm.loop !28

for.end:                                          ; preds = %for.cond.cleanup
  %30 = load i64, ptr %raw, align 8, !tbaa !26
  %31 = inttoptr i64 %30 to ptr
  %arraydecay42 = getelementptr inbounds [512 x i8], ptr %data, i64 0, i64 0
  %32 = load i32, ptr %n, align 4, !tbaa !9
  %conv43 = sext i32 %32 to i64
  call void @_ZL19vuln_write_anywherePvPKhm(ptr noundef %31, ptr noundef %arraydecay42, i64 noundef %conv43)
  %33 = load ptr, ptr %tx, align 8, !tbaa !5
  %34 = load i32, ptr %n, align 4, !tbaa !9
  %35 = load i64, ptr %raw, align 8, !tbaa !26
  %call44 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %33, ptr noundef @.str.25, i32 noundef %34, i64 noundef %35)
  %36 = load ptr, ptr @stderr, align 8, !tbaa !5
  %37 = load i32, ptr %n, align 4, !tbaa !9
  %38 = load i64, ptr %raw, align 8, !tbaa !26
  %call45 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %36, ptr noundef @.str.26, i32 noundef %37, i64 noundef %38)
  call void @llvm.lifetime.end.p0(i64 512, ptr %data) #13
  br label %if.end46

if.end46:                                         ; preds = %for.end, %if.then33
  call void @llvm.lifetime.end.p0(i64 4, ptr %got) #13
  call void @llvm.lifetime.end.p0(i64 1025, ptr %hex) #13
  call void @llvm.lifetime.end.p0(i64 4, ptr %n) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %raw) #13
  br label %if.end130

if.else47:                                        ; preds = %if.else
  %arraydecay48 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call49 = call i32 @strcmp(ptr noundef %arraydecay48, ptr noundef @.str.27) #23
  %cmp50 = icmp eq i32 %call49, 0
  br i1 %cmp50, label %if.then51, label %if.else63

if.then51:                                        ; preds = %if.else47
  %39 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle52 = getelementptr inbounds %struct.Task, ptr %39, i32 0, i32 0
  %call53 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %handle52) #13
  br i1 %call53, label %lor.lhs.false54, label %if.then57

lor.lhs.false54:                                  ; preds = %if.then51
  %40 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle55 = getelementptr inbounds %struct.Task, ptr %40, i32 0, i32 0
  %call56 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %handle55) #13
  br i1 %call56, label %if.then57, label %if.else59

if.then57:                                        ; preds = %lor.lhs.false54, %if.then51
  %41 = load ptr, ptr %tx, align 8, !tbaa !5
  %call58 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %41, ptr noundef @.str.28)
  br label %if.end62

if.else59:                                        ; preds = %lor.lhs.false54
  %42 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle60 = getelementptr inbounds %struct.Task, ptr %42, i32 0, i32 0
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %handle60)
  %43 = load ptr, ptr %tx, align 8, !tbaa !5
  %call61 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %43, ptr noundef @.str.29)
  br label %if.end62

if.end62:                                         ; preds = %if.else59, %if.then57
  br label %if.end129

if.else63:                                        ; preds = %if.else47
  %arraydecay64 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call65 = call i32 @strcmp(ptr noundef %arraydecay64, ptr noundef @.str.30) #23
  %cmp66 = icmp eq i32 %call65, 0
  br i1 %cmp66, label %if.then67, label %if.else78

if.then67:                                        ; preds = %if.else63
  %44 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle68 = getelementptr inbounds %struct.Task, ptr %44, i32 0, i32 0
  %call69 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %handle68) #13
  br i1 %call69, label %if.else72, label %if.then70

if.then70:                                        ; preds = %if.then67
  %45 = load ptr, ptr %tx, align 8, !tbaa !5
  %call71 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %45, ptr noundef @.str.31)
  br label %if.end77

if.else72:                                        ; preds = %if.then67
  call void @llvm.lifetime.start.p0(i64 8, ptr %h) #13
  %46 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle73 = getelementptr inbounds %struct.Task, ptr %46, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %h, ptr align 8 %handle73, i64 8, i1 false), !tbaa.struct !22
  %47 = load ptr, ptr @_ZL8g_worker, align 8, !tbaa !5
  %handle74 = getelementptr inbounds %struct.Task, ptr %47, i32 0, i32 0
  %call75 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %handle74, ptr null) #13
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7destroyEv(ptr noundef nonnull align 8 dereferenceable(8) %h)
  %48 = load ptr, ptr %tx, align 8, !tbaa !5
  %call76 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %48, ptr noundef @.str.29)
  call void @llvm.lifetime.end.p0(i64 8, ptr %h) #13
  br label %if.end77

if.end77:                                         ; preds = %if.else72, %if.then70
  br label %if.end128

if.else78:                                        ; preds = %if.else63
  %arraydecay79 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call80 = call i32 @strcmp(ptr noundef %arraydecay79, ptr noundef @.str.32) #23
  %cmp81 = icmp eq i32 %call80, 0
  br i1 %cmp81, label %if.then82, label %if.else95

if.then82:                                        ; preds = %if.else78
  %49 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %handle83 = getelementptr inbounds %struct.Task, ptr %49, i32 0, i32 0
  %call84 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %handle83) #13
  br i1 %call84, label %lor.lhs.false85, label %if.then88

lor.lhs.false85:                                  ; preds = %if.then82
  %50 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %handle86 = getelementptr inbounds %struct.Task, ptr %50, i32 0, i32 0
  %call87 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %handle86) #13
  br i1 %call87, label %if.then88, label %if.else90

if.then88:                                        ; preds = %lor.lhs.false85, %if.then82
  %51 = load ptr, ptr %tx, align 8, !tbaa !5
  %call89 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %51, ptr noundef @.str.33)
  br label %if.end94

if.else90:                                        ; preds = %lor.lhs.false85
  %52 = load ptr, ptr @_ZL6g_priv, align 8, !tbaa !5
  %handle91 = getelementptr inbounds %struct.Task, ptr %52, i32 0, i32 0
  call void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %handle91)
  %53 = load ptr, ptr %tx, align 8, !tbaa !5
  %54 = load i8, ptr @_ZL16g_privileged_ran, align 1, !tbaa !20, !range !29, !noundef !30
  %tobool92 = trunc i8 %54 to i1
  %55 = zext i1 %tobool92 to i64
  %cond = select i1 %tobool92, ptr @.str.35, ptr @.str.36
  %call93 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %53, ptr noundef @.str.34, ptr noundef %cond)
  br label %if.end94

if.end94:                                         ; preds = %if.else90, %if.then88
  br label %if.end127

if.else95:                                        ; preds = %if.else78
  %arraydecay96 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call97 = call i32 @strcmp(ptr noundef %arraydecay96, ptr noundef @.str.37) #23
  %cmp98 = icmp eq i32 %call97, 0
  br i1 %cmp98, label %if.then99, label %if.else109

if.then99:                                        ; preds = %if.else95
  %call100 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle) #13
  br i1 %call100, label %lor.lhs.false101, label %if.then103

lor.lhs.false101:                                 ; preds = %if.then99
  %call102 = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle) #13
  br i1 %call102, label %if.then103, label %if.else105

if.then103:                                       ; preds = %lor.lhs.false101, %if.then99
  %56 = load ptr, ptr %tx, align 8, !tbaa !5
  %call104 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %56, ptr noundef @.str.38)
  br label %if.end108

if.else105:                                       ; preds = %lor.lhs.false101
  %57 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call106 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %57, ptr noundef @.str.39)
  call void @_ZNKSt7__n486116coroutine_handleIvE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) @_ZL21g_redirectable_handle)
  %58 = load ptr, ptr %tx, align 8, !tbaa !5
  %call107 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %58, ptr noundef @.str.29)
  br label %if.end108

if.end108:                                        ; preds = %if.else105, %if.then103
  br label %if.end126

if.else109:                                       ; preds = %if.else95
  %arraydecay110 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call111 = call i32 @strcmp(ptr noundef %arraydecay110, ptr noundef @.str.40) #23
  %cmp112 = icmp eq i32 %call111, 0
  br i1 %cmp112, label %if.then113, label %if.else115

if.then113:                                       ; preds = %if.else109
  call void @_ZL11reset_statev()
  %59 = load ptr, ptr %tx, align 8, !tbaa !5
  %call114 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %59, ptr noundef @.str.29)
  br label %if.end125

if.else115:                                       ; preds = %if.else109
  %arraydecay116 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call117 = call i32 @strcmp(ptr noundef %arraydecay116, ptr noundef @.str.41) #23
  %cmp118 = icmp eq i32 %call117, 0
  br i1 %cmp118, label %if.then119, label %if.else121

if.then119:                                       ; preds = %if.else115
  %60 = load ptr, ptr %tx, align 8, !tbaa !5
  %call120 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %60, ptr noundef @.str.42)
  br label %while.end

if.else121:                                       ; preds = %if.else115
  %61 = load ptr, ptr %tx, align 8, !tbaa !5
  %arraydecay122 = getelementptr inbounds [4096 x i8], ptr %line, i64 0, i64 0
  %call123 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %61, ptr noundef @.str.43, ptr noundef %arraydecay122)
  br label %if.end124

if.end124:                                        ; preds = %if.else121
  br label %if.end125

if.end125:                                        ; preds = %if.end124, %if.then113
  br label %if.end126

if.end126:                                        ; preds = %if.end125, %if.end108
  br label %if.end127

if.end127:                                        ; preds = %if.end126, %if.end94
  br label %if.end128

if.end128:                                        ; preds = %if.end127, %if.end77
  br label %if.end129

if.end129:                                        ; preds = %if.end128, %if.end62
  br label %if.end130

if.end130:                                        ; preds = %if.end129, %if.end46
  br label %if.end131

if.end131:                                        ; preds = %if.end130, %if.then20
  %62 = load ptr, ptr %tx, align 8, !tbaa !5
  %call132 = call i32 @fflush(ptr noundef %62)
  br label %while.cond, !llvm.loop !25

while.end:                                        ; preds = %if.then119, %while.cond
  %63 = load ptr, ptr %rx, align 8, !tbaa !5
  %call133 = call i32 @fclose(ptr noundef %63)
  %64 = load ptr, ptr %tx, align 8, !tbaa !5
  %call134 = call i32 @fclose(ptr noundef %64)
  call void @llvm.lifetime.end.p0(i64 4096, ptr %line) #13
  store i32 0, ptr %cleanup.dest.slot, align 4
  br label %cleanup

cleanup:                                          ; preds = %while.end, %if.then
  call void @llvm.lifetime.end.p0(i64 8, ptr %tx) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %rx) #13
  %cleanup.dest = load i32, ptr %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable [
    i32 0, label %cleanup.cont
    i32 1, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup, %cleanup
  ret void

unreachable:                                      ; preds = %cleanup
  unreachable
}

declare i32 @close(i32 noundef) #1

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4TaskD2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #6 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %handle = getelementptr inbounds %struct.Task, ptr %this1, i32 0, i32 0
  %call = call noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %handle) #13
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %handle2 = getelementptr inbounds %struct.Task, ptr %this1, i32 0, i32 0
  invoke void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7destroyEv(ptr noundef nonnull align 8 dereferenceable(8) %handle2)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %if.then
  br label %if.end

if.end:                                           ; preds = %invoke.cont, %entry
  ret void

terminate.lpad:                                   ; preds = %if.then
  %0 = landingpad { ptr, i32 }
          catch ptr null
  %1 = extractvalue { ptr, i32 } %0, 0
  call void @__clang_call_terminate(ptr %1) #24
  unreachable
}

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPv(ptr noundef) #8

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIvEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr %0) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  store ptr %0, ptr %.addr, align 8, !tbaa !31
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %this1, i32 0, i32 0
  store ptr null, ptr %_M_fr_ptr, align 8, !tbaa !33
  ret ptr %this1
}

; Function Attrs: mustprogress noinline presplitcoroutine uwtable
define internal void @_ZL11worker_coroi(ptr dead_on_unwind noalias writable sret(%struct.Task) align 8 %agg.result, i32 noundef %id) #9 personality ptr @__gxx_personality_v0 {
entry:
  %result.ptr = alloca ptr, align 8
  %id.addr = alloca i32, align 4
  %id1 = alloca i32, align 4
  %__promise = alloca %"struct.Task::promise_type", align 1
  %ref.tmp = alloca %"struct.std::__n4861::suspend_always", align 1
  %undef.agg.tmp = alloca %"struct.std::__n4861::suspend_always", align 1
  %agg.tmp = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %ref.tmp3 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %ref.tmp9 = alloca %"struct.std::__n4861::suspend_always", align 1
  %agg.tmp11 = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %ref.tmp12 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp23 = alloca %"struct.std::__n4861::suspend_always", align 1
  %agg.tmp25 = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %ref.tmp26 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %ref.tmp39 = alloca %"struct.std::__n4861::suspend_always", align 1
  %undef.agg.tmp40 = alloca %"struct.std::__n4861::suspend_always", align 1
  %agg.tmp42 = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %ref.tmp43 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  store i32 %id, ptr %id.addr, align 4, !tbaa !9
  %0 = bitcast ptr %__promise to ptr
  %1 = call token @llvm.coro.id(i32 16, ptr %0, ptr null, ptr null)
  %2 = call i1 @llvm.coro.alloc(token %1)
  br i1 %2, label %coro.alloc, label %coro.init

coro.alloc:                                       ; preds = %entry
  %3 = call i64 @llvm.coro.size.i64()
  %call = call noalias noundef nonnull ptr @_Znwm(i64 noundef %3) #25
  br label %coro.init

coro.init:                                        ; preds = %coro.alloc, %entry
  %4 = phi ptr [ null, %entry ], [ %call, %coro.alloc ]
  %5 = call ptr @llvm.coro.begin(token %1, ptr %4)
  call void @llvm.lifetime.start.p0(i64 4, ptr %id1) #13
  %6 = load i32, ptr %id.addr, align 4, !tbaa !9
  store i32 %6, ptr %id1, align 4, !tbaa !9
  call void @llvm.lifetime.start.p0(i64 1, ptr %__promise) #13
  call void @_ZN4Task12promise_type17get_return_objectEv(ptr dead_on_unwind writable sret(%struct.Task) align 8 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp) #13
  call void @_ZN4Task12promise_type15initial_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  %call2 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #13
  br i1 %call2, label %init.ready, label %init.suspend

init.suspend:                                     ; preds = %coro.init
  %7 = call token @llvm.coro.save(ptr null)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp3) #13
  %call4 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %5) #13
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %ref.tmp3, i32 0, i32 0
  store ptr %call4, ptr %coerce.dive, align 8
  %call5 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp3) #13
  %coerce.dive6 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp, i32 0, i32 0
  store ptr %call5, ptr %coerce.dive6, align 8
  %coerce.dive7 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp, i32 0, i32 0
  %8 = load ptr, ptr %coerce.dive7, align 8
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp, ptr %8) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp3) #13
  %9 = call i8 @llvm.coro.suspend(token %7, i1 false)
  switch i8 %9, label %coro.ret [
    i8 0, label %init.ready
    i8 1, label %init.cleanup
  ]

init.cleanup:                                     ; preds = %init.suspend
  br label %cleanup

init.ready:                                       ; preds = %init.suspend, %coro.init
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #13
  br label %cleanup

cleanup:                                          ; preds = %init.ready, %init.cleanup
  %cleanup.dest.slot.0 = phi i32 [ 0, %init.ready ], [ 2, %init.cleanup ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp) #13
  switch i32 %cleanup.dest.slot.0, label %cleanup53 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup
  %10 = load ptr, ptr @stderr, align 8, !tbaa !5
  %11 = load i32, ptr %id1, align 4, !tbaa !9
  %call8 = invoke i32 (ptr, ptr, ...) @fprintf(ptr noundef %10, ptr noundef @.str.6, i32 noundef %11)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %cleanup.cont
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp9) #13
  %call10 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp9) #13
  br i1 %call10, label %await.ready, label %await.suspend

await.suspend:                                    ; preds = %invoke.cont
  %12 = call token @llvm.coro.save(ptr null)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp12) #13
  %call13 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %5) #13
  %coerce.dive14 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %ref.tmp12, i32 0, i32 0
  store ptr %call13, ptr %coerce.dive14, align 8
  %call15 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp12) #13
  %coerce.dive16 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp11, i32 0, i32 0
  store ptr %call15, ptr %coerce.dive16, align 8
  %coerce.dive17 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp11, i32 0, i32 0
  %13 = load ptr, ptr %coerce.dive17, align 8
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp9, ptr %13) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp12) #13
  %14 = call i8 @llvm.coro.suspend(token %12, i1 false)
  switch i8 %14, label %coro.ret [
    i8 0, label %await.ready
    i8 1, label %await.cleanup
  ]

await.cleanup:                                    ; preds = %await.suspend
  br label %cleanup18

lpad:                                             ; preds = %cleanup.cont34, %cleanup.cont20, %cleanup.cont
  %15 = landingpad { ptr, i32 }
          catch ptr null
  %16 = extractvalue { ptr, i32 } %15, 0
  store ptr %16, ptr %exn.slot, align 8
  %17 = extractvalue { ptr, i32 } %15, 1
  store i32 %17, ptr %ehselector.slot, align 4
  br label %catch

catch:                                            ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %18 = call ptr @__cxa_begin_catch(ptr %exn) #13
  call void @_ZN4Task12promise_type19unhandled_exceptionEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  invoke void @__cxa_end_catch()
          to label %invoke.cont38 unwind label %lpad37

invoke.cont38:                                    ; preds = %catch
  br label %try.cont

try.cont:                                         ; preds = %invoke.cont38
  br label %coro.final

coro.final:                                       ; preds = %try.cont, %invoke.cont35
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp39) #13
  call void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  %call41 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp39) #13
  br i1 %call41, label %final.ready, label %final.suspend

final.suspend:                                    ; preds = %coro.final
  %19 = call token @llvm.coro.save(ptr null)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp43) #13
  %call44 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %5) #13
  %coerce.dive45 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %ref.tmp43, i32 0, i32 0
  store ptr %call44, ptr %coerce.dive45, align 8
  %call46 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp43) #13
  %coerce.dive47 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp42, i32 0, i32 0
  store ptr %call46, ptr %coerce.dive47, align 8
  %coerce.dive48 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp42, i32 0, i32 0
  %20 = load ptr, ptr %coerce.dive48, align 8
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp39, ptr %20) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp43) #13
  %21 = call i8 @llvm.coro.suspend(token %19, i1 true)
  switch i8 %21, label %coro.ret [
    i8 0, label %final.ready
    i8 1, label %final.cleanup
  ]

final.cleanup:                                    ; preds = %final.suspend
  br label %cleanup49

await.ready:                                      ; preds = %await.suspend, %invoke.cont
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp9) #13
  br label %cleanup18

cleanup18:                                        ; preds = %await.ready, %await.cleanup
  %cleanup.dest.slot.1 = phi i32 [ 0, %await.ready ], [ 2, %await.cleanup ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp9) #13
  switch i32 %cleanup.dest.slot.1, label %cleanup53 [
    i32 0, label %cleanup.cont20
  ]

cleanup.cont20:                                   ; preds = %cleanup18
  %22 = load ptr, ptr @stderr, align 8, !tbaa !5
  %23 = load i32, ptr %id1, align 4, !tbaa !9
  %call22 = invoke i32 (ptr, ptr, ...) @fprintf(ptr noundef %22, ptr noundef @.str.7, i32 noundef %23)
          to label %invoke.cont21 unwind label %lpad

invoke.cont21:                                    ; preds = %cleanup.cont20
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp23) #13
  %call24 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp23) #13
  br i1 %call24, label %await2.ready, label %await2.suspend

await2.suspend:                                   ; preds = %invoke.cont21
  %24 = call token @llvm.coro.save(ptr null)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp26) #13
  %call27 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %5) #13
  %coerce.dive28 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %ref.tmp26, i32 0, i32 0
  store ptr %call27, ptr %coerce.dive28, align 8
  %call29 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp26) #13
  %coerce.dive30 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp25, i32 0, i32 0
  store ptr %call29, ptr %coerce.dive30, align 8
  %coerce.dive31 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp25, i32 0, i32 0
  %25 = load ptr, ptr %coerce.dive31, align 8
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp23, ptr %25) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp26) #13
  %26 = call i8 @llvm.coro.suspend(token %24, i1 false)
  switch i8 %26, label %coro.ret [
    i8 0, label %await2.ready
    i8 1, label %await2.cleanup
  ]

await2.cleanup:                                   ; preds = %await2.suspend
  br label %cleanup32

await2.ready:                                     ; preds = %await2.suspend, %invoke.cont21
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp23) #13
  br label %cleanup32

cleanup32:                                        ; preds = %await2.ready, %await2.cleanup
  %cleanup.dest.slot.2 = phi i32 [ 0, %await2.ready ], [ 2, %await2.cleanup ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp23) #13
  switch i32 %cleanup.dest.slot.2, label %cleanup53 [
    i32 0, label %cleanup.cont34
  ]

cleanup.cont34:                                   ; preds = %cleanup32
  %27 = load ptr, ptr @stderr, align 8, !tbaa !5
  %28 = load i32, ptr %id1, align 4, !tbaa !9
  %call36 = invoke i32 (ptr, ptr, ...) @fprintf(ptr noundef %27, ptr noundef @.str.8, i32 noundef %28)
          to label %invoke.cont35 unwind label %lpad

invoke.cont35:                                    ; preds = %cleanup.cont34
  call void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  br label %coro.final

lpad37:                                           ; preds = %catch
  %29 = landingpad { ptr, i32 }
          cleanup
  %30 = extractvalue { ptr, i32 } %29, 0
  store ptr %30, ptr %exn.slot, align 8
  %31 = extractvalue { ptr, i32 } %29, 1
  store i32 %31, ptr %ehselector.slot, align 4
  %32 = call i1 @llvm.coro.end(ptr null, i1 true, token none)
  br i1 %32, label %eh.resume, label %cleanup.cont52

final.ready:                                      ; preds = %final.suspend, %coro.final
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp39) #13
  br label %cleanup49

cleanup49:                                        ; preds = %final.ready, %final.cleanup
  %cleanup.dest.slot.3 = phi i32 [ 0, %final.ready ], [ 2, %final.cleanup ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp39) #13
  switch i32 %cleanup.dest.slot.3, label %cleanup53 [
    i32 0, label %cleanup.cont51
  ]

cleanup.cont51:                                   ; preds = %cleanup49
  br label %cleanup53

cleanup53:                                        ; preds = %cleanup.cont51, %cleanup49, %cleanup32, %cleanup18, %cleanup
  %cleanup.dest.slot.4 = phi i32 [ %cleanup.dest.slot.0, %cleanup ], [ %cleanup.dest.slot.1, %cleanup18 ], [ %cleanup.dest.slot.2, %cleanup32 ], [ %cleanup.dest.slot.3, %cleanup49 ], [ 0, %cleanup.cont51 ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %__promise) #13
  call void @llvm.lifetime.end.p0(i64 4, ptr %id1) #13
  %33 = call ptr @llvm.coro.free(token %1, ptr %5)
  %34 = icmp ne ptr %33, null
  br i1 %34, label %coro.free, label %after.coro.free

coro.free:                                        ; preds = %cleanup53
  call void @_ZdlPv(ptr noundef %33) #13
  br label %after.coro.free

after.coro.free:                                  ; preds = %cleanup53, %coro.free
  switch i32 %cleanup.dest.slot.4, label %unreachable [
    i32 0, label %cleanup.cont57
    i32 2, label %coro.ret
  ]

cleanup.cont57:                                   ; preds = %after.coro.free
  br label %coro.ret

coro.ret:                                         ; preds = %cleanup.cont57, %after.coro.free, %final.suspend, %await2.suspend, %await.suspend, %init.suspend
  %35 = call i1 @llvm.coro.end(ptr null, i1 false, token none)
  ret void

cleanup.cont52:                                   ; preds = %lpad37
  call void @llvm.lifetime.end.p0(i64 1, ptr %__promise) #13
  call void @llvm.lifetime.end.p0(i64 4, ptr %id1) #13
  %36 = call ptr @llvm.coro.free(token %1, ptr %5)
  %37 = icmp ne ptr %36, null
  br i1 %37, label %coro.free58, label %after.coro.free59

coro.free58:                                      ; preds = %cleanup.cont52
  call void @_ZdlPv(ptr noundef %36) #13
  br label %after.coro.free59

after.coro.free59:                                ; preds = %cleanup.cont52, %coro.free58
  br label %eh.resume

eh.resume:                                        ; preds = %after.coro.free59, %lpad37
  %exn60 = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn60, 0
  %lpad.val61 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val61

unreachable:                                      ; preds = %after.coro.free
  unreachable
}

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) #10

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4TaskC2EOS_(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr noundef nonnull align 8 dereferenceable(8) %o) unnamed_addr #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %o.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  store ptr %o, ptr %o.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %handle = getelementptr inbounds %struct.Task, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %o.addr, align 8, !tbaa !5
  %handle2 = getelementptr inbounds %struct.Task, ptr %0, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %handle, ptr align 8 %handle2, i64 8, i1 false), !tbaa.struct !22
  %1 = load ptr, ptr %o.addr, align 8, !tbaa !5
  %handle3 = getelementptr inbounds %struct.Task, ptr %1, i32 0, i32 0
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %handle3, ptr null) #13
  ret void
}

; Function Attrs: mustprogress noinline uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #2 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !35
  call void @llvm.coro.resume(ptr %0)
  ret void
}

; Function Attrs: mustprogress noinline presplitcoroutine uwtable
define internal void @_ZL15privileged_corov(ptr dead_on_unwind noalias writable sret(%struct.Task) align 8 %agg.result) #9 personality ptr @__gxx_personality_v0 {
entry:
  %result.ptr = alloca ptr, align 8
  %__promise = alloca %"struct.Task::promise_type", align 1
  %ref.tmp = alloca %"struct.std::__n4861::suspend_always", align 1
  %undef.agg.tmp = alloca %"struct.std::__n4861::suspend_always", align 1
  %agg.tmp = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %ref.tmp2 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %is_admin = alloca i8, align 1
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %ref.tmp8 = alloca %"struct.std::__n4861::suspend_always", align 1
  %agg.tmp10 = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %ref.tmp11 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %f = alloca ptr, align 8
  %buf = alloca [128 x i8], align 16
  %ref.tmp43 = alloca %"struct.std::__n4861::suspend_always", align 1
  %undef.agg.tmp44 = alloca %"struct.std::__n4861::suspend_always", align 1
  %agg.tmp46 = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %ref.tmp47 = alloca %"struct.std::__n4861::coroutine_handle", align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  %0 = bitcast ptr %__promise to ptr
  %1 = call token @llvm.coro.id(i32 16, ptr %0, ptr null, ptr null)
  %2 = call i1 @llvm.coro.alloc(token %1)
  br i1 %2, label %coro.alloc, label %coro.init

coro.alloc:                                       ; preds = %entry
  %3 = call i64 @llvm.coro.size.i64()
  %call = call noalias noundef nonnull ptr @_Znwm(i64 noundef %3) #25
  br label %coro.init

coro.init:                                        ; preds = %coro.alloc, %entry
  %4 = phi ptr [ null, %entry ], [ %call, %coro.alloc ]
  %5 = call ptr @llvm.coro.begin(token %1, ptr %4)
  call void @llvm.lifetime.start.p0(i64 1, ptr %__promise) #13
  call void @_ZN4Task12promise_type17get_return_objectEv(ptr dead_on_unwind writable sret(%struct.Task) align 8 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp) #13
  call void @_ZN4Task12promise_type15initial_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  %call1 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #13
  br i1 %call1, label %init.ready, label %init.suspend

init.suspend:                                     ; preds = %coro.init
  %6 = call token @llvm.coro.save(ptr null)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp2) #13
  %call3 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %5) #13
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %ref.tmp2, i32 0, i32 0
  store ptr %call3, ptr %coerce.dive, align 8
  %call4 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp2) #13
  %coerce.dive5 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp, i32 0, i32 0
  store ptr %call4, ptr %coerce.dive5, align 8
  %coerce.dive6 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp, i32 0, i32 0
  %7 = load ptr, ptr %coerce.dive6, align 8
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp, ptr %7) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp2) #13
  %8 = call i8 @llvm.coro.suspend(token %6, i1 false)
  switch i8 %8, label %coro.ret [
    i8 0, label %init.ready
    i8 1, label %init.cleanup
  ]

init.cleanup:                                     ; preds = %init.suspend
  br label %cleanup

init.ready:                                       ; preds = %init.suspend, %coro.init
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #13
  br label %cleanup

cleanup:                                          ; preds = %init.ready, %init.cleanup
  %cleanup.dest.slot.0 = phi i32 [ 0, %init.ready ], [ 2, %init.cleanup ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp) #13
  switch i32 %cleanup.dest.slot.0, label %cleanup58 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup
  call void @llvm.lifetime.start.p0(i64 1, ptr %is_admin) #13
  store volatile i8 0, ptr %is_admin, align 1, !tbaa !20
  store ptr %is_admin, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %9 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call7 = invoke i32 (ptr, ptr, ...) @fprintf(ptr noundef %9, ptr noundef @.str.9)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %cleanup.cont
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp8) #13
  %call9 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8) #13
  br i1 %call9, label %await.ready, label %await.suspend

await.suspend:                                    ; preds = %invoke.cont
  %10 = call token @llvm.coro.save(ptr null)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp11) #13
  %call12 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %5) #13
  %coerce.dive13 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %ref.tmp11, i32 0, i32 0
  store ptr %call12, ptr %coerce.dive13, align 8
  %call14 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp11) #13
  %coerce.dive15 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp10, i32 0, i32 0
  store ptr %call14, ptr %coerce.dive15, align 8
  %coerce.dive16 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp10, i32 0, i32 0
  %11 = load ptr, ptr %coerce.dive16, align 8
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8, ptr %11) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp11) #13
  %12 = call i8 @llvm.coro.suspend(token %10, i1 false)
  switch i8 %12, label %coro.ret [
    i8 0, label %await.ready
    i8 1, label %await.cleanup
  ]

await.cleanup:                                    ; preds = %await.suspend
  br label %cleanup17

lpad:                                             ; preds = %if.else, %if.then, %cleanup.cont
  %13 = landingpad { ptr, i32 }
          catch ptr null
  %14 = extractvalue { ptr, i32 } %13, 0
  store ptr %14, ptr %exn.slot, align 8
  %15 = extractvalue { ptr, i32 } %13, 1
  store i32 %15, ptr %ehselector.slot, align 4
  br label %ehcleanup40

await.ready:                                      ; preds = %await.suspend, %invoke.cont
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp8) #13
  br label %cleanup17

cleanup17:                                        ; preds = %await.ready, %await.cleanup
  %cleanup.dest.slot.1 = phi i32 [ 0, %await.ready ], [ 2, %await.cleanup ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp8) #13
  switch i32 %cleanup.dest.slot.1, label %cleanup38 [
    i32 0, label %cleanup.cont19
  ]

cleanup.cont19:                                   ; preds = %cleanup17
  store ptr null, ptr @_ZL14g_is_admin_ptr, align 8, !tbaa !5
  %16 = load volatile i8, ptr %is_admin, align 1, !tbaa !20, !range !29, !noundef !30
  %tobool = trunc i8 %16 to i1
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %cleanup.cont19
  %17 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call21 = invoke i32 (ptr, ptr, ...) @fprintf(ptr noundef %17, ptr noundef @.str.10)
          to label %invoke.cont20 unwind label %lpad

invoke.cont20:                                    ; preds = %if.then
  call void @llvm.lifetime.start.p0(i64 8, ptr %f) #13
  %call24 = invoke noalias ptr @popen(ptr noundef @.str.11, ptr noundef @.str.12)
          to label %invoke.cont23 unwind label %lpad22

invoke.cont23:                                    ; preds = %invoke.cont20
  store ptr %call24, ptr %f, align 8, !tbaa !5
  %18 = load ptr, ptr %f, align 8, !tbaa !5
  %tobool25 = icmp ne ptr %18, null
  br i1 %tobool25, label %if.then26, label %if.end

if.then26:                                        ; preds = %invoke.cont23
  call void @llvm.lifetime.start.p0(i64 128, ptr %buf) #13
  call void @llvm.memset.p0.i64(ptr align 16 %buf, i8 0, i64 128, i1 false)
  %arraydecay = getelementptr inbounds [128 x i8], ptr %buf, i64 0, i64 0
  %19 = load ptr, ptr %f, align 8, !tbaa !5
  %call29 = invoke i64 @fread(ptr noundef %arraydecay, i64 noundef 1, i64 noundef 127, ptr noundef %19)
          to label %invoke.cont28 unwind label %lpad27

invoke.cont28:                                    ; preds = %if.then26
  %20 = load ptr, ptr %f, align 8, !tbaa !5
  %call31 = invoke i32 @pclose(ptr noundef %20)
          to label %invoke.cont30 unwind label %lpad27

invoke.cont30:                                    ; preds = %invoke.cont28
  %21 = load ptr, ptr @stderr, align 8, !tbaa !5
  %arraydecay32 = getelementptr inbounds [128 x i8], ptr %buf, i64 0, i64 0
  %call34 = invoke i32 (ptr, ptr, ...) @fprintf(ptr noundef %21, ptr noundef @.str.13, ptr noundef %arraydecay32)
          to label %invoke.cont33 unwind label %lpad27

invoke.cont33:                                    ; preds = %invoke.cont30
  call void @llvm.lifetime.end.p0(i64 128, ptr %buf) #13
  br label %if.end

lpad22:                                           ; preds = %invoke.cont20
  %22 = landingpad { ptr, i32 }
          catch ptr null
  %23 = extractvalue { ptr, i32 } %22, 0
  store ptr %23, ptr %exn.slot, align 8
  %24 = extractvalue { ptr, i32 } %22, 1
  store i32 %24, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad27:                                           ; preds = %invoke.cont30, %invoke.cont28, %if.then26
  %25 = landingpad { ptr, i32 }
          catch ptr null
  %26 = extractvalue { ptr, i32 } %25, 0
  store ptr %26, ptr %exn.slot, align 8
  %27 = extractvalue { ptr, i32 } %25, 1
  store i32 %27, ptr %ehselector.slot, align 4
  call void @llvm.lifetime.end.p0(i64 128, ptr %buf) #13
  br label %ehcleanup

if.end:                                           ; preds = %invoke.cont33, %invoke.cont23
  store i8 1, ptr @_ZL16g_privileged_ran, align 1, !tbaa !20
  call void @llvm.lifetime.end.p0(i64 8, ptr %f) #13
  br label %if.end37

ehcleanup:                                        ; preds = %lpad27, %lpad22
  call void @llvm.lifetime.end.p0(i64 8, ptr %f) #13
  br label %ehcleanup40

if.else:                                          ; preds = %cleanup.cont19
  %28 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call36 = invoke i32 (ptr, ptr, ...) @fprintf(ptr noundef %28, ptr noundef @.str.14)
          to label %invoke.cont35 unwind label %lpad

invoke.cont35:                                    ; preds = %if.else
  br label %if.end37

if.end37:                                         ; preds = %invoke.cont35, %if.end
  call void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  br label %cleanup38

cleanup38:                                        ; preds = %if.end37, %cleanup17
  %cleanup.dest.slot.2 = phi i32 [ %cleanup.dest.slot.1, %cleanup17 ], [ 3, %if.end37 ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %is_admin) #13
  switch i32 %cleanup.dest.slot.2, label %cleanup58 [
    i32 3, label %coro.final
  ]

ehcleanup40:                                      ; preds = %ehcleanup, %lpad
  call void @llvm.lifetime.end.p0(i64 1, ptr %is_admin) #13
  br label %catch

catch:                                            ; preds = %ehcleanup40
  %exn = load ptr, ptr %exn.slot, align 8
  %29 = call ptr @__cxa_begin_catch(ptr %exn) #13
  call void @_ZN4Task12promise_type19unhandled_exceptionEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  invoke void @__cxa_end_catch()
          to label %invoke.cont42 unwind label %lpad41

invoke.cont42:                                    ; preds = %catch
  br label %try.cont

try.cont:                                         ; preds = %invoke.cont42
  br label %coro.final

coro.final:                                       ; preds = %try.cont, %cleanup38
  call void @llvm.lifetime.start.p0(i64 1, ptr %ref.tmp43) #13
  call void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %__promise) #13
  %call45 = call noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp43) #13
  br i1 %call45, label %final.ready, label %final.suspend

final.suspend:                                    ; preds = %coro.final
  %30 = call token @llvm.coro.save(ptr null)
  call void @llvm.lifetime.start.p0(i64 8, ptr %ref.tmp47) #13
  %call48 = call ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %5) #13
  %coerce.dive49 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %ref.tmp47, i32 0, i32 0
  store ptr %call48, ptr %coerce.dive49, align 8
  %call50 = call ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp47) #13
  %coerce.dive51 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp46, i32 0, i32 0
  store ptr %call50, ptr %coerce.dive51, align 8
  %coerce.dive52 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %agg.tmp46, i32 0, i32 0
  %31 = load ptr, ptr %coerce.dive52, align 8
  call void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp43, ptr %31) #13
  call void @llvm.lifetime.end.p0(i64 8, ptr %ref.tmp47) #13
  %32 = call i8 @llvm.coro.suspend(token %30, i1 true)
  switch i8 %32, label %coro.ret [
    i8 0, label %final.ready
    i8 1, label %final.cleanup
  ]

final.cleanup:                                    ; preds = %final.suspend
  br label %cleanup53

lpad41:                                           ; preds = %catch
  %33 = landingpad { ptr, i32 }
          cleanup
  %34 = extractvalue { ptr, i32 } %33, 0
  store ptr %34, ptr %exn.slot, align 8
  %35 = extractvalue { ptr, i32 } %33, 1
  store i32 %35, ptr %ehselector.slot, align 4
  %36 = call i1 @llvm.coro.end(ptr null, i1 true, token none)
  br i1 %36, label %eh.resume, label %cleanup.cont57

final.ready:                                      ; preds = %final.suspend, %coro.final
  call void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp43) #13
  br label %cleanup53

cleanup53:                                        ; preds = %final.ready, %final.cleanup
  %cleanup.dest.slot.3 = phi i32 [ 0, %final.ready ], [ 2, %final.cleanup ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %ref.tmp43) #13
  switch i32 %cleanup.dest.slot.3, label %cleanup58 [
    i32 0, label %cleanup.cont55
  ]

cleanup.cont55:                                   ; preds = %cleanup53
  br label %cleanup58

cleanup58:                                        ; preds = %cleanup.cont55, %cleanup53, %cleanup38, %cleanup
  %cleanup.dest.slot.4 = phi i32 [ %cleanup.dest.slot.0, %cleanup ], [ %cleanup.dest.slot.2, %cleanup38 ], [ %cleanup.dest.slot.3, %cleanup53 ], [ 0, %cleanup.cont55 ]
  call void @llvm.lifetime.end.p0(i64 1, ptr %__promise) #13
  %37 = call ptr @llvm.coro.free(token %1, ptr %5)
  %38 = icmp ne ptr %37, null
  br i1 %38, label %coro.free, label %after.coro.free

coro.free:                                        ; preds = %cleanup58
  call void @_ZdlPv(ptr noundef %37) #13
  br label %after.coro.free

after.coro.free:                                  ; preds = %cleanup58, %coro.free
  switch i32 %cleanup.dest.slot.4, label %unreachable [
    i32 0, label %cleanup.cont62
    i32 2, label %coro.ret
  ]

cleanup.cont62:                                   ; preds = %after.coro.free
  br label %coro.ret

coro.ret:                                         ; preds = %cleanup.cont62, %after.coro.free, %final.suspend, %await.suspend, %init.suspend
  %39 = call i1 @llvm.coro.end(ptr null, i1 false, token none)
  ret void

cleanup.cont57:                                   ; preds = %lpad41
  call void @llvm.lifetime.end.p0(i64 1, ptr %__promise) #13
  %40 = call ptr @llvm.coro.free(token %1, ptr %5)
  %41 = icmp ne ptr %40, null
  br i1 %41, label %coro.free64, label %after.coro.free65

coro.free64:                                      ; preds = %cleanup.cont57
  call void @_ZdlPv(ptr noundef %40) #13
  br label %after.coro.free65

after.coro.free65:                                ; preds = %cleanup.cont57, %coro.free64
  br label %eh.resume

eh.resume:                                        ; preds = %after.coro.free65, %lpad41
  %exn66 = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn66, 0
  %lpad.val67 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val67

unreachable:                                      ; preds = %after.coro.free
  unreachable
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvNS0_IvEEEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #6 comdat align 2 {
entry:
  %retval = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %this1) #13
  %call2 = call ptr @_ZNSt7__n486116coroutine_handleIvE12from_addressEPv(ptr noundef %call) #13
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %retval, i32 0, i32 0
  store ptr %call2, ptr %coerce.dive, align 8
  %coerce.dive3 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %retval, i32 0, i32 0
  %0 = load ptr, ptr %coerce.dive3, align 8
  ret ptr %0
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #11

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef ptr @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7addressEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !35
  ret ptr %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: read)
declare token @llvm.coro.id(i32, ptr readnone, ptr nocapture readonly, ptr) #12

; Function Attrs: nounwind
declare i1 @llvm.coro.alloc(token) #13

; Function Attrs: nounwind memory(none)
declare i64 @llvm.coro.size.i64() #14

; Function Attrs: nounwind
declare ptr @llvm.coro.begin(token, ptr writeonly) #13

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type17get_return_objectEv(ptr dead_on_unwind noalias writable sret(%struct.Task) align 8 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %this) #6 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %result.ptr = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %agg.tmp = alloca %"struct.std::__n4861::coroutine_handle", align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %call = invoke ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_promiseERS2_(ptr noundef nonnull align 1 dereferenceable(1) %this1)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %agg.tmp, i32 0, i32 0
  store ptr %call, ptr %coerce.dive, align 8
  %coerce.dive2 = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %agg.tmp, i32 0, i32 0
  %0 = load ptr, ptr %coerce.dive2, align 8
  call void @_ZN4TaskC2ENSt7__n486116coroutine_handleINS_12promise_typeEEE(ptr noundef nonnull align 8 dereferenceable(8) %agg.result, ptr %0) #13
  ret void

terminate.lpad:                                   ; preds = %entry
  %1 = landingpad { ptr, i32 }
          catch ptr null
  %2 = extractvalue { ptr, i32 } %1, 0
  call void @__clang_call_terminate(ptr %2) #24
  unreachable
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type15initial_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486114suspend_always11await_readyEv(ptr noundef nonnull align 1 dereferenceable(1) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  ret i1 false
}

; Function Attrs: nomerge nounwind
declare token @llvm.coro.save(ptr) #15

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486114suspend_always13await_suspendENS_16coroutine_handleIvEE(ptr noundef nonnull align 1 dereferenceable(1) %this, ptr %.coerce) #6 comdat align 2 {
entry:
  %0 = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %this.addr = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %0, i32 0, i32 0
  store ptr %.coerce, ptr %coerce.dive, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_addressEPv(ptr noundef %__a) #6 comdat align 2 {
entry:
  %retval = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %__a.addr = alloca ptr, align 8
  store ptr %__a, ptr %__a.addr, align 8, !tbaa !5
  call void @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %retval) #13
  %0 = load ptr, ptr %__a.addr, align 8, !tbaa !5
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %retval, i32 0, i32 0
  store ptr %0, ptr %_M_fr_ptr, align 8, !tbaa !35
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %retval, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  ret ptr %1
}

; Function Attrs: nounwind
declare i8 @llvm.coro.suspend(token, i1) #13

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486114suspend_always12await_resumeEv(ptr noundef nonnull align 1 dereferenceable(1) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type11return_voidEv(ptr noundef nonnull align 1 dereferenceable(1) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  ret void
}

declare ptr @__cxa_begin_catch(ptr)

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type19unhandled_exceptionEv(ptr noundef nonnull align 1 dereferenceable(1) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  call void @_ZSt9terminatev() #24
  unreachable
}

declare void @__cxa_end_catch()

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4Task12promise_type13final_suspendEv(ptr noundef nonnull align 1 dereferenceable(1) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  ret void
}

; Function Attrs: nounwind
declare i1 @llvm.coro.end(ptr, i1, token) #13

; Function Attrs: nounwind memory(argmem: read)
declare ptr @llvm.coro.free(token, ptr nocapture readonly) #16

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEE12from_promiseERS2_(ptr noundef nonnull align 1 dereferenceable(1) %__p) #6 comdat align 2 {
entry:
  %retval = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %__p.addr = alloca ptr, align 8
  store ptr %__p, ptr %__p.addr, align 8, !tbaa !5
  call void @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %retval) #13
  %0 = load ptr, ptr %__p.addr, align 8, !tbaa !5
  %1 = call ptr @llvm.coro.promise(ptr %0, i32 1, i1 true)
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %retval, i32 0, i32 0
  store ptr %1, ptr %_M_fr_ptr, align 8, !tbaa !35
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %retval, i32 0, i32 0
  %2 = load ptr, ptr %coerce.dive, align 8
  ret ptr %2
}

; Function Attrs: noinline noreturn nounwind uwtable
define linkonce_odr hidden void @__clang_call_terminate(ptr noundef %0) #17 comdat {
  %2 = call ptr @__cxa_begin_catch(ptr %0) #13
  call void @_ZSt9terminatev() #24
  unreachable
}

declare void @_ZSt9terminatev()

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZN4TaskC2ENSt7__n486116coroutine_handleINS_12promise_typeEEE(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr %h.coerce) unnamed_addr #6 comdat align 2 {
entry:
  %h = alloca %"struct.std::__n4861::coroutine_handle", align 8
  %this.addr = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %h, i32 0, i32 0
  store ptr %h.coerce, ptr %coerce.dive, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %handle = getelementptr inbounds %struct.Task, ptr %this1, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %handle, ptr align 8 %h, i64 8, i1 false), !tbaa.struct !22
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %this1, i32 0, i32 0
  store ptr null, ptr %_M_fr_ptr, align 8, !tbaa !35
  ret void
}

; Function Attrs: nounwind memory(none)
declare ptr @llvm.coro.promise(ptr nocapture, i32, i1) #14

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef nonnull align 8 dereferenceable(8) ptr @_ZNSt7__n486116coroutine_handleIN4Task12promise_typeEEaSEDn(ptr noundef nonnull align 8 dereferenceable(8) %this, ptr %0) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  store ptr %0, ptr %.addr, align 8, !tbaa !31
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %this1, i32 0, i32 0
  store ptr null, ptr %_M_fr_ptr, align 8, !tbaa !35
  ret ptr %this1
}

declare void @llvm.coro.resume(ptr)

declare noalias ptr @popen(ptr noundef, ptr noundef) #1

declare i64 @fread(ptr noundef, i64 noundef, i64 noundef, ptr noundef) #1

declare i32 @pclose(ptr noundef) #1

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local ptr @_ZNSt7__n486116coroutine_handleIvE12from_addressEPv(ptr noundef %__a) #6 comdat align 2 {
entry:
  %retval = alloca %"struct.std::__n4861::coroutine_handle.0", align 8
  %__a.addr = alloca ptr, align 8
  store ptr %__a, ptr %__a.addr, align 8, !tbaa !5
  call void @_ZNSt7__n486116coroutine_handleIvEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %retval) #13
  %0 = load ptr, ptr %__a.addr, align 8, !tbaa !5
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %retval, i32 0, i32 0
  store ptr %0, ptr %_M_fr_ptr, align 8, !tbaa !33
  %coerce.dive = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %retval, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local void @_ZNSt7__n486116coroutine_handleIvEC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %this1, i32 0, i32 0
  store ptr null, ptr %_M_fr_ptr, align 8, !tbaa !33
  ret void
}

; Function Attrs: nounwind
declare noalias ptr @fdopen(i32 noundef, ptr noundef) #4

; Function Attrs: nounwind
declare i32 @dup(i32 noundef) #4

declare i32 @fflush(ptr noundef) #1

declare ptr @fgets(ptr noundef, i32 noundef, ptr noundef) #1

; Function Attrs: nounwind willreturn memory(read)
declare i64 @strcspn(ptr noundef, ptr noundef) #18

; Function Attrs: nounwind willreturn memory(read)
declare i32 @strcmp(ptr noundef, ptr noundef) #18

; Function Attrs: mustprogress noinline uwtable
define internal void @_ZL13hijack_targetPv(ptr noundef %frame) #2 {
entry:
  %frame.addr = alloca ptr, align 8
  %f = alloca ptr, align 8
  %buf = alloca [128 x i8], align 16
  %nul = alloca ptr, align 8
  store ptr %frame, ptr %frame.addr, align 8, !tbaa !5
  %0 = load ptr, ptr @stderr, align 8, !tbaa !5
  %call = call i32 @getpid() #13
  %call1 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %0, ptr noundef @.str.44, i32 noundef %call)
  call void @llvm.lifetime.start.p0(i64 8, ptr %f) #13
  %call2 = call noalias ptr @popen(ptr noundef @.str.11, ptr noundef @.str.12)
  store ptr %call2, ptr %f, align 8, !tbaa !5
  %1 = load ptr, ptr %f, align 8, !tbaa !5
  %tobool = icmp ne ptr %1, null
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 128, ptr %buf) #13
  call void @llvm.memset.p0.i64(ptr align 16 %buf, i8 0, i64 128, i1 false)
  %arraydecay = getelementptr inbounds [128 x i8], ptr %buf, i64 0, i64 0
  %2 = load ptr, ptr %f, align 8, !tbaa !5
  %call3 = call i64 @fread(ptr noundef %arraydecay, i64 noundef 1, i64 noundef 127, ptr noundef %2)
  %3 = load ptr, ptr %f, align 8, !tbaa !5
  %call4 = call i32 @pclose(ptr noundef %3)
  %4 = load ptr, ptr @stderr, align 8, !tbaa !5
  %arraydecay5 = getelementptr inbounds [128 x i8], ptr %buf, i64 0, i64 0
  %call6 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %4, ptr noundef @.str.45, ptr noundef %arraydecay5)
  call void @llvm.lifetime.end.p0(i64 128, ptr %buf) #13
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = load ptr, ptr %frame.addr, align 8, !tbaa !5
  %tobool7 = icmp ne ptr %5, null
  br i1 %tobool7, label %if.then8, label %if.end9

if.then8:                                         ; preds = %if.end
  call void @llvm.lifetime.start.p0(i64 8, ptr %nul) #13
  store ptr null, ptr %nul, align 8, !tbaa !5
  %6 = load ptr, ptr %frame.addr, align 8, !tbaa !5
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %6, ptr align 8 %nul, i64 8, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr %nul) #13
  br label %if.end9

if.end9:                                          ; preds = %if.then8, %if.end
  call void @llvm.lifetime.end.p0(i64 8, ptr %f) #13
  ret void
}

; Function Attrs: nounwind willreturn memory(read)
declare i32 @strncmp(ptr noundef, ptr noundef, i64 noundef) #18

; Function Attrs: nounwind
declare i32 @__isoc23_sscanf(ptr noundef, ptr noundef, ...) #4

; Function Attrs: mustprogress noinline nounwind uwtable
define internal void @_ZL19vuln_write_anywherePvPKhm(ptr noundef %dest, ptr noundef %src, i64 noundef %n) #6 {
entry:
  %dest.addr = alloca ptr, align 8
  %src.addr = alloca ptr, align 8
  %n.addr = alloca i64, align 8
  store ptr %dest, ptr %dest.addr, align 8, !tbaa !5
  store ptr %src, ptr %src.addr, align 8, !tbaa !5
  store i64 %n, ptr %n.addr, align 8, !tbaa !37
  %0 = load ptr, ptr %dest.addr, align 8, !tbaa !5
  %1 = load ptr, ptr %src.addr, align 8, !tbaa !5
  %2 = load i64, ptr %n.addr, align 8, !tbaa !37
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %0, ptr align 1 %1, i64 %2, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !35
  %tobool = icmp ne ptr %0, null
  ret i1 %tobool
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !35
  %1 = call i1 @llvm.coro.done(ptr %0)
  ret i1 %1
}

; Function Attrs: mustprogress noinline uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486116coroutine_handleIN4Task12promise_typeEE7destroyEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #2 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !35
  call void @llvm.coro.destroy(ptr %0)
  ret void
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvEcvbEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !33
  %tobool = icmp ne ptr %0, null
  ret i1 %tobool
}

; Function Attrs: mustprogress noinline nounwind uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZNKSt7__n486116coroutine_handleIvE4doneEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #6 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !33
  %1 = call i1 @llvm.coro.done(ptr %0)
  ret i1 %1
}

; Function Attrs: mustprogress noinline uwtable
define linkonce_odr dso_local void @_ZNKSt7__n486116coroutine_handleIvE6resumeEv(ptr noundef nonnull align 8 dereferenceable(8) %this) #2 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8, !tbaa !5
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_fr_ptr = getelementptr inbounds %"struct.std::__n4861::coroutine_handle.0", ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %_M_fr_ptr, align 8, !tbaa !33
  call void @llvm.coro.resume(ptr %0)
  ret void
}

declare i32 @fclose(ptr noundef) #1

; Function Attrs: nounwind memory(argmem: readwrite)
declare i1 @llvm.coro.done(ptr nocapture readonly) #19

declare void @llvm.coro.destroy(ptr)

attributes #0 = { mustprogress noinline norecurse uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { mustprogress noinline uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #6 = { mustprogress noinline nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { cold "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { mustprogress noinline presplitcoroutine uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #12 = { nocallback nofree nosync nounwind willreturn memory(argmem: read) }
attributes #13 = { nounwind }
attributes #14 = { nounwind memory(none) }
attributes #15 = { nomerge nounwind }
attributes #16 = { nounwind memory(argmem: read) }
attributes #17 = { noinline noreturn nounwind uwtable "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #18 = { nounwind willreturn memory(read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #19 = { nounwind memory(argmem: readwrite) }
attributes #20 = { cold }
attributes #21 = { builtin nounwind }
attributes #22 = { builtin allocsize(0) }
attributes #23 = { nounwind willreturn memory(read) }
attributes #24 = { noreturn nounwind }
attributes #25 = { allocsize(0) }

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
!17 = distinct !{!17, !18, !19}
!18 = !{!"llvm.loop.mustprogress"}
!19 = !{!"llvm.loop.unroll.disable"}
!20 = !{!21, !21, i64 0}
!21 = !{!"bool", !7, i64 0}
!22 = !{i64 0, i64 8, !5}
!23 = !{!13, !13, i64 0}
!24 = !{!7, !7, i64 0}
!25 = distinct !{!25, !18, !19}
!26 = !{!27, !27, i64 0}
!27 = !{!"long long", !7, i64 0}
!28 = distinct !{!28, !18, !19}
!29 = !{i8 0, i8 2}
!30 = !{}
!31 = !{!32, !32, i64 0}
!32 = !{!"std::nullptr_t", !7, i64 0}
!33 = !{!34, !6, i64 0}
!34 = !{!"_ZTSNSt7__n486116coroutine_handleIvEE", !6, i64 0}
!35 = !{!36, !6, i64 0}
!36 = !{!"_ZTSNSt7__n486116coroutine_handleIN4Task12promise_typeEEE", !6, i64 0}
!37 = !{!38, !38, i64 0}
!38 = !{!"long", !7, i64 0}
