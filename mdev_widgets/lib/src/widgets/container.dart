import 'package:flutter/material.dart' hide Container;
import 'package:flutter/material.dart' as material show Container;

import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Container extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Decoration? decoration;
  final String callerId;

  Container({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.width,
    this.height,
    this.alignment,
    this.decoration,
  }) : callerId = extractCallerId();

  @override
  State<Container> createState() => _ContainerState();

  static final props = <PropDescriptor>[
    ...CommonProps.all,
    // Padding
    NumberProp('paddingTop', label: 'Padding Top', min: 0, step: 1),
    NumberProp('paddingRight', label: 'Padding Right', min: 0, step: 1),
    NumberProp('paddingBottom', label: 'Padding Bottom', min: 0, step: 1),
    NumberProp('paddingLeft', label: 'Padding Left', min: 0, step: 1),
    NumberProp('paddingAll', label: 'Padding All', min: 0, step: 1),
    // Margin
    NumberProp('marginTop', label: 'Margin Top', min: 0, step: 1),
    NumberProp('marginRight', label: 'Margin Right', min: 0, step: 1),
    NumberProp('marginBottom', label: 'Margin Bottom', min: 0, step: 1),
    NumberProp('marginLeft', label: 'Margin Left', min: 0, step: 1),
    NumberProp('marginAll', label: 'Margin All', min: 0, step: 1),
    // Size
    NumberProp('width', label: 'Width', min: 0),
    NumberProp('height', label: 'Height', min: 0),
    // Color
    ColorProp('color', label: 'Background Color'),
    // Alignment
    AlignmentProp('alignment', label: 'Alignment'),
  ];
}

class _ContainerState extends State<Container> with ConfigurableWidgetMixin<Container> {
  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Container';

  @override
  List<PropDescriptor> get propDescriptors => Container.props;

  @override
  Map<String, dynamic> get additionalInitialValues {
    final values = <String, dynamic>{};

    // Padding
    if (widget.padding != null) {
      final p = widget.padding!.resolve(TextDirection.ltr);
      values['paddingTop'] = p.top;
      values['paddingRight'] = p.right;
      values['paddingBottom'] = p.bottom;
      values['paddingLeft'] = p.left;
    }

    // Margin
    if (widget.margin != null) {
      final m = widget.margin!.resolve(TextDirection.ltr);
      values['marginTop'] = m.top;
      values['marginRight'] = m.right;
      values['marginBottom'] = m.bottom;
      values['marginLeft'] = m.left;
    }

    // Size
    if (widget.width != null) values['width'] = widget.width;
    if (widget.height != null) values['height'] = widget.height;

    return values;
  }

  @override
  Widget build(BuildContext context) {
    return buildWithConfig(
      builder: (config, styles) {
        // Padding
        EdgeInsetsGeometry? effectivePadding = widget.padding;
        if (config != null) {
          final all = _parseNum(config.get('paddingAll'));
          if (all != null) {
            effectivePadding = EdgeInsets.all(all);
          } else {
            final resolved = widget.padding?.resolve(TextDirection.ltr);
            final top = _parseNum(config.get('paddingTop')) ?? resolved?.top;
            final right = _parseNum(config.get('paddingRight')) ?? resolved?.right;
            final bottom = _parseNum(config.get('paddingBottom')) ?? resolved?.bottom;
            final left = _parseNum(config.get('paddingLeft')) ?? resolved?.left;
            if (top != null || right != null || bottom != null || left != null) {
              effectivePadding = EdgeInsets.only(
                top: top ?? 0,
                right: right ?? 0,
                bottom: bottom ?? 0,
                left: left ?? 0,
              );
            }
          }
        }

        // Margin
        EdgeInsetsGeometry? effectiveMargin = widget.margin;
        if (config != null) {
          final all = _parseNum(config.get('marginAll'));
          if (all != null) {
            effectiveMargin = EdgeInsets.all(all);
          } else {
            final resolved = widget.margin?.resolve(TextDirection.ltr);
            final top = _parseNum(config.get('marginTop')) ?? resolved?.top;
            final right = _parseNum(config.get('marginRight')) ?? resolved?.right;
            final bottom = _parseNum(config.get('marginBottom')) ?? resolved?.bottom;
            final left = _parseNum(config.get('marginLeft')) ?? resolved?.left;
            if (top != null || right != null || bottom != null || left != null) {
              effectiveMargin = EdgeInsets.only(
                top: top ?? 0,
                right: right ?? 0,
                bottom: bottom ?? 0,
                left: left ?? 0,
              );
            }
          }
        }

        // Size
        final effectiveWidth = _parseNum(config?.get('width')) ?? widget.width;
        final effectiveHeight = _parseNum(config?.get('height')) ?? widget.height;

        // Color
        final colorValue = config?.get('color');
        final effectiveColor = parseColor(colorValue) ?? widget.color;

        // Alignment
        final alignmentValue = config?.get('alignment');
        final effectiveAlignment = alignmentValue != null
            ? const AlignmentProp('', label: '').parse(alignmentValue, widget.alignment ?? Alignment.topLeft)
            : widget.alignment;

        return material.Container(
          padding: effectivePadding,
          margin: effectiveMargin,
          width: effectiveWidth,
          height: effectiveHeight,
          color: widget.decoration == null ? effectiveColor : null,
          alignment: effectiveAlignment,
          decoration: widget.decoration,
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
