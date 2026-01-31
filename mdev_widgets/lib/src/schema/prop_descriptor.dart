import 'package:flutter/material.dart';

/// Base class for property descriptors that define widget configuration schema.
///
/// Each property descriptor knows:
/// - Its key, label, and default value
/// - How to serialize to schema JSON for the dashboard
/// - How to parse values from the server
abstract class PropDescriptor {
  final String key;
  final String label;
  final dynamic defaultValue;

  const PropDescriptor(this.key, {required this.label, this.defaultValue});

  /// Convert to schema JSON for server/dashboard.
  Map<String, dynamic> toSchema();

  /// Get the current default value.
  dynamic get value => defaultValue;

  /// Get a JSON-serializable initial value for the properties map.
  /// Override for types like enums that need conversion.
  dynamic get serializableDefault => defaultValue;
}

/// Boolean property (checkbox in dashboard).
class BoolProp extends PropDescriptor {
  const BoolProp(super.key, {required super.label, super.defaultValue = false});

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'bool',
    'label': label,
    'default': defaultValue,
  };

  bool parse(dynamic value) => value == true;
}

/// Number property (number input in dashboard).
class NumberProp extends PropDescriptor {
  final double? min;
  final double? max;
  final double? step;

  const NumberProp(super.key, {
    required super.label,
    super.defaultValue,
    this.min,
    this.max,
    this.step,
  });

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'number',
    'label': label,
    'default': defaultValue,
    if (min != null) 'min': min,
    if (max != null) 'max': max,
    if (step != null) 'step': step,
  };

  double? parse(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// String property (text input in dashboard).
class StringProp extends PropDescriptor {
  final String? placeholder;

  const StringProp(super.key, {
    required super.label,
    super.defaultValue = '',
    this.placeholder,
  });

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'string',
    'label': label,
    'default': defaultValue,
    if (placeholder != null) 'placeholder': placeholder,
  };

  String parse(dynamic value) => value?.toString() ?? '';
}

/// Text override property (shows default text as placeholder).
class TextOverrideProp extends PropDescriptor {
  const TextOverrideProp(super.key, {required super.label, super.defaultValue = ''});

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'textOverride',
    'label': label,
    'default': defaultValue,
  };

  String parse(dynamic value) => value?.toString() ?? '';
}

/// Color property (color picker with registered color dropdown).
class ColorProp extends PropDescriptor {
  const ColorProp(super.key, {required super.label, super.defaultValue});

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'color',
    'label': label,
    'default': defaultValue,
  };

  Color? parse(dynamic value) {
    if (value == null) return null;
    if (value is! String || value.isEmpty) return null;
    try {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }
}

/// Size property (size picker with registered size dropdown).
class SizeProp extends PropDescriptor {
  final String? prefix;

  const SizeProp(super.key, {
    required super.label,
    super.defaultValue,
    this.prefix,
  });

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'size',
    'label': label,
    'default': defaultValue,
    if (prefix != null) 'prefix': prefix,
  };

  double? parseWithRegistry(dynamic value, Map<String, double> sizes) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return null;
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
      return sizes[value];
    }
    return null;
  }
}

/// Enum property (dropdown in dashboard).
class EnumProp<T extends Enum> extends PropDescriptor {
  final List<T> values;

  const EnumProp(super.key, {
    required super.label,
    required this.values,
    required T super.defaultValue,
  });

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'enum',
    'label': label,
    'options': values.map((e) => e.name).toList(),
    'default': (defaultValue as T).name,
  };

  /// Enums are stored as null (use widget default) or string name.
  @override
  dynamic get serializableDefault => null;

  T parse(dynamic value) {
    if (value == null) return defaultValue as T;
    final name = value.toString();
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => defaultValue as T,
    );
  }
}

/// Text style property (text style dropdown).
class TextStyleProp extends PropDescriptor {
  const TextStyleProp(super.key, {required super.label, super.defaultValue = ''});

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'textStyle',
    'label': label,
    'default': defaultValue,
  };

  String parse(dynamic value) => value?.toString() ?? '';
}

/// Font weight property (dropdown with weight options).
class FontWeightProp extends PropDescriptor {
  static const options = [
    'normal', 'bold',
    'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900'
  ];

  const FontWeightProp(super.key, {required super.label, super.defaultValue});

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'enum',
    'label': label,
    'options': options,
    'default': defaultValue,
  };

  @override
  dynamic get serializableDefault => null;

  FontWeight? parse(dynamic value) {
    switch (value) {
      case 'bold': return FontWeight.bold;
      case 'w100': return FontWeight.w100;
      case 'w200': return FontWeight.w200;
      case 'w300': return FontWeight.w300;
      case 'w400': return FontWeight.w400;
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700;
      case 'w800': return FontWeight.w800;
      case 'w900': return FontWeight.w900;
      default: return null;
    }
  }
}

/// Font style property (normal/italic dropdown).
class FontStyleProp extends PropDescriptor {
  static const options = ['normal', 'italic'];

  const FontStyleProp(super.key, {required super.label, super.defaultValue});

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'enum',
    'label': label,
    'options': options,
    'default': defaultValue,
  };

  @override
  dynamic get serializableDefault => null;

  FontStyle? parse(dynamic value) {
    return value == 'italic' ? FontStyle.italic : null;
  }
}

/// Alignment property for Stack widget.
class AlignmentProp extends PropDescriptor {
  static const options = [
    'topLeft', 'topCenter', 'topRight',
    'centerLeft', 'center', 'centerRight',
    'bottomLeft', 'bottomCenter', 'bottomRight',
    'topStart', 'topEnd',
    'centerStart', 'centerEnd',
    'bottomStart', 'bottomEnd',
  ];

  const AlignmentProp(super.key, {required super.label, super.defaultValue = 'topStart'});

  @override
  Map<String, dynamic> toSchema() => {
    'key': key,
    'type': 'enum',
    'label': label,
    'options': options,
    'default': defaultValue,
  };

  @override
  dynamic get serializableDefault => null;

  AlignmentGeometry parse(dynamic value, AlignmentGeometry fallback) {
    switch (value) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      case 'topStart': return AlignmentDirectional.topStart;
      case 'topEnd': return AlignmentDirectional.topEnd;
      case 'centerStart': return AlignmentDirectional.centerStart;
      case 'centerEnd': return AlignmentDirectional.centerEnd;
      case 'bottomStart': return AlignmentDirectional.bottomStart;
      case 'bottomEnd': return AlignmentDirectional.bottomEnd;
      default: return fallback;
    }
  }
}
