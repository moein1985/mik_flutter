PS C:\Users\Moein\Documents\Codes\mik_flutter\mik_flutter> flutter run -d emulator-5554
Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
Running Gradle task 'assembleDebug'...                             14.7s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...        1,781ms
D/FlutterJNI( 6221): Beginning load of flutter...
D/FlutterJNI( 6221): flutter (null) was loaded normally!
I/flutter ( 6221): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
I/flutter ( 6221): [14:44:26.935] ℹ️ INFO [Main] 🚀 App starting...
I/flutter ( 6221): [14:44:26.947] ℹ️ INFO [Main] ✅ Bloc observer initialized
I/flutter ( 6221): [14:44:27.017] ℹ️ INFO [Main] ✅ Dependencies initialized
Syncing files to device sdk gphone64 x86 64...                     136ms

Flutter run key commands.
r Hot reload. 
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on sdk gphone64 x86 64 is available at: http://127.0.0.1:8964/nhkmxeSVC9Q=/
The Flutter DevTools debugger and profiler on sdk gphone64 x86 64 is available at: http://127.0.0.1:8964/nhkmxeSVC9Q=/devtools/?uri=ws://127.0.0.1:8964/nhkmxeSVC9Q=/ws
I/flutter ( 6221): [14:44:27.203] 🔍 DEBUG [BlocObserver] onCreate: AuthBloc
I/flutter ( 6221): [14:44:27.949] ℹ️ INFO [BlocObserver] onEvent: AuthBloc -> LoadSavedCredentialsRequested
I/flutter ( 6221): [14:44:27.952] 🔍 DEBUG [BlocObserver]   Event details: LoadSavedCredentialsRequested()
I/Choreographer( 6221): Skipped 140 frames!  The application may be doing too much work on its main thread.
I/WindowExtensionsImpl( 6221): Initializing Window Extensions, vendor API level=9, activity embedding enabled=true
I/m.example.hsmik( 6221): Compiler allocated 5042KB to compile void android.view.ViewRootImpl.performTraversals()
I/m.example.hsmik( 6221): AssetManager2(0x7bae3bc6db58) locale list changing from [] to [en-US]
I/Choreographer( 6221): Skipped 52 frames!  The application may be doing too much work on its main thread.
I/HWUI    ( 6221): Davey! duration=992ms; Flags=1, FrameTimelineVsyncId=50009, IntendedVsync=16733007872768, Vsync=16733874539400, InputEventId=0, HandleInputStart=16733887087100, AnimationStart=16733887105200, PerformTraversalsStart=16733887130200, DrawStart=16733901201500, FrameDeadline=16733024539434, FrameStartTime=16733886691100, FrameInterval=16666666, WorkloadTarget=16666666, SyncQueued=16733902246700, SyncStart=16733903119200, IssueDrawCommandsStart=16733903308900, SwapBuffers=16733921036300, FrameCompleted=16734000784600, DequeueBufferDuration=76966900, QueueBufferDuration=333600, GpuCompleted=16733960064400, SwapBuffersCompleted=16734000784600, DisplayPresentTime=0, CommandSubmissionCompleted=16733921036300,
D/WindowLayoutComponentImpl( 6221): Register WindowLayoutInfoListener on Context=com.example.hsmik.MainActivity@df2e77f, of which baseContext=android.app.ContextImpl@90dc28b
I/flutter ( 6221): [14:44:30.203] 🔍 DEBUG [BlocObserver] onTransition: AuthBloc
I/flutter ( 6221): [14:44:30.204] 🔍 DEBUG [BlocObserver]   Event: LoadSavedCredentialsRequested
I/flutter ( 6221): [14:44:30.206] 🔍 DEBUG [BlocObserver]   CurrentState: AuthInitial
I/flutter ( 6221): [14:44:30.206] 🔍 DEBUG [BlocObserver]   NextState: AuthUnauthenticated
I/flutter ( 6221): [14:44:30.215] ℹ️ INFO [BlocObserver] onChange: AuthBloc
I/flutter ( 6221): [14:44:30.215] 🔍 DEBUG [BlocObserver]   From: AuthInitial
I/flutter ( 6221): [14:44:30.217] 🔍 DEBUG [BlocObserver]   To: AuthUnauthenticated
D/InsetsController( 6221): hide(ime(), fromIme=false)
I/ImeTracker( 6221): com.example.hsmik:85cb09b6: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN
D/ProfileInstaller( 6221): Installing profile for com.example.hsmik
I/flutter ( 6221): [14:44:32.675] ℹ️ INFO [BlocObserver] onEvent: AuthBloc -> LoginRequested
I/flutter ( 6221): [14:44:32.679] 🔍 DEBUG [BlocObserver]   Event details: LoginRequested(RouterCredentials(192.168.85.1, 8788, hsco, Hs-co@12321#, false), true)
I/flutter ( 6221): [14:44:32.681] 🔍 DEBUG [BlocObserver] onTransition: AuthBloc
I/flutter ( 6221): [14:44:32.682] 🔍 DEBUG [BlocObserver]   Event: LoginRequested
I/flutter ( 6221): [14:44:32.682] 🔍 DEBUG [BlocObserver]   CurrentState: AuthUnauthenticated
I/flutter ( 6221): [14:44:32.683] 🔍 DEBUG [BlocObserver]   NextState: AuthLoading
I/flutter ( 6221): [14:44:32.683] ℹ️ INFO [BlocObserver] onChange: AuthBloc
I/flutter ( 6221): [14:44:32.683] 🔍 DEBUG [BlocObserver]   From: AuthUnauthenticated
I/flutter ( 6221): [14:44:32.683] 🔍 DEBUG [BlocObserver]   To: AuthLoading
I/flutter ( 6221): [14:44:32.689] ℹ️ INFO [RouterOSClientV2] Connecting without SSL to 192.168.85.1:8788
I/flutter ( 6221): [14:44:32.697] ℹ️ INFO [RouterOSClientV2] Connected successfully (SSL: false)
I/flutter ( 6221): [14:44:32.700] 🔍 DEBUG [RouterOSClientV2] Logging in as hsco
I/flutter ( 6221): [14:44:32.898] ℹ️ INFO [RouterOSClientV2] Login successful
I/flutter ( 6221): [14:44:32.902] ℹ️ INFO [RouterOSClient] Connecting without SSL to 192.168.85.1:8788
I/flutter ( 6221): [14:44:32.949] ℹ️ INFO [RouterOSClient] Connected successfully (SSL: false)
I/flutter ( 6221): [14:44:32.952] 🔍 DEBUG [RouterOSClient] Sending command: /login
I/flutter ( 6221): [14:44:32.980] 🔍 DEBUG [RouterOSClient] Processing response: lastType=done, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:32.981] 🔍 DEBUG [RouterOSClient] Command response: 1 items
I/flutter ( 6221): [14:44:33.005] 🔍 DEBUG [BlocObserver] onTransition: AuthBloc
I/flutter ( 6221): [14:44:33.005] 🔍 DEBUG [BlocObserver]   Event: LoginRequested
I/flutter ( 6221): [14:44:33.005] 🔍 DEBUG [BlocObserver]   CurrentState: AuthLoading
I/flutter ( 6221): [14:44:33.006] 🔍 DEBUG [BlocObserver]   NextState: AuthAuthenticated
I/flutter ( 6221): [14:44:33.006] ℹ️ INFO [BlocObserver] onChange: AuthBloc
I/flutter ( 6221): [14:44:33.006] 🔍 DEBUG [BlocObserver]   From: AuthLoading
I/flutter ( 6221): [14:44:33.007] 🔍 DEBUG [BlocObserver]   To: AuthAuthenticated
I/flutter ( 6221): [14:44:33.062] 🔍 DEBUG [BlocObserver] onCreate: DashboardBloc
I/flutter ( 6221): [14:44:33.068] ℹ️ INFO [BlocObserver] onEvent: DashboardBloc -> LoadDashboardData
I/flutter ( 6221): [14:44:33.069] 🔍 DEBUG [BlocObserver]   Event details: LoadDashboardData()
I/flutter ( 6221): [14:44:33.204] 🔍 DEBUG [BlocObserver] onTransition: DashboardBloc
I/flutter ( 6221): [14:44:33.205] 🔍 DEBUG [BlocObserver]   Event: LoadDashboardData
I/flutter ( 6221): [14:44:33.206] 🔍 DEBUG [BlocObserver]   CurrentState: DashboardInitial
I/flutter ( 6221): [14:44:33.207] 🔍 DEBUG [BlocObserver]   NextState: DashboardLoading
I/flutter ( 6221): [14:44:33.208] ℹ️ INFO [BlocObserver] onChange: DashboardBloc
I/flutter ( 6221): [14:44:33.208] 🔍 DEBUG [BlocObserver]   From: DashboardInitial
I/flutter ( 6221): [14:44:33.209] 🔍 DEBUG [BlocObserver]   To: DashboardLoading
I/flutter ( 6221): [14:44:33.212] 🔍 DEBUG [RouterOSClientV2] Sending command: [/system/resource/print]
I/flutter ( 6221): [14:44:33.233] 🔍 DEBUG [RouterOSClientV2] Command response: 1 items
I/flutter ( 6221): [14:44:33.235] 🔍 DEBUG [BlocObserver] onTransition: DashboardBloc
I/flutter ( 6221): [14:44:33.235] 🔍 DEBUG [BlocObserver]   Event: LoadDashboardData
I/flutter ( 6221): [14:44:33.236] 🔍 DEBUG [BlocObserver]   CurrentState: DashboardLoading
I/flutter ( 6221): [14:44:33.237] 🔍 DEBUG [BlocObserver]   NextState: DashboardLoaded
I/flutter ( 6221): [14:44:33.237] ℹ️ INFO [BlocObserver] onChange: DashboardBloc
I/flutter ( 6221): [14:44:33.237] 🔍 DEBUG [BlocObserver]   From: DashboardLoading
I/flutter ( 6221): [14:44:33.237] 🔍 DEBUG [BlocObserver]   To: DashboardLoaded
W/WindowOnBackDispatcher( 6221): sendCancelIfRunning: isInProgress=false callback=io.flutter.embedding.android.FlutterActivity$1@b59f803
I/flutter ( 6221): [14:44:35.666] 🔍 DEBUG [BlocObserver] onCreate: LogsBloc
I/flutter ( 6221): [14:44:35.670] 🔍 DEBUG [BlocObserver] onCreate: LogsBloc
I/flutter ( 6221): [14:44:35.781] ℹ️ INFO [BlocObserver] onEvent: LogsBloc -> LoadLogs
I/flutter ( 6221): [14:44:35.782] 🔍 DEBUG [BlocObserver]   Event details: LoadLogs(null, null, null, null)
I/flutter ( 6221): [14:44:35.804] 🔍 DEBUG [BlocObserver] onTransition: LogsBloc
I/flutter ( 6221): [14:44:35.805] 🔍 DEBUG [BlocObserver]   Event: LoadLogs
I/flutter ( 6221): [14:44:35.805] 🔍 DEBUG [BlocObserver]   CurrentState: LogsInitial
I/flutter ( 6221): [14:44:35.805] 🔍 DEBUG [BlocObserver]   NextState: LogsLoading
I/flutter ( 6221): [14:44:35.805] ℹ️ INFO [BlocObserver] onChange: LogsBloc
I/flutter ( 6221): [14:44:35.806] 🔍 DEBUG [BlocObserver]   From: LogsInitial
I/flutter ( 6221): [14:44:35.806] 🔍 DEBUG [BlocObserver]   To: LogsLoading
I/flutter ( 6221): [14:44:35.811] 🔍 DEBUG [RouterOSClient] Sending command: /log/print
I/flutter ( 6221): [14:44:35.881] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.885] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.885] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.886] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.887] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.887] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.888] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.888] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.892] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.916] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.918] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.921] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.939] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.941] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.941] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.952] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.955] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.964] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.966] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.977] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.979] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.984] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.986] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.992] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.995] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.997] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:35.999] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.020] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.022] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.022] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.023] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.029] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.032] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.034] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.037] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.038] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.039] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.041] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.042] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.043] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.048] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.048] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.049] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.050] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.057] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.057] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.058] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.061] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.062] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.063] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.064] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.064] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.065] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.065] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.065] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.067] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.067] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.069] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.072] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.073] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.074] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.074] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.076] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.076] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.077] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.079] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.080] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.084] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.085] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.085] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.086] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.086] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.086] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.106] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.111] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.120] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.126] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.131] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.138] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.142] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.148] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.152] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.157] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.161] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.165] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.170] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.173] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.179] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.183] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.187] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.194] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.198] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.202] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.206] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.210] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.215] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.219] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.223] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.228] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.232] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.236] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.242] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.246] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.251] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.257] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.262] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.269] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.276] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.283] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.291] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.296] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.300] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.304] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.309] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.314] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.318] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.324] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.329] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.334] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.339] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.345] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.348] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.352] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.356] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.360] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.364] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.369] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.374] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.379] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.383] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.387] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.393] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.398] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.404] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.409] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.413] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.417] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.421] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.425] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.429] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.434] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.439] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.443] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.448] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.451] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.456] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.459] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.465] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.470] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.475] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.479] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.483] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.487] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.490] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.494] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.500] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.506] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.512] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.517] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.521] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.526] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.530] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.538] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.542] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.546] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.550] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.553] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.558] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.563] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.569] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.572] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.580] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.584] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.589] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.596] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.602] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.609] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.614] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.619] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.623] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.627] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.631] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.637] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.643] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.648] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.653] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.660] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.666] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.673] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.677] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.681] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.685] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.691] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.695] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.700] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.704] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.707] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.710] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.716] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.721] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.725] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.729] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.735] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.741] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.745] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.753] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.760] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.763] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.766] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.770] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.775] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.780] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.784] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.788] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.795] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.798] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.802] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.806] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.813] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.818] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.824] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.830] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.835] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.839] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.845] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.850] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.854] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.859] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.863] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.866] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.873] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.876] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.882] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.886] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.890] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.897] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.900] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.903] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.908] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.912] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.916] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.921] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.925] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.929] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.932] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.937] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.943] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.949] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.957] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.963] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.966] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.969] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.971] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.975] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.977] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.981] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.985] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.989] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.991] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.993] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:36.998] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.003] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.009] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.013] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.018] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.021] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.023] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.026] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.029] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.033] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.034] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.038] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.043] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.048] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.054] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.059] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.065] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.070] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.075] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.078] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.084] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.090] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.094] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.100] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.104] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.110] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.114] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.117] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.122] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.128] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.133] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.138] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.144] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.150] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.156] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.161] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.165] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.169] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.173] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.176] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.180] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.183] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.186] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.189] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.193] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.197] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.199] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.202] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.205] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.210] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.213] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.217] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.219] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.223] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.227] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.230] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.234] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.237] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.241] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.244] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.249] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.251] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.255] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.260] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.262] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.268] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.271] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.274] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.277] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.280] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.283] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.286] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.292] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.294] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.298] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.301] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.303] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.306] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.309] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.313] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.316] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.320] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.324] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.328] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.332] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.335] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.337] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.339] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.343] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.348] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.352] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.356] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.359] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.362] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.365] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.368] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.373] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.376] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.380] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.382] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.385] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.391] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.395] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.397] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.398] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.406] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.410] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.412] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.414] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.420] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.423] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.425] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.430] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.434] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.439] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.442] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.445] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.452] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.454] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.462] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.464] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.466] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.473] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.476] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.481] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.485] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.487] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.490] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.493] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.496] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.499] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.501] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.506] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.509] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.512] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.516] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.522] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.524] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.530] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.534] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.536] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.540] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.543] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.545] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.547] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.549] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.552] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.556] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.561] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.565] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.569] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.571] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.577] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.580] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.584] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.589] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.592] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.597] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.601] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.603] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.605] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.611] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.615] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.618] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.623] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.630] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.634] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.638] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.641] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.645] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.646] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.649] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.652] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.657] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.659] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.661] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.665] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.669] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.672] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.675] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.678] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.681] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.685] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.689] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.691] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.693] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.696] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.700] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.703] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.705] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.707] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.708] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.713] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.716] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.719] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.722] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.726] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.729] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.734] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.737] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.741] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.743] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.747] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.750] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.753] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.757] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.760] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.765] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.769] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.773] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.776] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.781] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.785] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.788] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.793] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.796] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.798] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.800] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.804] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.808] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.810] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.814] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.816] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.820] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.824] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.828] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.831] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.834] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.837] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.844] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.848] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.858] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.862] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.869] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.870] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.872] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.874] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.877] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.878] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.882] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.885] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.889] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.892] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.895] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.898] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.900] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.904] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.907] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.910] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.913] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.917] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.918] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.921] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.925] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.928] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.931] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.934] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.938] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.941] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.946] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.951] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.954] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.957] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.960] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.962] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.966] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.969] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.972] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.974] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.976] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.978] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.981] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.985] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.988] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.990] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.996] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:37.998] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.000] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.003] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.007] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.009] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.011] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.013] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.016] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.019] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.021] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.025] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.029] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.032] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.035] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.040] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.042] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.045] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.048] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.050] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.054] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.057] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.060] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.062] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.065] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.068] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.069] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.073] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.076] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.078] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.081] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.085] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.088] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.091] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.094] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.097] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.099] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.101] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.104] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.108] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.111] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.114] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.122] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.126] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.129] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.132] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.135] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.137] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.139] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.142] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.145] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.148] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.150] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.154] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.158] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.160] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.164] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.166] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.169] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.171] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.176] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.177] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.181] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.186] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.189] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.193] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.195] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.200] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.203] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.205] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.207] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.210] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.212] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.214] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.219] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.223] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.224] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.226] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.229] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.232] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.233] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.235] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.237] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.239] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.241] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.244] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.245] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.248] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.250] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.252] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.254] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.257] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.261] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.264] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.266] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.269] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.270] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.278] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.280] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.283] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.284] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.288] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.290] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.293] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.295] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.298] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.302] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.305] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.307] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.312] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.315] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.317] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.319] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.322] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.324] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.327] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.329] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.331] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.335] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.337] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.340] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.341] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.345] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.346] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.349] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.352] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.354] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.358] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.360] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.364] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.367] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.369] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.373] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.374] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.377] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.378] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.381] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.383] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.385] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.387] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.389] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.393] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.394] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.395] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.398] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.403] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.405] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.407] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.410] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.414] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.416] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.417] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.418] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.420] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.422] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.426] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.428] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.431] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.434] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.436] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.439] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.441] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.442] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.445] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.449] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.452] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.454] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.456] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.458] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.460] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.462] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.463] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.465] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.468] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.474] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.476] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.478] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.480] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.481] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.485] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.486] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.490] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.494] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.497] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.500] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.504] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.506] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.507] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.509] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.512] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.513] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.515] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.516] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.517] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.518] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.520] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.522] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.524] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.527] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.530] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.531] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.532] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.533] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.534] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.536] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.540] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.541] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.543] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.545] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.546] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.550] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.551] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.552] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.554] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.558] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.561] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.563] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.565] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.568] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.569] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.572] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.574] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.575] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.576] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.580] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.581] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.588] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.589] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.590] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.591] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.592] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.595] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.597] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.598] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.599] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.600] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.601] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.604] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.608] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.610] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.616] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.618] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.622] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.622] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.624] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.629] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.630] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.634] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.636] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.638] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.639] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.642] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.644] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.645] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.647] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.648] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.652] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.654] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.656] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.658] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.660] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.662] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.665] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.667] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.668] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.669] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.670] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.671] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.672] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.674] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.677] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.679] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.681] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.682] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.686] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.687] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.689] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.689] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.690] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.692] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.694] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.696] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.697] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.699] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.701] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.703] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.705] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.706] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.709] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.710] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.711] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.712] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.716] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.718] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.720] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.721] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.721] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.722] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.727] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.730] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.730] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.733] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.737] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.738] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.741] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.742] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.745] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.748] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.750] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.752] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.754] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.756] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.759] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.760] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.761] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.762] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.764] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.766] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.769] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.771] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.772] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.776] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.778] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.781] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.783] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.785] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.789] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.792] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.794] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.796] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.797] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.801] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.803] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.806] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.808] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.810] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.810] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.813] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.816] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.818] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.818] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.820] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.821] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.821] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.822] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.824] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.826] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.831] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.834] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.836] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.838] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.840] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.842] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.845] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.847] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.849] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.851] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.853] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.854] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.859] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.860] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.862] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.865] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.868] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.870] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.873] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.875] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.877] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.877] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.878] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.880] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.883] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.888] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.890] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.892] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.893] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.893] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.894] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.896] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.898] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.898] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.900] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.901] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.901] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.901] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.902] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.903] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.903] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.903] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.905] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.905] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.906] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.908] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.909] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.909] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.909] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.910] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.910] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.910] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.910] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.911] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.912] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.912] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.914] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.915] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.916] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.919] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.920] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.921] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.921] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.922] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.923] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.925] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.925] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.925] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.926] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.927] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.928] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.930] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.935] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.938] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.940] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.942] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.942] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.942] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.944] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.946] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.946] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.946] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.947] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.947] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.950] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.950] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.951] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.953] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.954] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.956] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.957] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.959] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.960] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.961] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.962] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.963] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.965] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.966] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.968] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.970] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.971] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.973] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.974] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.976] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.977] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.977] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.978] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.979] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.980] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.980] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.980] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.980] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.982] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.984] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.986] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.986] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.987] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.988] 🔍 DEBUG [RouterOSClient] Processing response: lastType=done, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:38.989] 🔍 DEBUG [RouterOSClient] Command response: 1001 items
I/flutter ( 6221): [14:44:38.993] 🔍 DEBUG [RouterOSClient] Retrieved 1000 log entries
I/flutter ( 6221): [14:44:39.003] 🔍 DEBUG [BlocObserver] onTransition: LogsBloc
I/flutter ( 6221): [14:44:39.004] 🔍 DEBUG [BlocObserver]   Event: LoadLogs
I/flutter ( 6221): [14:44:39.004] 🔍 DEBUG [BlocObserver]   CurrentState: LogsLoading
I/flutter ( 6221): [14:44:39.006] 🔍 DEBUG [BlocObserver]   NextState: LogsLoaded
I/flutter ( 6221): [14:44:39.007] ℹ️ INFO [BlocObserver] onChange: LogsBloc
I/flutter ( 6221): [14:44:39.008] 🔍 DEBUG [BlocObserver]   From: LogsLoading
I/flutter ( 6221): [14:44:39.009] 🔍 DEBUG [BlocObserver]   To: LogsLoaded
I/flutter ( 6221): [14:44:41.318] ℹ️ INFO [BlocObserver] onEvent: LogsBloc -> StartFollowingLogs
I/flutter ( 6221): [14:44:41.319] 🔍 DEBUG [BlocObserver]   Event details: StartFollowingLogs(null)
I/flutter ( 6221): [14:44:41.322] 🔍 DEBUG [BlocObserver] onTransition: LogsBloc
I/flutter ( 6221): [14:44:41.322] 🔍 DEBUG [BlocObserver]   Event: StartFollowingLogs
I/flutter ( 6221): [14:44:41.323] 🔍 DEBUG [BlocObserver]   CurrentState: LogsInitial
I/flutter ( 6221): [14:44:41.324] 🔍 DEBUG [BlocObserver]   NextState: LogsFollowing
I/flutter ( 6221): [14:44:41.325] ℹ️ INFO [BlocObserver] onChange: LogsBloc
I/flutter ( 6221): [14:44:41.325] 🔍 DEBUG [BlocObserver]   From: LogsInitial
I/flutter ( 6221): [14:44:41.327] 🔍 DEBUG [BlocObserver]   To: LogsFollowing
I/flutter ( 6221): [14:44:41.340] ℹ️ INFO [LogsDataSource] followLogs called with topics: null
I/flutter ( 6221): [14:44:41.341] 🔍 DEBUG [RouterOSClient] followLogs: Creating stream with tag=logs_1765451681341, cancelledTags={}, activeTag=null
I/flutter ( 6221): [14:44:41.344] ℹ️ INFO [RouterOSClient] Starting to follow logs
I/flutter ( 6221): [14:44:41.345] 🔍 DEBUG [RouterOSClient] followLogs: Sending command to socket
I/flutter ( 6221): [14:44:41.346] ℹ️ INFO [LogsDataSource] Stream started
I/flutter ( 6221): [14:44:42.105] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:42.111] 🔍 DEBUG [LogsDataSource] Received log data: {type: re, .id: *8614, .dead: true}
I/flutter ( 6221): [14:44:51.130] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:51.131] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:51.131] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:51.132] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:51.133] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:51.134] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:51.135] 🔍 DEBUG [LogsDataSource] Received log data: {type: re, .id: *89FC, time: 14:44:42, topics: ipsec,info, message: ISAKMP-SA deleted 94.183.134.153[500]-2.180.3.207[500] spi:4a34fe65a05bb240:0000000000000000 rekey:1}
I/flutter ( 6221): [14:44:51.147] 🔍 DEBUG [LogsDataSource] Received log data: {type: re, .id: *89FD, time: 14:44:51, topics: l2tp,ppp,info, message: to_home: initializing...}
I/flutter ( 6221): [14:44:51.148] 🔍 DEBUG [LogsDataSource] Received log data: {type: re, .id: *89FE, time: 14:44:51, topics: l2tp,ppp,info, message: to_home: connecting...}
I/flutter ( 6221): [14:44:51.150] 🔍 DEBUG [LogsDataSource] Received log data: {type: re, .id: *89FF, time: 14:44:51, topics: ipsec,info, message: initiate new phase 1 (Identity Protection): 94.183.134.153[500]<=>2.180.3.207[500]}
I/flutter ( 6221): [14:44:51.155] 🔍 DEBUG [LogsDataSource] Received log data: {type: re, .id: *8615, .dead: true}
I/flutter ( 6221): [14:44:51.159] 🔍 DEBUG [LogsDataSource] Received log data: {type: re, .id: *8616, .dead: true}
I/flutter ( 6221): [14:44:51.261] 🔍 DEBUG [BlocObserver] onTransition: LogsBloc
I/flutter ( 6221): [14:44:51.261] 🔍 DEBUG [BlocObserver]   Event: StartFollowingLogs
I/flutter ( 6221): [14:44:51.261] 🔍 DEBUG [BlocObserver]   CurrentState: LogsFollowing
I/flutter ( 6221): [14:44:51.262] 🔍 DEBUG [BlocObserver]   NextState: LogsFollowing
I/flutter ( 6221): [14:44:51.262] ℹ️ INFO [BlocObserver] onChange: LogsBloc
I/flutter ( 6221): [14:44:51.263] 🔍 DEBUG [BlocObserver]   From: LogsFollowing
I/flutter ( 6221): [14:44:51.265] 🔍 DEBUG [BlocObserver]   To: LogsFollowing
I/flutter ( 6221): [14:44:54.884] ℹ️ INFO [BlocObserver] onEvent: LogsBloc -> StopFollowingLogs
I/flutter ( 6221): [14:44:54.884] 🔍 DEBUG [BlocObserver]   Event details: StopFollowingLogs()
I/flutter ( 6221): [14:44:54.890] 🔍 DEBUG [RouterOSClient] stopStreaming called: activeTag=logs_1765451681341, cancelledTags={}
I/flutter ( 6221): [14:44:54.890] ℹ️ INFO [RouterOSClient] Stopping streaming operation: logs_1765451681341
I/flutter ( 6221): [14:44:54.890] 🔍 DEBUG [RouterOSClient] Added logs_1765451681341 to cancelledTags: {logs_1765451681341}
I/flutter ( 6221): [14:44:54.891] 🔍 DEBUG [RouterOSClient] Sending /cancel command
I/flutter ( 6221): [14:44:54.891] 🔍 DEBUG [RouterOSClient] Waiting 100ms for cancel response...
I/flutter ( 6221): [14:44:54.897] ℹ️ INFO [LogsDataSource] Stream ended
I/flutter ( 6221): [14:44:54.916] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={logs_1765451681341}
I/flutter ( 6221): [14:44:54.917] 🔍 DEBUG [RouterOSClient] Processing response: lastType=done, activeTag=null, cancelledTags={logs_1765451681341}
I/flutter ( 6221): [14:44:54.918] 🔍 DEBUG [RouterOSClient] Ignoring cancelled tag response, clearing cancelledTags
I/flutter ( 6221): [14:44:54.919] 🔍 DEBUG [RouterOSClient] Processing response: lastType=done, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:44:55.016] 🔍 DEBUG [RouterOSClient] Done waiting, cancelledTags now: {}
I/flutter ( 6221): [14:44:55.017] 🔍 DEBUG [BlocObserver] onTransition: LogsBloc
I/flutter ( 6221): [14:44:55.017] 🔍 DEBUG [BlocObserver]   Event: StopFollowingLogs
I/flutter ( 6221): [14:44:55.018] 🔍 DEBUG [BlocObserver]   CurrentState: LogsFollowing
I/flutter ( 6221): [14:44:55.018] 🔍 DEBUG [BlocObserver]   NextState: LogsLoaded
I/flutter ( 6221): [14:44:55.018] ℹ️ INFO [BlocObserver] onChange: LogsBloc
I/flutter ( 6221): [14:44:55.019] 🔍 DEBUG [BlocObserver]   From: LogsFollowing
I/flutter ( 6221): [14:44:55.020] 🔍 DEBUG [BlocObserver]   To: LogsLoaded
I/flutter ( 6221): [14:45:01.747] ℹ️ INFO [BlocObserver] onEvent: LogsBloc -> StartFollowingLogs
I/flutter ( 6221): [14:45:01.748] 🔍 DEBUG [BlocObserver]   Event details: StartFollowingLogs(null)
I/flutter ( 6221): [14:45:01.749] 🔍 DEBUG [BlocObserver] onTransition: LogsBloc
I/flutter ( 6221): [14:45:01.749] 🔍 DEBUG [BlocObserver]   Event: StartFollowingLogs
I/flutter ( 6221): [14:45:01.750] 🔍 DEBUG [BlocObserver]   CurrentState: LogsLoaded
I/flutter ( 6221): [14:45:01.751] 🔍 DEBUG [BlocObserver]   NextState: LogsFollowing
I/flutter ( 6221): [14:45:01.752] ℹ️ INFO [BlocObserver] onChange: LogsBloc
I/flutter ( 6221): [14:45:01.752] 🔍 DEBUG [BlocObserver]   From: LogsLoaded
I/flutter ( 6221): [14:45:01.752] 🔍 DEBUG [BlocObserver]   To: LogsFollowing
I/flutter ( 6221): [14:45:01.753] ℹ️ INFO [LogsDataSource] followLogs called with topics: null
I/flutter ( 6221): [14:45:01.754] 🔍 DEBUG [RouterOSClient] followLogs: Creating stream with tag=logs_1765451701754, cancelledTags={}, activeTag=null
I/flutter ( 6221): [14:45:01.754] ℹ️ INFO [RouterOSClient] Starting to follow logs
I/flutter ( 6221): [14:45:01.755] 🔍 DEBUG [RouterOSClient] followLogs: Sending command to socket
I/flutter ( 6221): [14:45:01.756] ℹ️ INFO [LogsDataSource] Stream started
I/flutter ( 6221): [14:45:08.513] 🔍 DEBUG [RouterOSClient] Processing response: lastType=done, activeTag=logs_1765451701754, cancelledTags={}
I/flutter ( 6221): [14:45:08.514] ! WARN [RouterOSClient] Stream closing due to done response! tag=logs_1765451701754
I/flutter ( 6221): [14:45:08.516] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:08.516] ℹ️ INFO [LogsDataSource] Stream ended
I/flutter ( 6221): [14:45:13.450] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:13.450] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:15.107] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:15.108] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:15.108] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:15.108] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:16.100] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:16.101] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:19.179] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:19.180] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:20.750] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/flutter ( 6221): [14:45:20.751] 🔍 DEBUG [RouterOSClient] Processing response: lastType=re, activeTag=null, cancelledTags={}
I/fl