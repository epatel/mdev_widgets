# MDev Widgets

A Flutter package for dynamic widget configuration with stack-based ID extraction and live editing via a web dashboard.

## Features

- **Stack-based widget IDs** - Widgets auto-generate unique IDs from their call site location
- **Schema-driven configuration** - Property descriptors define widget schemas for automatic UI generation
- **Live configuration** - Edit widget properties in real-time via web dashboard
- **Themed colors** - Light/dark theme support for registered colors
- **Style registry** - Centralized colors, sizes, and text styles
- **Persistence** - Configs saved locally and synced with server
- **Hot restart safe** - Handles Flutter web hot restart gracefully

## Quick Start

```bash
# Setup and run
make venv        # Create Python virtual environment
make server      # Start config server (in one terminal)
make app         # Run Flutter app in Chrome (in another terminal)

# Or run both together
make all

# Open dashboard
make dashboard   # Opens http://localhost:8081

# Run tests
make test
make analyze
```

## Usage

```dart
import 'package:mdev_widgets/mdev.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final setup = await MdevSetup.init();

  // Register styles (colors support light/dark themes)
  setup.provider.registerColor('primary', light: '#6200ee', dark: '#bb86fc');
  setup.provider.registerSize('spacing-md', 16.0);
  setup.provider.registerTextStyle('heading', const TextStyleConfig(
    fontSize: 24.0,
    fontWeight: 'bold',
  ));

  runApp(setup.wrapApp(const MyApp()));
  setup.connect();
}

// mdev widgets replace Flutter's - no prefix needed
Column(
  children: [
    Text('Hello World'),
    Padding(padding: EdgeInsets.all(16), child: ...),
  ],
)
```

## Available Widgets

| Widget | Key Properties | Description |
|--------|----------------|-------------|
| `Text` | textStyle, fontSize, fontWeight, color | Text with style registry lookup |
| `Column` | padding, spacing, backgroundColor, alignment | Vertical layout with auto-spacing |
| `Row` | spacing, alignment | Horizontal layout with spacing |
| `Padding` | paddingTop/Right/Bottom/Left, paddingAll | Individual edge control |
| `Container` | padding, margin, color, width, height, alignment | Most versatile layout widget |
| `SizedBox` | width, height | Simple sizing/spacing |
| `Center` | widthFactor, heightFactor | Centering wrapper |
| `Expanded` | flex | Fills available space in flex layouts |
| `Flexible` | flex, fit | Flexible child in flex layouts |
| `Wrap` | direction, spacing, runSpacing | Flexible wrapping layout |
| `Stack` | alignment, fit | Overlapping widget layout |
| `AppBar` | title, actions, etc. | Full AppBar passthrough |

**Common properties (all widgets):**
- `visible` - Toggle visibility
- `highlight` - Debug overlay (orange border)

## Widget ID Generation

Widgets auto-generate unique IDs from their call site (file:line:col):

```dart
Column(children: [
  Text('Hello'),   // ID: build (my_widget.dart:15:5)
  Text('World'),   // ID: build (my_widget.dart:16:5)
])

// Helper method shows call hierarchy
Widget wrapItem(Widget child) => Padding(padding: EdgeInsets.all(8), child: child);

Column(children: [
  wrapItem(Text('A')),  // ID: [wrapItem] build (my_widget.dart:5:32)
])
```

## Schema-Driven Configuration

Widgets define their properties using typed descriptors:

```dart
class TextProps {
  static const textStyle = TextStyleProp('textStyle', label: 'Text Style');
  static const fontSize = SizeProp('fontSize', label: 'Font Size');
  static const fontWeight = FontWeightProp('fontWeight', label: 'Font Weight');
  static const color = ColorProp('color', label: 'Color');

  static final List<PropDescriptor> all = [
    CommonProps.visible,
    CommonProps.highlight,
    textStyle,
    fontSize,
    fontWeight,
    color,
  ];
}
```

Property types include:
- `BoolProp` - Checkbox toggle
- `NumberProp` - Number input with min/max/step
- `StringProp` - Text input
- `ColorProp` - Color picker with hex validation
- `SizeProp` - Size with registered sizes dropdown
- `EnumProp<T>` - Dropdown for enum values
- `TextStyleProp` - Registered text style dropdown
- `FontWeightProp` - Font weight options
- `AlignmentProp` - Alignment options

The dashboard auto-generates UI controls based on widget schemas.

## WebSocket Protocol

```json
// Widget registration
{"type": "register", "id": "...", "widgetType": "Text", "properties": {...}, "schema": [...]}

// Property update
{"type": "update_prop", "id": "...", "key": "fontSize", "value": 24}

// Style updates
{"type": "styles", "data": {"colors": {...}, "sizes": {...}, "textStyles": {...}}}

// Reset commands
{"type": "reset", "id": "..."}
{"type": "reset_all"}
```

## Project Structure

```
├── mdev_widgets/              # Flutter package
│   ├── lib/src/
│   │   ├── widgets/           # 12 configurable widgets
│   │   ├── schema/            # PropDescriptor types, ConfigurableWidgetMixin
│   │   ├── providers/         # WidgetConfigProvider, StyleRegistry
│   │   ├── services/          # ConfigSocket, ConfigPersistence, SessionStorage
│   │   └── models/            # WidgetConfig, ThemedColor, TextStyleConfig
│   ├── server/
│   │   ├── config_server.py   # WebSocket server (auto-reloads on changes)
│   │   ├── dashboard.html     # Web dashboard UI
│   │   └── tests/             # Python tests
│   └── test/                  # Flutter tests (136 tests)
├── mdev_widgets_demo/         # Full demo app with multiple tabs
└── Makefile                   # Build commands (run `make` for menu)
```

## Architecture

```
┌─────────────────┐       WebSocket      ┌─────────────────┐
│  Flutter App    │ ◄──────────────────► │  Python Server  │
│                 │                      │                 │
│  ┌───────────┐  │                      │  ┌───────────┐  │
│  │   Text    │──┼── register ─────────►│  │  widgets  │  │
│  │  Column   │  │                      │  │  schemas  │  │
│  └───────────┘  │                      │  │  styles   │  │
│       │         │                      │  └───────────┘  │
│       ▼         │                      │       │         │
│  ┌───────────┐  │◄── update_prop ──────┼───────┘         │
│  │ Provider  │  │                      │                 │
│  └───────────┘  │                      │  Dashboard UI   │
└─────────────────┘                      └─────────────────┘
```

## Requirements

- Flutter SDK ^3.10.8
- Dart SDK ^3.10.8
- Python 3.x (for config server)
- websockets >=12.0 (Python package, auto-installed)

## License

MIT
