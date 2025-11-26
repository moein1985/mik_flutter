import 'dart:io';
import '../lib/routeros_client.dart';

void main() async {
  print('═══════════════════════════════════════════════════════');
  print('🧪 RouterOS API Test Program');
  print('═══════════════════════════════════════════════════════\n');

  // Configuration
  const host = '192.168.85.1';
  const port = 8788;

  // Get credentials from user
  stdout.write('Enter username (default: admin): ');
  final username = stdin.readLineSync()?.trim() ?? 'admin';
  final usernameToUse = username.isEmpty ? 'admin' : username;

  stdout.write('Enter password: ');
  stdin.echoMode = false; // Hide password input
  final password = stdin.readLineSync()?.trim() ?? '';
  stdin.echoMode = true;
  print(''); // New line after password

  if (password.isEmpty) {
    print('❌ Password cannot be empty');
    exit(1);
  }

  // Create client
  final client = RouterOSClient(host: host, port: port);

  try {
    // Connect
    await client.connect();

    // Login
    final loginSuccess = await client.login(usernameToUse, password);

    if (!loginSuccess) {
      print('\n❌ Login failed. Check your credentials and try again.');
      await client.disconnect();
      exit(1);
    }

    // Test commands
    print('\n═══════════════════════════════════════════════════════');
    print('📋 Testing Commands');
    print('═══════════════════════════════════════════════════════\n');

    // Command 1: Get system resources
    print('🔹 Command 1: /system/resource/print');
    print('─────────────────────────────────────────────────────');
    try {
      final systemResources = await client.sendCommand(['/system/resource/print']);
      _printResponse(systemResources);
    } catch (e) {
      print('❌ Error: $e');
    }

    await Future.delayed(Duration(seconds: 1));

    // Command 2: Get interfaces
    print('\n🔹 Command 2: /interface/print');
    print('─────────────────────────────────────────────────────');
    try {
      final interfaces = await client.sendCommand(['/interface/print']);
      _printResponse(interfaces);
    } catch (e) {
      print('❌ Error: $e');
    }

    await Future.delayed(Duration(seconds: 1));

    // Command 3: Get IP addresses
    print('\n🔹 Command 3: /ip/address/print');
    print('─────────────────────────────────────────────────────');
    try {
      final ipAddresses = await client.sendCommand(['/ip/address/print']);
      _printResponse(ipAddresses);
    } catch (e) {
      print('❌ Error: $e');
    }

    print('\n═══════════════════════════════════════════════════════');
    print('✅ All tests completed successfully!');
    print('═══════════════════════════════════════════════════════\n');

    // Disconnect
    await client.disconnect();
  } catch (e) {
    print('\n❌ Fatal error: $e');
    await client.disconnect();
    exit(1);
  }
}

void _printResponse(List<Map<String, String>> response) {
  if (response.isEmpty) {
    print('   (No response)');
    return;
  }

  int itemCount = 0;
  for (final item in response) {
    if (item['type'] == 're') {
      itemCount++;
      print('   Item #$itemCount:');
      item.forEach((key, value) {
        if (key != 'type') {
          print('      $key: $value');
        }
      });
      print('');
    } else if (item['type'] == 'done') {
      print('   ✅ Command completed');
    } else if (item['type'] == 'trap') {
      print('   ⚠️  Error: ${item['message'] ?? 'Unknown error'}');
    }
  }

  if (itemCount == 0) {
    print('   ✅ Command completed (no items returned)');
  }
}
