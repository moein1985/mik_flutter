import 'package:flutter/material.dart';

/// Asterisk PBX Dashboard Page
/// 
/// Main dashboard for Asterisk PBX module showing:
/// - Live system statistics
/// - Active calls monitoring
/// - Extension status
/// - Queue information
/// - System resources
class AsteriskDashboardPage extends StatelessWidget {
  const AsteriskDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asterisk PBX Dashboard'),
        backgroundColor: const Color(0xFFFF6600),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_in_talk,
              size: 100,
              color: const Color(0xFFFF6600),
            ),
            const SizedBox(height: 24),
            const Text(
              'Asterisk PBX Module',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Complete PBX management with real-time monitoring',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.dashboard, color: Color(0xFFFF6600)),
                      title: Text('Live System Dashboard'),
                    ),
                    ListTile(
                      leading: Icon(Icons.people, color: Color(0xFFFF6600)),
                      title: Text('Extension Management'),
                    ),
                    ListTile(
                      leading: Icon(Icons.call, color: Color(0xFFFF6600)),
                      title: Text('Active Call Monitoring'),
                    ),
                    ListTile(
                      leading: Icon(Icons.queue, color: Color(0xFFFF6600)),
                      title: Text('Queue Management'),
                    ),
                    ListTile(
                      leading: Icon(Icons.assessment, color: Color(0xFFFF6600)),
                      title: Text('CDR Reports'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
