import 'package:flutter/widgets.dart' as flutter;
import 'package:mdev_widgets/mdev.dart';

class CenterDemo extends StatelessWidget {
  const CenterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Center',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const flutter.SizedBox(height: 4),
        Text(
          'Centers child with optional width/height factors',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const flutter.SizedBox(height: 12),
        Row(
          children: [
            flutter.Container(
              width: 100,
              height: 100,
              color: Colors.indigo.shade100,
              child: Center(
                child: flutter.Container(
                  width: 40,
                  height: 40,
                  color: Colors.indigo,
                  child: const flutter.Center(
                    child: flutter.Text('C', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            const flutter.SizedBox(width: 16),
            flutter.Container(
              width: 100,
              height: 100,
              color: Colors.pink.shade100,
              child: Center(
                widthFactor: 2.0,
                child: flutter.Container(
                  width: 30,
                  height: 30,
                  color: Colors.pink,
                ),
              ),
            ),
            const flutter.SizedBox(width: 16),
            flutter.Container(
              width: 100,
              height: 100,
              color: Colors.cyan.shade100,
              child: Center(
                heightFactor: 1.5,
                child: flutter.Container(
                  width: 40,
                  height: 40,
                  color: Colors.cyan,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
