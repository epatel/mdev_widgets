import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/widget_config.dart';
import '../providers/widget_config_provider.dart';
import 'prop_descriptor.dart';

/// Common properties shared by all configurable widgets.
class CommonProps {
  static const visible = BoolProp('visible', label: 'Visible', defaultValue: true);
  static const highlight = BoolProp('highlight', label: 'Highlight', defaultValue: false);

  static const List<PropDescriptor> all = [visible, highlight];
}

/// Mixin for StatefulWidget states that provides config registration and common build patterns.
mixin ConfigurableWidgetMixin<T extends StatefulWidget> on State<T> {
  /// The unique caller ID for this widget instance.
  String get callerId;

  /// The widget type name (e.g., 'Text', 'Column').
  String get widgetType;

  /// The property descriptors for this widget type.
  List<PropDescriptor> get propDescriptors;

  /// Additional initial values to include in registration (e.g., defaultText for Text).
  Map<String, dynamic> get additionalInitialValues => {};

  /// Register with the config provider on init.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerWidget();
    });
  }

  void _registerWidget() {
    final schema = propDescriptors.map((p) => p.toSchema()).toList();
    final values = <String, dynamic>{};
    for (final prop in propDescriptors) {
      values[prop.key] = prop.serializableDefault;
    }
    // Add any additional initial values
    values.addAll(additionalInitialValues);

    context.read<WidgetConfigProvider>().registerWithSchema(
      callerId,
      widgetType,
      schema: schema,
      values: values,
    );
  }

  /// Build the widget with config selector.
  ///
  /// The [builder] receives the config and styles, and should return the widget tree.
  /// Visibility and highlight are handled automatically.
  Widget buildWithConfig({
    required Widget Function(WidgetConfig? config, StyleRegistry styles) builder,
  }) {
    return Selector<WidgetConfigProvider, (WidgetConfig?, StyleRegistry)>(
      selector: (_, provider) => (provider.getConfig(callerId), provider.styles),
      builder: (context, data, child) {
        final (config, styles) = data;

        // Handle visibility
        if (config != null && config.get('visible', true) == false) {
          return const SizedBox.shrink();
        }

        // Build the widget
        Widget result = builder(config, styles);

        // Apply highlight overlay if enabled
        if (config?.get('highlight', false) == true) {
          result = wrapWithHighlight(result);
        }

        return result;
      },
    );
  }

  /// Build without StyleRegistry (for simpler widgets that don't need it).
  Widget buildWithConfigOnly({
    required Widget Function(WidgetConfig? config) builder,
  }) {
    return Selector<WidgetConfigProvider, WidgetConfig?>(
      selector: (_, provider) => provider.getConfig(callerId),
      builder: (context, config, child) {
        // Handle visibility
        if (config != null && config.get('visible', true) == false) {
          return const SizedBox.shrink();
        }

        // Build the widget
        Widget result = builder(config);

        // Apply highlight overlay if enabled
        if (config?.get('highlight', false) == true) {
          result = wrapWithHighlight(result);
        }

        return result;
      },
    );
  }
}

/// Wrap a widget with a highlight overlay.
Widget wrapWithHighlight(Widget child) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      child,
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

/// Parse a color from hex string.
Color? parseColor(dynamic value) {
  if (value == null) return null;
  if (value is! String || value.isEmpty) return null;
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

/// Parse a size value, looking up registered sizes if needed.
double? parseSize(dynamic value, StyleRegistry styles) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
    return styles.getSize(value);
  }
  return null;
}

/// Parse main axis alignment.
MainAxisAlignment parseMainAxisAlignment(dynamic value, MainAxisAlignment fallback) {
  if (value == null) return fallback;
  return MainAxisAlignment.values.firstWhere(
    (e) => e.name == value.toString(),
    orElse: () => fallback,
  );
}

/// Parse cross axis alignment.
CrossAxisAlignment parseCrossAxisAlignment(dynamic value, CrossAxisAlignment fallback) {
  if (value == null) return fallback;
  return CrossAxisAlignment.values.firstWhere(
    (e) => e.name == value.toString(),
    orElse: () => fallback,
  );
}

/// Parse font weight.
FontWeight? parseFontWeight(dynamic value) {
  switch (value) {
    case 'bold': return FontWeight.bold;
    case 'w100': return FontWeight.w100;
    case 'w200': return FontWeight.w200;
    case 'w300': return FontWeight.w300;
    case 'w400': return FontWeight.w400;
    case 'w500': return FontWeight.w500;
    case 'w600': return FontWeight.w600;
    case 'w700': return FontWeight.w700;
    case 'w800': return FontWeight.w800;
    case 'w900': return FontWeight.w900;
    default: return null;
  }
}

/// Parse font style.
FontStyle? parseFontStyle(dynamic value) {
  return value == 'italic' ? FontStyle.italic : null;
}
