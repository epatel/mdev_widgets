import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/models/widget_config.dart';

void main() {
  group('ThemedColor', () {
    test('creates with light and dark values', () {
      const color = ThemedColor(light: '#000000', dark: '#ffffff');

      expect(color.light, equals('#000000'));
      expect(color.dark, equals('#ffffff'));
    });

    group('forBrightness', () {
      test('returns light color when isDark is false', () {
        const color = ThemedColor(light: '#6200ee', dark: '#bb86fc');

        expect(color.forBrightness(false), equals('#6200ee'));
      });

      test('returns dark color when isDark is true', () {
        const color = ThemedColor(light: '#6200ee', dark: '#bb86fc');

        expect(color.forBrightness(true), equals('#bb86fc'));
      });
    });

    group('JSON serialization', () {
      test('toJson creates correct structure', () {
        const color = ThemedColor(light: '#f5f5f5', dark: '#1e1e1e');

        final json = color.toJson();

        expect(json['light'], equals('#f5f5f5'));
        expect(json['dark'], equals('#1e1e1e'));
        expect(json.length, equals(2));
      });

      test('fromJson parses correctly', () {
        final json = {'light': '#ffffff', 'dark': '#000000'};

        final color = ThemedColor.fromJson(json);

        expect(color.light, equals('#ffffff'));
        expect(color.dark, equals('#000000'));
      });

      test('fromJson provides defaults for missing values', () {
        final json = <String, dynamic>{};

        final color = ThemedColor.fromJson(json);

        expect(color.light, equals('#000000'));
        expect(color.dark, equals('#ffffff'));
      });

      test('round-trip preserves data', () {
        const original = ThemedColor(light: '#03dac6', dark: '#018786');

        final json = original.toJson();
        final restored = ThemedColor.fromJson(json);

        expect(restored.light, equals(original.light));
        expect(restored.dark, equals(original.dark));
      });
    });
  });
}
