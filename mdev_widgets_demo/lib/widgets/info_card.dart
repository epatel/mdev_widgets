import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

/// Shared configuration for all InfoCard widgets.
///
/// This config is registered once and applies to ALL InfoCard instances.
/// Changes in the dashboard affect every InfoCard in the app.
class InfoCardConfig {
  static const String configId = 'InfoCard.config';
  static const String widgetType = 'InfoCard';

  static final List<mdev.PropDescriptor> props = [
    // Common
    mdev.BoolProp('visible', label: 'Visible', defaultValue: true),
    mdev.BoolProp('highlight', label: 'Highlight', defaultValue: false),
    // Layout
    mdev.NumberProp('innerPadding', label: 'Inner Padding', defaultValue: 16, min: 0, max: 48, step: 4),
    mdev.NumberProp('headerSpacing', label: 'Header Spacing', defaultValue: 12, min: 0, max: 32, step: 4),
    mdev.NumberProp('contentSpacing', label: 'Content Spacing', defaultValue: 12, min: 0, max: 32, step: 4),
    // Typography
    mdev.NumberProp('titleFontSize', label: 'Title Size', defaultValue: 16, min: 12, max: 32, step: 1),
    mdev.NumberProp('subtitleFontSize', label: 'Subtitle Size', defaultValue: 12, min: 10, max: 24, step: 1),
    mdev.NumberProp('descriptionFontSize', label: 'Description Size', defaultValue: 14, min: 10, max: 24, step: 1),
    // Colors
    mdev.ColorProp('titleColor', label: 'Title Color'),
    mdev.ColorProp('subtitleColor', label: 'Subtitle Color'),
    mdev.ColorProp('descriptionColor', label: 'Description Color'),
    // Icon
    mdev.NumberProp('iconSize', label: 'Icon Size', defaultValue: 24, min: 16, max: 48, step: 4),
    mdev.NumberProp('iconPadding', label: 'Icon Padding', defaultValue: 8, min: 0, max: 24, step: 2),
  ];

  /// Register the InfoCard config with the provider.
  /// Call this once at app startup.
  static void register(mdev.WidgetConfigProvider provider) {
    final schema = props.map((p) => p.toSchema()).toList();
    final values = <String, dynamic>{};
    for (final prop in props) {
      values[prop.key] = prop.serializableDefault;
    }
    provider.registerWithSchema(configId, widgetType, schema: schema, values: values);
  }
}

/// A configurable info card widget.
///
/// All InfoCard instances share the same config (InfoCard.config).
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
    return Selector<mdev.WidgetConfigProvider, mdev.WidgetConfig?>(
      selector: (_, provider) => provider.getConfig(InfoCardConfig.configId),
      builder: (context, config, child) {
        // Read config values with defaults
        final innerPadding = _getDouble(config, 'innerPadding', 16);
        final headerSpacing = _getDouble(config, 'headerSpacing', 12);
        final contentSpacing = _getDouble(config, 'contentSpacing', 12);

        final titleFontSize = _getDouble(config, 'titleFontSize', 16);
        final subtitleFontSize = _getDouble(config, 'subtitleFontSize', 12);
        final descriptionFontSize = _getDouble(config, 'descriptionFontSize', 14);

        final titleColor = _getColor(config, 'titleColor');
        final subtitleColor = _getColor(config, 'subtitleColor') ?? Colors.grey.shade600;
        final descriptionColor = _getColor(config, 'descriptionColor') ?? Colors.grey.shade700;

        final iconSize = _getDouble(config, 'iconSize', 24);
        final iconPadding = _getDouble(config, 'iconPadding', 8);

        // Visibility
        if (config?.get('visible', true) == false) {
          return const SizedBox.shrink();
        }

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
              padding: EdgeInsets.all(innerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: iconColor, size: iconSize),
                      ),
                      SizedBox(width: headerSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: contentSpacing),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      color: descriptionColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Highlight
        if (config?.get('highlight', false) == true) {
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
      },
    );
  }

  double _getDouble(mdev.WidgetConfig? config, String key, double defaultValue) {
    final value = config?.get(key);
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }

  Color? _getColor(mdev.WidgetConfig? config, String key) {
    final value = config?.get(key);
    if (value == null || value is! String || value.isEmpty) return null;
    try {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }
}
