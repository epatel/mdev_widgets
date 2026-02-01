import 'package:mdev_widgets/mdev_widgets.dart';

import 'widgets/info_card_mdev.dart';

Future<MdevSetup> initMdev() async {
  final setup = await MdevSetup.init();

  _registerColors(setup.provider);
  _registerSizes(setup.provider);
  _registerTextStyles(setup.provider);
  _registerCustomWidgets(setup.provider);

  return setup;
}

void _registerCustomWidgets(WidgetConfigProvider provider) {
  // Register custom widget configs using adapters
  infoCardAdapter.register(provider);
}

void _registerColors(WidgetConfigProvider provider) {
  provider.registerColor('primary', light: '#6200ee', dark: '#bb86fc');
  provider.registerColor('secondary', light: '#03dac6', dark: '#03dac6');
  provider.registerColor('error', light: '#b00020', dark: '#cf6679');
  provider.registerColor('surface', light: '#ffffff', dark: '#121212');
  provider.registerColor('background', light: '#f5f5f5', dark: '#1e1e1e');
}

void _registerSizes(WidgetConfigProvider provider) {
  // Spacing
  provider.registerSize('spacing-xs', 4.0);
  provider.registerSize('spacing-sm', 8.0);
  provider.registerSize('spacing-md', 16.0);
  provider.registerSize('spacing-lg', 24.0);
  provider.registerSize('spacing-xl', 32.0);

  // Padding
  provider.registerSize('padding-sm', 8.0);
  provider.registerSize('padding-md', 16.0);
  provider.registerSize('padding-lg', 24.0);

  // Sizes (icons, components)
  provider.registerSize('size-xs', 16.0);
  provider.registerSize('size-sm', 24.0);
  provider.registerSize('size-md', 32.0);
  provider.registerSize('size-lg', 48.0);
  provider.registerSize('size-xl', 64.0);
}

void _registerTextStyles(WidgetConfigProvider provider) {
  provider.registerTextStyle(
    'heading',
    const TextStyleConfig(
      fontSize: 24,
      fontWeight: 'bold',
      color: '#6200ee',
    ),
  );
  provider.registerTextStyle(
    'subheading',
    const TextStyleConfig(
      fontSize: 18,
      fontWeight: 'w500',
      color: '#333333',
    ),
  );
  provider.registerTextStyle(
    'body',
    const TextStyleConfig(
      fontSize: 14,
      color: '#666666',
    ),
  );
  provider.registerTextStyle(
    'caption',
    const TextStyleConfig(
      fontSize: 12,
      fontStyle: 'italic',
      color: '#999999',
    ),
  );
}
