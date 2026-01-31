import 'package:flutter/widgets.dart' as flutter;
import 'package:mdev_widgets/mdev.dart';

class ContainerDemo extends StatelessWidget {
  const ContainerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Container',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const flutter.SizedBox(height: 4),
        Text(
          'Most versatile layout widget with padding, margin, color, size',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const flutter.SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              alignment: Alignment.center,
              child: const flutter.Text(
                '100x100',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              width: 120,
              height: 80,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(4),
              color: Colors.green,
              alignment: Alignment.center,
              child: const flutter.Text(
                'Padding & Margin',
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 100,
              height: 100,
              color: Colors.orange,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(8),
              child: const flutter.Text(
                'Aligned',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
