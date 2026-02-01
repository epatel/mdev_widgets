import '../models/widget_config.dart';
import '../providers/widget_config_provider.dart';
import 'prop_descriptor.dart';

/// Adapter for registering plain config classes with mdev.
///
/// Usage:
/// ```dart
/// final adapter = ConfigAdapter<MyConfig>(
///   configId: 'MyWidget.config',
///   widgetType: 'MyWidget',
///   props: [
///     BoolProp('visible', label: 'Visible', defaultValue: true),
///     NumberProp('padding', label: 'Padding', defaultValue: 16),
///   ],
///   fromJson: MyConfig.fromJson,
/// );
///
/// // Register with provider
/// adapter.register(provider);
///
/// // Read config in widget
/// final config = adapter.resolve(provider);
/// ```
class ConfigAdapter<T> {
  final String configId;
  final String widgetType;
  final List<PropDescriptor> props;
  final T Function(Map<String, dynamic>) fromJson;

  const ConfigAdapter({
    required this.configId,
    required this.widgetType,
    required this.props,
    required this.fromJson,
  });

  /// Generate schema JSON from props.
  List<Map<String, dynamic>> get schema =>
      props.map((p) => p.toSchema()).toList();

  /// Generate default values map from props.
  Map<String, dynamic> get defaultValues {
    final values = <String, dynamic>{};
    for (final prop in props) {
      values[prop.key] = prop.serializableDefault;
    }
    return values;
  }

  /// Register this config with the provider.
  void register(WidgetConfigProvider provider) {
    provider.registerWithSchema(
      configId,
      widgetType,
      schema: schema,
      values: defaultValues,
    );
  }

  /// Resolve the current config from the provider.
  ///
  /// Merges default values with any overrides from the dashboard.
  T resolve(WidgetConfigProvider provider) {
    final widgetConfig = provider.getConfig(configId);
    final json = Map<String, dynamic>.from(defaultValues);

    // Apply overrides
    if (widgetConfig != null) {
      for (final key in json.keys) {
        final override = widgetConfig.get(key);
        if (override != null) {
          json[key] = override;
        }
      }
    }

    return fromJson(json);
  }

  /// Get the raw WidgetConfig for more advanced use cases.
  WidgetConfig? getWidgetConfig(WidgetConfigProvider provider) =>
      provider.getConfig(configId);
}

/// Extension to make config resolution more convenient.
extension ConfigAdapterExtension on WidgetConfigProvider {
  /// Resolve a config using its adapter.
  T resolveConfig<T>(ConfigAdapter<T> adapter) => adapter.resolve(this);
}
