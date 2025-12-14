import 'package:flutter/foundation.dart';
import 'package:router_os_client/router_os_client.dart';


/// Example demonstrating the new tag functionality in RouterOSClient
void main() async {
  // Create client instance
  final client = RouterOSClient(
    address: '192.168.1.1',
    user: 'admin',
    password: 'password',
    verbose: true,
  );

  try {
    // Login to the device
    if (kDebugMode) {
      print('Logging in...');
    }
    bool loginSuccess = await client.login();
    if (!loginSuccess) {
      if (kDebugMode) {
        print('Login failed!');
      }
      return;
    }
    if (kDebugMode) {
      print('Login successful!');
    }

    // Example 1: Traditional usage (backward compatible)
    if (kDebugMode) {
      print('\n=== Example 1: Traditional Usage ===');
    }
    var interfaces = await client.talk('/interface/print');
    if (kDebugMode) {
      print('Found ${interfaces.length} interfaces');
    }

    // Example 2: Using tags for single commands
    if (kDebugMode) {
      print('\n=== Example 2: Single Tagged Command ===');
    }
    var taggedResponse = await client.talkTagged(
        '/system/resource/print',
        null,
        'system-info'
    );
    if (kDebugMode) {
      print('Response tag: ${taggedResponse.tag}');
    }
    if (kDebugMode) {
      print('Is done: ${taggedResponse.isDone}');
    }
    if (kDebugMode) {
      print('Data: ${taggedResponse.data}');
    }

    // Example 3: Multiple simultaneous commands with tags
    if (kDebugMode) {
      print('\n=== Example 3: Multiple Simultaneous Commands ===');
    }
    var commands = [
      TaggedCommand(
        command: '/interface/print',
        tag: 'interfaces-cmd',
      ),
      TaggedCommand(
        command: '/ip/address/print',
        tag: 'addresses-cmd',
      ),
      TaggedCommand(
        command: '/system/identity/print',
        tag: 'identity-cmd',
      ),
    ];

    await for (var response in client.talkMultiple(commands)) {
      if (kDebugMode) {
        print('Received response for tag: ${response.tag}');
      }
      if (kDebugMode) {
        print('Done: ${response.isDone}, Error: ${response.isError}');
      }
      if (kDebugMode) {
        print('Data count: ${response.data.length}');
      }

      if (response.isError) {
        if (kDebugMode) {
          print('Error: ${response.errorMessage}');
        }
      }
    }

    // Example 4: Long-running command with streaming and cancellation
    if (kDebugMode) {
      print('\n=== Example 4: Streaming with Cancellation ===');
    }
    String streamTag = 'interface-monitor';

    // Start streaming interface changes
    var streamFuture = _monitorInterfaces(client, streamTag);

    // Simulate some activity (wait 5 seconds then cancel)
    await Future.delayed(const Duration(seconds: 5));

    if (kDebugMode) {
      print('Cancelling interface monitor...');
    }
    await client.cancelTagged(streamTag);

    // Wait for stream to finish
    await streamFuture;

    // Example 5: Batch operations with different parameters
    if (kDebugMode) {
      print('\n=== Example 5: Batch Operations ===');
    }
    await _performBatchOperations(client);

  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  } finally {
    client.close();
    if (kDebugMode) {
      print('Connection closed.');
    }
  }
}

/// Example of monitoring interface changes
Future<void> _monitorInterfaces(RouterOSClient client, String tag) async {
  try {
    if (kDebugMode) {
      print('Starting interface monitoring with tag: $tag');
    }
    await for (var data in client.streamData('/interface/listen', null, tag)) {
      if (kDebugMode) {
        print('Interface change detected: $data');
      }
    }
    if (kDebugMode) {
      print('Interface monitoring stopped.');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Interface monitoring error: $e');
    }
  }
}

/// Example of performing batch operations
Future<void> _performBatchOperations(RouterOSClient client) async {
  var batchCommands = [
    TaggedCommand(
      command: '/system/resource/print',
      params: {'.proplist': 'cpu-load,free-memory,uptime'},
      tag: 'resource-info',
    ),
    TaggedCommand(
      command: '/interface/print',
      params: {'?type': 'ether'},
      tag: 'ethernet-interfaces',
    ),
    TaggedCommand(
      command: '/ip/route/print',
      params: {'?dst-address': '0.0.0.0/0'},
      tag: 'default-routes',
    ),
  ];

  var responseCount = 0;
  var totalCommands = batchCommands.length;

  await for (var response in client.talkMultiple(batchCommands)) {
    responseCount++;

    switch (response.tag) {
      case 'resource-info':
        if (kDebugMode) {
          print('System Resource Info:');
        }
        for (var item in response.data) {
          if (kDebugMode) {
            print('  CPU Load: ${item['cpu-load']}%');
          }
          if (kDebugMode) {
            print('  Free Memory: ${item['free-memory']} bytes');
          }
          if (kDebugMode) {
            print('  Uptime: ${item['uptime']}');
          }
        }
        break;

      case 'ethernet-interfaces':
        if (kDebugMode) {
          print('Ethernet Interfaces:');
        }
        for (var item in response.data) {
          if (kDebugMode) {
            print('  ${item['name']}: ${item['running'] == 'true' ? 'UP' : 'DOWN'}');
          }
        }
        break;

      case 'default-routes':
        if (kDebugMode) {
          print('Default Routes:');
        }
        for (var item in response.data) {
          if (kDebugMode) {
            print('  Gateway: ${item['gateway']}');
          }
        }
        break;
    }

    if (responseCount >= totalCommands) {
      break;
    }
  }
}
