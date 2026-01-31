import 'package:flutter/material.dart' hide SizedBox;
import 'package:flutter/material.dart' as material show SizedBox;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class SizedBox extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final String callerId;

  SizedBox({
    super.key,
    this.child,
    this.width,
    this.height,
  }) : callerId = extractCallerId();

  /// Creates a SizedBox that expands to fill available space.
  SizedBox.expand({
    super.key,
    this.child,
  })  : width = double.infinity,
        height = double.infinity,
        callerId = extractCallerId();

  /// Creates a SizedBox that shrinks to fit its child.
  SizedBox.shrink({
    super.key,
    this.child,
  })  : width = 0,
        height = 0,
        callerId = extractCallerId();

  @override
  State<SizedBox> createState() => _SizedBoxState();

  static final props = <PropDescriptor>[
    ...CommonProps.all,
    NumberProp('width', label: 'Width', min: 0),
    NumberProp('height', label: 'Height', min: 0),
  ];
}

class _SizedBoxState extends State<SizedBox> with ConfigurableWidgetMixin<SizedBox> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'SizedBox';

  @override
  List<PropDescriptor> get propDescriptors => SizedBox.props;

  @override
  Map<String, dynamic> get additionalInitialValues {
    final values = <String, dynamic>{};
    if (widget.width != null && widget.width != double.infinity) {
      values['width'] = widget.width;
    }
    if (widget.height != null && widget.height != double.infinity) {
      values['height'] = widget.height;
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    return buildWithConfigOnly(
      builder: (config) {
        final effectiveWidth = _parseNum(config?.get('width')) ?? widget.width;
        final effectiveHeight = _parseNum(config?.get('height')) ?? widget.height;

        return material.SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
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
