import 'package:flutter/widgets.dart' as flutter;
import 'package:mdev_widgets/mdev.dart';

/// Demo showing how to build custom widgets with configurable internals.
///
/// The InfoCard widget uses mdev widgets for its internal layout,
/// making padding, spacing, and text styles configurable via the dashboard.
class CustomWidgetDemo extends StatelessWidget {
  const CustomWidgetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Widget Example',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Build your own widgets using mdev components for live configuration',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        SizedBox(height: 16),

        // Example cards using the custom InfoCard widget
        Wrap(
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

        SizedBox(height: 32),
        Text(
          'How It Works',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Use mdev widgets inside your custom widget',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'Replace Flutter\'s Column, Padding, Text with mdev versions',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              SizedBox(height: 12),
              Text(
                '2. Each mdev widget auto-registers by code location',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'Unique IDs are generated from file:line:column',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              SizedBox(height: 12),
              Text(
                '3. Open the dashboard to configure',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'Change padding, spacing, colors, font sizes live',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A custom card widget with configurable internals using mdev widgets.
///
/// The internal padding, spacing, and text styles can be adjusted via
/// the mdev dashboard without code changes.
class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  const InfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return flutter.SizedBox(
      width: 280,
      child: flutter.DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Outer padding - configurable via dashboard
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Main content column - spacing is configurable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon row
              Row(
                children: [
                  flutter.Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  SizedBox(width: 12),
                  // Title column - inner spacing configurable
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title text - font size configurable
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Subtitle text - color/size configurable
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Spacing between header and description - configurable
              SizedBox(height: 12),
              // Description text - all text properties configurable
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
