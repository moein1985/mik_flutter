import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hsmik/features/snmp/presentation/pages/snmp_dashboard_page.dart';
import 'package:hsmik/features/snmp/presentation/bloc/snmp_monitor_bloc.dart';
import 'package:hsmik/features/snmp/presentation/bloc/snmp_monitor_state.dart';
import 'package:hsmik/features/snmp/presentation/bloc/snmp_monitor_event.dart';
import 'package:hsmik/features/snmp/presentation/bloc/saved_snmp_device_bloc.dart';
import 'package:hsmik/features/snmp/presentation/bloc/saved_snmp_device_state.dart';
import 'package:hsmik/features/snmp/presentation/bloc/saved_snmp_device_event.dart';
import 'package:hsmik/injection_container.dart' as di;

class MockSnmpMonitorBloc extends Mock implements SnmpMonitorBloc {}
class MockSavedSnmpDeviceBloc extends Mock implements SavedSnmpDeviceBloc {}

class _FakeSavedSnmpDeviceEvent extends Fake implements SavedSnmpDeviceEvent {}

void main() {
  late MockSnmpMonitorBloc mockMonitor;
  late MockSavedSnmpDeviceBloc mockSavedBloc;

  setUpAll(() {
    registerFallbackValue(_FakeSavedSnmpDeviceEvent());
  });

  setUp(() {
    mockMonitor = MockSnmpMonitorBloc();
    mockSavedBloc = MockSavedSnmpDeviceBloc();

    // default states
    when(() => mockMonitor.state).thenReturn(const SnmpMonitorInitial());
    whenListen(mockMonitor, const Stream<SnmpMonitorState>.empty(), initialState: const SnmpMonitorInitial());
    when(() => mockMonitor.close()).thenAnswer((_) async {});

    when(() => mockSavedBloc.state).thenReturn(const SavedSnmpDeviceLoaded(devices: []));
    whenListen(mockSavedBloc, const Stream<SavedSnmpDeviceState>.empty(), initialState: const SavedSnmpDeviceLoaded(devices: []));
    when(() => mockSavedBloc.close()).thenAnswer((_) async {});

    // register in DI so bottom sheet/dialog can fetch it
    di.sl.registerFactory<SavedSnmpDeviceBloc>(() => mockSavedBloc);
  });

  tearDown(() async {
    // Reset any registrations we added
    if (di.sl.isRegistered<SavedSnmpDeviceBloc>()) {
      await di.sl.reset(dispose: false);
    }
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<SnmpMonitorBloc>.value(
        value: mockMonitor,
        child: child,
      ),
    );
  }

  testWidgets('shows error SnackBar when refreshing with empty IP', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const SnmpDashboardPage()));

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.text('Please enter device IP address'), findsOneWidget);
  });

  testWidgets('adds FetchDataRequested when IP entered and refresh tapped', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const SnmpDashboardPage()));

    await tester.enterText(find.byType(TextField).at(0), '1.2.3.4');
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    verify(() => mockMonitor.add(const FetchDataRequested(ip: '1.2.3.4', community: 'public', port: 161))).called(1);
  });

  testWidgets('Save flow: open sheet -> Save Current -> Save dialog and emits SaveDevice', (tester) async {
    when(() => mockSavedBloc.state).thenReturn(const SavedSnmpDeviceLoaded(devices: []));
    whenListen(mockSavedBloc, Stream.fromIterable([const SavedSnmpDeviceLoaded(devices: [])]), initialState: const SavedSnmpDeviceLoaded(devices: []));

    await tester.pumpWidget(buildTestableWidget(const SnmpDashboardPage()));

    // fill IP so dialog default name is non-empty
    await tester.enterText(find.byType(TextField).at(0), '2.2.2.2');

    // open saved devices sheet
    await tester.tap(find.byTooltip('Saved Devices'));
    await tester.pumpAndSettle();

    // tap Save Current
    expect(find.text('Save Current'), findsOneWidget);
    await tester.tap(find.text('Save Current'));
    await tester.pumpAndSettle();

    // Save dialog should appear
    expect(find.text('Save SNMP Device'), findsOneWidget);

    // Press Save (name autofilled); Save dialog uses di.sl to add SaveDevice to bloc
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    // Snackbar should show success
    expect(find.text('Device saved successfully'), findsOneWidget);

    // Verify save event was added to the saved bloc (one SaveDevice call; the LoadSavedDevices call also happens)
    verify(() => mockSavedBloc.add(any(that: isA<SaveDevice>()))).called(1);
  });
}
