// lib/features/shell/presentation/screens/main_shell.dart

import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/home_config.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../home/presentation/screens/placeholder_screen.dart';

class MainShell extends StatefulWidget {
  final AppConfig appConfig;

  const MainShell({super.key, required this.appConfig});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<NavItemView> _tabs;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // build tabs from appConfig.navigation
    final navItems = widget.appConfig.navigation;

    // Ensure there's at least one tab
    if (navItems.isEmpty) {
      _tabs = [
        NavItemView(id: 'home', label: 'Home', icon: Icons.home_rounded),
      ];
    } else {
      _tabs = navItems
          .map(
            (n) => NavItemView(
              id: n.id,
              label: n.label,
              icon: _mapIconName(n.icon),
            ),
          )
          .toList();
    }

    // Home sections config
    final homeSections = HomeConfigLoader.loadSections(widget.appConfig);

    _pages = _tabs.map((tab) {
      if (tab.id == 'home') {
        return HomeScreen(appConfig: widget.appConfig, sections: homeSections);
      }

      // later you can map 'items', 'orders', 'profile' إلى screens حقيقية
      return PlaceholderScreen(title: tab.label);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: c.primary,
        unselectedItemColor: c.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        items: _tabs
            .map(
              (t) =>
                  BottomNavigationBarItem(icon: Icon(t.icon), label: t.label),
            )
            .toList(),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  IconData _mapIconName(String name) {
    switch (name) {
      case 'home':
        return Icons.home_rounded;
      case 'search':
        return Icons.search_rounded;
      case 'ticket':
        return Icons.confirmation_num_rounded;
      case 'user':
        return Icons.person_rounded;
      case 'bag':
        return Icons.shopping_bag_rounded;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.circle_rounded;
    }
  }
}

class NavItemView {
  final String id;
  final String label;
  final IconData icon;

  NavItemView({required this.id, required this.label, required this.icon});
}
