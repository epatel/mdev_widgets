import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as material show Text;
import 'package:provider/provider.dart';

import '../providers/widget_config_provider.dart';
import '../schema/configurable_widget.dart';
import '../schema/prop_descriptor.dart';
import 'stack_id_mixin.dart';

class Text extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final String callerId;

  Text(this.data, {super.key, this.style}) : callerId = extractCallerId();

  @override
  State<Text> createState() => _TextState();

  /// Property descriptors for Text widget.
  static final props = <PropDescriptor>[
    TextStyleProp('textStyle', label: 'Text Style'),
    TextOverrideProp('text', label: 'Text Override'),
    NumberProp('fontSize', label: 'Font Size'),
    FontWeightProp('fontWeight', label: 'Font Weight'),
    FontStyleProp('fontStyle', label: 'Font Style'),
    ColorProp('color', label: 'Color'),
    ...CommonProps.all,
  ];
}

class _TextState extends State<Text> with ConfigurableWidgetMixin<Text> {
  String? _lastRegisteredText;

  @override
  String get callerId => widget.callerId;

  @override
  String get widgetType => 'Text';

  @override
  List<PropDescriptor> get propDescriptors => Text.props;

  @override
  Map<String, dynamic> get additionalInitialValues => {'defaultText': widget.data};

  @override
  void initState() {
    _lastRegisteredText = widget.data;
    super.initState();
  }

  @override
  void didUpdateWidget(Text oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _updateDefaultText();
    }
  }

  void _updateDefaultText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_lastRegisteredText != widget.data) {
        _lastRegisteredText = widget.data;
        context.read<WidgetConfigProvider>().updateDefaultText(widget.callerId, widget.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildWithConfig(
      builder: (config, styles) {
        final overriddenText = config?.get('text', '') as String? ?? '';
        final text = overriddenText.isNotEmpty ? overriddenText : widget.data;

        // Merge with DefaultTextStyle like Flutter's Text widget does
        final defaultStyle = DefaultTextStyle.of(context).style;
        final baseStyle = defaultStyle.merge(widget.style);

        final textStyleName = config?.get('textStyle', '') as String? ?? '';
        final registeredStyle = textStyleName.isNotEmpty
            ? styles.getTextStyle(textStyleName)
            : null;

        TextStyle style;
        if (registeredStyle != null) {
          style = baseStyle.copyWith(
            fontSize: registeredStyle.fontSize ?? baseStyle.fontSize,
            fontWeight: parseFontWeight(registeredStyle.fontWeight),
            fontStyle: parseFontStyle(registeredStyle.fontStyle),
            color: registeredStyle.color != null
                ? parseColor(registeredStyle.color!)
                : baseStyle.color,
            letterSpacing: registeredStyle.letterSpacing,
            height: registeredStyle.height,
          );
        } else {
          // Only apply config values if explicitly set (not null)
          final configFontSize = config?.get('fontSize');
          final configFontWeight = config?.get('fontWeight');
          final configFontStyle = config?.get('fontStyle');
          final configColor = config?.get('color');

          style = baseStyle.copyWith(
            fontSize: configFontSize != null ? (configFontSize as num).toDouble() : null,
            fontWeight: configFontWeight != null ? parseFontWeight(configFontWeight) : null,
            fontStyle: configFontStyle != null ? parseFontStyle(configFontStyle) : null,
            color: configColor != null ? parseColor(configColor) : null,
          );
        }

        return material.Text(text, style: style);
      },
    );
  }
}
