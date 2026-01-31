import 'package:flutter/material.dart' hide Row;
import 'package:flutter/material.dart' as material show Row;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Row extends StatefulWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final String callerId;

  Row({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : callerId = extractCallerId();

  @override
  State<Row> createState() => _RowState();

  /// Property descriptors for Row widget.
  static final props = <PropDescriptor>[
    SizeProp('spacing', label: 'Spacing', prefix: 'spacing-'),
    EnumProp('mainAxisAlignment',
      label: 'Main Axis',
      values: MainAxisAlignment.values,
      defaultValue: MainAxisAlignment.start,
    ),
    EnumProp('crossAxisAlignment',
      label: 'Cross Axis',
      values: CrossAxisAlignment.values,
      defaultValue: CrossAxisAlignment.center,
    ),
    ...CommonProps.all,
  ];
}

class _RowState extends State<Row> with ConfigurableWidgetMixin<Row> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Row';

  @override
  List<PropDescriptor> get propDescriptors => Row.props;

  @override
  Widget build(BuildContext context) {
    return buildWithConfig(
      builder: (config, styles) {
        // Only apply config values when explicitly set (not null)
        final configSpacing = config?.get('spacing');
        final configMainAxis = config?.get('mainAxisAlignment');
        final configCrossAxis = config?.get('crossAxisAlignment');

        final spacing = configSpacing != null ? parseSize(configSpacing, styles) ?? 0.0 : 0.0;
        final mainAxis = configMainAxis != null
            ? parseMainAxisAlignment(configMainAxis, widget.mainAxisAlignment)
            : widget.mainAxisAlignment;
        final crossAxis = configCrossAxis != null
            ? parseCrossAxisAlignment(configCrossAxis, widget.crossAxisAlignment)
            : widget.crossAxisAlignment;

        return material.Row(
          mainAxisAlignment: mainAxis,
          crossAxisAlignment: crossAxis,
          mainAxisSize: widget.mainAxisSize,
          children: spacing > 0
              ? _addSpacing(widget.children, spacing)
              : widget.children,
        );
      },
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }
}
