import 'package:flutter/material.dart' hide Column;
import 'package:flutter/material.dart' as material show Column;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Column extends StatefulWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final String callerId;

  Column({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : callerId = extractCallerId();

  @override
  State<Column> createState() => _ColumnState();

  /// Property descriptors for Column widget.
  static final props = <PropDescriptor>[
    SizeProp('padding', label: 'Padding', prefix: 'padding-'),
    SizeProp('spacing', label: 'Spacing', prefix: 'spacing-'),
    ColorProp('backgroundColor', label: 'Background'),
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

class _ColumnState extends State<Column> with ConfigurableWidgetMixin<Column> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Column';

  @override
  List<PropDescriptor> get propDescriptors => Column.props;

  @override
  Widget build(BuildContext context) {
    return buildWithConfig(
      builder: (config, styles) {
        // Only apply config values when explicitly set (not null)
        final configPadding = config?.get('padding');
        final configSpacing = config?.get('spacing');
        final configBgColor = config?.get('backgroundColor');
        final configMainAxis = config?.get('mainAxisAlignment');
        final configCrossAxis = config?.get('crossAxisAlignment');

        final padding = configPadding != null ? parseSize(configPadding, styles) ?? 0.0 : 0.0;
        final spacing = configSpacing != null ? parseSize(configSpacing, styles) ?? 0.0 : 0.0;
        final bgColor = configBgColor != null ? parseColor(configBgColor) : null;
        final mainAxis = configMainAxis != null
            ? parseMainAxisAlignment(configMainAxis, widget.mainAxisAlignment)
            : widget.mainAxisAlignment;
        final crossAxis = configCrossAxis != null
            ? parseCrossAxisAlignment(configCrossAxis, widget.crossAxisAlignment)
            : widget.crossAxisAlignment;

        Widget column = material.Column(
          mainAxisAlignment: mainAxis,
          crossAxisAlignment: crossAxis,
          mainAxisSize: widget.mainAxisSize,
          children: spacing > 0
              ? _addSpacing(widget.children, spacing)
              : widget.children,
        );

        if (bgColor != null) {
          column = Container(color: bgColor, child: column);
        }

        if (padding > 0) {
          column = Padding(padding: EdgeInsets.all(padding), child: column);
        }

        return column;
      },
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}
