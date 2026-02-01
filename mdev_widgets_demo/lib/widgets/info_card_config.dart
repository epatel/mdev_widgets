/// Configuration data for InfoCard widgets.
///
/// A plain data class with toJson/fromJson - no mdev dependencies.
class InfoCardConfig {
  final bool visible;
  final bool highlight;
  final double innerPadding;
  final double headerSpacing;
  final double contentSpacing;
  final String? titleStyle;
  final String? subtitleStyle;
  final String? descriptionStyle;
  final double iconSize;
  final double iconPadding;

  const InfoCardConfig({
    this.visible = true,
    this.highlight = false,
    this.innerPadding = 16,
    this.headerSpacing = 12,
    this.contentSpacing = 12,
    this.titleStyle,
    this.subtitleStyle,
    this.descriptionStyle,
    this.iconSize = 24,
    this.iconPadding = 8,
  });

  /// Default configuration values.
  static const defaults = InfoCardConfig();

  Map<String, dynamic> toJson() => {
    'visible': visible,
    'highlight': highlight,
    'innerPadding': innerPadding,
    'headerSpacing': headerSpacing,
    'contentSpacing': contentSpacing,
    'titleStyle': titleStyle,
    'subtitleStyle': subtitleStyle,
    'descriptionStyle': descriptionStyle,
    'iconSize': iconSize,
    'iconPadding': iconPadding,
  };

  factory InfoCardConfig.fromJson(Map<String, dynamic> json) => InfoCardConfig(
    visible: json['visible'] as bool? ?? true,
    highlight: json['highlight'] as bool? ?? false,
    innerPadding: (json['innerPadding'] as num?)?.toDouble() ?? 16,
    headerSpacing: (json['headerSpacing'] as num?)?.toDouble() ?? 12,
    contentSpacing: (json['contentSpacing'] as num?)?.toDouble() ?? 12,
    titleStyle: json['titleStyle'] as String?,
    subtitleStyle: json['subtitleStyle'] as String?,
    descriptionStyle: json['descriptionStyle'] as String?,
    iconSize: (json['iconSize'] as num?)?.toDouble() ?? 24,
    iconPadding: (json['iconPadding'] as num?)?.toDouble() ?? 8,
  );

  InfoCardConfig copyWith({
    bool? visible,
    bool? highlight,
    double? innerPadding,
    double? headerSpacing,
    double? contentSpacing,
    String? titleStyle,
    String? subtitleStyle,
    String? descriptionStyle,
    double? iconSize,
    double? iconPadding,
  }) => InfoCardConfig(
    visible: visible ?? this.visible,
    highlight: highlight ?? this.highlight,
    innerPadding: innerPadding ?? this.innerPadding,
    headerSpacing: headerSpacing ?? this.headerSpacing,
    contentSpacing: contentSpacing ?? this.contentSpacing,
    titleStyle: titleStyle ?? this.titleStyle,
    subtitleStyle: subtitleStyle ?? this.subtitleStyle,
    descriptionStyle: descriptionStyle ?? this.descriptionStyle,
    iconSize: iconSize ?? this.iconSize,
    iconPadding: iconPadding ?? this.iconPadding,
  );
}
