import 'dart:async';
import 'package:router_os_client/router_os_client.dart';

void main() async {
  final client = RouterOSClient(
    address: '192.168.85.1',
    port: 8788,
    useSsl: false,
    user: 'hsco',
    password: 'Hs-co@12321#',
  );

  try {
    print('Logging in...');
    final success = await client.login();
    print('Login result: $success');

    // Test 1: Regular print first
    print('\n--- Test 1: Regular /log/print ---');
    final logs = await client.talk(['/log/print']);
    print('Got ${logs.length} logs');
    if (logs.isNotEmpty) {
      print('First log: ${logs.first}');
    }

    // Test 2: Stream with follow-only using streamData
    print('\n--- Test 2: Stream with follow-only ---');
    print('Starting stream... (waiting 10 seconds for new logs)');
    print('Create some activity on the router to generate logs!');
    
    int count = 0;
    final completer = Completer<void>();
    
    // Set timeout
    Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        print('\nTimeout - stopping stream');
        client.cancelTagged('follow_test');
        completer.complete();
      }
    });
    
    // Listen to stream
    client.streamData('/log/print', {'follow-only': ''}, 'follow_test').listen(
      (data) {
        count++;
        print('Received log #$count: $data');
      },
      onError: (e) {
        print('Stream error: $e');
      },
      onDone: () {
        print('Stream done');
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    
    await completer.future;
    
    print('\n--- Results ---');
    print('Total logs received: $count');

  } catch (e, st) {
    print('Error: $e');
    print('Stack: $st');
  } finally {
    client.close();
    print('Connection closed');
  }
}
