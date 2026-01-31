import 'package:flutter/material.dart' hide Padding;
import 'package:flutter/material.dart' as material show Padding;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Padding extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final String callerId;

  Padding({
    super.key,
    required this.child,
    required this.padding,
  }) : callerId = extractCallerId();

  @override
  State<Padding> createState() => _PaddingState();

  /// Property descriptors for Padding widget.
  static final props = <PropDescriptor>[
    ...CommonProps.all,
    NumberProp('paddingTop', label: 'Top', min: 0, step: 1),
    NumberProp('paddingRight', label: 'Right', min: 0, step: 1),
    NumberProp('paddingBottom', label: 'Bottom', min: 0, step: 1),
    NumberProp('paddingLeft', label: 'Left', min: 0, step: 1),
    NumberProp('paddingAll', label: 'All (uniform)', min: 0, step: 1),
  ];
}

class _PaddingState extends State<Padding> with ConfigurableWidgetMixin<Padding> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Padding';

  @override
  List<PropDescriptor> get propDescriptors => Padding.props;

  @override
  Map<String, dynamic> get additionalInitialValues {
    // Resolve the EdgeInsetsGeometry to EdgeInsets to get the actual values
    final resolved = widget.padding.resolve(TextDirection.ltr);
    return {
      'paddingTop': resolved.top,
      'paddingRight': resolved.right,
      'paddingBottom': resolved.bottom,
      'paddingLeft': resolved.left,
    };
  }

  @override
  Widget build(BuildContext context) {
    return buildWithConfigOnly(
      builder: (config) {
        EdgeInsetsGeometry effectivePadding = widget.padding;

        if (config != null) {
          // Check if "all" is set - it overrides individual values
          final all = config.get('paddingAll');
          if (all != null && all is num) {
            effectivePadding = EdgeInsets.all(all.toDouble());
          } else {
            // Use individual values, falling back to original widget.padding
            final resolved = widget.padding.resolve(TextDirection.ltr);
            final top = _parseNum(config.get('paddingTop')) ?? resolved.top;
            final right = _parseNum(config.get('paddingRight')) ?? resolved.right;
            final bottom = _parseNum(config.get('paddingBottom')) ?? resolved.bottom;
            final left = _parseNum(config.get('paddingLeft')) ?? resolved.left;
            effectivePadding = EdgeInsets.only(
              top: top,
              right: right,
              bottom: bottom,
              left: left,
            );
          }
        }

        return material.Padding(
          padding: effectivePadding,
          child: widget.child,
        );
      },
    );
  }

  double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
