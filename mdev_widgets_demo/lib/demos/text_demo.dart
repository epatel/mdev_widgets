import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

import '../components/demo_section.dart';

class TextDemo extends StatelessWidget {
  const TextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Text Widget',
      description: 'Configurable text with styles, colors, and font options.',
      demo: _buildDemo(),
    );
  }

  Widget _buildDemo() {
    return mdev.Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mdev.Text('Heading Style', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        mdev.Text('Subheading Style', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        mdev.Text('Body text with normal styling.'),
        const SizedBox(height: 8),
        mdev.Text('Caption text in italics', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      ],
    );
  }
}
