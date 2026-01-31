import 'package:flutter/material.dart' hide Expanded;
import 'package:flutter/material.dart' as material show Expanded;
import 'package:provider/provider.dart';

import '../models/widget_config.dart';
import '../providers/widget_config_provider.dart';
import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

/// Expanded widget that must remain unwrapped to work in Row/Column/Flex.
/// Config visualization is applied to the child instead.
class Expanded extends StatefulWidget {
  final Widget child;
  final int flex;
  final String callerId;

  Expanded({
    super.key,
    required this.child,
    this.flex = 1,
  }) : callerId = extractCallerId();

  @override
  State<Expanded> createState() => _ExpandedState();

  static final props = <PropDescriptor>[
    ...CommonProps.all,
    NumberProp('flex', label: 'Flex', min: 1, step: 1, defaultValue: 1),
  ];
}

class _ExpandedState extends State<Expanded> {
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
    final schema = Expanded.props.map((p) => p.toSchema()).toList();
    final values = <String, dynamic>{};
    for (final prop in Expanded.props) {
      values[prop.key] = prop.serializableDefault;
    }
    values['flex'] = widget.flex;

    context.read<WidgetConfigProvider>().registerWithSchema(
      widget.callerId,
      'Expanded',
      schema: schema,
      values: values,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final effectiveFlex = _parseInt(config?.get('flex')) ?? widget.flex;

    // Visibility check - if not visible, return empty Expanded
    if (config != null && config.get('visible', true) == false) {
      return material.Expanded(
        flex: effectiveFlex,
        child: const SizedBox.shrink(),
      );
    }

    // Build child with optional highlight
    Widget child = widget.child;
    if (config?.get('highlight', false) == true) {
      child = wrapWithHighlight(child);
    }

    return material.Expanded(
      flex: effectiveFlex,
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
}
