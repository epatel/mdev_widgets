import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

import '../components/demo_section.dart';

class AppBarDemo extends StatelessWidget {
  const AppBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'AppBar Widget',
      description: 'Configurable app bar with title, colors, and elevation.',
      demo: _buildDemo(),
    );
  }

  Widget _buildDemo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 56,
        child: mdev.AppBar(
          title: const Text('Custom AppBar'),
          backgroundColor: Colors.teal,
        ),
      ),
    );
  }
}
