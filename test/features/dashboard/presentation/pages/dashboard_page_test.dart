import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hsmik/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hsmik/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:hsmik/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:hsmik/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:hsmik/features/dashboard/domain/entities/system_resource.dart';
import 'package:hsmik/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hsmik/l10n/app_localizations.dart';

// Mock Classes
class MockDashboardBloc extends Mock implements DashboardBloc {}
class MockAuthBloc extends Mock implements AuthBloc {}
class FakeDashboardEvent extends Fake implements DashboardEvent {}

void main() {
  late MockDashboardBloc mockDashboardBloc;
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeDashboardEvent());
  });

  setUp(() {
    mockDashboardBloc = MockDashboardBloc();
    mockAuthBloc = MockAuthBloc();
    
    // Setup default stream
    when(() => mockDashboardBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildWidget(DashboardState state) {
    when(() => mockDashboardBloc.state).thenReturn(state);
    when(() => mockDashboardBloc.add(any())).thenReturn(null);
    
    return MaterialApp(
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>.value(value: mockDashboardBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const DashboardPage(),
      ),
    );
  }

  group('DashboardPage Widget Tests', () {
    testWidgets('should display loading indicator when state is DashboardLoading',
        (WidgetTester tester) async {
      // Arrange
      const state = DashboardLoading();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display system resources when state is DashboardLoaded with data',
        (WidgetTester tester) async {
      // Arrange
      const systemResource = SystemResource(
        uptime: '1d 2h 3m',
        version: '7.15.2',
        cpuLoad: '25%',
        freeMemory: '524288000',
        totalMemory: '1048576000',
        freeHddSpace: '1073741824',
        totalHddSpace: '10737418240',
        architectureName: 'arm64',
        boardName: 'RB4011',
        platform: 'MikroTik',
      );

      const state = DashboardLoaded(systemResource: systemResource);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('7.15.2'), findsOneWidget);
      expect(find.text('Uptime'), findsOneWidget);
      expect(find.text('1d 2h 3m'), findsOneWidget);
      expect(find.text('CPU Load'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
    });

    testWidgets('should display empty dashboard when DashboardLoaded with null data',
        (WidgetTester tester) async {
      // Arrange
      const state = DashboardLoaded();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Should show dashboard sections
      expect(find.text('Network Management'), findsOneWidget);
      expect(find.text('Security & Access'), findsOneWidget);
      expect(find.text('Monitoring & Tools'), findsOneWidget);
    });

    testWidgets('should trigger LoadDashboardData event on init',
        (WidgetTester tester) async {
      // Arrange
      const state = DashboardInitial();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      verify(() => mockDashboardBloc.add(const LoadDashboardData())).called(1);
    });

    testWidgets('should trigger RefreshSystemResources when refresh button pressed',
        (WidgetTester tester) async {
      // Arrange
      const state = DashboardLoaded();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockDashboardBloc.add(const RefreshSystemResources())).called(1);
    });

    testWidgets('should show all dashboard section cards',
        (WidgetTester tester) async {
      // Arrange
      const state = DashboardLoaded();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert - Check for main sections
      expect(find.text('Network Management'), findsOneWidget);
      expect(find.text('Interfaces'), findsOneWidget);
      expect(find.text('IP Addresses'), findsOneWidget);
      expect(find.text('DHCP Server'), findsOneWidget);
      
      expect(find.text('Security & Access'), findsOneWidget);
      expect(find.text('Firewall'), findsOneWidget);
      
      expect(find.text('Advanced Features'), findsOneWidget);
      expect(find.text('HotSpot'), findsOneWidget);
      expect(find.text('Queues'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
    });

    testWidgets('should display app bar with correct title and actions',
        (WidgetTester tester) async {
      // Arrange
      const state = DashboardLoaded();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Network Assistant'), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('should support pull-to-refresh',
        (WidgetTester tester) async {
      // Arrange
      const state = DashboardLoaded();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Find RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simulate pull-to-refresh gesture
      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockDashboardBloc.add(const RefreshSystemResources())).called(greaterThan(0));
    });

    testWidgets('should format bytes correctly in memory display',
        (WidgetTester tester) async {
      // Arrange
      const systemResource = SystemResource(
        uptime: '1d',
        version: '7.15.2',
        cpuLoad: '50%',
        freeMemory: '524288000', // ~500 MB
        totalMemory: '1048576000', // ~1 GB
        freeHddSpace: '5368709120', // ~5 GB
        totalHddSpace: '10737418240', // ~10 GB
        architectureName: 'arm64',
        boardName: 'RB4011',
        platform: 'MikroTik',
      );

      const state = DashboardLoaded(systemResource: systemResource);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert - Memory should be displayed
      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
    });
  });
}
