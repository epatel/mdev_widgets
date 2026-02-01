import 'package:mdev_widgets/mdev_widgets.dart';

import 'info_card_config.dart';
export 'info_card_config.dart';

/// Mdev adapter for InfoCardConfig.
///
/// Provides schema and registration for the dashboard.
final infoCardAdapter = ConfigAdapter<InfoCardConfig>(
  configId: 'InfoCard.config',
  widgetType: 'InfoCard',
  props: [
    // Common
    BoolProp('visible', label: 'Visible', defaultValue: true),
    BoolProp('highlight', label: 'Highlight', defaultValue: false),
    // Layout
    NumberProp('innerPadding', label: 'Inner Padding', defaultValue: 16, min: 0, max: 48, step: 4),
    NumberProp('headerSpacing', label: 'Header Spacing', defaultValue: 12, min: 0, max: 32, step: 4),
    NumberProp('contentSpacing', label: 'Content Spacing', defaultValue: 12, min: 0, max: 32, step: 4),
    // Typography (text style references)
    TextStyleProp('titleStyle', label: 'Title Style'),
    TextStyleProp('subtitleStyle', label: 'Subtitle Style'),
    TextStyleProp('descriptionStyle', label: 'Description Style'),
    // Icon
    NumberProp('iconSize', label: 'Icon Size', defaultValue: 24, min: 16, max: 48, step: 4),
    NumberProp('iconPadding', label: 'Icon Padding', defaultValue: 8, min: 0, max: 24, step: 2),
  ],
  fromJson: InfoCardConfig.fromJson,
);
