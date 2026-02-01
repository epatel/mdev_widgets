import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_shadow.dart' as mdev;

import '../components/demo_section.dart';
import '../components/demo_box.dart';

class ColumnDemo extends StatelessWidget {
  const ColumnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Column Widget',
      description: 'Vertical layout with configurable spacing, padding, and alignment.',
      demo: _buildDemo(),
    );
  }

  Widget _buildDemo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: mdev.Column(
        children: [
          DemoBox(label: 'Item 1', color: Colors.blue),
          DemoBox(label: 'Item 2', color: Colors.green),
          DemoBox(label: 'Item 3', color: Colors.orange),
        ],
      ),
    );
  }
}
