import 'package:flutter/material.dart';

import '../models/widget_config.dart';

/// Utilities for resolving styles from the StyleRegistry.
class StyleUtils {
  StyleUtils._();

  /// Resolve a text style from the registry by name.
  ///
  /// Returns [fallback] if [styleName] is null, empty, or not found.
  static TextStyle resolveTextStyle(
    StyleRegistry styles,
    String? styleName, {
    required TextStyle fallback,
  }) {
    if (styleName == null || styleName.isEmpty) return fallback;

    final config = styles.getTextStyle(styleName);
    if (config == null) return fallback;

    return textStyleFromConfig(config);
  }

  /// Convert a TextStyleConfig to a Flutter TextStyle.
  static TextStyle textStyleFromConfig(TextStyleConfig config) {
    return TextStyle(
      fontSize: config.fontSize,
      fontWeight: parseFontWeight(config.fontWeight),
      fontStyle: config.fontStyle == 'italic' ? FontStyle.italic : null,
      color: parseColor(config.color),
      letterSpacing: config.letterSpacing,
      height: config.height,
    );
  }

  /// Parse a font weight string to FontWeight.
  static FontWeight? parseFontWeight(String? weight) {
    switch (weight) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return null;
    }
  }

  /// Parse a hex color string to Color.
  ///
  /// Supports formats: #RGB, #RRGGBB, #AARRGGBB
  static Color? parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceFirst('#', '');
      if (hex.length == 3) {
        // #RGB -> #RRGGBB
        final r = hex[0];
        final g = hex[1];
        final b = hex[2];
        return Color(int.parse('FF$r$r$g$g$b$b', radix: 16));
      } else if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Resolve a color from the registry by name, respecting theme.
  static Color? resolveColor(
    StyleRegistry styles,
    String? colorName, {
    required bool isDark,
  }) {
    if (colorName == null || colorName.isEmpty) return null;
    final colorHex = styles.getColor(colorName, isDark: isDark);
    return parseColor(colorHex);
  }

  /// Resolve a size from the registry by name.
  static double? resolveSize(StyleRegistry styles, String? sizeName) {
    if (sizeName == null || sizeName.isEmpty) return null;
    return styles.getSize(sizeName);
  }
}

/// Extension on StyleRegistry for convenient style resolution.
extension StyleRegistryExtension on StyleRegistry {
  /// Resolve a text style by name with a fallback.
  TextStyle resolveTextStyle(String? styleName, {required TextStyle fallback}) =>
      StyleUtils.resolveTextStyle(this, styleName, fallback: fallback);

  /// Resolve a color by name, respecting theme.
  Color? resolveColor(String? colorName, {required bool isDark}) =>
      StyleUtils.resolveColor(this, colorName, isDark: isDark);

  /// Resolve a size by name.
  double? resolveSize(String? sizeName) =>
      StyleUtils.resolveSize(this, sizeName);
}
