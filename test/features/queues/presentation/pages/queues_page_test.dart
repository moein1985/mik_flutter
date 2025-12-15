import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hsmik/features/queues/presentation/pages/queues_page.dart';
import 'package:hsmik/features/queues/presentation/bloc/queues_bloc.dart';
import 'package:hsmik/features/queues/presentation/bloc/queues_state.dart';
import 'package:hsmik/features/queues/presentation/bloc/queues_event.dart';
import 'package:hsmik/features/queues/domain/entities/simple_queue.dart';
import 'package:hsmik/l10n/app_localizations.dart';

// Mock Classes
class MockQueuesBloc extends Mock implements QueuesBloc {}
class FakeQueuesEvent extends Fake implements QueuesEvent {}

void main() {
  late MockQueuesBloc mockQueuesBloc;

  setUpAll(() {
    registerFallbackValue(FakeQueuesEvent());
  });

  setUp(() {
    mockQueuesBloc = MockQueuesBloc();
    
    // Setup default stream
    when(() => mockQueuesBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildWidget(QueuesState state) {
    when(() => mockQueuesBloc.state).thenReturn(state);
    when(() => mockQueuesBloc.add(any())).thenReturn(null);
    
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
      home: BlocProvider<QueuesBloc>.value(
        value: mockQueuesBloc,
        child: const QueuesPage(),
      ),
    );
  }

  group('QueuesPage Widget Tests', () {
    testWidgets('should display loading indicator when state is QueuesLoading',
        (WidgetTester tester) async {
      // Arrange
      const state = QueuesLoading();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display empty view when QueuesLoaded with empty list',
        (WidgetTester tester) async {
      // Arrange
      const state = QueuesLoaded([]);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No queues found'), findsOneWidget);
      expect(find.byIcon(Icons.queue), findsWidgets);
    });

    testWidgets('should display queue list when QueuesLoaded with data',
        (WidgetTester tester) async {
      // Arrange
      const queues = [
        SimpleQueue(
          id: '*1',
          name: 'default-queue',
          target: '192.168.1.0/24',
          maxLimit: '10M/10M',
          disabled: false,
        ),
        SimpleQueue(
          id: '*2',
          name: 'guest-queue',
          target: '192.168.2.0/24',
          maxLimit: '5M/5M',
          disabled: true,
        ),
      ];

      const state = QueuesLoaded(queues);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('default-queue'), findsOneWidget);
      expect(find.text('guest-queue'), findsOneWidget);
      expect(find.text('192.168.1.0/24'), findsOneWidget);
      expect(find.text('192.168.2.0/24'), findsOneWidget);
      // maxLimit appears twice (upload/download)
      expect(find.text('10M/10M'), findsWidgets);
      expect(find.text('5M/5M'), findsWidgets);
    });

    testWidgets('should display error view when state is QueuesError',
        (WidgetTester tester) async {
      // Arrange
      const state = QueuesError('Failed to load queues');

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to load queues'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should trigger LoadQueues event on init',
        (WidgetTester tester) async {
      // Arrange
      const state = QueuesInitial();

      // Act
      await tester.pumpWidget(buildWidget(state));

      // Assert
      verify(() => mockQueuesBloc.add(const LoadQueues())).called(1);
    });

    testWidgets('should trigger RefreshQueues when refresh button pressed',
        (WidgetTester tester) async {
      // Arrange
      const state = QueuesLoaded([]);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockQueuesBloc.add(const RefreshQueues())).called(1);
    });

    testWidgets('should display FloatingActionButton for adding queue',
        (WidgetTester tester) async {
      // Arrange
      const state = QueuesLoaded([]);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display app bar with correct title',
        (WidgetTester tester) async {
      // Arrange
      const state = QueuesLoaded([]);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Simple Queues'), findsOneWidget);
    });

    testWidgets('should show disabled badge for disabled queues',
        (WidgetTester tester) async {
      // Arrange
      const queues = [
        SimpleQueue(
          id: '*1',
          name: 'disabled-queue',
          target: '192.168.3.0/24',
          maxLimit: '1M/1M',
          disabled: true,
        ),
      ];

      const state = QueuesLoaded(queues);

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('disabled-queue'), findsOneWidget);
      expect(find.text('1 Disabled'), findsOneWidget);
    });

    testWidgets('should display loading during operation',
        (WidgetTester tester) async {
      // Arrange
      const state = QueueOperationInProgress();

      // Act
      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
