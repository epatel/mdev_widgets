import 'package:flutter/material.dart' hide Column;
import 'package:flutter/material.dart' as material show Column, Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mdev_widgets/src/widgets/column.dart';
import 'package:mdev_widgets/src/providers/widget_config_provider.dart';

void main() {
  group('Column widget', () {
    late WidgetConfigProvider provider;

    setUp(() {
      provider = WidgetConfigProvider();
    });

    Widget createTestApp(Widget child) {
      return MaterialApp(
        home: ChangeNotifierProvider<WidgetConfigProvider>.value(
          value: provider,
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('renders children', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(
          children: const [
            material.Text('Child 1'),
            material.Text('Child 2'),
            material.Text('Child 3'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(find.text('Child 3'), findsOneWidget);
    });

    testWidgets('registers with provider', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Test')]),
      ));
      await tester.pumpAndSettle();

      expect(provider.configs.length, equals(1));
      final config = provider.configs.values.first;
      expect(config.type, equals('Column'));
    });

    testWidgets('respects visible property', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Hidden')]),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'visible': false},
      });
      await tester.pumpAndSettle();

      expect(find.text('Hidden'), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('applies mainAxisAlignment', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Aligned')]),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'mainAxisAlignment': 'center'},
      });
      await tester.pumpAndSettle();

      final column = tester.widget<material.Column>(find.byType(material.Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('applies crossAxisAlignment', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Cross')]),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'crossAxisAlignment': 'stretch'},
      });
      await tester.pumpAndSettle();

      final column = tester.widget<material.Column>(find.byType(material.Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.stretch));
    });

    testWidgets('applies padding from config', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Padded')]),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'padding': 20.0},
      });
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsOneWidget);
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(20.0)));
    });

    testWidgets('applies spacing between children', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(
          children: const [
            material.Text('First'),
            material.Text('Second'),
            material.Text('Third'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'spacing': 16.0},
      });
      await tester.pumpAndSettle();

      // Should have SizedBoxes for spacing
      expect(find.byType(SizedBox), findsNWidgets(2)); // 2 gaps for 3 children
    });

    testWidgets('applies backgroundColor', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Colored')]),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'backgroundColor': '#ff0000'},
      });
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, equals(const Color(0xFFFF0000)));
    });

    testWidgets('shows highlight when enabled', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Highlight')]),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'highlight': true},
      });
      await tester.pumpAndSettle();

      // Find the specific highlight border decoration
      expect(
        find.byWidgetPredicate((widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null),
        findsOneWidget,
      );
    });

    testWidgets('uses registered size for padding', (tester) async {
      provider.registerSize('padding-lg', 32.0);

      await tester.pumpWidget(createTestApp(
        Column(children: const [material.Text('Named Size')]),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'padding': 'padding-lg'},
      });
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsOneWidget);
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(32.0)));
    });

    testWidgets('preserves mainAxisSize from constructor', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [material.Text('Min Size')],
        ),
      ));
      await tester.pumpAndSettle();

      final column = tester.widget<material.Column>(find.byType(material.Column));
      expect(column.mainAxisSize, equals(MainAxisSize.min));
    });

    testWidgets('preserves alignment from constructor when config is null', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [material.Text('Custom Align')],
        ),
      ));
      await tester.pumpAndSettle();

      final column = tester.widget<material.Column>(find.byType(material.Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.spaceAround));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.end));
    });

    testWidgets('combines multiple config properties', (tester) async {
      provider.registerSize('spacing-md', 16.0);

      await tester.pumpWidget(createTestApp(
        Column(
          children: const [
            material.Text('Item 1'),
            material.Text('Item 2'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {
          'padding': 24.0,
          'spacing': 'spacing-md',
          'backgroundColor': '#e0e0e0',
          'mainAxisAlignment': 'center',
        },
      });
      await tester.pumpAndSettle();

      // Verify all properties are applied
      expect(find.byType(Padding), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget); // 1 gap for 2 children

      final column = tester.widget<material.Column>(find.byType(material.Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}
