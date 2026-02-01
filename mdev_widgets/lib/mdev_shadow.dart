/// Shadow import - replaces Flutter material.dart with mdev-configurable widgets.
///
/// Usage:
/// ```dart
/// import 'package:mdev_widgets/mdev_shadow.dart';
///
/// // Now use mdev widgets directly (no prefix needed):
/// Text('hello')      // mdev.Text (configurable)
/// Column(...)        // mdev.Column (configurable)
/// Row(...)           // mdev.Row (configurable)
/// Padding(...)       // mdev.Padding (configurable)
/// // etc.
///
/// // All other Flutter widgets work normally:
/// Scaffold(...)
/// ElevatedButton(...)
/// ```
///
/// If you need Flutter's original versions of shadowed widgets:
/// ```dart
/// import 'package:flutter/material.dart' as flutter;
/// flutter.Text(...)  // Original Flutter Text
/// ```
library;

// Export Flutter material, hiding widgets that mdev overrides
export 'package:flutter/material.dart'
    hide Text, Column, Row, Padding, Wrap, Stack, AppBar, Container, SizedBox, Center, Expanded, Flexible;

// Export mdev shadow widgets
export 'src/widgets/app_bar.dart';
export 'src/widgets/center.dart';
export 'src/widgets/column.dart';
export 'src/widgets/container.dart';
export 'src/widgets/expanded.dart';
export 'src/widgets/flexible.dart';
export 'src/widgets/padding.dart';
export 'src/widgets/row.dart';
export 'src/widgets/sized_box.dart';
export 'src/widgets/stack.dart';
export 'src/widgets/text.dart';
export 'src/widgets/wrap.dart';
