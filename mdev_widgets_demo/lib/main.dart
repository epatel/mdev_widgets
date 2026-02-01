import 'package:mdev_widgets/mdev_shadow.dart';

import 'init_mdev.dart';
import 'demos/appbar_demo.dart';
import 'demos/center_demo.dart';
import 'demos/column_demo.dart';
import 'demos/container_demo.dart';
import 'demos/flex_demo.dart';
import 'demos/padding_demo.dart';
import 'demos/row_demo.dart';
import 'demos/sized_box_demo.dart';
import 'demos/stack_demo.dart';
import 'demos/text_demo.dart';
import 'demos/wrap_demo.dart';
import 'demos/custom_widget_demo.dart';
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
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mdev Widgets Demo'),
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
              Tab(text: 'Essentials'),
              Tab(text: 'Padding'),
              Tab(text: 'Layout'),
              Tab(text: 'Text & AppBar'),
              Tab(text: 'Custom Widget'),
              Tab(text: 'Instructions'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EssentialsTab(),
            PaddingDemo(),
            _LayoutTab(),
            _TextAppBarTab(),
            _CustomWidgetTab(),
            _InstructionsTab(),
          ],
        ),
      ),
    );
  }
}

class _EssentialsTab extends StatelessWidget {
  const _EssentialsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerDemo(),
          SizedBox(height: 24),
          SizedBoxDemo(),
          SizedBox(height: 24),
          CenterDemo(),
          SizedBox(height: 24),
          FlexDemo(),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [TextDemo(), SizedBox(height: 24), AppBarDemo()],
      ),
    );
  }
}

class _CustomWidgetTab extends StatelessWidget {
  const _CustomWidgetTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: CustomWidgetDemo(),
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
