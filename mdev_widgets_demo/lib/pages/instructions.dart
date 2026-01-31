import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: mdev.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mdev.Text('How to Use', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _step('1. Open the dashboard at http://localhost:8080'),
          _step('2. Find widgets grouped by type, then by file'),
          _step('3. Toggle "Highlight" to identify widgets'),
          _step('4. Modify properties to see live updates'),
          _step('5. Use registered styles for consistency'),
        ],
      ),
    );
  }

  Widget _step(String text) {
    return mdev.Text(text);
  }
}
