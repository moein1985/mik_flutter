import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'injection_container.dart' as di;
import 'l10n/app_localizations.dart';
import 'core/utils/logger.dart';
import 'core/utils/bloc_observer.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

const String _glitchtipDsn = String.fromEnvironment(
  'GLITCHTIP_DSN',
  defaultValue: 'https://d96581f7386a4bac97b44f9b6091fe1f@selfhosting-sentry.duckdns.org/1',
);

/// Custom HttpOverrides to accept self-signed SSL certificates
/// Used for connecting to MikroTik routers with self-signed certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

extension MyAppExtension on BuildContext {
  MyAppState? get myAppState => findAncestorStateOfType<MyAppState>();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow self-signed SSL certificates for MikroTik routers
  HttpOverrides.global = MyHttpOverrides();

  Future<void> bootstrap() async {
    // Initialize logging
    AppLogger.i('🚀 App starting...', tag: 'Main');

    // Set up Bloc observer
    Bloc.observer = AppBlocObserver();
    AppLogger.i('✅ Bloc observer initialized', tag: 'Main');

    // Initialize dependencies
    await di.init();
    AppLogger.i('✅ Dependencies initialized', tag: 'Main');

    runApp(const MyApp());
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = _glitchtipDsn;
      options.tracesSampleRate = 0.2; // Adjust as needed
      options.sendDefaultPii = false;
      options.environment = 'production';
    },
    appRunner: bootstrap,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState? of(BuildContext context) => context.myAppState;
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Create AuthBloc once and share it between router and providers
    _authBloc = di.sl<AuthBloc>();
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Use the same AuthBloc instance that AppRouter uses
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Network Assistant',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        
        // Router
        routerConfig: _appRouter.router,
        
        // Localization
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fa', ''),
        ],
        
        // Theme
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        // Dark Theme
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}
