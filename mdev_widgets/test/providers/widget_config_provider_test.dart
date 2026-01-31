import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/providers/widget_config_provider.dart';
import 'package:mdev_widgets/src/models/widget_config.dart';

void main() {
  group('WidgetConfigProvider', () {
    late WidgetConfigProvider provider;

    setUp(() {
      provider = WidgetConfigProvider();
    });

    group('widget registration', () {
      test('register adds new widget config', () {
        provider.register('widget-1', 'Text');

        expect(provider.configs.length, equals(1));
        expect(provider.configs.containsKey('widget-1'), isTrue);
        expect(provider.configs['widget-1']!.type, equals('Text'));
      });

      test('register with properties stores them', () {
        provider.register('widget-1', 'Column', properties: {
          'padding': 16.0,
          'visible': true,
        });

        final config = provider.getConfig('widget-1');
        expect(config!.get('padding'), equals(16.0));
        expect(config.get('visible'), isTrue);
      });

      test('register does not overwrite existing widget', () {
        provider.register('widget-1', 'Text', properties: {'fontSize': 14.0});
        provider.register('widget-1', 'Text', properties: {'fontSize': 20.0});

        final config = provider.getConfig('widget-1');
        // Should keep original value
        expect(config!.get('fontSize'), equals(14.0));
      });

      test('unregister removes widget', () {
        provider.register('widget-1', 'Text');
        expect(provider.configs.length, equals(1));

        provider.unregister('widget-1');
        expect(provider.configs.length, equals(0));
      });

      test('unregister non-existent widget is safe', () {
        expect(() => provider.unregister('non-existent'), returnsNormally);
      });
    });

    group('widget retrieval', () {
      test('getConfig returns registered widget', () {
        provider.register('widget-1', 'Text');

        final config = provider.getConfig('widget-1');

        expect(config, isNotNull);
        expect(config!.id, equals('widget-1'));
      });

      test('getConfig returns null for unregistered', () {
        final config = provider.getConfig('non-existent');

        expect(config, isNull);
      });

      test('getConfigsByType returns matching widgets', () {
        provider.register('text-1', 'Text');
        provider.register('text-2', 'Text');
        provider.register('column-1', 'Column');

        final textConfigs = provider.getConfigsByType('Text');

        expect(textConfigs.length, equals(2));
        expect(textConfigs.every((c) => c.type == 'Text'), isTrue);
      });

      test('getConfigsByType returns empty for no matches', () {
        provider.register('text-1', 'Text');

        final paddingConfigs = provider.getConfigsByType('Padding');

        expect(paddingConfigs, isEmpty);
      });

      test('configs map is unmodifiable', () {
        provider.register('widget-1', 'Text');

        expect(() {
          provider.configs['widget-2'] = WidgetConfig(id: 'widget-2', type: 'Text');
        }, throwsUnsupportedError);
      });
    });

    group('update operations', () {
      test('updateDefaultText updates the property', () {
        provider.register('text-1', 'Text', properties: {'defaultText': 'Old'});

        provider.updateDefaultText('text-1', 'New');

        final config = provider.getConfig('text-1');
        expect(config!.get('defaultText'), equals('New'));
      });

      test('updateFromServer updates properties', () {
        provider.register('widget-1', 'Text', properties: {'fontSize': 14.0});

        provider.updateFromServer('widget-1', {
          'properties': {'fontSize': 20.0, 'color': '#ff0000'},
        });

        final config = provider.getConfig('widget-1');
        expect(config!.get('fontSize'), equals(20.0));
        expect(config.get('color'), equals('#ff0000'));
      });

      test('updateFromServer ignores non-existent widget', () {
        expect(
          () => provider.updateFromServer('non-existent', {'properties': {}}),
          returnsNormally,
        );
      });
    });

    group('style registration', () {
      test('registerColor adds themed color to styles', () {
        provider.registerColor('primary', light: '#6200ee', dark: '#bb86fc');

        final color = provider.styles.getThemedColor('primary');
        expect(color, isNotNull);
        expect(color!.light, equals('#6200ee'));
        expect(color.dark, equals('#bb86fc'));
      });

      test('registerSize adds size to styles', () {
        provider.registerSize('padding-md', 16.0);

        expect(provider.styles.getSize('padding-md'), equals(16.0));
      });

      test('registerTextStyle adds text style to styles', () {
        provider.registerTextStyle('heading', const TextStyleConfig(
          fontSize: 24.0,
          fontWeight: 'bold',
        ));

        final style = provider.styles.getTextStyle('heading');
        expect(style, isNotNull);
        expect(style!.fontSize, equals(24.0));
      });

      test('updateStylesFromServer updates registry', () {
        provider.updateStylesFromServer({
          'colors': {
            'primary': {'light': '#000', 'dark': '#fff'},
          },
          'sizes': {'gap': 8},
        });

        expect(provider.styles.getColor('primary', isDark: false), equals('#000'));
        expect(provider.styles.getSize('gap'), equals(8.0));
      });
    });

    group('callbacks', () {
      test('onRegister called when widget registered', () {
        String? registeredId;
        String? registeredType;
        Map<String, dynamic>? registeredProps;

        provider.onRegister = (id, type, props, {schema}) {
          registeredId = id;
          registeredType = type;
          registeredProps = props;
        };

        provider.register('test-widget', 'Text', properties: {'fontSize': 16.0});

        expect(registeredId, equals('test-widget'));
        expect(registeredType, equals('Text'));
        expect(registeredProps!['fontSize'], equals(16.0));
      });

      test('onUnregister called when widget unregistered', () {
        String? unregisteredId;

        provider.onUnregister = (id) {
          unregisteredId = id;
        };

        provider.register('test-widget', 'Text');
        provider.unregister('test-widget');

        expect(unregisteredId, equals('test-widget'));
      });

      test('onStyleChange called when styles change', () {
        Map<String, dynamic>? changedStyles;

        provider.onStyleChange = (styles) {
          changedStyles = styles;
        };

        provider.registerColor('primary', light: '#000', dark: '#fff');

        expect(changedStyles, isNotNull);
        expect(changedStyles!['colors'], isNotNull);
      });
    });

    group('reregisterAll', () {
      test('calls onRegister for all widgets', () {
        final registeredIds = <String>[];

        provider.register('widget-1', 'Text');
        provider.register('widget-2', 'Column');

        provider.onRegister = (id, type, props, {schema}) {
          registeredIds.add(id);
        };

        provider.reregisterAll();

        expect(registeredIds, containsAll(['widget-1', 'widget-2']));
      });

      test('calls onStyleChange', () {
        var styleChangeCalled = false;

        provider.registerColor('test', light: '#000', dark: '#fff');
        provider.onStyleChange = (_) {
          styleChangeCalled = true;
        };

        provider.reregisterAll();

        expect(styleChangeCalled, isTrue);
      });
    });

    group('serialization', () {
      test('toJsonList returns all configs as JSON', () {
        provider.register('widget-1', 'Text', properties: {'fontSize': 14.0});
        provider.register('widget-2', 'Column', properties: {'padding': 16.0});

        final jsonList = provider.toJsonList();

        expect(jsonList.length, equals(2));
        expect(jsonList.any((j) => j['id'] == 'widget-1'), isTrue);
        expect(jsonList.any((j) => j['id'] == 'widget-2'), isTrue);
      });

      test('toJsonList returns empty for no configs', () {
        final jsonList = provider.toJsonList();

        expect(jsonList, isEmpty);
      });
    });

    group('notification', () {
      test('notifies listeners on register', () {
        var notified = false;
        provider.addListener(() => notified = true);

        provider.register('widget-1', 'Text');

        expect(notified, isTrue);
      });

      test('notifies listeners on unregister', () {
        provider.register('widget-1', 'Text');

        var notified = false;
        provider.addListener(() => notified = true);

        provider.unregister('widget-1');

        expect(notified, isTrue);
      });

      test('notifies listeners on updateFromServer', () {
        provider.register('widget-1', 'Text');

        var notified = false;
        provider.addListener(() => notified = true);

        provider.updateFromServer('widget-1', {'properties': {'fontSize': 20.0}});

        expect(notified, isTrue);
      });

      test('notifies listeners on style registration', () {
        var notified = false;
        provider.addListener(() => notified = true);

        provider.registerColor('test', light: '#000', dark: '#fff');

        expect(notified, isTrue);
      });
    });
  });
}
