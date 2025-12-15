import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hsmik/features/hotspot/presentation/pages/hotspot_page.dart';
import 'package:hsmik/features/hotspot/presentation/bloc/hotspot_bloc.dart';
import 'package:hsmik/features/hotspot/presentation/bloc/hotspot_state.dart';
import 'package:hsmik/features/hotspot/presentation/bloc/hotspot_event.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_server.dart';
import 'package:hsmik/l10n/app_localizations.dart';

// Mock Classes
class MockHotspotBloc extends Mock implements HotspotBloc {}
class FakeHotspotEvent extends Fake implements HotspotEvent {}

void main() {
  late MockHotspotBloc mockHotspotBloc;

  setUpAll(() {
    registerFallbackValue(FakeHotspotEvent());
  });

  setUp(() {
    mockHotspotBloc = MockHotspotBloc();
    
    // Setup default stream
    when(() => mockHotspotBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildWidget(HotspotState state) {
    when(() => mockHotspotBloc.state).thenReturn(state);
    when(() => mockHotspotBloc.add(any())).thenReturn(null);
    
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
      home: BlocProvider<HotspotBloc>.value(
        value: mockHotspotBloc,
        child: const HotspotPage(),
      ),
    );
  }

  group('HotspotPage Widget Tests', () {
    testWidgets('should display loading indicator when state is HotspotLoading',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotLoading();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display no hotspot view when HotspotLoaded with empty list',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotLoaded(servers: []);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('HotSpot is not configured'), findsOneWidget);
      expect(find.text('No HotSpot server found on this router.'), findsOneWidget);
      expect(find.text('Setup HotSpot'), findsOneWidget);
    });

    testWidgets('should display main content when HotspotLoaded with servers',
        (WidgetTester tester) async {
      // Arrange
      const servers = [
        HotspotServer(
          id: '*1',
          name: 'hotspot1',
          interfaceName: 'bridge',
          addressPool: 'pool1',
          disabled: false,
        ),
        HotspotServer(
          id: '*2',
          name: 'hotspot2',
          interfaceName: 'ether2',
          addressPool: 'pool2',
          disabled: true,
        ),
      ];

      const state = HotspotLoaded(servers: servers);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Should show main content with tabs or cards
      expect(find.text('HotSpot is not configured'), findsNothing);
    });

    testWidgets('should display error view when state is HotspotError',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotError('Failed to load hotspot servers');

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to load hotspot servers'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should trigger LoadHotspotServers event on init',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotInitial();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      verify(() => mockHotspotBloc.add(const LoadHotspotServers())).called(1);
    });

    testWidgets('should trigger LoadHotspotServers when refresh button pressed',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotLoaded(servers: []);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Assert - called once on init, once on refresh
      verify(() => mockHotspotBloc.add(const LoadHotspotServers())).called(2);
    });

    testWidgets('should display app bar with correct title and actions',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotLoaded(servers: []);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('HotSpot'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should display package disabled view when HotspotPackageDisabled',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotPackageDisabled();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('HotSpot Package Disabled'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show setup button when no hotspot configured',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotLoaded(servers: []);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      final setupButton = find.text('Setup HotSpot');
      expect(setupButton, findsOneWidget);
    });

    testWidgets('should display info icon in app bar',
        (WidgetTester tester) async {
      // Arrange
      const state = HotspotInitial();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
