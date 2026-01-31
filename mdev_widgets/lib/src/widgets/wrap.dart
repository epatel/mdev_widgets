import 'package:flutter/material.dart' hide Wrap;
import 'package:flutter/material.dart' as material show Wrap;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Wrap extends StatefulWidget {
  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;
  final String callerId;

  Wrap({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
  }) : callerId = extractCallerId();

  @override
  State<Wrap> createState() => _WrapState();

  /// Property descriptors for Wrap widget.
  static final props = <PropDescriptor>[
    EnumProp('direction',
      label: 'Direction',
      values: Axis.values,
      defaultValue: Axis.horizontal,
    ),
    EnumProp('alignment',
      label: 'Alignment',
      values: WrapAlignment.values,
      defaultValue: WrapAlignment.start,
    ),
    SizeProp('spacing', label: 'Spacing', prefix: 'spacing-'),
    SizeProp('runSpacing', label: 'Run Spacing', prefix: 'spacing-'),
    ...CommonProps.all,
  ];
}

class _WrapState extends State<Wrap> with ConfigurableWidgetMixin<Wrap> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Wrap';

  @override
  List<PropDescriptor> get propDescriptors => Wrap.props;

  @override
  Widget build(BuildContext context) {
    return buildWithConfig(
      builder: (config, styles) {
        // Only apply config values when explicitly set (not null)
        final configDirection = config?.get('direction');
        final configAlignment = config?.get('alignment');
        final configSpacing = config?.get('spacing');
        final configRunSpacing = config?.get('runSpacing');

        final direction = configDirection != null
            ? Axis.values.firstWhere((e) => e.name == configDirection, orElse: () => widget.direction)
            : widget.direction;
        final alignment = configAlignment != null
            ? WrapAlignment.values.firstWhere((e) => e.name == configAlignment, orElse: () => widget.alignment)
            : widget.alignment;
        final spacing = configSpacing != null
            ? parseSize(configSpacing, styles) ?? widget.spacing
            : widget.spacing;
        final runSpacing = configRunSpacing != null
            ? parseSize(configRunSpacing, styles) ?? widget.runSpacing
            : widget.runSpacing;

        return material.Wrap(
          direction: direction,
          alignment: alignment,
          runAlignment: widget.runAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          spacing: spacing,
          runSpacing: runSpacing,
          children: widget.children,
        );
      },
    );
  }
}
