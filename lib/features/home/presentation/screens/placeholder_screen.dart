// lib/features/home/presentation/screens/placeholder_screen.dart

import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title screen', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
