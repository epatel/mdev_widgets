import 'package:flutter/material.dart' hide Flexible;
import 'package:flutter/material.dart' as material show Flexible;
import 'package:provider/provider.dart';

import '../models/widget_config.dart';
import '../providers/widget_config_provider.dart';
import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

/// Flexible widget that must remain unwrapped to work in Row/Column/Flex.
/// Config visualization is applied to the child instead.
class Flexible extends StatefulWidget {
  final Widget child;
  final int flex;
  final FlexFit fit;
  final String callerId;

  Flexible({
    super.key,
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
  }) : callerId = extractCallerId();

  @override
  State<Flexible> createState() => _FlexibleState();

  static final props = <PropDescriptor>[
    ...CommonProps.all,
    NumberProp('flex', label: 'Flex', min: 1, step: 1, defaultValue: 1),
    EnumProp<FlexFit>('fit', label: 'Fit', values: FlexFit.values, defaultValue: FlexFit.loose),
  ];
}

class _FlexibleState extends State<Flexible> {
  WidgetConfigProvider? _provider;
  WidgetConfig? _config;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerWidget();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<WidgetConfigProvider>();
    if (_provider != provider) {
      _provider?.removeListener(_onConfigChange);
      _provider = provider;
      _provider?.addListener(_onConfigChange);
      _updateConfig();
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onConfigChange);
    super.dispose();
  }

  void _onConfigChange() {
    _updateConfig();
  }

  void _updateConfig() {
    final newConfig = _provider?.getConfig(widget.callerId);
    if (newConfig != _config) {
      setState(() {
        _config = newConfig;
      });
    }
  }

  void _registerWidget() {
    final schema = Flexible.props.map((p) => p.toSchema()).toList();
    final values = <String, dynamic>{};
    for (final prop in Flexible.props) {
      values[prop.key] = prop.serializableDefault;
    }
    values['flex'] = widget.flex;

    context.read<WidgetConfigProvider>().registerWithSchema(
      widget.callerId,
      'Flexible',
      schema: schema,
      values: values,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final effectiveFlex = _parseInt(config?.get('flex')) ?? widget.flex;
    final effectiveFit = _parseFit(config?.get('fit')) ?? widget.fit;

    // Visibility check - if not visible, return empty Flexible
    if (config != null && config.get('visible', true) == false) {
      return material.Flexible(
        flex: effectiveFlex,
        fit: effectiveFit,
        child: const SizedBox.shrink(),
      );
    }

    // Build child with optional highlight
    Widget child = widget.child;
    if (config?.get('highlight', false) == true) {
      child = wrapWithHighlight(child);
    }

    return material.Flexible(
      flex: effectiveFlex,
      fit: effectiveFit,
      child: child,
    );
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  FlexFit? _parseFit(dynamic value) {
    if (value == null) return null;
    final name = value.toString();
    return FlexFit.values.firstWhere(
      (e) => e.name == name,
      orElse: () => widget.fit,
    );
  }
}
