PS C:\Users\Moein\Documents\Codes\mik_flutter> flutter run -d R5CY23R9DXR
"fa": 1 untranslated message(s).
To see a detailed report, use the untranslated-messages-file 
option in the l10n.yaml file:
untranslated-messages-file: desiredFileName.txt
<other option>: <other selection> 


This will generate a JSON format file containing all messages that 
need to be translated.
Launching lib\main.dart on SM S938B in debug mode...
Running Gradle task 'assembleDebug'...                              4.0s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          11.8s
D/FlutterJNI( 6465): Beginning load of flutter...
D/FlutterJNI( 6465): flutter (null) was loaded normally!
I/flutter ( 6465): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
I/flutter ( 6465): [17:52:55.057] ℹ️ INFO [Main] 🚀 App starting...
I/flutter ( 6465): [17:52:55.077] ℹ️ INFO [Main] ✅ Hive initialized
I/flutter ( 6465): [17:52:55.077] ℹ️ INFO [Main] ✅ Bloc observer initialized
I/flutter ( 6465): [17:52:55.098] ℹ️ INFO [Main] ✅ Dependencies initialized
I/flutter ( 6465): [17:52:55.099] ℹ️ INFO [Main] ✅ Default admin user ensured
I/flutter ( 6465): [17:52:55.102] ℹ️ INFO [SubscriptionService] Initializing Poolakey...
I/flutter ( 6465): [17:52:55.141] ℹ️ INFO [MyApp] MyApp.initState start
I/flutter ( 6465): [17:52:55.142] 🔍 DEBUG [BlocObserver] onCreate: AppAuthBloc
I/flutter ( 6465): [17:52:55.146] ℹ️ INFO [MyApp] AppAuthBloc instance created
I/flutter ( 6465): [17:52:55.147] 🔍 DEBUG [BlocObserver] onCreate: AuthBloc
I/flutter ( 6465): [17:52:55.148] ℹ️ INFO [MyApp] AuthBloc instance created
I/flutter ( 6465): [17:52:55.163] ℹ️ INFO [MyApp] AppRouter created
I/flutter ( 6465): [17:52:55.163] 🔍 DEBUG [BackButtonHandler] Initializing BackButtonHandler
I/flutter ( 6465): [17:52:55.163] 🔍 DEBUG [BackButtonHandler] Setting callback: registered
I/flutter ( 6465): [17:52:55.163] ℹ️ INFO [MyApp] Dispatching CheckAuthStatus event
I/flutter ( 6465): [17:52:55.163] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> CheckAuthStatus
I/flutter ( 6465): [17:52:55.164] 🔍 DEBUG [BlocObserver]   Event details: CheckAuthStatus()
I/flutter ( 6465): [17:52:55.164] ℹ️ INFO [MyApp] CheckAuthStatus event dispatched
I/flutter ( 6465): [17:52:55.167] ℹ️ INFO [MyApp] MyApp.build called
D/Sentry  ( 6465): File /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.options-cache is not a File.
D/Sentry  ( 6465): Processing file: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/3665f388-ad9f-4ff1-97ed-b134d4d3f854.envelope
D/Sentry  ( 6465): Captured Envelope is already cached
D/Sentry  ( 6465): Envelope enqueued
I/flutter ( 6465): [17:52:55.426] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthInitial, issAppAuthenticated=false, isOnAppLogin=false
I/flutter ( 6465): [17:52:55.426] ℹ️ INFO [AppRouter] Redirecting to AppLogin
Syncing files to device SM S938B...                                160ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM S938B is available at: http://127.0.0.1:25589/wtfj4FTcyOM=/
The Flutter DevTools debugger and profiler on SM S938B is available at:
http://127.0.0.1:25589/wtfj4FTcyOM=/devtools/?uri=ws://127.0.0.1:25589/wtfj4FTcyOM=/ws
I/flutter ( 6465): [17:52:55.619] ℹ️ INFO [AppAuthBloc] CheckAuthStatus received
I/flutter ( 6465): [17:52:55.619] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:52:55.619] 🔍 DEBUG [BlocObserver]   Event: CheckAuthStatus
I/flutter ( 6465): [17:52:55.619] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthInitial
I/flutter ( 6465): [17:52:55.619] 🔍 DEBUG [BlocObserver]   NextState: AppAuthLoading
I/flutter ( 6465): [17:52:55.620] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:52:55.620] 🔍 DEBUG [BlocObserver]   From: AppAuthInitial
I/flutter ( 6465): [17:52:55.620] 🔍 DEBUG [BlocObserver]   To: AppAuthLoading
I/flutter ( 6465): [17:52:55.620] ℹ️ INFO [GetCurrentUserUseCase] GetCurrentUserUseCase: START
I/flutter ( 6465): [17:52:55.620] ℹ️ INFO [AppAuthRepository] getLoggedInUser: calling localDataSource     
I/flutter ( 6465): [17:52:55.620] ℹ️ INFO [AppAuthLocalDataSource] getLoggedInUser: START
I/flutter ( 6465): [17:52:55.620] ℹ️ INFO [AppAuthLocalDataSource] getLoggedInUser: session userId = admin__default
I/flutter ( 6465): [17:52:55.625] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthLoading, issAppAuthenticated=false, isOnAppLogin=false
I/flutter ( 6465): [17:52:55.625] ℹ️ INFO [AppRouter] Redirecting to AppLogin
I/flutter ( 6465): [17:52:55.627] ℹ️ INFO [AppAuthLocalDataSource] getLoggedInUser: found user = true      
I/flutter ( 6465): [17:52:55.627] ℹ️ INFO [AppAuthRepository] getLoggedInUser: localDataSource returned useer=true
I/flutter ( 6465): [17:52:55.628] ℹ️ INFO [GetCurrentUserUseCase] GetCurrentUserUseCase: returned user=true
I/flutter ( 6465): [17:52:55.628] ℹ️ INFO [AppAuthBloc] CheckAuthStatus result: user found = true
I/flutter ( 6465): [17:52:55.628] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:52:55.628] 🔍 DEBUG [BlocObserver]   Event: CheckAuthStatus
I/flutter ( 6465): [17:52:55.628] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthLoading
I/flutter ( 6465): [17:52:55.628] 🔍 DEBUG [BlocObserver]   NextState: AppAuthAuthenticated
I/flutter ( 6465): [17:52:55.628] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:52:55.628] 🔍 DEBUG [BlocObserver]   From: AppAuthLoading
I/flutter ( 6465): [17:52:55.629] 🔍 DEBUG [BlocObserver]   To: AppAuthAuthenticated
I/flutter ( 6465): [17:52:55.630] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthAuthenticatted, isAppAuthenticated=true, isOnAppLogin=false
I/flutter ( 6465): [17:52:55.630] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/flutter ( 6465): [17:52:55.632] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthAuthenticatted, isAppAuthenticated=true, isOnAppLogin=false
I/flutter ( 6465): [17:52:55.632] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/Choreographer( 6465): Skipped 66 frames!  The application may be doing too much work on its main thread. 
I/flutter ( 6465): [17:52:55.809] ℹ️ INFO [SubscriptionService] ✅ Poolakey connected successfully
I/BLASTBufferQueue( 6465): [e1d9f91 SurfaceView[com.example.hsmik/com.example.hsmik.MainActivity]@0#1](f:0,a:0,s:0) onFrameAvailable the first frame is available
I/SurfaceComposerClient( 6465): apply transaction with the first frame. layerId: 40038, bufferData(ID: 27766963568650, frameNumber: 1)
I/SurfaceView( 6465): 236822417 finishedDrawing
I/Choreographer( 6465): Skipped 31 frames!  The application may be doing too much work on its main thread.
D/VRI[MainActivity]@bdf53f5( 6465): Setup new sync=wmsSync-VRI[MainActivity]@bdf53f5#1
I/VRI[MainActivity]@bdf53f5( 6465): Creating new active sync group VRI[MainActivity]@bdf53f5#2
D/VRI[MainActivity]@bdf53f5( 6465): Draw frame after cancel
D/VRI[MainActivity]@bdf53f5( 6465): registerCallbacksForSync syncBuffer=false
D/SurfaceView( 6465): 236822417 updateSurfacePosition RenderWorker, frameNr = 1, position = [0, 0, 1440, 3120] surfaceSize = 1440x3120
I/SV[236822417 MainActivity]( 6465): uSP: rtp = Rect(0, 0 - 1440, 3120) rtsw = 1440 rtsh = 3120
I/SV[236822417 MainActivity]( 6465): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SV[236822417 MainActivity]( 6465): aOrMT: VRI[MainActivity]@bdf53f5 t = android.view.SurfaceControl$Transaction@8d0294 fN = 1 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1932 android.graphics.RenderNode$CompositePositionUpdateListener.positionChanged:401
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed24e8d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SurfaceView.applyOrMergeTransaction:1863 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1932
D/VRI[MainActivity]@bdf53f5( 6465): Received frameDrawingCallback syncResult=0 frameNum=1.
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed292e90 mBlastBufferQueue=0xb4000078bd25d460 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$12.onFrameDraw:15441 android.view.ThreadedRenderer$1.onFrameDraw:718 <bottom of call stack>
I/VRI[MainActivity]@bdf53f5( 6465): Setting up sync and frameCommitCallback
I/BLASTBufferQueue( 6465): [VRI[MainActivity]@bdf53f5#0](f:0,a:0,s:0) onFrameAvailable the first frame is available
I/SurfaceComposerClient( 6465): apply transaction with the first frame. layerId: 40033, bufferData(ID: 27766963568655, frameNumber: 1)
I/VRI[MainActivity]@bdf53f5( 6465): Received frameCommittedCallback lastAttemptedDrawFrameNum=1 didProduceBuffer=true
D/HWUI    ( 6465): CFMS:: SetUp Pid : 6465    Tid : 6498
D/VRI[MainActivity]@bdf53f5( 6465): reportDrawFinished seqId=0
D/VRI[MainActivity]@bdf53f5( 6465): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb40000789d250dc0}
D/InputMethodManagerUtils( 6465): startInputInner - Id : 0
I/InputMethodManager( 6465): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/InputMethodManager( 6465): handleMessage: setImeVisibility visible=false
D/InsetsController( 6465): hide(ime(), fromIme=false)
I/ImeTracker( 6465): com.example.hsmik:c8140cac: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN
D/InputTransport( 6465): Input channel constructed: 'ClientS', fd=214
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@bdf53f5
I/flutter ( 6465): [17:52:58.009] ℹ️ INFO [AppRouter] Redirect check: matched=/settings, appAuth=AppAuthAutthenticated, isAppAuthenticated=true, isOnAppLogin=false
I/flutter ( 6465): [17:52:58.009] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/flutter ( 6465): [17:52:58.014] 🔍 DEBUG [BlocObserver] onCreate: SettingsCubit
I/flutter ( 6465): [17:52:58.060] ℹ️ INFO [BlocObserver] onChange: SettingsCubit
I/flutter ( 6465): [17:52:58.060] 🔍 DEBUG [BlocObserver]   From: SettingsState
I/flutter ( 6465): [17:52:58.060] 🔍 DEBUG [BlocObserver]   To: SettingsState
I/flutter ( 6465): [17:52:58.987] ℹ️ INFO [SettingsPage] Checking biometric capability
I/flutter ( 6465): [17:52:58.997] ℹ️ INFO [SettingsPage] canCheckBiometrics=true isSupported=true
I/flutter ( 6465): [17:52:59.003] ℹ️ INFO [SettingsPage] Starting biometric authentication
I/ImeFocusController( 6465): onPreWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
I/ImeFocusController( 6465): onPostWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
D/InputTransport( 6465): Input channel destroyed: 'ClientS', fd=214
W/Sentry  ( 6465): Timed out waiting for envelope submission.
D/Sentry  ( 6465): Deleted file /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/3665f388-ad9f-4ff1-97ed-b134d4d3f854.envelope.
D/Sentry  ( 6465): Finished processing cached files from /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5
D/Sentry  ( 6465): EnvelopeFileObserverIntegration installed.
D/ConnectivityManager( 6465): StackLog: [android.net.ConnectivityManager.sendRequestForNetwork(ConnectivityManager.java:4736)] [android.net.ConnectivityManager.registerDefaultNetworkCallbackForUid(ConnectivityManager.java:5461)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5428)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5402)] [io.sentry.android.core.internal.util.AndroidConnectionStatusProvider.registerNetworkCallback(AndroidConnectionStatusProvider.java:308)] [io.sentry.android.core.internal.util.AndroidConnectionStatusProvider.addConnectionStatusObserver(AndroidConnectionStatusProvider.java:98)] [io.sentry.android.core.SendCachedEnvelopeIntegration.lambda$sendCachedEnvelopes$0$io-sentry-android-core-SendCachedEnvelopeIntegration(SendCachedEnvelopeIntegration.java:101)] [io.sentry.android.core.SendCachedEnvelopeIntegration$$ExternalSyntheticLambda0.run(D8$$SyntheticClass:0)] [java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:524)] [java.util.concurrent.FutureTask.run(FutureTask.java:317)] [java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:348)] [java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1156)] [java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:651)] [java.lang.Thread.run(Thread.java:1119)]
D/Sentry  ( 6465): Started processing cached files from /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): Processing dir. /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): Processing 0 items from cache dir /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): Finished processing cached files from /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): SendCachedEnvelopeIntegration installed.
D/Sentry  ( 6465): Serializing object: {
D/Sentry  ( 6465):      "timestamp": "2025-12-29T14:22:55.041Z",
D/Sentry  ( 6465):      "type": "navigation",
D/Sentry  ( 6465):      "data": {
D/Sentry  ( 6465):              "state": "foreground"
D/Sentry  ( 6465):      },
D/Sentry  ( 6465):      "category": "app.lifecycle",
D/Sentry  ( 6465):      "level": "info"
D/Sentry  ( 6465): }
D/Sentry  ( 6465): SystemEventsBreadcrumbsIntegration installed.
D/ConnectivityManager( 6465): StackLog: [android.net.ConnectivityManager.sendRequestForNetwork(ConnectivityManager.java:4736)] [android.net.ConnectivityManager.registerDefaultNetworkCallbackForUid(ConnectivityManager.java:5461)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5428)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5402)] [io.sentry.android.core.internal.util.AndroidConnectionStatusProvider.registerNetworkCallback(AndroidConnectionStatusProvider.java:308)] [io.sentry.android.core.NetworkBreadcrumbsIntegration$1.run(NetworkBreadcrumbsIntegration.java:95)] [java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:524)] [java.util.concurrent.FutureTask.run(FutureTask.java:317)] [java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:348)] [java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1156)] [java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:651)] [java.lang.Thread.run(Thread.java:1119)]
D/Sentry  ( 6465): NetworkBreadcrumbsIntegration installed.
D/Sentry  ( 6465): Serializing object: "com.example.hsmik@1.0.1+6"
D/Sentry  ( 6465): Deleting proguard-uuid.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.options-cache/proguard-uuid.json
D/Sentry  ( 6465): Serializing object: {
D/Sentry  ( 6465):      "name": "sentry.java.android.flutter",
D/Sentry  ( 6465):      "version": "7.22.4",
D/Sentry  ( 6465):      "packages": [
D/Sentry  ( 6465):              {
D/Sentry  ( 6465):                      "name": "maven:io.sentry:sentry",
D/Sentry  ( 6465):                      "version": "7.22.4"
D/Sentry  ( 6465):              },
D/Sentry  ( 6465):              {
D/Sentry  ( 6465):                      "name": "maven:io.sentry:sentry-android-core",
D/Sentry  ( 6465):                      "version": "7.22.4"
D/Sentry  ( 6465):              },
D/Sentry  ( 6465):              {
D/Sentry  ( 6465):                      "name": "pub:sentry",
D/Sentry  ( 6465):                      "version": "8.14.2"
D/Sentry  ( 6465):              },
D/Sentry  ( 6465):              {
D/Sentry  ( 6465):                      "name": "pub:sentry_flutter",
D/Sentry  ( 6465):                      "version": "8.14.2"
D/Sentry  ( 6465):              },
D/Sentry  ( 6465):              {
D/Sentry  ( 6465):                      "name": "maven:io.sentry:sentry-android-ndk",
D/Sentry  ( 6465):                      "version": "7.22.4"
D/Sentry  ( 6465):              }
D/Sentry  ( 6465):      ],
D/Sentry  ( 6465):      "integrations": [
D/Sentry  ( 6465):              "isolateErrorIntegration",
D/Sentry  ( 6465):              "widgetsFlutterBindingIntegration",
D/Sentry  ( 6465):              "OnErrorIntegration",
D/Sentry  ( 6465):              "flutterErrorIntegration",
D/Sentry  ( 6465):              "widgetsBindingIntegration",
D/Sentry  ( 6465):              "UncaughtExceptionHandler",
D/Sentry  ( 6465):              "ShutdownHook",
D/Sentry  ( 6465):              "SendCachedEnvelope",
D/Sentry  ( 6465):              "Ndk",
D/Sentry  ( 6465):              "AppLifecycle",
D/Sentry  ( 6465):              "ActivityLifecycle",
D/Sentry  ( 6465):              "ActivityBreadcrumbs",
D/Sentry  ( 6465):              "UserInteraction",
D/Sentry  ( 6465):              "AppComponentsBreadcrumbs",
D/Sentry  ( 6465):              "SystemEventsBreadcrumbs",
D/Sentry  ( 6465):              "NetworkBreadcrumbs"
D/Sentry  ( 6465):      ]
D/Sentry  ( 6465): }
D/Sentry  ( 6465): Deleting dist.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.options-cache/dist.json
D/Sentry  ( 6465): Envelope sent successfully.
D/Sentry  ( 6465): Serializing object: "production"
D/Sentry  ( 6465): Serializing object: {}
D/Sentry  ( 6465): Deleting replay-error-sample-rate.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.options-cache/replay-error-sample-rate.json
D/Sentry  ( 6465): Deleting user.json from scope cache
D/Sentry  ( 6465): Deleting level.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/level.json
D/Sentry  ( 6465): Deleting request.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/request.json
D/Sentry  ( 6465): Deleting fingerprint.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/fingerprint.json
D/Sentry  ( 6465): Deleting contexts.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/contexts.json
D/Sentry  ( 6465): Deleting extras.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/extras.json
D/Sentry  ( 6465): Deleting tags.json from scope cache
D/Sentry  ( 6465): Envelope was not cached: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/3665f388-ad9f-4ff1-97ed-b134d4d3f854.envelope
D/Sentry  ( 6465): Envelope flushed
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/tags.json
D/Sentry  ( 6465): Deleting trace.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/trace.json
D/Sentry  ( 6465): Deleting transaction.json from scope cache
D/Sentry  ( 6465): Failed to delete: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache/transaction.json
W/Sentry  ( 6465): Current session is not ended, we'd need to end it.
D/Sentry  ( 6465): Started processing cached files from /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5
D/Sentry  ( 6465): Processing dir. /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5
D/Sentry  ( 6465): Processing 0 items from cache dir /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5
D/Sentry  ( 6465): File /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox is not a File.
D/Sentry  ( 6465): File /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.sentry-native is not a File.
D/Sentry  ( 6465): File /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.scope-cache is not a File.
D/Sentry  ( 6465): Processing file: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/session.json
D/Sentry  ( 6465): File '/data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/session.json' doesn't match extension expected.
D/Sentry  ( 6465): File /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/.options-cache is not a File.
D/Sentry  ( 6465): Finished processing cached files from /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5
D/Sentry  ( 6465): Started processing cached files from /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): Processing dir. /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): Processing 0 items from cache dir /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): Finished processing cached files from /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/outbox
D/Sentry  ( 6465): Serializing object: {
D/Sentry  ( 6465):      "timestamp": "2025-12-29T14:22:59.431Z",
D/Sentry  ( 6465):      "type": "system",
D/Sentry  ( 6465):      "data": {
D/Sentry  ( 6465):              "level": 66.0,
D/Sentry  ( 6465):              "charging": true,
D/Sentry  ( 6465):              "action": "BATTERY_CHANGED"
D/Sentry  ( 6465):      },
D/Sentry  ( 6465):      "category": "device.event",
D/Sentry  ( 6465):      "level": "info"
D/Sentry  ( 6465): }
D/Sentry  ( 6465): Serializing object: {
D/Sentry  ( 6465):      "timestamp": "2025-12-29T14:22:59.432Z",
D/Sentry  ( 6465):      "type": "system",
D/Sentry  ( 6465):      "data": {
D/Sentry  ( 6465):              "action": "NETWORK_AVAILABLE"
D/Sentry  ( 6465):      },
D/Sentry  ( 6465):      "category": "network.event",
D/Sentry  ( 6465):      "level": "info"
D/Sentry  ( 6465): }
D/Sentry  ( 6465): Serializing object: {
D/Sentry  ( 6465):      "timestamp": "2025-12-29T14:22:59.432Z",
D/Sentry  ( 6465):      "type": "system",
D/Sentry  ( 6465):      "data": {
D/Sentry  ( 6465):              "upload_bandwidth": 12000,
D/Sentry  ( 6465):              "action": "NETWORK_CAPABILITIES_CHANGED",
D/Sentry  ( 6465):              "vpn_active": true,
D/Sentry  ( 6465):              "network_type": "wifi",
D/Sentry  ( 6465):              "download_bandwidth": 21766
D/Sentry  ( 6465):      },
D/Sentry  ( 6465):      "category": "network.event",
D/Sentry  ( 6465):      "level": "info"
D/Sentry  ( 6465): }
D/ProfileInstaller( 6465): Installing profile for com.example.hsmik
D/Sentry  ( 6465): Envelope sent successfully.
D/Sentry  ( 6465): Envelope flushed
D/Sentry  ( 6465): Marking envelope submission result: true
D/Sentry  ( 6465): Adding Envelope to offline storage: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/22a066f4-2638-425d-88de-b17dc168afb1.envelope
D/Sentry  ( 6465): Serializing object: {
D/Sentry  ( 6465):      "sid": "67f0caec-e3cc-40f6-a629-630d7bc353fa",
D/Sentry  ( 6465):      "did": "f686902f-c2e4-4bd7-bd55-a48487213cc5",
D/Sentry  ( 6465):      "started": "2025-12-29T14:21:35.595Z",
D/Sentry  ( 6465):      "status": "exited",
D/Sentry  ( 6465):      "seq": 1767018179436,
D/Sentry  ( 6465):      "errors": 0,
D/Sentry  ( 6465):      "duration": 83.841,
D/Sentry  ( 6465):      "timestamp": "2025-12-29T14:22:59.436Z",
D/Sentry  ( 6465):      "attrs": {
D/Sentry  ( 6465):              "release": "com.example.hsmik@1.0.1+6",
D/Sentry  ( 6465):              "environment": "production"
D/Sentry  ( 6465):      }
D/Sentry  ( 6465): }
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@bdf53f5
I/BiometricPrompt( 6465): onAuthenticationSucceeded: 2
I/flutter ( 6465): [17:53:02.089] ℹ️ INFO [SettingsPage] Biometric authenticate result: true
I/flutter ( 6465): [17:53:02.092] ℹ️ INFO [SettingsPage] Persisting biometric setting: true
I/InsetsSourceConsumer( 6465): applyRequestedVisibilityToControl: visible=true, type=statusBars, host=com.example.hsmik/com.example.hsmik.MainActivity
I/InsetsSourceConsumer( 6465): applyRequestedVisibilityToControl: visible=true, type=navigationBars, host=com.example.hsmik/com.example.hsmik.MainActivity
I/flutter ( 6465): [17:53:02.101] ℹ️ INFO [BlocObserver] onChange: SettingsCubit
I/flutter ( 6465): [17:53:02.101] 🔍 DEBUG [BlocObserver]   From: SettingsState
I/flutter ( 6465): [17:53:02.101] 🔍 DEBUG [BlocObserver]   To: SettingsState
I/flutter ( 6465): [17:53:02.101] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> BiometricToggleRequested  
I/flutter ( 6465): [17:53:02.101] 🔍 DEBUG [BlocObserver]   Event details: BiometricToggleRequested(true)  
I/flutter ( 6465): [17:53:02.105] ℹ️ INFO [AppAuthBloc] BiometricToggleRequested received: enable=true for  user=admin_default
I/flutter ( 6465): [17:53:02.105] ℹ️ INFO [AppAuthRepository] Enabling biometric for user: admin_default   
D/VRI[MainActivity]@bdf53f5( 6465): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb40000789d250dc0}
D/InputMethodManagerUtils( 6465): startInputInner - Id : 0
I/InputMethodManager( 6465): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/flutter ( 6465): [17:53:02.110] ℹ️ INFO [AppAuthRepository] Enabled biometric for user: admin_default    
I/flutter ( 6465): [17:53:02.110] ℹ️ INFO [AppAuthBloc] Biometric toggle succeeded for user=admin_default:  enable=true
I/flutter ( 6465): [17:53:02.111] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:02.111] 🔍 DEBUG [BlocObserver]   Event: BiometricToggleRequested
I/flutter ( 6465): [17:53:02.111] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthAuthenticated
I/flutter ( 6465): [17:53:02.111] 🔍 DEBUG [BlocObserver]   NextState: AppAuthAuthenticated
I/flutter ( 6465): [17:53:02.111] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:02.111] 🔍 DEBUG [BlocObserver]   From: AppAuthAuthenticated
D/InputTransport( 6465): Input channel constructed: 'ClientS', fd=228
I/flutter ( 6465): [17:53:02.111] 🔍 DEBUG [BlocObserver]   To: AppAuthAuthenticated
I/flutter ( 6465): [17:53:02.112] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthAuthenticatted, isAppAuthenticated=true, isOnAppLogin=false
I/flutter ( 6465): [17:53:02.112] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/InputMethodManager( 6465): handleMessage: setImeVisibility visible=false
D/InsetsController( 6465): hide(ime(), fromIme=false)
I/ImeTracker( 6465): com.example.hsmik:918b949: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
D/Sentry  ( 6465): Envelope sent successfully.
D/Sentry  ( 6465): Discarding envelope from cache: /data/user/0/com.example.hsmik/cache/sentry/5c1a219bd82a6489bb31859005155424db92b7f5/22a066f4-2638-425d-88de-b17dc168afb1.envelope
D/Sentry  ( 6465): Envelope flushed
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@bdf53f5
I/flutter ( 6465): [17:53:06.503] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> LogoutRequested
I/flutter ( 6465): [17:53:06.503] 🔍 DEBUG [BlocObserver]   Event details: LogoutRequested()
I/flutter ( 6465): [17:53:06.507] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:06.507] 🔍 DEBUG [BlocObserver]   Event: LogoutRequested
I/flutter ( 6465): [17:53:06.507] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthAuthenticated
I/flutter ( 6465): [17:53:06.507] 🔍 DEBUG [BlocObserver]   NextState: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:06.507] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:06.507] 🔍 DEBUG [BlocObserver]   From: AppAuthAuthenticated
I/flutter ( 6465): [17:53:06.508] 🔍 DEBUG [BlocObserver]   To: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:06.508] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthUnauthenticcated, isAppAuthenticated=false, isOnAppLogin=false
I/flutter ( 6465): [17:53:06.508] ℹ️ INFO [AppRouter] Redirecting to AppLogin
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
I/flutter ( 6465): [17:53:06.983] 🔍 DEBUG [BlocObserver] onClose: SettingsCubit
I/flutter ( 6465): [17:53:07.553] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> BiometricLoginRequested
I/flutter ( 6465): [17:53:07.554] 🔍 DEBUG [BlocObserver]   Event details: BiometricLoginRequested()
I/flutter ( 6465): [17:53:07.556] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:07.556] 🔍 DEBUG [BlocObserver]   Event: BiometricLoginRequested
I/flutter ( 6465): [17:53:07.556] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:07.556] 🔍 DEBUG [BlocObserver]   NextState: AppAuthLoading
I/flutter ( 6465): [17:53:07.556] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:07.557] 🔍 DEBUG [BlocObserver]   From: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:07.557] 🔍 DEBUG [BlocObserver]   To: AppAuthLoading
I/flutter ( 6465): [17:53:07.557] ℹ️ INFO [GetCurrentUserUseCase] GetCurrentUserUseCase: START
I/flutter ( 6465): [17:53:07.557] ℹ️ INFO [AppAuthRepository] getLoggedInUser: calling localDataSource     
I/flutter ( 6465): [17:53:07.557] ℹ️ INFO [AppAuthLocalDataSource] getLoggedInUser: START
I/flutter ( 6465): [17:53:07.558] ℹ️ INFO [AppAuthLocalDataSource] getLoggedInUser: session userId = null  
I/flutter ( 6465): [17:53:07.558] ℹ️ INFO [AppAuthLocalDataSource] No session user id found
I/flutter ( 6465): [17:53:07.558] ℹ️ INFO [AppRouter] Redirect check: matched=/app-login, appAuth=AppAuthLooading, isAppAuthenticated=false, isOnAppLogin=true
I/flutter ( 6465): [17:53:07.559] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/flutter ( 6465): [17:53:07.559] ℹ️ INFO [AppAuthRepository] getLoggedInUser: localDataSource returned useer=false
I/flutter ( 6465): [17:53:07.559] ℹ️ INFO [GetCurrentUserUseCase] GetCurrentUserUseCase: returned user=falsse
I/flutter ( 6465): [17:53:07.560] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:07.560] 🔍 DEBUG [BlocObserver]   Event: BiometricLoginRequested
I/flutter ( 6465): [17:53:07.560] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthLoading
I/flutter ( 6465): [17:53:07.560] 🔍 DEBUG [BlocObserver]   NextState: AppAuthError
I/flutter ( 6465): [17:53:07.560] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:07.561] 🔍 DEBUG [BlocObserver]   From: AppAuthLoading
I/flutter ( 6465): [17:53:07.561] 🔍 DEBUG [BlocObserver]   To: AppAuthError
I/flutter ( 6465): [17:53:07.561] ℹ️ INFO [AppRouter] Redirect check: matched=/app-login, appAuth=AppAuthErrror, isAppAuthenticated=false, isOnAppLogin=true
I/flutter ( 6465): [17:53:07.561] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@bdf53f5
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@bdf53f5
I/InputMethodManager_LC( 6465): showSoftInput(View,I)
I/ImeTracker( 6465): com.example.hsmik:bc46a023: onRequestShow at ORIGIN_CLIENT reason SHOW_SOFT_INPUT fromUser false
I/InputMethodManager_LC( 6465): ssi(): flags=0 view=com.example.hsmik reason=SHOW_SOFT_INPUT
I/InputMethodManager_LC( 6465): ssi() view is not EditText
D/InputMethodManagerUtils( 6465): startInputInner - Id : 0
I/InputMethodManager( 6465): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
D/InsetsController( 6465): show(ime(), fromIme=false)
D/InsetsController( 6465): Setting requestedVisibleTypes to -1 (was -9)
I/InsetsController( 6465): setRequestedVisibleTypes: visible=true, mask=ime, host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.InsetsController.controlAnimationUnchecked:1604 android.view.InsetsController.applyAnimation:2416 android.view.InsetsController.applyAnimation:2343 android.view.InsetsController.show:1422 android.view.inputmethod.InputMethodManager.showSoftInput:2659 android.view.inputmethod.InputMethodManager.showSoftInput:2571 android.view.inputmethod.InputMethodManager.showSoftInput:2563 android.view.inputmethod.InputMethodManager.showSoftInput:2491 io.flutter.plugin.editing.TextInputPlugin.showTextInput:433 io.flutter.plugin.editing.TextInputPlugin$2.show:114
D/InputTransport( 6465): Input channel constructed: 'ClientS', fd=186
I/VRI[MainActivity]@bdf53f5( 6465): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3120] display=[0,0][1440,3120] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
D/InputConnectionAdaptor( 6465): The input method toggled cursor monitoring on
I/InsetsController( 6465): onStateChanged: host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.ViewRootImpl.onInsetsStateChanged:3026, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1440, 3120), mDisplayCutout=DisplayCutout{insets=Rect(0, 113 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(685, 0 - 755, 113), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=1440 displayHeight=3120 physicalDisplayWidth=1440 physicalDisplayHeight=3120 density={3.75} cutoutSpec={M 0,0 H -9.333333333333333 V 30.13333333333333 H 9.333333333333333 V 0 H 0 Z @dp} rotation={0} scale={1.0} physicalPixelDisplaySizeRatio={1.0}}} sideOverrides={}}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=56, center=Point(56, 56)}, RoundedCorner{position=TopRight, radius=56, center=Point(1384, 56)}, RoundedCorner{position=BottomRight, radius=56, center=Point(1384, 3064)}, RoundedCorner{position=BottomLeft, radius=56, center=Point(56, 3064)}]}  mRoundedCornerFrame=Rect(0, 0 - 1440, 3120), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1275, 0 - 1440, 113) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1440 displayHeight=3120 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {3 mType=ime mFrame=[0,0][0,0] mVisible=false mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {27 mType=displayCutout mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {192a0001 mType=navigationBars mFrame=[0,3064][1440,3120] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0004 mType=systemGestures mFrame=[0,0][112,3120] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {192a0005 mType=mandatorySystemGestures mFrame=[0,3000][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {192a0024 mType=systemGestures mFrame=[1328,0][1440,3120] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {6d840000 mType=statusBars mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840005 mType=mandatorySystemGestures mFrame=[0,0][1440,158] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840006 mType=tappableElement mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }
I/VRI[MainActivity]@bdf53f5( 6465): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3120] display=[0,0][1440,3120] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
I/InsetsController( 6465): onStateChanged: host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.ViewRootImpl.onInsetsStateChanged:3026, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1440, 3120), mDisplayCutout=DisplayCutout{insets=Rect(0, 113 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(685, 0 - 755, 113), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=1440 displayHeight=3120 physicalDisplayWidth=1440 physicalDisplayHeight=3120 density={3.75} cutoutSpec={M 0,0 H -9.333333333333333 V 30.13333333333333 H 9.333333333333333 V 0 H 0 Z @dp} rotation={0} scale={1.0} physicalPixelDisplaySizeRatio={1.0}}} sideOverrides={}}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=56, center=Point(56, 56)}, RoundedCorner{position=TopRight, radius=56, center=Point(1384, 56)}, RoundedCorner{position=BottomRight, radius=56, center=Point(1384, 3064)}, RoundedCorner{position=BottomLeft, radius=56, center=Point(56, 3064)}]}  mRoundedCornerFrame=Rect(0, 0 - 1440, 3120), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1275, 0 - 1440, 113) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1440 displayHeight=3120 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {3 mType=ime mFrame=[0,1984][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {27 mType=displayCutout mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {192a0001 mType=navigationBars mFrame=[0,3064][1440,3120] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0004 mType=systemGestures mFrame=[0,0][112,3120] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {192a0005 mType=mandatorySystemGestures mFrame=[0,3000][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {192a0024 mType=systemGestures mFrame=[1328,0][1440,3120] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {6d840000 mType=statusBars mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840005 mType=mandatorySystemGestures mFrame=[0,0][1440,158] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840006 mType=tappableElement mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }     
I/VRI[MainActivity]@bdf53f5( 6465): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3120] display=[0,0][1440,3120] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
I/InsetsController( 6465): onStateChanged: host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.ViewRootImpl.onInsetsStateChanged:3026, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1440, 3120), mDisplayCutout=DisplayCutout{insets=Rect(0, 113 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(685, 0 - 755, 113), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=1440 displayHeight=3120 physicalDisplayWidth=1440 physicalDisplayHeight=3120 density={3.75} cutoutSpec={M 0,0 H -9.333333333333333 V 30.13333333333333 H 9.333333333333333 V 0 H 0 Z @dp} rotation={0} scale={1.0} physicalPixelDisplaySizeRatio={1.0}}} sideOverrides={}}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=56, center=Point(56, 56)}, RoundedCorner{position=TopRight, radius=56, center=Point(1384, 56)}, RoundedCorner{position=BottomRight, radius=56, center=Point(1384, 3064)}, RoundedCorner{position=BottomLeft, radius=56, center=Point(56, 3064)}]}  mRoundedCornerFrame=Rect(0, 0 - 1440, 3120), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1275, 0 - 1440, 113) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1440 displayHeight=3120 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {3 mType=ime mFrame=[0,1984][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {27 mType=displayCutout mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {192a0001 mType=navigationBars mFrame=[0,3064][1440,3120] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0004 mType=systemGestures mFrame=[0,0][112,3120] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {192a0005 mType=mandatorySystemGestures mFrame=[0,3000][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {192a0024 mType=systemGestures mFrame=[1328,0][1440,3120] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {6d840000 mType=statusBars mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840005 mType=mandatorySystemGestures mFrame=[0,0][1440,158] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840006 mType=tappableElement mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }     
I/InsetsController( 6465): controlAnimationUncheckedInner: Added types=ime, animType=0, host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.InsetsController.controlAnimationUnchecked:1608 android.view.InsetsController.applyAnimation:2416 android.view.InsetsController.applyAnimation:2343
I/BLASTBufferQueue_Java( 6465): update, w= 1440 h= 3120 mName = VRI[MainActivity]@bdf53f5 mNativeObject= 0xb4000078bd25d460 sc.mNativeObject= 0xb40000791d235a10 format= -3 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3574 android.view.ViewRootImpl.relayoutWindow:11685 android.view.ViewRootImpl.performTraversals:4804 android.view.ViewRootImpl.doTraversal:3924 android.view.ViewRootImpl$TraversalRunnable.run:12903 android.view.Choreographer$CallbackRecord.run:1901
I/VRI[MainActivity]@bdf53f5( 6465): Relayout returned: old=(0,0,1440,3120) new=(0,0,1440,3120) relayoutAsync=true req=(1440,3120)0 dur=0 res=0x0 s={true 0xb40000789d250dc0} ch=false seqId=0
W/InteractionJankMonitor( 6465): Initializing without READ_DEVICE_CONFIG permission. enabled=false, interval=1, missedFrameThreshold=3, frameTimeThreshold=64, package=com.example.hsmik
I/VRI[MainActivity]@bdf53f5( 6465): registerCallbackForPendingTransactions
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed260450 mBlastBufferQueue=0xb4000078bd25d460 fn= 3 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed256c10 mBlastBufferQueue=0xb4000078bd25d460 fn= 3 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$10.onFrameDraw:6536 android.view.ViewRootImpl$4.onFrameDraw:2489 android.view.ThreadedRenderer$1.onFrameDraw:718
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2256d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 4 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29d690 mBlastBufferQueue=0xb4000078bd25d460 fn= 5 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2925d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 6 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25df90 mBlastBufferQueue=0xb4000078bd25d460 fn= 7 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25e4d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 8 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25ef50 mBlastBufferQueue=0xb4000078bd25d460 fn= 9 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29f610 mBlastBufferQueue=0xb4000078bd25d460 fn= 10 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed24b990 mBlastBufferQueue=0xb4000078bd25d460 fn= 11 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed24b990 mBlastBufferQueue=0xb4000078bd25d460 fn= 12 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed247710 mBlastBufferQueue=0xb4000078bd25d460 fn= 13 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed24b990 mBlastBufferQueue=0xb4000078bd25d460 fn= 14 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29f610 mBlastBufferQueue=0xb4000078bd25d460 fn= 15 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2925d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 16 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25ef50 mBlastBufferQueue=0xb4000078bd25d460 fn= 17 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25df90 mBlastBufferQueue=0xb4000078bd25d460 fn= 18 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed260450 mBlastBufferQueue=0xb4000078bd25d460 fn= 19 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28c3d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 20 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28bcd0 mBlastBufferQueue=0xb4000078bd25d460 fn= 21 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28b410 mBlastBufferQueue=0xb4000078bd25d460 fn= 22 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28c590 mBlastBufferQueue=0xb4000078bd25d460 fn= 23 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28ab50 mBlastBufferQueue=0xb4000078bd25d460 fn= 24 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28da90 mBlastBufferQueue=0xb4000078bd25d460 fn= 25 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28cc90 mBlastBufferQueue=0xb4000078bd25d460 fn= 26 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28f4d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 27 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2941d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 28 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed295350 mBlastBufferQueue=0xb4000078bd25d460 fn= 29 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29e490 mBlastBufferQueue=0xb4000078bd25d460 fn= 30 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2574d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 31 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25a950 mBlastBufferQueue=0xb4000078bd25d460 fn= 32 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed292790 mBlastBufferQueue=0xb4000078bd25d460 fn= 33 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28bb10 mBlastBufferQueue=0xb4000078bd25d460 fn= 34 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed292b10 mBlastBufferQueue=0xb4000078bd25d460 fn= 35 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29f610 mBlastBufferQueue=0xb4000078bd25d460 fn= 36 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29d310 mBlastBufferQueue=0xb4000078bd25d460 fn= 37 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a0410 mBlastBufferQueue=0xb4000078bd25d460 fn= 38 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a1210 mBlastBufferQueue=0xb4000078bd25d460 fn= 39 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29e9d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 40 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a0e90 mBlastBufferQueue=0xb4000078bd25d460 fn= 41 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a1c90 mBlastBufferQueue=0xb4000078bd25d460 fn= 42 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2607d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 43 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28f150 mBlastBufferQueue=0xb4000078bd25d460 fn= 44 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed26b510 mBlastBufferQueue=0xb4000078bd25d460 fn= 45 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25b910 mBlastBufferQueue=0xb4000078bd25d460 fn= 46 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/InsetsController( 6465): cancelAnimation: types=ime, animType=0, host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.InsetsController.notifyFinished:2006 android.view.InsetsAnimationControlImpl.applyChangeInsets:335 android.view.InsetsController.lambda$new$3:957
I/ImeTracker( 6465): com.example.hsmik:bc46a023: onShown
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29fb50 mBlastBufferQueue=0xb4000078bd25d460 fn= 47 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
D/InputMethodManagerUtils( 6465): startInputInner - Id : 0
I/InputMethodManager( 6465): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/InputMethodManager_LC( 6465): showSoftInput(View,I)
I/ImeTracker( 6465): com.example.hsmik:9806c7d1: onRequestShow at ORIGIN_CLIENT reason SHOW_SOFT_INPUT fromUser false
I/InputMethodManager_LC( 6465): ssi(): flags=0 view=com.example.hsmik reason=SHOW_SOFT_INPUT
I/InputMethodManager_LC( 6465): ssi() view is not EditText
D/InsetsController( 6465): show(ime(), fromIme=false)
I/ImeTracker( 6465): com.example.hsmik:9806c7d1: onCancelled at PHASE_CLIENT_APPLY_ANIMATION
D/InputTransport( 6465): Input channel constructed: 'ClientS', fd=242
D/InputConnectionAdaptor( 6465): The input method toggled cursor monitoring on
D/InputConnectionAdaptor( 6465): The input method toggled cursor monitoring off
D/InputConnectionAdaptor( 6465): The input method toggled cursor monitoring on
I/InsetsController( 6465): onStateChanged: host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.ViewRootImpl.onInsetsStateChanged:3026, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1440, 3120), mDisplayCutout=DisplayCutout{insets=Rect(0, 113 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(685, 0 - 755, 113), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=1440 displayHeight=3120 physicalDisplayWidth=1440 physicalDisplayHeight=3120 density={3.75} cutoutSpec={M 0,0 H -9.333333333333333 V 30.13333333333333 H 9.333333333333333 V 0 H 0 Z @dp} rotation={0} scale={1.0} physicalPixelDisplaySizeRatio={1.0}}} sideOverrides={}}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=56, center=Point(56, 56)}, RoundedCorner{position=TopRight, radius=56, center=Point(1384, 56)}, RoundedCorner{position=BottomRight, radius=56, center=Point(1384, 3064)}, RoundedCorner{position=BottomLeft, radius=56, center=Point(56, 3064)}]}  mRoundedCornerFrame=Rect(0, 0 - 1440, 3120), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1275, 0 - 1440, 113) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1440 displayHeight=3120 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {3 mType=ime mFrame=[0,1830][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {27 mType=displayCutout mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {192a0001 mType=navigationBars mFrame=[0,3064][1440,3120] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0004 mType=systemGestures mFrame=[0,0][112,3120] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {192a0005 mType=mandatorySystemGestures mFrame=[0,3000][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {192a0024 mType=systemGestures mFrame=[1328,0][1440,3120] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {6d840000 mType=statusBars mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840005 mType=mandatorySystemGestures mFrame=[0,0][1440,158] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840006 mType=tappableElement mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }     
I/VRI[MainActivity]@bdf53f5( 6465): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3120] display=[0,0][1440,3120] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@bdf53f5
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@bdf53f5
I/flutter ( 6465): [17:53:23.093] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> LoginRequested
I/flutter ( 6465): [17:53:23.094] 🔍 DEBUG [BlocObserver]   Event details: LoginRequested(admin, M@12321)
I/flutter ( 6465): [17:53:23.095] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:23.095] 🔍 DEBUG [BlocObserver]   Event: LoginRequested
I/flutter ( 6465): [17:53:23.096] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthError
I/flutter ( 6465): [17:53:23.096] 🔍 DEBUG [BlocObserver]   NextState: AppAuthLoading
I/flutter ( 6465): [17:53:23.096] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:23.096] 🔍 DEBUG [BlocObserver]   From: AppAuthError
I/flutter ( 6465): [17:53:23.096] 🔍 DEBUG [BlocObserver]   To: AppAuthLoading
I/flutter ( 6465): [17:53:23.105] ℹ️ INFO [AppRouter] Redirect check: matched=/app-login, appAuth=AppAuthLooading, isAppAuthenticated=false, isOnAppLogin=true
I/flutter ( 6465): [17:53:23.105] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/flutter ( 6465): [17:53:23.125] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:23.126] 🔍 DEBUG [BlocObserver]   Event: LoginRequested
I/flutter ( 6465): [17:53:23.126] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthLoading
I/flutter ( 6465): [17:53:23.126] 🔍 DEBUG [BlocObserver]   NextState: AppAuthAuthenticated
I/flutter ( 6465): [17:53:23.126] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:23.126] 🔍 DEBUG [BlocObserver]   From: AppAuthLoading
I/flutter ( 6465): [17:53:23.126] 🔍 DEBUG [BlocObserver]   To: AppAuthAuthenticated
I/flutter ( 6465): [17:53:23.127] ℹ️ INFO [AppRouter] Redirect check: matched=/app-login, appAuth=AppAuthAuuthenticated, isAppAuthenticated=true, isOnAppLogin=true
I/flutter ( 6465): [17:53:23.127] ℹ️ INFO [AppRouter] Authenticated and on app login - redirect to home    
I/flutter ( 6465): [17:53:23.127] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthAuthenticatted, isAppAuthenticated=true, isOnAppLogin=false
I/flutter ( 6465): [17:53:23.128] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/ImeTracker( 6465): com.example.hsmik:4653990d: onRequestHide at ORIGIN_CLIENT reason HIDE_SOFT_INPUT fromUser false
I/InputMethodManager_LC( 6465): hsifw() - flag : 0
I/InputMethodManager_LC( 6465): hsifw() - mService.hideSoftInput
D/InsetsController( 6465): hide(ime(), fromIme=false)
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=android.view.ImeBackAnimationController@cfea249
D/InsetsController( 6465): Setting requestedVisibleTypes to -9 (was -1)
I/InsetsController( 6465): setRequestedVisibleTypes: visible=false, mask=ime, host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.InsetsController.controlAnimationUnchecked:1604 android.view.InsetsController.applyAnimation:2416 android.view.InsetsController.applyAnimation:2343 android.view.InsetsController.hide:1540 android.view.inputmethod.InputMethodManager.hideSoftInputFromWindow:2889 android.view.inputmethod.InputMethodManager.hideSoftInputFromWindow:2812 android.view.inputmethod.InputMethodManager.hideSoftInputFromWindow:2773 io.flutter.plugin.editing.TextInputPlugin.hideTextInput:447 io.flutter.plugin.editing.TextInputPlugin.access$400:44 io.flutter.plugin.editing.TextInputPlugin$2.hide:122
I/InsetsController( 6465): controlAnimationUncheckedInner: Added types=ime, animType=1, host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.InsetsController.controlAnimationUnchecked:1608 android.view.InsetsController.applyAnimation:2416 android.view.InsetsController.applyAnimation:2343
D/CompatChangeReporter( 6465): Compat change id reported: 395521150; UID 10528; state: ENABLED
I/BLASTBufferQueue_Java( 6465): update, w= 1440 h= 3120 mName = VRI[MainActivity]@bdf53f5 mNativeObject= 0xb4000078bd25d460 sc.mNativeObject= 0xb40000791d235a10 format= -3 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3574 android.view.ViewRootImpl.relayoutWindow:11685 android.view.ViewRootImpl.performTraversals:4804 android.view.ViewRootImpl.doTraversal:3924 android.view.ViewRootImpl$TraversalRunnable.run:12903 android.view.Choreographer$CallbackRecord.run:1901
I/VRI[MainActivity]@bdf53f5( 6465): Relayout returned: old=(0,0,1440,3120) new=(0,0,1440,3120) relayoutAsync=true req=(1440,3120)0 dur=0 res=0x0 s={true 0xb40000789d250dc0} ch=false seqId=0
I/VRI[MainActivity]@bdf53f5( 6465): registerCallbackForPendingTransactions
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29fb50 mBlastBufferQueue=0xb4000078bd25d460 fn= 48 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed26b510 mBlastBufferQueue=0xb4000078bd25d460 fn= 48 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$10.onFrameDraw:6536 android.view.ViewRootImpl$4.onFrameDraw:2489 android.view.ThreadedRenderer$1.onFrameDraw:718
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28f150 mBlastBufferQueue=0xb4000078bd25d460 fn= 49 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25b910 mBlastBufferQueue=0xb4000078bd25d460 fn= 50 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25c010 mBlastBufferQueue=0xb4000078bd25d460 fn= 51 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed262050 mBlastBufferQueue=0xb4000078bd25d460 fn= 52 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29d4d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 53 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed262e50 mBlastBufferQueue=0xb4000078bd25d460 fn= 54 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed245090 mBlastBufferQueue=0xb4000078bd25d460 fn= 55 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed258490 mBlastBufferQueue=0xb4000078bd25d460 fn= 56 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2589d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 57 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28d550 mBlastBufferQueue=0xb4000078bd25d460 fn= 58 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28b950 mBlastBufferQueue=0xb4000078bd25d460 fn= 59 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28ff50 mBlastBufferQueue=0xb4000078bd25d460 fn= 60 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25df90 mBlastBufferQueue=0xb4000078bd25d460 fn= 61 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29a910 mBlastBufferQueue=0xb4000078bd25d460 fn= 62 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25e4d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 63 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a1750 mBlastBufferQueue=0xb4000078bd25d460 fn= 64 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed261250 mBlastBufferQueue=0xb4000078bd25d460 fn= 65 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a2710 mBlastBufferQueue=0xb4000078bd25d460 fn= 66 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29dd90 mBlastBufferQueue=0xb4000078bd25d460 fn= 67 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a1e50 mBlastBufferQueue=0xb4000078bd25d460 fn= 68 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a0b10 mBlastBufferQueue=0xb4000078bd25d460 fn= 69 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a0250 mBlastBufferQueue=0xb4000078bd25d460 fn= 70 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29e110 mBlastBufferQueue=0xb4000078bd25d460 fn= 71 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29e2d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 72 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a21d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 73 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25ff10 mBlastBufferQueue=0xb4000078bd25d460 fn= 74 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed25e4d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 75 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29a910 mBlastBufferQueue=0xb4000078bd25d460 fn= 76 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28ff50 mBlastBufferQueue=0xb4000078bd25d460 fn= 77 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed28b950 mBlastBufferQueue=0xb4000078bd25d460 fn= 78 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2589d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 79 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed245090 mBlastBufferQueue=0xb4000078bd25d460 fn= 80 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed29d4d0 mBlastBufferQueue=0xb4000078bd25d460 fn= 81 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed257850 mBlastBufferQueue=0xb4000078bd25d460 fn= 82 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
I/InsetsController( 6465): cancelAnimation: types=ime, animType=1, host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.InsetsController.notifyFinished:2006 android.view.InsetsAnimationControlImpl.applyChangeInsets:335 android.view.InsetsController.lambda$new$3:957
D/InputMethodManagerUtils( 6465): startInputInner - Id : 0
I/InputMethodManager( 6465): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a0250 mBlastBufferQueue=0xb4000078bd25d460 fn= 83 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
D/InputTransport( 6465): Input channel constructed: 'ClientS', fd=192
I/InsetsController( 6465): onStateChanged: host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.ViewRootImpl.onInsetsStateChanged:3026, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1440, 3120), mDisplayCutout=DisplayCutout{insets=Rect(0, 113 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(685, 0 - 755, 113), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=1440 displayHeight=3120 physicalDisplayWidth=1440 physicalDisplayHeight=3120 density={3.75} cutoutSpec={M 0,0 H -9.333333333333333 V 30.13333333333333 H 9.333333333333333 V 0 H 0 Z @dp} rotation={0} scale={1.0} physicalPixelDisplaySizeRatio={1.0}}} sideOverrides={}}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=56, center=Point(56, 56)}, RoundedCorner{position=TopRight, radius=56, center=Point(1384, 56)}, RoundedCorner{position=BottomRight, radius=56, center=Point(1384, 3064)}, RoundedCorner{position=BottomLeft, radius=56, center=Point(56, 3064)}]}  mRoundedCornerFrame=Rect(0, 0 - 1440, 3120), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1275, 0 - 1440, 113) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1440 displayHeight=3120 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {3 mType=ime mFrame=[0,1830][1440,3120] mVisible=false mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {27 mType=displayCutout mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {192a0001 mType=navigationBars mFrame=[0,3064][1440,3120] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0004 mType=systemGestures mFrame=[0,0][112,3120] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {192a0005 mType=mandatorySystemGestures mFrame=[0,3000][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {192a0024 mType=systemGestures mFrame=[1328,0][1440,3120] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {6d840000 mType=statusBars mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840005 mType=mandatorySystemGestures mFrame=[0,0][1440,158] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840006 mType=tappableElement mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }    
I/VRI[MainActivity]@bdf53f5( 6465): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3120] display=[0,0][1440,3120] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
I/InsetsSourceConsumer( 6465): applyRequestedVisibilityToControl: visible=false, type=ime, host=com.example.hsmik/com.example.hsmik.MainActivity
I/InsetsSourceConsumer( 6465): applyRequestedVisibilityToControl: visible=true, type=navigationBars, host=com.example.hsmik/com.example.hsmik.MainActivity
I/ImeTracker( 6465): system_server:5de9c986: onCancelled at PHASE_CLIENT_ON_CONTROLS_CHANGED
I/VRI[MainActivity]@bdf53f5( 6465): mWNT: t=0xb4000078ed2a0b10 mBlastBufferQueue=0xb4000078bd25d460 fn= 84 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SyncRtSurfaceTransactionApplier.applyTransaction:100 android.view.SyncRtSurfaceTransactionApplier.lambda$scheduleApply$0:73 android.view.SyncRtSurfaceTransactionApplier.$r8$lambda$afI4fXg3U3-nBZQEDQMiNy-B06s:0
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
I/InsetsController( 6465): onStateChanged: host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.ViewRootImpl.onInsetsStateChanged:3026, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1440, 3120), mDisplayCutout=DisplayCutout{insets=Rect(0, 113 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(685, 0 - 755, 113), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=1440 displayHeight=3120 physicalDisplayWidth=1440 physicalDisplayHeight=3120 density={3.75} cutoutSpec={M 0,0 H -9.333333333333333 V 30.13333333333333 H 9.333333333333333 V 0 H 0 Z @dp} rotation={0} scale={1.0} physicalPixelDisplaySizeRatio={1.0}}} sideOverrides={}}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=56, center=Point(56, 56)}, RoundedCorner{position=TopRight, radius=56, center=Point(1384, 56)}, RoundedCorner{position=BottomRight, radius=56, center=Point(1384, 3064)}, RoundedCorner{position=BottomLeft, radius=56, center=Point(56, 3064)}]}  mRoundedCornerFrame=Rect(0, 0 - 1440, 3120), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1275, 0 - 1440, 113) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1440 displayHeight=3120 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {3 mType=ime mFrame=[0,0][0,0] mVisible=false mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {27 mType=displayCutout mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {192a0001 mType=navigationBars mFrame=[0,3064][1440,3120] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0004 mType=systemGestures mFrame=[0,0][112,3120] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {192a0005 mType=mandatorySystemGestures mFrame=[0,3000][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {192a0024 mType=systemGestures mFrame=[1328,0][1440,3120] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {6d840000 mType=statusBars mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840005 mType=mandatorySystemGestures mFrame=[0,0][1440,158] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840006 mType=tappableElement mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }
I/VRI[MainActivity]@bdf53f5( 6465): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3120] display=[0,0][1440,3120] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
I/InsetsController( 6465): onStateChanged: host=com.example.hsmik/com.example.hsmik.MainActivity, from=android.view.ViewRootImpl.onInsetsStateChanged:3026, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1440, 3120), mDisplayCutout=DisplayCutout{insets=Rect(0, 113 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(685, 0 - 755, 113), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=1440 displayHeight=3120 physicalDisplayWidth=1440 physicalDisplayHeight=3120 density={3.75} cutoutSpec={M 0,0 H -9.333333333333333 V 30.13333333333333 H 9.333333333333333 V 0 H 0 Z @dp} rotation={0} scale={1.0} physicalPixelDisplaySizeRatio={1.0}}} sideOverrides={}}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=56, center=Point(56, 56)}, RoundedCorner{position=TopRight, radius=56, center=Point(1384, 56)}, RoundedCorner{position=BottomRight, radius=56, center=Point(1384, 3064)}, RoundedCorner{position=BottomLeft, radius=56, center=Point(56, 3064)}]}  mRoundedCornerFrame=Rect(0, 0 - 1440, 3120), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1275, 0 - 1440, 113) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1440 displayHeight=3120 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {3 mType=ime mFrame=[0,0][0,0] mVisible=false mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {27 mType=displayCutout mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {192a0001 mType=navigationBars mFrame=[0,3064][1440,3120] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0004 mType=systemGestures mFrame=[0,0][112,3120] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {192a0005 mType=mandatorySystemGestures mFrame=[0,3000][1440,3120] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {192a0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {192a0024 mType=systemGestures mFrame=[1328,0][1440,3120] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {6d840000 mType=statusBars mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840005 mType=mandatorySystemGestures mFrame=[0,0][1440,158] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {6d840006 mType=tappableElement mFrame=[0,0][1440,113] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }
I/VRI[MainActivity]@bdf53f5( 6465): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3120] display=[0,0][1440,3120] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
I/flutter ( 6465): [17:53:24.704] ℹ️ INFO [AppRouter] Redirect check: matched=/settings, appAuth=AppAuthAutthenticated, isAppAuthenticated=true, isOnAppLogin=false
I/flutter ( 6465): [17:53:24.704] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/flutter ( 6465): [17:53:24.709] 🔍 DEBUG [BlocObserver] onCreate: SettingsCubit
I/flutter ( 6465): [17:53:24.740] ℹ️ INFO [BlocObserver] onChange: SettingsCubit
I/flutter ( 6465): [17:53:24.740] 🔍 DEBUG [BlocObserver]   From: SettingsState
I/flutter ( 6465): [17:53:24.740] 🔍 DEBUG [BlocObserver]   To: SettingsState
I/flutter ( 6465): [17:53:25.978] ℹ️ INFO [SettingsPage] Checking biometric capability
I/flutter ( 6465): [17:53:25.986] ℹ️ INFO [SettingsPage] canCheckBiometrics=true isSupported=true
I/flutter ( 6465): [17:53:25.989] ℹ️ INFO [SettingsPage] Starting biometric authentication
I/ImeFocusController( 6465): onPreWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
I/ImeFocusController( 6465): onPostWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
D/InputTransport( 6465): Input channel destroyed: 'ClientS', fd=228
I/BiometricPrompt( 6465): onAuthenticationSucceeded: 2
I/flutter ( 6465): [17:53:27.380] ℹ️ INFO [SettingsPage] Biometric authenticate result: true
I/flutter ( 6465): [17:53:27.382] ℹ️ INFO [SettingsPage] Persisting biometric setting: true
I/flutter ( 6465): [17:53:27.392] ℹ️ INFO [BlocObserver] onChange: SettingsCubit
I/flutter ( 6465): [17:53:27.392] 🔍 DEBUG [BlocObserver]   From: SettingsState
I/flutter ( 6465): [17:53:27.392] 🔍 DEBUG [BlocObserver]   To: SettingsState
I/flutter ( 6465): [17:53:27.392] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> BiometricToggleRequested  
I/flutter ( 6465): [17:53:27.393] 🔍 DEBUG [BlocObserver]   Event details: BiometricToggleRequested(true)  
I/flutter ( 6465): [17:53:27.393] ℹ️ INFO [AppAuthBloc] BiometricToggleRequested received: enable=true for  user=admin_default
I/flutter ( 6465): [17:53:27.393] ℹ️ INFO [AppAuthRepository] Enabling biometric for user: admin_default   
I/flutter ( 6465): [17:53:27.395] ℹ️ INFO [AppAuthRepository] Enabled biometric for user: admin_default    
I/flutter ( 6465): [17:53:27.395] ℹ️ INFO [AppAuthBloc] Biometric toggle succeeded for user=admin_default:  enable=true
I/InsetsSourceConsumer( 6465): applyRequestedVisibilityToControl: visible=true, type=statusBars, host=com.example.hsmik/com.example.hsmik.MainActivity
I/InsetsSourceConsumer( 6465): applyRequestedVisibilityToControl: visible=true, type=navigationBars, host=com.example.hsmik/com.example.hsmik.MainActivity
D/VRI[MainActivity]@bdf53f5( 6465): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb40000789d250dc0}
D/InputMethodManagerUtils( 6465): startInputInner - Id : 0
I/InputMethodManager( 6465): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/InputMethodManager( 6465): handleMessage: setImeVisibility visible=false
D/InsetsController( 6465): hide(ime(), fromIme=false)
I/ImeTracker( 6465): com.example.hsmik:e41e3be5: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN
D/InputTransport( 6465): Input channel constructed: 'ClientS', fd=252
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@bdf53f5
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@bdf53f5
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
I/flutter ( 6465): [17:53:35.134] 🔍 DEBUG [BlocObserver] onClose: SettingsCubit
I/flutter ( 6465): [17:53:36.351] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> LogoutRequested
I/flutter ( 6465): [17:53:36.352] 🔍 DEBUG [BlocObserver]   Event details: LogoutRequested()
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
I/flutter ( 6465): [17:53:36.362] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:36.362] 🔍 DEBUG [BlocObserver]   Event: LogoutRequested
I/flutter ( 6465): [17:53:36.362] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthAuthenticated
I/flutter ( 6465): [17:53:36.363] 🔍 DEBUG [BlocObserver]   NextState: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:36.363] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:36.363] 🔍 DEBUG [BlocObserver]   From: AppAuthAuthenticated
I/flutter ( 6465): [17:53:36.363] 🔍 DEBUG [BlocObserver]   To: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:36.364] ℹ️ INFO [AppRouter] Redirect check: matched=/, appAuth=AppAuthUnauthenticcated, isAppAuthenticated=false, isOnAppLogin=false
I/flutter ( 6465): [17:53:36.364] ℹ️ INFO [AppRouter] Redirecting to AppLogin
W/WindowOnBackDispatcher( 6465): sendCancelIfRunning: isInProgress=false callback=androidx.activity.OnBackPressedDispatcher$Api34Impl$createOnBackAnimationCallback$1@adfaa83
I/flutter ( 6465): [17:53:37.639] ℹ️ INFO [BlocObserver] onEvent: AppAuthBloc -> BiometricLoginRequested
I/flutter ( 6465): [17:53:37.640] 🔍 DEBUG [BlocObserver]   Event details: BiometricLoginRequested()
I/flutter ( 6465): [17:53:37.640] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:37.641] 🔍 DEBUG [BlocObserver]   Event: BiometricLoginRequested
I/flutter ( 6465): [17:53:37.641] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:37.641] 🔍 DEBUG [BlocObserver]   NextState: AppAuthLoading
I/flutter ( 6465): [17:53:37.642] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:37.642] 🔍 DEBUG [BlocObserver]   From: AppAuthUnauthenticated
I/flutter ( 6465): [17:53:37.642] 🔍 DEBUG [BlocObserver]   To: AppAuthLoading
I/flutter ( 6465): [17:53:37.642] ℹ️ INFO [GetCurrentUserUseCase] GetCurrentUserUseCase: START
I/flutter ( 6465): [17:53:37.643] ℹ️ INFO [AppAuthRepository] getLoggedInUser: calling localDataSource     
I/flutter ( 6465): [17:53:37.643] ℹ️ INFO [AppAuthLocalDataSource] getLoggedInUser: START
I/flutter ( 6465): [17:53:37.643] ℹ️ INFO [AppAuthLocalDataSource] getLoggedInUser: session userId = null  
I/flutter ( 6465): [17:53:37.644] ℹ️ INFO [AppAuthLocalDataSource] No session user id found
I/flutter ( 6465): [17:53:37.644] ℹ️ INFO [AppRouter] Redirect check: matched=/app-login, appAuth=AppAuthLooading, isAppAuthenticated=false, isOnAppLogin=true
I/flutter ( 6465): [17:53:37.644] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/flutter ( 6465): [17:53:37.645] ℹ️ INFO [AppAuthRepository] getLoggedInUser: localDataSource returned useer=false
I/flutter ( 6465): [17:53:37.645] ℹ️ INFO [GetCurrentUserUseCase] GetCurrentUserUseCase: returned user=falsse
I/flutter ( 6465): [17:53:37.645] 🔍 DEBUG [BlocObserver] onTransition: AppAuthBloc
I/flutter ( 6465): [17:53:37.645] 🔍 DEBUG [BlocObserver]   Event: BiometricLoginRequested
I/flutter ( 6465): [17:53:37.646] 🔍 DEBUG [BlocObserver]   CurrentState: AppAuthLoading
I/flutter ( 6465): [17:53:37.646] 🔍 DEBUG [BlocObserver]   NextState: AppAuthError
I/flutter ( 6465): [17:53:37.646] ℹ️ INFO [BlocObserver] onChange: AppAuthBloc
I/flutter ( 6465): [17:53:37.646] 🔍 DEBUG [BlocObserver]   From: AppAuthLoading
I/flutter ( 6465): [17:53:37.646] 🔍 DEBUG [BlocObserver]   To: AppAuthError
I/flutter ( 6465): [17:53:37.647] ℹ️ INFO [AppRouter] Redirect check: matched=/app-login, appAuth=AppAuthErrror, isAppAuthenticated=false, isOnAppLogin=true
I/flutter ( 6465): [17:53:37.647] ℹ️ INFO [AppRouter] Router auth check: needsRouterAuth=false, authState=AAuthInitial, isRouterAuthenticated=false
I/VRI[MainActivity]@bdf53f5( 6465): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@bdf53f5
