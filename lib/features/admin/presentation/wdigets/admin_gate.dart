import 'package:flutter/material.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

class AdminGate extends StatefulWidget {
  /// Allow ANY admin role by default
  final List<String> allowRoles;
  final WidgetBuilder builder;

  const AdminGate({
    super.key,
    this.allowRoles = const ['OWNER', 'SUPER_ADMIN', 'MANAGER'],
    required this.builder,
  });

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  final _store = AdminTokenStore();
  String? _role;
  String? _token;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final role = await _store.getRole();
    final token = await _store.getToken();
    if (!mounted) return;

    setState(() {
      _role = role;
      _token = token;
      _loading = false;
    });

    if (token == null || token.isEmpty || role == null || role.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }

    final allowed = widget.allowRoles.map((r) => r.toUpperCase()).toSet();
    if (!allowed.contains(role.toUpperCase())) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.builder(context);
  }
}
