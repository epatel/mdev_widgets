import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/widget_config.dart';

class ConfigPersistence {
  static const String _widgetsKey = 'widget_configs';
  static const String _stylesKey = 'style_registry';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveWidgetConfigs(Map<String, WidgetConfig> configs) async {
    if (_prefs == null) return;

    final jsonList = configs.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _prefs!.setString(_widgetsKey, jsonEncode(jsonList));
  }

  Map<String, WidgetConfig> loadWidgetConfigs() {
    if (_prefs == null) return {};

    final jsonString = _prefs!.getString(_widgetsKey);
    if (jsonString == null) return {};

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonMap.map(
        (key, value) => MapEntry(
          key,
          WidgetConfig.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      debugPrint('Error loading widget configs: $e');
      return {};
    }
  }

  Future<void> saveStyles(Map<String, dynamic> styles) async {
    if (_prefs == null) return;
    await _prefs!.setString(_stylesKey, jsonEncode(styles));
  }

  Map<String, dynamic> loadStyles() {
    if (_prefs == null) return {};

    final jsonString = _prefs!.getString(_stylesKey);
    if (jsonString == null) return {};

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading styles: $e');
      return {};
    }
  }

  Future<void> clear() async {
    await _prefs?.remove(_widgetsKey);
    await _prefs?.remove(_stylesKey);
  }
}
