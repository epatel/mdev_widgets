class WidgetConfig {
  final String id;
  final String type;
  final Map<String, dynamic> properties;
  final List<Map<String, dynamic>>? schema;

  WidgetConfig({
    required this.id,
    required this.type,
    Map<String, dynamic>? properties,
    this.schema,
  }) : properties = properties ?? {};

  dynamic get(String key, [dynamic defaultValue]) =>
      properties[key] ?? defaultValue;

  void set(String key, dynamic value) => properties[key] = value;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'properties': properties,
    if (schema != null) 'schema': schema,
  };

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => WidgetConfig(
    id: json['id'] as String,
    type: json['type'] as String,
    properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
    schema: json['schema'] != null
        ? (json['schema'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : null,
  );

  WidgetConfig copyWith({Map<String, dynamic>? properties, List<Map<String, dynamic>>? schema}) => WidgetConfig(
    id: id,
    type: type,
    properties: properties ?? Map.from(this.properties),
    schema: schema ?? this.schema,
  );
}

class TextStyleConfig {
  final double? fontSize;
  final String? fontWeight;
  final String? fontStyle;
  final String? color;
  final double? letterSpacing;
  final double? height;

  const TextStyleConfig({
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.color,
    this.letterSpacing,
    this.height,
  });

  Map<String, dynamic> toJson() => {
    if (fontSize != null) 'fontSize': fontSize,
    if (fontWeight != null) 'fontWeight': fontWeight,
    if (fontStyle != null) 'fontStyle': fontStyle,
    if (color != null) 'color': color,
    if (letterSpacing != null) 'letterSpacing': letterSpacing,
    if (height != null) 'height': height,
  };

  factory TextStyleConfig.fromJson(Map<String, dynamic> json) => TextStyleConfig(
    fontSize: (json['fontSize'] as num?)?.toDouble(),
    fontWeight: json['fontWeight'] as String?,
    fontStyle: json['fontStyle'] as String?,
    color: json['color'] as String?,
    letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
    height: (json['height'] as num?)?.toDouble(),
  );
}

class ThemedColor {
  final String light;
  final String dark;

  const ThemedColor({required this.light, required this.dark});

  String forBrightness(bool isDark) => isDark ? dark : light;

  Map<String, String> toJson() => {'light': light, 'dark': dark};

  factory ThemedColor.fromJson(Map<String, dynamic> json) => ThemedColor(
    light: json['light'] as String? ?? '#000000',
    dark: json['dark'] as String? ?? '#ffffff',
  );
}

class StyleRegistry {
  final Map<String, ThemedColor> _colors = {};
  final Map<String, double> _sizes = {};
  final Map<String, TextStyleConfig> _textStyles = {};
  final Map<String, dynamic> _custom = {};

  void registerColor(String key, {required String light, required String dark}) {
    _colors[key] = ThemedColor(light: light, dark: dark);
  }

  void registerSize(String key, double value) => _sizes[key] = value;
  void registerTextStyle(String key, TextStyleConfig style) => _textStyles[key] = style;
  void register(String key, dynamic value) => _custom[key] = value;

  ThemedColor? getThemedColor(String key) => _colors[key];
  String? getColor(String key, {bool isDark = false}) => _colors[key]?.forBrightness(isDark);
  double? getSize(String key) => _sizes[key];
  TextStyleConfig? getTextStyle(String key) => _textStyles[key];
  dynamic get(String key) => _custom[key];

  Map<String, ThemedColor> get colors => Map.unmodifiable(_colors);
  Map<String, double> get sizes => Map.unmodifiable(_sizes);
  Map<String, TextStyleConfig> get textStyles => Map.unmodifiable(_textStyles);
  Map<String, dynamic> get custom => Map.unmodifiable(_custom);

  Map<String, dynamic> toJson() => {
    'colors': _colors.map((k, v) => MapEntry(k, v.toJson())),
    'sizes': _sizes,
    'textStyles': _textStyles.map((k, v) => MapEntry(k, v.toJson())),
    'custom': _custom,
  };

  void updateFromJson(Map<String, dynamic> json) {
    if (json['colors'] != null) {
      _colors.clear();
      (json['colors'] as Map).forEach((k, v) {
        if (v is Map) {
          _colors[k.toString()] = ThemedColor.fromJson(Map<String, dynamic>.from(v));
        }
      });
    }
    if (json['sizes'] != null) {
      _sizes.clear();
      (json['sizes'] as Map).forEach((k, v) => _sizes[k.toString()] = (v as num).toDouble());
    }
    if (json['textStyles'] != null) {
      _textStyles.clear();
      (json['textStyles'] as Map).forEach((k, v) =>
        _textStyles[k.toString()] = TextStyleConfig.fromJson(v as Map<String, dynamic>));
    }
    if (json['custom'] != null) {
      _custom.clear();
      (json['custom'] as Map).forEach((k, v) => _custom[k.toString()] = v);
    }
  }
}
