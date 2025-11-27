import 'package:flutter/material.dart';
import 'hotspot_users_page.dart';
import 'hotspot_active_users_page.dart';
import 'hotspot_servers_page.dart';
import 'hotspot_profiles_page.dart';

class HotspotPage extends StatelessWidget {
  const HotspotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Management'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCard(
            context,
            icon: Icons.people,
            title: 'Users',
            subtitle: 'Manage hotspot users',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HotspotUsersPage(),
                ),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.person,
            title: 'Active Users',
            subtitle: 'Online users',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HotspotActiveUsersPage(),
                ),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.router,
            title: 'Servers',
            subtitle: 'HotSpot servers',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HotspotServersPage(),
                ),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.settings,
            title: 'Profiles',
            subtitle: 'User profiles',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HotspotProfilesPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
