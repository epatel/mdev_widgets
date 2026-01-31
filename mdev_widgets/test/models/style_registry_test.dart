import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/models/widget_config.dart';

void main() {
  group('StyleRegistry', () {
    late StyleRegistry registry;

    setUp(() {
      registry = StyleRegistry();
    });

    group('color registration', () {
      test('registers themed color', () {
        registry.registerColor('primary', light: '#6200ee', dark: '#bb86fc');

        final color = registry.getThemedColor('primary');
        expect(color, isNotNull);
        expect(color!.light, equals('#6200ee'));
        expect(color.dark, equals('#bb86fc'));
      });

      test('getColor returns light variant', () {
        registry.registerColor('primary', light: '#6200ee', dark: '#bb86fc');

        expect(registry.getColor('primary', isDark: false), equals('#6200ee'));
      });

      test('getColor returns dark variant', () {
        registry.registerColor('primary', light: '#6200ee', dark: '#bb86fc');

        expect(registry.getColor('primary', isDark: true), equals('#bb86fc'));
      });

      test('getColor returns null for unregistered', () {
        expect(registry.getColor('unknown'), isNull);
      });

      test('colors map is unmodifiable', () {
        registry.registerColor('test', light: '#fff', dark: '#000');

        expect(() => registry.colors['test'] = const ThemedColor(light: '', dark: ''),
            throwsUnsupportedError);
      });

      test('overwrites existing color', () {
        registry.registerColor('primary', light: '#000', dark: '#fff');
        registry.registerColor('primary', light: '#111', dark: '#eee');

        expect(registry.getColor('primary', isDark: false), equals('#111'));
      });
    });

    group('size registration', () {
      test('registers size', () {
        registry.registerSize('padding-md', 16.0);

        expect(registry.getSize('padding-md'), equals(16.0));
      });

      test('getSize returns null for unregistered', () {
        expect(registry.getSize('unknown'), isNull);
      });

      test('sizes map is unmodifiable', () {
        registry.registerSize('test', 10.0);

        expect(() => registry.sizes['test'] = 20.0, throwsUnsupportedError);
      });

      test('registers multiple sizes', () {
        registry.registerSize('spacing-xs', 4.0);
        registry.registerSize('spacing-sm', 8.0);
        registry.registerSize('spacing-md', 16.0);
        registry.registerSize('spacing-lg', 24.0);
        registry.registerSize('spacing-xl', 32.0);

        expect(registry.sizes.length, equals(5));
        expect(registry.getSize('spacing-xs'), equals(4.0));
        expect(registry.getSize('spacing-xl'), equals(32.0));
      });
    });

    group('text style registration', () {
      test('registers text style', () {
        const style = TextStyleConfig(fontSize: 24.0, fontWeight: 'bold');
        registry.registerTextStyle('heading', style);

        final retrieved = registry.getTextStyle('heading');
        expect(retrieved, isNotNull);
        expect(retrieved!.fontSize, equals(24.0));
        expect(retrieved.fontWeight, equals('bold'));
      });

      test('getTextStyle returns null for unregistered', () {
        expect(registry.getTextStyle('unknown'), isNull);
      });

      test('textStyles map is unmodifiable', () {
        registry.registerTextStyle('test', const TextStyleConfig());

        expect(() => registry.textStyles['test'] = const TextStyleConfig(),
            throwsUnsupportedError);
      });
    });

    group('custom values', () {
      test('registers custom value', () {
        registry.register('customKey', 'customValue');

        expect(registry.get('customKey'), equals('customValue'));
      });

      test('registers various types', () {
        registry.register('string', 'value');
        registry.register('number', 42);
        registry.register('double', 3.14);
        registry.register('bool', true);
        registry.register('list', [1, 2, 3]);
        registry.register('map', {'key': 'value'});

        expect(registry.get('string'), equals('value'));
        expect(registry.get('number'), equals(42));
        expect(registry.get('double'), equals(3.14));
        expect(registry.get('bool'), isTrue);
        expect(registry.get('list'), equals([1, 2, 3]));
        expect(registry.get('map'), equals({'key': 'value'}));
      });

      test('custom map is unmodifiable', () {
        registry.register('test', 'value');

        expect(() => registry.custom['test'] = 'new', throwsUnsupportedError);
      });
    });

    group('JSON serialization', () {
      test('toJson creates complete structure', () {
        registry.registerColor('primary', light: '#6200ee', dark: '#bb86fc');
        registry.registerSize('padding-md', 16.0);
        registry.registerTextStyle('body', const TextStyleConfig(fontSize: 14.0));
        registry.register('version', '1.0');

        final json = registry.toJson();

        expect(json['colors'], isA<Map>());
        expect(json['colors']['primary']['light'], equals('#6200ee'));
        expect(json['sizes'], isA<Map>());
        expect(json['sizes']['padding-md'], equals(16.0));
        expect(json['textStyles'], isA<Map>());
        expect(json['textStyles']['body']['fontSize'], equals(14.0));
        expect(json['custom']['version'], equals('1.0'));
      });

      test('updateFromJson updates colors', () {
        final json = {
          'colors': {
            'primary': {'light': '#ff0000', 'dark': '#00ff00'},
            'secondary': {'light': '#0000ff', 'dark': '#ffff00'},
          }
        };

        registry.updateFromJson(json);

        expect(registry.colors.length, equals(2));
        expect(registry.getColor('primary', isDark: false), equals('#ff0000'));
        expect(registry.getColor('secondary', isDark: true), equals('#ffff00'));
      });

      test('updateFromJson updates sizes', () {
        final json = {
          'sizes': {
            'small': 8,
            'medium': 16,
            'large': 24,
          }
        };

        registry.updateFromJson(json);

        expect(registry.sizes.length, equals(3));
        expect(registry.getSize('small'), equals(8.0));
        expect(registry.getSize('large'), equals(24.0));
      });

      test('updateFromJson updates text styles', () {
        final json = {
          'textStyles': {
            'heading': {'fontSize': 32, 'fontWeight': 'bold'},
            'caption': {'fontSize': 12, 'fontStyle': 'italic'},
          }
        };

        registry.updateFromJson(json);

        expect(registry.textStyles.length, equals(2));
        expect(registry.getTextStyle('heading')?.fontSize, equals(32.0));
        expect(registry.getTextStyle('caption')?.fontStyle, equals('italic'));
      });

      test('updateFromJson clears existing values', () {
        registry.registerColor('old', light: '#000', dark: '#fff');
        registry.registerSize('oldSize', 100.0);

        final json = {
          'colors': {
            'new': {'light': '#111', 'dark': '#eee'},
          },
          'sizes': {
            'newSize': 50,
          },
        };

        registry.updateFromJson(json);

        expect(registry.getThemedColor('old'), isNull);
        expect(registry.getThemedColor('new'), isNotNull);
        expect(registry.getSize('oldSize'), isNull);
        expect(registry.getSize('newSize'), equals(50.0));
      });

      test('round-trip preserves all data', () {
        registry.registerColor('primary', light: '#6200ee', dark: '#bb86fc');
        registry.registerColor('error', light: '#b00020', dark: '#cf6679');
        registry.registerSize('padding-sm', 8.0);
        registry.registerSize('padding-lg', 24.0);
        registry.registerTextStyle('title', const TextStyleConfig(
          fontSize: 20.0,
          fontWeight: 'w600',
          letterSpacing: 0.15,
        ));

        final json = registry.toJson();
        final newRegistry = StyleRegistry();
        newRegistry.updateFromJson(json);

        expect(newRegistry.getColor('primary', isDark: false), equals('#6200ee'));
        expect(newRegistry.getColor('error', isDark: true), equals('#cf6679'));
        expect(newRegistry.getSize('padding-sm'), equals(8.0));
        expect(newRegistry.getTextStyle('title')?.fontSize, equals(20.0));
        expect(newRegistry.getTextStyle('title')?.letterSpacing, equals(0.15));
      });
    });
  });
}
