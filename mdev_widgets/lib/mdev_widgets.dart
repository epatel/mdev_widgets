/// Core tools for building custom configurable widgets.
///
/// Use for creating custom configs like InfoCard:
/// ```dart
/// import 'package:mdev_widgets/mdev_widgets.dart';
///
/// final myAdapter = ConfigAdapter<MyConfig>(
///   configId: 'MyWidget.config',
///   widgetType: 'MyWidget',
///   props: [
///     BoolProp('visible', label: 'Visible', defaultValue: true),
///     NumberProp('padding', label: 'Padding', defaultValue: 16),
///   ],
///   fromJson: MyConfig.fromJson,
/// );
/// ```
///
/// For shadow widgets (Column, Row, Text, etc.), use:
/// ```dart
/// import 'package:mdev_widgets/mdev_shadow.dart' as mdev;
/// ```
library;

// Setup
export 'src/mdev_setup.dart';

// Schema & Config Tools
export 'src/schema/prop_descriptor.dart';
export 'src/schema/config_adapter.dart';

// Models
export 'src/models/widget_config.dart';

// Providers
export 'src/providers/widget_config_provider.dart';

// Utils
export 'src/utils/style_utils.dart';

// Services (advanced)
export 'src/services/config_socket.dart';
export 'src/services/config_persistence.dart';

// Low-level (rarely needed directly)
export 'src/widgets/stack_id_mixin.dart';
export 'src/schema/configurable_widget.dart';
