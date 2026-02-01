import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_shadow.dart' as mdev;

import '../components/demo_section.dart';

class WrapDemo extends StatelessWidget {
  const WrapDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Wrap Widget',
      description: 'Flow layout that wraps children to next line.',
      demo: _buildDemo(),
    );
  }

  Widget _buildDemo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: mdev.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _chip('Flutter'),
          _chip('Dart'),
          _chip('Widgets'),
          _chip('Config'),
          _chip('Live Edit'),
          _chip('WebSocket'),
          _chip('Provider'),
          _chip('Stack ID'),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.deepPurple.shade700),
      ),
    );
  }
}
