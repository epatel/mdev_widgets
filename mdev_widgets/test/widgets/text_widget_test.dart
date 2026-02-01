import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as material show Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mdev_widgets/src/widgets/text.dart';
import 'package:mdev_widgets/src/providers/widget_config_provider.dart';
import 'package:mdev_widgets/src/models/widget_config.dart';

void main() {
  group('Text widget', () {
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

    testWidgets('renders text content', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Hello World'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('applies custom style', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Styled Text', style: const TextStyle(fontSize: 24.0)),
      ));
      await tester.pumpAndSettle();

      final textWidget = tester.widget<material.Text>(find.text('Styled Text'));
      expect(textWidget.style?.fontSize, equals(24.0));
    });

    testWidgets('registers with provider on init', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Register Me'),
      ));
      await tester.pumpAndSettle();

      // Provider should have a registered config
      expect(provider.configs.length, equals(1));
      final config = provider.configs.values.first;
      expect(config.type, equals('Text'));
      // defaultText is stored in properties (registered defaults)
      expect(config.getDefault('defaultText'), equals('Register Me'));
    });

    testWidgets('respects visible property', (tester) async {
      // Pre-register with visible: false
      await tester.pumpWidget(createTestApp(
        Text('Hidden Text'),
      ));
      await tester.pumpAndSettle();

      // Get the registered ID
      final configId = provider.configs.keys.first;

      // Update to invisible
      provider.updateFromServer(configId, {
        'properties': {'visible': false},
      });
      await tester.pumpAndSettle();

      // Text should not be visible (SizedBox.shrink)
      expect(find.text('Hidden Text'), findsNothing);
    });

    testWidgets('uses text override when set', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Original'),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'text': 'Overridden'},
      });
      await tester.pumpAndSettle();

      expect(find.text('Overridden'), findsOneWidget);
      expect(find.text('Original'), findsNothing);
    });

    testWidgets('applies fontSize from config', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Sized Text'),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'fontSize': 32.0},
      });
      await tester.pumpAndSettle();

      final textWidget = tester.widget<material.Text>(find.text('Sized Text'));
      expect(textWidget.style?.fontSize, equals(32.0));
    });

    testWidgets('applies color from config', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Colored Text'),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'color': '#ff0000'},
      });
      await tester.pumpAndSettle();

      final textWidget = tester.widget<material.Text>(find.text('Colored Text'));
      expect(textWidget.style?.color, equals(const Color(0xFFFF0000)));
    });

    testWidgets('applies font weight from config', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Bold Text'),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'fontWeight': 'bold'},
      });
      await tester.pumpAndSettle();

      final textWidget = tester.widget<material.Text>(find.text('Bold Text'));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('applies registered text style', (tester) async {
      provider.registerTextStyle('heading', const TextStyleConfig(
        fontSize: 28.0,
        fontWeight: 'bold',
      ));

      await tester.pumpWidget(createTestApp(
        Text('Heading Style'),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'textStyle': 'heading'},
      });
      await tester.pumpAndSettle();

      final textWidget = tester.widget<material.Text>(find.text('Heading Style'));
      expect(textWidget.style?.fontSize, equals(28.0));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('shows highlight when enabled', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Highlight Me'),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'highlight': true},
      });
      await tester.pumpAndSettle();

      // With highlight enabled, text should be wrapped with a DecoratedBox
      expect(find.byType(DecoratedBox), findsAtLeastNWidgets(1));
      // Find the specific highlight border
      expect(
        find.byWidgetPredicate((widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null),
        findsOneWidget,
      );
    });

    testWidgets('inherits from DefaultTextStyle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WidgetConfigProvider>.value(
            value: provider,
            child: Scaffold(
              body: DefaultTextStyle(
                style: const TextStyle(fontSize: 20.0, color: Colors.blue),
                child: Text('Inherited Style'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<material.Text>(find.text('Inherited Style'));
      // Should inherit from DefaultTextStyle
      expect(textWidget.style?.fontSize, equals(20.0));
      expect(textWidget.style?.color, equals(Colors.blue));
    });

    testWidgets('config overrides inherited style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WidgetConfigProvider>.value(
            value: provider,
            child: Scaffold(
              body: DefaultTextStyle(
                style: const TextStyle(fontSize: 20.0),
                child: Text('Override Me'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      provider.updateFromServer(configId, {
        'properties': {'fontSize': 30.0},
      });
      await tester.pumpAndSettle();

      final textWidget = tester.widget<material.Text>(find.text('Override Me'));
      // Config should override inherited style
      expect(textWidget.style?.fontSize, equals(30.0));
    });

    testWidgets('updates defaultText when widget data changes', (tester) async {
      String text = 'Initial';

      await tester.pumpWidget(createTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Text(text),
                ElevatedButton(
                  onPressed: () => setState(() => text = 'Updated'),
                  child: const material.Text('Change'),
                ),
              ],
            );
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Initial'), findsOneWidget);

      // Tap button to change text
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      expect(find.text('Updated'), findsOneWidget);
    });

    testWidgets('parses font weight variants correctly', (tester) async {
      await tester.pumpWidget(createTestApp(
        Text('Weight Test'),
      ));
      await tester.pumpAndSettle();

      final configId = provider.configs.keys.first;

      // Test various weight values
      for (final weight in ['w100', 'w300', 'w500', 'w700', 'w900']) {
        provider.updateFromServer(configId, {
          'properties': {'fontWeight': weight},
        });
        await tester.pumpAndSettle();

        final textWidget = tester.widget<material.Text>(find.text('Weight Test'));
        expect(textWidget.style?.fontWeight, isNotNull,
            reason: 'Font weight $weight should be parsed');
      }
    });
  });
}
