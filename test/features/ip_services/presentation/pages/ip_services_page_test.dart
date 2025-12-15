import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hsmik/features/ip_services/presentation/pages/ip_services_page.dart';
import 'package:hsmik/features/ip_services/presentation/bloc/ip_service_bloc.dart';
import 'package:hsmik/features/ip_services/presentation/bloc/ip_service_state.dart';
import 'package:hsmik/features/ip_services/presentation/bloc/ip_service_event.dart';
import 'package:hsmik/features/ip_services/domain/entities/ip_service.dart';
import 'package:hsmik/l10n/app_localizations.dart';

// Mock Classes
class MockIpServiceBloc extends Mock implements IpServiceBloc {}
class FakeIpServiceEvent extends Fake implements IpServiceEvent {}

void main() {
  late MockIpServiceBloc mockIpServiceBloc;

  setUpAll(() {
    registerFallbackValue(FakeIpServiceEvent());
  });

  setUp(() {
    mockIpServiceBloc = MockIpServiceBloc();
    
    // Setup default stream
    when(() => mockIpServiceBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildWidget(IpServiceState state) {
    when(() => mockIpServiceBloc.state).thenReturn(state);
    when(() => mockIpServiceBloc.add(any())).thenReturn(null);
    
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
      home: BlocProvider<IpServiceBloc>.value(
        value: mockIpServiceBloc,
        child: const IpServicesPage(),
      ),
    );
  }

  group('IpServicesPage Widget Tests', () {
    testWidgets('should display loading indicator when state is IpServiceLoading',
        (WidgetTester tester) async {
      // Arrange
      const state = IpServiceLoading();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display empty view when IpServiceLoaded with empty list',
        (WidgetTester tester) async {
      // Arrange
      const state = IpServiceLoaded([]);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Empty view should be shown
      expect(find.text('No Services Found'), findsOneWidget);
      expect(find.text('Unable to load router services'), findsOneWidget);
    });

    testWidgets('should trigger LoadIpServices event on init',
        (WidgetTester tester) async {
      // Arrange
      const state = IpServiceInitial();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      verify(() => mockIpServiceBloc.add(const LoadIpServices())).called(1);
    });

    testWidgets('should display app bar with correct title and actions',
        (WidgetTester tester) async {
      // Arrange
      const state = IpServiceLoaded([]);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('IP Services'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsWidgets);
      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('should display creating certificate view when IpServiceCreatingCertificate',
        (WidgetTester tester) async {
      // Arrange
      const state = IpServiceCreatingCertificate('Creating certificate...');

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      // Assert
      expect(find.text('Creating certificate...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle IpServiceError state',
        (WidgetTester tester) async {
      // Arrange
      const state = IpServiceError('Failed to load services');

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert - Error state shows empty view
      expect(find.text('No Services Found'), findsOneWidget);
    });

    testWidgets('should display info icon in app bar',
        (WidgetTester tester) async {
      // Arrange
      const state = IpServiceInitial();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });

    testWidgets('should show services list when loaded with data',
        (WidgetTester tester) async {
      // Arrange
      const services = [
        IpService(
          id: '*1',
          name: 'www',
          port: 80,
          disabled: false,
        ),
        IpService(
          id: '*2',
          name: 'api',
          port: 8728,
          disabled: false,
        ),
      ];

      const state = IpServiceLoaded(services);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert - should not show empty view
      expect(find.text('No Services Found'), findsNothing);
      // Should show some service UI (not necessarily text of service names)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
