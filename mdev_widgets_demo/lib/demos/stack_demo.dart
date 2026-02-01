import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_shadow.dart' as mdev;

import '../components/demo_section.dart';

class StackDemo extends StatelessWidget {
  const StackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Stack Widget',
      description: 'Overlapping widgets with configurable alignment.',
      demo: _buildDemo(),
    );
  }

  Widget _buildDemo() {
    return SizedBox(
      height: 150,
      child: mdev.Stack(
        children: [
          _layer(0, Colors.blue.shade200, 150),
          Positioned(
            left: 30,
            top: 30,
            child: _layer(0, Colors.green.shade200, 120),
          ),
          Positioned(
            left: 60,
            top: 60,
            child: _layerWithText(Colors.orange.shade200, 90, 'Top'),
          ),
        ],
      ),
    );
  }

  Widget _layer(double offset, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _layerWithText(Color color, double size, String text) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(text)),
    );
  }
}
