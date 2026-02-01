import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_widgets.dart';
import 'package:provider/provider.dart';

import 'info_card_mdev.dart';

/// A configurable info card widget.
///
/// All InfoCard instances share the same config.
/// Changes in the dashboard affect every InfoCard in the app.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WidgetConfigProvider>();
    final config = infoCardAdapter.resolve(provider);
    final styles = provider.styles;

    // Visibility
    if (!config.visible) {
      return const SizedBox.shrink();
    }

    // Resolve text styles using mdev utilities
    final titleStyle = styles.resolveTextStyle(
      config.titleStyle,
      fallback: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
    final subtitleStyle = styles.resolveTextStyle(
      config.subtitleStyle,
      fallback: TextStyle(fontSize: 12, color: Colors.grey.shade600),
    );
    final descriptionStyle = styles.resolveTextStyle(
      config.descriptionStyle,
      fallback: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
    );

    Widget result = SizedBox(
      width: 280,
      child: DecoratedBox(
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
        child: Padding(
          padding: EdgeInsets.all(config.innerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(config.iconPadding),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: config.iconSize),
                  ),
                  SizedBox(width: config.headerSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: titleStyle),
                        Text(subtitle, style: subtitleStyle),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: config.contentSpacing),
              // Description
              Text(description, style: descriptionStyle),
            ],
          ),
        ),
      ),
    );

    // Highlight
    if (config.highlight) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  color: Colors.orange.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return result;
  }
}
