import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/models/widget_config.dart';

void main() {
  group('TextStyleConfig', () {
    test('creates with all null values', () {
      const config = TextStyleConfig();

      expect(config.fontSize, isNull);
      expect(config.fontWeight, isNull);
      expect(config.fontStyle, isNull);
      expect(config.color, isNull);
      expect(config.letterSpacing, isNull);
      expect(config.height, isNull);
    });

    test('creates with all values', () {
      const config = TextStyleConfig(
        fontSize: 16.0,
        fontWeight: 'bold',
        fontStyle: 'italic',
        color: '#ff0000',
        letterSpacing: 1.5,
        height: 1.2,
      );

      expect(config.fontSize, equals(16.0));
      expect(config.fontWeight, equals('bold'));
      expect(config.fontStyle, equals('italic'));
      expect(config.color, equals('#ff0000'));
      expect(config.letterSpacing, equals(1.5));
      expect(config.height, equals(1.2));
    });

    group('JSON serialization', () {
      test('toJson only includes non-null values', () {
        const config = TextStyleConfig(fontSize: 14.0, fontWeight: 'normal');

        final json = config.toJson();

        expect(json['fontSize'], equals(14.0));
        expect(json['fontWeight'], equals('normal'));
        expect(json.containsKey('fontStyle'), isFalse);
        expect(json.containsKey('color'), isFalse);
      });

      test('toJson includes all set values', () {
        const config = TextStyleConfig(
          fontSize: 18.0,
          fontWeight: 'w600',
          fontStyle: 'italic',
          color: '#333333',
          letterSpacing: 0.5,
          height: 1.5,
        );

        final json = config.toJson();

        expect(json.length, equals(6));
        expect(json['fontSize'], equals(18.0));
        expect(json['fontWeight'], equals('w600'));
        expect(json['fontStyle'], equals('italic'));
        expect(json['color'], equals('#333333'));
        expect(json['letterSpacing'], equals(0.5));
        expect(json['height'], equals(1.5));
      });

      test('fromJson parses all fields', () {
        final json = {
          'fontSize': 20,
          'fontWeight': 'bold',
          'fontStyle': 'normal',
          'color': '#000000',
          'letterSpacing': 2,
          'height': 1.8,
        };

        final config = TextStyleConfig.fromJson(json);

        expect(config.fontSize, equals(20.0));
        expect(config.fontWeight, equals('bold'));
        expect(config.fontStyle, equals('normal'));
        expect(config.color, equals('#000000'));
        expect(config.letterSpacing, equals(2.0));
        expect(config.height, equals(1.8));
      });

      test('fromJson handles missing fields', () {
        final json = {'fontSize': 16};

        final config = TextStyleConfig.fromJson(json);

        expect(config.fontSize, equals(16.0));
        expect(config.fontWeight, isNull);
        expect(config.color, isNull);
      });

      test('fromJson handles integer to double conversion', () {
        final json = {
          'fontSize': 16,
          'letterSpacing': 1,
          'height': 2,
        };

        final config = TextStyleConfig.fromJson(json);

        expect(config.fontSize, isA<double>());
        expect(config.fontSize, equals(16.0));
        expect(config.letterSpacing, isA<double>());
        expect(config.height, isA<double>());
      });

      test('round-trip preserves data', () {
        const original = TextStyleConfig(
          fontSize: 24.0,
          fontWeight: 'w500',
          fontStyle: 'italic',
          color: '#6200ee',
          letterSpacing: 0.25,
          height: 1.4,
        );

        final json = original.toJson();
        final restored = TextStyleConfig.fromJson(json);

        expect(restored.fontSize, equals(original.fontSize));
        expect(restored.fontWeight, equals(original.fontWeight));
        expect(restored.fontStyle, equals(original.fontStyle));
        expect(restored.color, equals(original.color));
        expect(restored.letterSpacing, equals(original.letterSpacing));
        expect(restored.height, equals(original.height));
      });
    });
  });
}
