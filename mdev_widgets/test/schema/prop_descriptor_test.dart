import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/schema/prop_descriptor.dart';

void main() {
  group('BoolProp', () {
    test('toSchema generates correct structure', () {
      const prop = BoolProp('visible', label: 'Visible', defaultValue: true);
      final schema = prop.toSchema();

      expect(schema['key'], equals('visible'));
      expect(schema['type'], equals('bool'));
      expect(schema['label'], equals('Visible'));
      expect(schema['default'], isTrue);
    });

    test('parse handles bool values', () {
      const prop = BoolProp('test', label: 'Test');

      expect(prop.parse(true), isTrue);
      expect(prop.parse(false), isFalse);
      expect(prop.parse(null), isFalse);
    });
  });

  group('NumberProp', () {
    test('toSchema generates correct structure', () {
      const prop = NumberProp('fontSize', label: 'Font Size', min: 8, max: 72);
      final schema = prop.toSchema();

      expect(schema['key'], equals('fontSize'));
      expect(schema['type'], equals('number'));
      expect(schema['label'], equals('Font Size'));
      expect(schema['min'], equals(8));
      expect(schema['max'], equals(72));
    });

    test('parse handles various numeric types', () {
      const prop = NumberProp('size', label: 'Size');

      expect(prop.parse(16), equals(16.0));
      expect(prop.parse(16.5), equals(16.5));
      expect(prop.parse('24'), equals(24.0));
      expect(prop.parse(null), isNull);
    });
  });

  group('EnumProp', () {
    test('toSchema generates correct structure with options', () {
      const prop = EnumProp<MainAxisAlignment>(
        'mainAxisAlignment',
        label: 'Main Axis',
        values: MainAxisAlignment.values,
        defaultValue: MainAxisAlignment.start,
      );
      final schema = prop.toSchema();

      expect(schema['key'], equals('mainAxisAlignment'));
      expect(schema['type'], equals('enum'));
      expect(schema['label'], equals('Main Axis'));
      expect(schema['options'], contains('start'));
      expect(schema['options'], contains('center'));
      expect(schema['options'], contains('spaceBetween'));
      expect(schema['default'], equals('start'));
    });

    test('parse returns correct enum value', () {
      const prop = EnumProp<MainAxisAlignment>(
        'test',
        label: 'Test',
        values: MainAxisAlignment.values,
        defaultValue: MainAxisAlignment.start,
      );

      expect(prop.parse('center'), equals(MainAxisAlignment.center));
      expect(prop.parse('spaceBetween'), equals(MainAxisAlignment.spaceBetween));
      expect(prop.parse('invalid'), equals(MainAxisAlignment.start));
      expect(prop.parse(null), equals(MainAxisAlignment.start));
    });
  });

  group('ColorProp', () {
    test('toSchema generates correct structure', () {
      const prop = ColorProp('backgroundColor', label: 'Background');
      final schema = prop.toSchema();

      expect(schema['key'], equals('backgroundColor'));
      expect(schema['type'], equals('color'));
      expect(schema['label'], equals('Background'));
    });

    test('parse handles hex colors', () {
      const prop = ColorProp('color', label: 'Color');

      expect(prop.parse('#ff0000'), equals(const Color(0xFFFF0000)));
      expect(prop.parse('#00ff00'), equals(const Color(0xFF00FF00)));
      expect(prop.parse('ff0000'), equals(const Color(0xFFFF0000)));
      expect(prop.parse(null), isNull);
      expect(prop.parse(''), isNull);
    });

    test('parse handles 8-digit hex colors', () {
      const prop = ColorProp('color', label: 'Color');

      expect(prop.parse('#80ff0000'), equals(const Color(0x80FF0000)));
    });
  });

  group('SizeProp', () {
    test('toSchema includes prefix when set', () {
      const prop = SizeProp('padding', label: 'Padding', prefix: 'padding-');
      final schema = prop.toSchema();

      expect(schema['key'], equals('padding'));
      expect(schema['type'], equals('size'));
      expect(schema['prefix'], equals('padding-'));
    });

    test('parseWithRegistry handles numeric values', () {
      const prop = SizeProp('size', label: 'Size');
      final sizes = <String, double>{'spacing-md': 16.0};

      expect(prop.parseWithRegistry(16, sizes), equals(16.0));
      expect(prop.parseWithRegistry(16.5, sizes), equals(16.5));
      expect(prop.parseWithRegistry('24', sizes), equals(24.0));
    });

    test('parseWithRegistry looks up registered sizes', () {
      const prop = SizeProp('size', label: 'Size');
      final sizes = <String, double>{'spacing-md': 16.0, 'spacing-lg': 24.0};

      expect(prop.parseWithRegistry('spacing-md', sizes), equals(16.0));
      expect(prop.parseWithRegistry('spacing-lg', sizes), equals(24.0));
      expect(prop.parseWithRegistry('spacing-unknown', sizes), isNull);
    });
  });

  group('FontWeightProp', () {
    test('toSchema includes all weight options', () {
      const prop = FontWeightProp('fontWeight', label: 'Font Weight');
      final schema = prop.toSchema();

      expect(schema['type'], equals('enum'));
      expect(schema['options'], contains('normal'));
      expect(schema['options'], contains('bold'));
      expect(schema['options'], contains('w100'));
      expect(schema['options'], contains('w900'));
    });

    test('parse returns correct FontWeight', () {
      const prop = FontWeightProp('fontWeight', label: 'Font Weight');

      expect(prop.parse('bold'), equals(FontWeight.bold));
      expect(prop.parse('w300'), equals(FontWeight.w300));
      expect(prop.parse('w700'), equals(FontWeight.w700));
      expect(prop.parse('normal'), isNull); // normal means default
      expect(prop.parse(null), isNull);
    });
  });

  group('AlignmentProp', () {
    test('toSchema includes all alignment options', () {
      const prop = AlignmentProp('alignment', label: 'Alignment');
      final schema = prop.toSchema();

      expect(schema['options'], contains('topLeft'));
      expect(schema['options'], contains('center'));
      expect(schema['options'], contains('bottomRight'));
      expect(schema['options'], contains('topStart'));
    });

    test('parse returns correct Alignment', () {
      const prop = AlignmentProp('alignment', label: 'Alignment');

      expect(prop.parse('center', Alignment.topLeft), equals(Alignment.center));
      expect(prop.parse('bottomRight', Alignment.topLeft), equals(Alignment.bottomRight));
      expect(prop.parse('topStart', Alignment.topLeft), equals(AlignmentDirectional.topStart));
      expect(prop.parse('invalid', Alignment.topLeft), equals(Alignment.topLeft));
    });
  });

  group('TextStyleProp', () {
    test('toSchema generates correct structure', () {
      const prop = TextStyleProp('textStyle', label: 'Text Style');
      final schema = prop.toSchema();

      expect(schema['key'], equals('textStyle'));
      expect(schema['type'], equals('textStyle'));
      expect(schema['label'], equals('Text Style'));
      expect(schema['default'], equals(''));
    });
  });
}
