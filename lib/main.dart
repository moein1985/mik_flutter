import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'injection_container.dart' as di;
import 'l10n/app_localizations.dart';
import 'core/utils/logger.dart';
import 'core/utils/bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/config/bazaar_config.dart';
import 'core/subscription/subscription_service.dart';
import 'core/services/back_button_handler.dart';
import 'features/app_auth/presentation/bloc/app_auth_bloc.dart';
import 'features/app_auth/presentation/bloc/app_auth_event.dart';
import 'features/app_auth/data/datasources/app_auth_local_datasource.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/app_auth/data/models/app_user_model.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';

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

    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapter(AppUserModelAdapter());
    await Hive.openBox<AppUserModel>('app_users');
    AppLogger.i('✅ Hive initialized', tag: 'Main');

    // Set up Bloc observer
    Bloc.observer = AppBlocObserver();
    AppLogger.i('✅ Bloc observer initialized', tag: 'Main');

    // Initialize dependencies
    await di.init();
    AppLogger.i('✅ Dependencies initialized', tag: 'Main');

    // Ensure default admin user exists
    final authDataSource = di.sl<AppAuthLocalDataSource>();
    await authDataSource.ensureDefaultAdminExists();
    AppLogger.i('✅ Default admin user ensured', tag: 'Main');

    // Initialize Cafe Bazaar Subscription (only if enabled')
    if (BazaarConfig.subscriptionEnabled) {
      Future.microtask(() async {
        try {
          final subscriptionService = di.sl<SubscriptionService>();
          await subscriptionService.initialize(BazaarConfig.rsaPublicKey);
          AppLogger.i('✅ Subscription service initialized', tag: 'Main');
        } catch (e) {
          AppLogger.w('⚠️ Subscription service initialization failed: $e', tag: 'Main');
        }
      });
    } else {
      AppLogger.i('ℹ️ Subscription disabled (BazaarConfig.subscriptionEnabled = false)', tag: 'Main');
    }

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
  ThemeMode _themeMode = ThemeMode.system;
  late final AppAuthBloc _appAuthBloc;
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    AppLogger.i('MyApp.initState start', tag: 'MyApp');
    // Create blocs once and share them
    _appAuthBloc = di.sl<AppAuthBloc>();
    AppLogger.i('AppAuthBloc instance created', tag: 'MyApp');
    _authBloc = di.sl<AuthBloc>();
    AppLogger.i('AuthBloc instance created', tag: 'MyApp');
    _appRouter = AppRouter(appAuthBloc: _appAuthBloc, authBloc: _authBloc);
    AppLogger.i('AppRouter created', tag: 'MyApp');
    
    // Initialize back button handler for Android 13+
    BackButtonHandler.initialize();
    
    // Setup global back button handler
    BackButtonHandler.setOnBackPressed(() {
      _handleBackButton();
    });
    
    // Check if user is already logged in
    AppLogger.i('Dispatching CheckAuthStatus event', tag: 'MyApp');
    _appAuthBloc.add(CheckAuthStatus());
    AppLogger.i('CheckAuthStatus event dispatched', tag: 'MyApp');
  }
  
  void _handleBackButton() {
    AppLogger.d('Global back button pressed', tag: 'MyApp');
    final currentLocation = _appRouter.router.routerDelegate.currentConfiguration.uri.path;
    AppLogger.d('Current location: $currentLocation', tag: 'MyApp');
    
    // If on home page, show exit confirmation
    if (currentLocation == '/') {
      _showExitConfirmation();
    } else {
      // For other pages, try to navigate back
      if (_appRouter.router.canPop()) {
        AppLogger.d('Popping route', tag: 'MyApp');
        _appRouter.router.pop();
        // Log resulting location to verify pop succeeded
        Future.microtask(() {
          final newLocation = _appRouter.router.routerDelegate.currentConfiguration.uri.path;
          AppLogger.d('Location after pop: $newLocation', tag: 'MyApp');
        });
      } else {
        // If can't pop (no route stack), show exit confirmation
        AppLogger.d('Cannot pop, showing exit dialog', tag: 'MyApp');
        _showExitConfirmation();
      }
    }
  }
  
  Future<void> _showExitConfirmation() async {
    if (!mounted) return;
    
    AppLogger.d('Showing exit confirmation dialog', tag: 'MyApp');
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Assistant'),
        content: const Text('آیا می‌خواهید از برنامه خارج شوید؟'),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.d('User cancelled exit', tag: 'MyApp');
              Navigator.of(context).pop(false);
            },
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              AppLogger.d('User confirmed exit', tag: 'MyApp');
              Navigator.of(context).pop(true);
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      AppLogger.d('Exiting app', tag: 'MyApp');
      SystemNavigator.pop();
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  /// Apply a new theme mode globally
  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i('MyApp.build called', tag: 'MyApp');
    return MultiBlocProvider(
      providers: [
        // App-level authentication
        BlocProvider.value(value: _appAuthBloc),
        // Router-level authentication
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
        BlocProvider(
          create: (_) => di.sl<SubscriptionBloc>()
            ..add(const CheckSubscriptionStatus()),
        ),
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
        themeMode: _themeMode,
      ),
    );
  }
}
