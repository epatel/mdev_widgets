import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/models/widget_config.dart';

void main() {
  group('WidgetConfig', () {
    test('creates with required fields', () {
      final config = WidgetConfig(id: 'test-id', type: 'Text');

      expect(config.id, equals('test-id'));
      expect(config.type, equals('Text'));
      expect(config.properties, isEmpty);
    });

    test('creates with properties', () {
      final config = WidgetConfig(
        id: 'test-id',
        type: 'Text',
        properties: {'fontSize': 16.0, 'color': '#ff0000'},
      );

      expect(config.properties['fontSize'], equals(16.0));
      expect(config.properties['color'], equals('#ff0000'));
    });

    test('get returns property value', () {
      final config = WidgetConfig(
        id: 'test-id',
        type: 'Text',
        properties: {'fontSize': 16.0},
      );

      expect(config.get('fontSize'), equals(16.0));
    });

    test('get returns default when property missing', () {
      final config = WidgetConfig(id: 'test-id', type: 'Text');

      expect(config.get('fontSize', 14.0), equals(14.0));
      expect(config.get('missing'), isNull);
    });

    test('set updates property value', () {
      final config = WidgetConfig(id: 'test-id', type: 'Text');

      config.set('fontSize', 20.0);

      expect(config.get('fontSize'), equals(20.0));
    });

    group('JSON serialization', () {
      test('toJson creates correct structure', () {
        final config = WidgetConfig(
          id: 'widget-123',
          type: 'Column',
          properties: {'visible': true, 'padding': 16.0},
        );

        final json = config.toJson();

        expect(json['id'], equals('widget-123'));
        expect(json['type'], equals('Column'));
        expect(json['properties']['visible'], isTrue);
        expect(json['properties']['padding'], equals(16.0));
      });

      test('fromJson recreates config', () {
        final json = {
          'id': 'widget-456',
          'type': 'Text',
          'properties': {'fontSize': 18.0, 'fontWeight': 'bold'},
        };

        final config = WidgetConfig.fromJson(json);

        expect(config.id, equals('widget-456'));
        expect(config.type, equals('Text'));
        expect(config.get('fontSize'), equals(18.0));
        expect(config.get('fontWeight'), equals('bold'));
      });

      test('fromJson handles missing properties', () {
        final json = {'id': 'test', 'type': 'Text'};

        final config = WidgetConfig.fromJson(json);

        expect(config.properties, isEmpty);
      });

      test('fromJson handles null properties', () {
        final json = {'id': 'test', 'type': 'Text', 'properties': null};

        final config = WidgetConfig.fromJson(json);

        expect(config.properties, isEmpty);
      });

      test('round-trip serialization preserves data', () {
        final original = WidgetConfig(
          id: 'complex-id (file.dart:42:10)',
          type: 'Padding',
          properties: {
            'visible': true,
            'highlight': false,
            'padding': 24.0,
            'nested': {'key': 'value'},
          },
        );

        final json = original.toJson();
        final restored = WidgetConfig.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.type, equals(original.type));
        expect(restored.get('visible'), equals(original.get('visible')));
        expect(restored.get('padding'), equals(original.get('padding')));
        expect(restored.get('nested'), equals({'key': 'value'}));
      });
    });

    group('copyWith', () {
      test('creates copy with same properties', () {
        final original = WidgetConfig(
          id: 'test',
          type: 'Text',
          properties: {'fontSize': 16.0},
        );

        final copy = original.copyWith();

        expect(copy.id, equals(original.id));
        expect(copy.type, equals(original.type));
        expect(copy.get('fontSize'), equals(16.0));
      });

      test('creates copy with new properties', () {
        final original = WidgetConfig(
          id: 'test',
          type: 'Text',
          properties: {'fontSize': 16.0},
        );

        final copy = original.copyWith(properties: {'fontSize': 24.0, 'color': '#000'});

        expect(copy.id, equals(original.id));
        expect(copy.get('fontSize'), equals(24.0));
        expect(copy.get('color'), equals('#000'));
        // Original unchanged
        expect(original.get('fontSize'), equals(16.0));
      });

      test('copy is independent from original', () {
        final original = WidgetConfig(
          id: 'test',
          type: 'Text',
          properties: {'fontSize': 16.0},
        );

        final copy = original.copyWith();
        copy.set('fontSize', 20.0);

        expect(original.get('fontSize'), equals(16.0));
        expect(copy.get('fontSize'), equals(20.0));
      });
    });

    group('schema support', () {
      test('creates with schema', () {
        final schema = [
          {'key': 'visible', 'type': 'bool', 'label': 'Visible', 'default': true},
          {'key': 'fontSize', 'type': 'number', 'label': 'Font Size'},
        ];
        final config = WidgetConfig(
          id: 'test',
          type: 'Text',
          schema: schema,
        );

        expect(config.schema, isNotNull);
        expect(config.schema!.length, equals(2));
        expect(config.schema![0]['key'], equals('visible'));
      });

      test('toJson includes schema when present', () {
        final schema = [
          {'key': 'visible', 'type': 'bool', 'label': 'Visible'},
        ];
        final config = WidgetConfig(
          id: 'test',
          type: 'Text',
          schema: schema,
        );

        final json = config.toJson();

        expect(json['schema'], isNotNull);
        expect(json['schema'], equals(schema));
      });

      test('toJson excludes schema when null', () {
        final config = WidgetConfig(id: 'test', type: 'Text');

        final json = config.toJson();

        expect(json.containsKey('schema'), isFalse);
      });

      test('fromJson parses schema', () {
        final json = {
          'id': 'test',
          'type': 'Text',
          'properties': {},
          'schema': [
            {'key': 'fontSize', 'type': 'number', 'label': 'Font Size'},
          ],
        };

        final config = WidgetConfig.fromJson(json);

        expect(config.schema, isNotNull);
        expect(config.schema!.length, equals(1));
        expect(config.schema![0]['key'], equals('fontSize'));
      });

      test('fromJson handles missing schema', () {
        final json = {'id': 'test', 'type': 'Text', 'properties': {}};

        final config = WidgetConfig.fromJson(json);

        expect(config.schema, isNull);
      });

      test('copyWith preserves schema', () {
        final schema = [
          {'key': 'visible', 'type': 'bool'},
        ];
        final original = WidgetConfig(
          id: 'test',
          type: 'Text',
          schema: schema,
        );

        final copy = original.copyWith();

        expect(copy.schema, equals(schema));
      });

      test('copyWith can update schema', () {
        final original = WidgetConfig(
          id: 'test',
          type: 'Text',
          schema: [{'key': 'old'}],
        );

        final newSchema = [{'key': 'new'}];
        final copy = original.copyWith(schema: newSchema);

        expect(copy.schema, equals(newSchema));
        expect(original.schema![0]['key'], equals('old'));
      });
    });
  });
}
