import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

class DemoSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget demo;

  const DemoSection({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
  });

  @override
  Widget build(BuildContext context) {
    return mdev.Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mdev.Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6200ee))),
        const SizedBox(height: 4),
        mdev.Text(description, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        demo,
      ],
    );
  }
}
