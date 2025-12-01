import 'package:flutter/material.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _store = AdminTokenStore();
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _store.getRole();
    if (!mounted) return;
    setState(() => _role = role?.toUpperCase());
  }

  Future<void> _logout() async {
    await _store.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final role = _role ?? 'ADMIN';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RoleBanner(role: role),
          const SizedBox(height: 16),
          // put your shared admin widgets here
          _AdminTile(
            icon: Icons.analytics_outlined,
            title: 'Overview / Analytics',
            onTap: () {},
          ),
          _AdminTile(
            icon: Icons.store_mall_directory_outlined,
            title: 'Projects / Owners',
            onTap: () {},
          ),
          _AdminTile(
            icon: Icons.group_outlined,
            title: 'Users & Managers',
            onTap: () {},
          ),
          _AdminTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _RoleBanner extends StatelessWidget {
  final String role;
  const _RoleBanner({required this.role});

  Color _roleColor(BuildContext ctx) {
    switch (role) {
      case 'SUPER_ADMIN':
        return Colors.red.shade400;
      case 'OWNER':
        return Colors.indigo.shade400;
      case 'MANAGER':
        return Colors.teal.shade400;
      default:
        return Theme.of(ctx).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _roleColor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: c),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Signed in as $role',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
               
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: t.titleMedium),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
