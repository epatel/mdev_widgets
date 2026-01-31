import 'package:flutter/material.dart' hide Stack;
import 'package:flutter/material.dart' as material show Stack;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Stack extends StatefulWidget {
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final StackFit fit;
  final Clip clipBehavior;
  final String callerId;

  Stack({
    super.key,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
  }) : callerId = extractCallerId();

  @override
  State<Stack> createState() => _StackState();

  /// Property descriptors for Stack widget.
  static final props = <PropDescriptor>[
    AlignmentProp('alignment', label: 'Alignment'),
    EnumProp('fit',
      label: 'Fit',
      values: StackFit.values,
      defaultValue: StackFit.loose,
    ),
    ...CommonProps.all,
  ];
}

class _StackState extends State<Stack> with ConfigurableWidgetMixin<Stack> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Stack';

  @override
  List<PropDescriptor> get propDescriptors => Stack.props;

  @override
  Widget build(BuildContext context) {
    return buildWithConfigOnly(
      builder: (config) {
        // Only apply config values when explicitly set (not null)
        final configAlignment = config?.get('alignment');
        final configFit = config?.get('fit');

        final alignment = configAlignment != null
            ? const AlignmentProp('', label: '').parse(configAlignment, widget.alignment)
            : widget.alignment;
        final fit = configFit != null
            ? StackFit.values.firstWhere((e) => e.name == configFit, orElse: () => widget.fit)
            : widget.fit;

        return material.Stack(
          alignment: alignment,
          fit: fit,
          clipBehavior: widget.clipBehavior,
          children: widget.children,
        );
      },
    );
  }
}
