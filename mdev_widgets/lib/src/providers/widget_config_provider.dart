import 'package:flutter/foundation.dart';

import '../models/widget_config.dart';
import '../services/config_persistence.dart';
import '../services/session_storage.dart'
    if (dart.library.js_interop) '../services/session_storage_web.dart';

typedef RegisterCallback = void Function(String id, String type, Map<String, dynamic> properties, {List<Map<String, dynamic>>? schema});
typedef UnregisterCallback = void Function(String id);
typedef StyleChangeCallback = void Function(Map<String, dynamic> styles);

class WidgetConfigProvider extends ChangeNotifier {
  static const _sessionKey = 'mdev_provider_session';

  bool _isActive = true;
  final String _sessionId;
  final SessionStorage _sessionStorage;

  /// Create a provider with optional custom session storage (for testing).
  WidgetConfigProvider({SessionStorage? sessionStorage})
      : _sessionId = DateTime.now().microsecondsSinceEpoch.toString(),
        _sessionStorage = sessionStorage ?? createSessionStorage() {
    // Store session ID so OLD providers can detect they're stale
    _sessionStorage.setItem(_sessionKey, _sessionId);
  }

  /// Check if this provider is still the current session
  bool get isCurrentSession {
    final current = _sessionStorage.getItem(_sessionKey);
    return current == _sessionId;
  }

  /// Deactivate this provider to ignore all updates (called before dispose)
  void deactivate() {
    _isActive = false;
  }

  final Map<String, WidgetConfig> _configs = {};
  final StyleRegistry _styles = StyleRegistry();
  final ConfigPersistence _persistence = ConfigPersistence();
  bool _initialized = false;

  RegisterCallback? onRegister;
  UnregisterCallback? onUnregister;
  StyleChangeCallback? onStyleChange;

  Map<String, WidgetConfig> get configs => Map.unmodifiable(_configs);
  StyleRegistry get styles => _styles;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    await _persistence.init();

    // Load persisted configs
    final savedConfigs = _persistence.loadWidgetConfigs();
    _configs.addAll(savedConfigs);

    _initialized = true;
    notifyListeners();
  }

  void register(String id, String type, {Map<String, dynamic>? properties}) {
    final isNew = !_configs.containsKey(id);
    if (isNew) {
      _configs[id] = WidgetConfig(id: id, type: type, properties: properties);
      _saveConfigs();
    }
    // Always notify socket so server gets registration (even if already in local cache)
    onRegister?.call(id, type, _configs[id]!.properties);
    if (isNew) {
      notifyListeners();
    }
  }

  /// Register a widget with schema information for the dashboard.
  void registerWithSchema(
    String id,
    String type, {
    required List<Map<String, dynamic>> schema,
    required Map<String, dynamic> values,
  }) {
    final isNew = !_configs.containsKey(id);
    if (isNew) {
      _configs[id] = WidgetConfig(id: id, type: type, properties: values, schema: schema);
      _saveConfigs();
    } else {
      // Update schema if missing (widget may have been persisted before schema support)
      final existing = _configs[id]!;
      if (existing.schema == null) {
        _configs[id] = WidgetConfig(
          id: id,
          type: type,
          properties: existing.properties,
          schema: schema,
        );
      }
    }
    // Always notify socket so server gets registration
    onRegister?.call(id, type, _configs[id]!.properties, schema: schema);
    if (isNew) {
      notifyListeners();
    }
  }

  void unregister(String id) {
    if (_configs.remove(id) != null) {
      _saveConfigs();
      onUnregister?.call(id);
      notifyListeners();
    }
  }

  WidgetConfig? getConfig(String id) => _configs[id];

  List<WidgetConfig> getConfigsByType(String type) =>
      _configs.values.where((c) => c.type == type).toList();

  void updateDefaultText(String id, String defaultText) {
    final config = _configs[id];
    if (config != null) {
      config.properties['defaultText'] = defaultText;
      _saveConfigs();
      onRegister?.call(id, config.type, config.properties);
      notifyListeners();
    }
  }

  void updateFromServer(String id, Map<String, dynamic> json) {
    if (!_isActive || !isCurrentSession) return;
    final existing = _configs[id];
    if (existing != null) {
      final serverProps = Map<String, dynamic>.from(json['properties'] as Map? ?? {});

      // Compute overrides: values that differ from registered defaults
      final overrides = <String, dynamic>{};
      for (final entry in serverProps.entries) {
        final defaultValue = existing.properties[entry.key];
        if (entry.value != defaultValue) {
          overrides[entry.key] = entry.value;
        }
      }

      _configs[id] = WidgetConfig(
        id: id,
        type: existing.type,
        properties: existing.properties,  // Keep original defaults
        overrides: overrides,              // Only store changed values
        schema: existing.schema,
      );
      _saveConfigs();
      notifyListeners();
    }
  }

  void updateStylesFromServer(Map<String, dynamic> json) {
    if (!_isActive || !isCurrentSession) return;
    _styles.updateFromJson(json);
    notifyListeners();
  }

  void registerColor(String key, {required String light, required String dark}) {
    _styles.registerColor(key, light: light, dark: dark);
    _notifyStyleChange();
    notifyListeners();
  }

  void registerSize(String key, double value) {
    _styles.registerSize(key, value);
    _notifyStyleChange();
    notifyListeners();
  }

  void registerTextStyle(String key, TextStyleConfig style) {
    _styles.registerTextStyle(key, style);
    _notifyStyleChange();
    notifyListeners();
  }

  void _notifyStyleChange() {
    onStyleChange?.call(_styles.toJson());
  }

  void _saveConfigs() {
    _persistence.saveWidgetConfigs(_configs);
  }

  /// Re-register all known widgets (called on reconnect)
  void reregisterAll() {
    for (final config in _configs.values) {
      onRegister?.call(config.id, config.type, config.properties, schema: config.schema);
    }
    onStyleChange?.call(_styles.toJson());
  }

  List<Map<String, dynamic>> toJsonList() =>
      _configs.values.map((c) => c.toJson()).toList();
}
