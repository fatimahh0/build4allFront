// lib/features/shell/presentation/screens/main_shell.dart

import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
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

  @override
  Widget build(BuildContext context) {
    final navItems = widget.appConfig.navigation;

   
    final effectiveNavItems = navItems.isEmpty
        ? [
            NavItemConfig(id: 'home', label: 'Home', icon: 'home'),
            NavItemConfig(id: 'profile', label: 'Profile', icon: 'user'),
          ]
        : navItems;

    final pages = effectiveNavItems.map((nav) {
      switch (nav.id) {
        case 'home':
          return const HomeScreen();
        case 'orders':
          return const PlaceholderScreen(title: 'Orders');
        case 'items':
          return const PlaceholderScreen(title: 'Items');
        case 'explore':
          return const PlaceholderScreen(title: 'Explore');
        case 'communication':
          return const PlaceholderScreen(title: 'Communication');
        case 'profile':
          return const PlaceholderScreen(title: 'Profile');
        default:
          return PlaceholderScreen(title: nav.label);
      }
    }).toList();

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          for (final nav in effectiveNavItems)
            BottomNavigationBarItem(
              icon: Icon(_mapIcon(nav.icon)),
              label: nav.label,
            ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
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
        return Icons.circle;
    }
  }
}
