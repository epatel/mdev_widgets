import 'package:flutter/material.dart';

import '../widgets/info_card.dart';

/// Demo showing how to create custom widgets with shared configuration.
///
/// All InfoCard instances share the same config (InfoCard.config).
/// Open the dashboard and look for the "InfoCard" section to configure:
/// - Padding and spacing
/// - Font sizes
/// - Colors
///
/// Changes affect ALL InfoCards on this page simultaneously.
class CustomWidgetDemo extends StatelessWidget {
  const CustomWidgetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Widget Config',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'All InfoCards share one config - changes affect all instances',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Multiple InfoCards - all use the same shared config
        const Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            InfoCard(
              icon: Icons.rocket_launch,
              iconColor: Colors.blue,
              title: 'Getting Started',
              subtitle: 'Quick setup guide',
              description: 'Learn how to integrate mdev widgets into your Flutter app.',
            ),
            InfoCard(
              icon: Icons.palette,
              iconColor: Colors.purple,
              title: 'Theming',
              subtitle: 'Customize appearance',
              description: 'Register colors, sizes, and text styles for your app.',
            ),
            InfoCard(
              icon: Icons.dashboard,
              iconColor: Colors.orange,
              title: 'Dashboard',
              subtitle: 'Live editing',
              description: 'Edit widget properties in real-time via the web dashboard.',
            ),
          ],
        ),

        const SizedBox(height: 32),
        const Text(
          'How It Works',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _step('1', 'Define InfoCardConfig with props (schema)'),
              const SizedBox(height: 8),
              _step('2', 'Register once at app startup'),
              const SizedBox(height: 8),
              _step('3', 'InfoCard reads from shared config'),
              const SizedBox(height: 8),
              _step('4', 'Dashboard shows "InfoCard" section'),
              const SizedBox(height: 8),
              _step('5', 'All InfoCards update together'),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Open the dashboard (make dashboard) and look for "InfoCard" under widget types. '
                  'Try changing innerPadding or titleFontSize!',
                  style: TextStyle(color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _step(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
