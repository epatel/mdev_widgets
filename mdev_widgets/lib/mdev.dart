/// Convenience import that provides mdev widgets without prefix.
///
/// Usage:
/// ```dart
/// import 'package:mdev_widgets_demo/mdev.dart';
///
/// // Now use mdev widgets directly:
/// Text('hello')      // mdev.Text
/// Column(...)        // mdev.Column
/// Row(...)           // mdev.Row
/// Padding(...)       // mdev.Padding
/// // etc.
///
/// // If you need Flutter's original widgets, add:
/// import 'package:flutter/material.dart' as flutter;
/// // Then use: flutter.Text(...)
/// ```
library;

// Export Flutter material, hiding widgets that mdev overrides
export 'package:flutter/material.dart'
    hide Text, Column, Row, Padding, Wrap, Stack, AppBar, Container, SizedBox, Center, Expanded, Flexible;

// Export mdev widgets (they become available without prefix)
export 'package:mdev_widgets/mdev_widgets.dart'
    show
        Text,
        Column,
        Row,
        Padding,
        Wrap,
        Stack,
        AppBar,
        Container,
        SizedBox,
        Center,
        Expanded,
        Flexible,
        // Also export setup-related classes
        MdevSetup,
        WidgetConfigProvider,
        TextStyleConfig;
