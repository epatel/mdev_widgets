import 'package:flutter/material.dart' hide Center;
import 'package:flutter/material.dart' as material show Center;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Center extends StatefulWidget {
  final Widget? child;
  final double? widthFactor;
  final double? heightFactor;
  final String callerId;

  Center({
    super.key,
    this.child,
    this.widthFactor,
    this.heightFactor,
  }) : callerId = extractCallerId();

  @override
  State<Center> createState() => _CenterState();

  static final props = <PropDescriptor>[
    ...CommonProps.all,
    NumberProp('widthFactor', label: 'Width Factor', min: 0, step: 0.1),
    NumberProp('heightFactor', label: 'Height Factor', min: 0, step: 0.1),
  ];
}

class _CenterState extends State<Center> with ConfigurableWidgetMixin<Center> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Center';

  @override
  List<PropDescriptor> get propDescriptors => Center.props;

  @override
  Map<String, dynamic> get additionalInitialValues {
    final values = <String, dynamic>{};
    if (widget.widthFactor != null) values['widthFactor'] = widget.widthFactor;
    if (widget.heightFactor != null) values['heightFactor'] = widget.heightFactor;
    return values;
  }

  @override
  Widget build(BuildContext context) {
    return buildWithConfigOnly(
      builder: (config) {
        final effectiveWidthFactor = _parseNum(config?.get('widthFactor')) ?? widget.widthFactor;
        final effectiveHeightFactor = _parseNum(config?.get('heightFactor')) ?? widget.heightFactor;

        return material.Center(
          widthFactor: effectiveWidthFactor,
          heightFactor: effectiveHeightFactor,
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
