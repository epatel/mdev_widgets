import 'package:flutter/material.dart';
import 'package:mdev_widgets/mdev_widgets.dart' as mdev;

import 'init_mdev.dart';
import 'demos/appbar_demo.dart';
import 'demos/column_demo.dart';
import 'demos/padding_demo.dart';
import 'demos/row_demo.dart';
import 'demos/stack_demo.dart';
import 'demos/text_demo.dart';
import 'demos/wrap_demo.dart';
import 'pages/instructions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final setup = await initMdev();

  runApp(setup.wrapApp(const MdevWidgetsDemo()));
  setup.connect();
}

class MdevWidgetsDemo extends StatefulWidget {
  const MdevWidgetsDemo({super.key});

  @override
  State<MdevWidgetsDemo> createState() => _MdevWidgetsDemoState();
}

class _MdevWidgetsDemoState extends State<MdevWidgetsDemo> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mdev Widgets Demo',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: DemoPage(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const DemoPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: mdev.AppBar(
          title: const Text('Mdev Widgets Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              onPressed: onToggleTheme,
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Padding'),
              Tab(text: 'Layout'),
              Tab(text: 'Text & AppBar'),
              Tab(text: 'Instructions'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PaddingDemo(),
            _LayoutTab(),
            _TextAppBarTab(),
            _InstructionsTab(),
          ],
        ),
      ),
    );
  }
}

class _LayoutTab extends StatelessWidget {
  const _LayoutTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: mdev.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ColumnDemo(),
          SizedBox(height: 24),
          RowDemo(),
          SizedBox(height: 24),
          WrapDemo(),
          SizedBox(height: 24),
          StackDemo(),
        ],
      ),
    );
  }
}

class _TextAppBarTab extends StatelessWidget {
  const _TextAppBarTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: mdev.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [TextDemo(), SizedBox(height: 24), AppBarDemo()],
      ),
    );
  }
}

class _InstructionsTab extends StatelessWidget {
  const _InstructionsTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Instructions(),
    );
  }
}
