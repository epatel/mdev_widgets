import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

Future<mdev.MdevSetup> initMdev() async {
  final setup = await mdev.MdevSetup.init();

  _registerColors(setup.provider);
  _registerSizes(setup.provider);
  _registerTextStyles(setup.provider);

  return setup;
}

void _registerColors(mdev.WidgetConfigProvider provider) {
  provider.registerColor('red', light: '#ff0000', dark: '#ff6666');
  provider.registerColor('green', light: '#00ff00', dark: '#66ff66');
  provider.registerColor('blue', light: '#0000ff', dark: '#6666ff');
  provider.registerColor('purple', light: '#6200ee', dark: '#bb86fc');
  provider.registerColor('orange', light: '#ff9800', dark: '#ffb74d');
}

void _registerSizes(mdev.WidgetConfigProvider provider) {
  // Spacing
  provider.registerSize('spacing-xs', 4.0);
  provider.registerSize('spacing-sm', 8.0);
  provider.registerSize('spacing-md', 16.0);
  provider.registerSize('spacing-lg', 24.0);
  provider.registerSize('spacing-xl', 32.0);
  provider.registerSize('spacing-xxl', 48.0);

  // Padding
  provider.registerSize('padding-xs', 4.0);
  provider.registerSize('padding-sm', 8.0);
  provider.registerSize('padding-md', 16.0);
  provider.registerSize('padding-lg', 24.0);
  provider.registerSize('padding-xl', 32.0);

  // Border radius
  provider.registerSize('radius-sm', 4.0);
  provider.registerSize('radius-md', 8.0);
  provider.registerSize('radius-lg', 16.0);
  provider.registerSize('radius-full', 9999.0);

  // Icon sizes
  provider.registerSize('icon-sm', 16.0);
  provider.registerSize('icon-md', 24.0);
  provider.registerSize('icon-lg', 32.0);
}

void _registerTextStyles(mdev.WidgetConfigProvider provider) {
  provider.registerTextStyle(
    'heading',
    const mdev.TextStyleConfig(
      fontSize: 24,
      fontWeight: 'bold',
      color: '#000000',
    ),
  );
  provider.registerTextStyle(
    'subheading',
    const mdev.TextStyleConfig(
      fontSize: 18,
      fontWeight: 'w500',
      color: '#333333',
    ),
  );
  provider.registerTextStyle(
    'body',
    const mdev.TextStyleConfig(
      fontSize: 14,
      fontWeight: 'normal',
      color: '#666666',
    ),
  );
  provider.registerTextStyle(
    'caption',
    const mdev.TextStyleConfig(
      fontSize: 12,
      fontWeight: 'normal',
      fontStyle: 'italic',
      color: '#999999',
    ),
  );
  provider.registerTextStyle(
    'button',
    const mdev.TextStyleConfig(
      fontSize: 14,
      fontWeight: 'bold',
      letterSpacing: 1.2,
      color: '#ffffff',
    ),
  );
}
