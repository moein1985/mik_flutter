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
    await client.login();

    // Test 1: Regular print first
    final logs = await client.talk(['/log/print']);
    if (logs.isNotEmpty) {
      // First log: ${logs.first}
    }

    // Test 2: Stream with follow-only using streamData
    // Starting stream... (waiting 10 seconds for new logs)
    // Create some activity on the router to generate logs!
    
    final completer = Completer<void>();
    
    // Set timeout
    Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        client.cancelTagged('follow_test');
        completer.complete();
      }
    });
    
    // Listen to stream
    client.streamData('/log/print', {'follow-only': ''}, 'follow_test').listen(
      (data) {
        // Received log
      },
      onError: (e) {
        // Stream error
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    
    await completer.future;

  } catch (e) {
    // Error
  } finally {
    client.close();
  }
}
