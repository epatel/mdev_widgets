import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

import '../components/demo_section.dart';
import '../components/demo_box.dart';

class RowDemo extends StatelessWidget {
  const RowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Row Widget',
      description: 'Horizontal layout with configurable spacing and alignment.',
      demo: _buildDemo(),
    );
  }

  Widget _buildDemo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: mdev.Row(
        children: [
          DemoBox(label: 'A', color: Colors.red),
          DemoBox(label: 'B', color: Colors.purple),
          DemoBox(label: 'C', color: Colors.teal),
        ],
      ),
    );
  }
}
