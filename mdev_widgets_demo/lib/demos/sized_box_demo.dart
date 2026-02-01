import 'package:flutter/material.dart' as flutter;
import 'package:mdev_widgets/mdev_shadow.dart';
class SizedBoxDemo extends StatelessWidget {
  const SizedBoxDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SizedBox',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const flutter.SizedBox(height: 4),
        Text(
          'Simple sizing and spacing widget',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const flutter.SizedBox(height: 12),
        Row(
          children: [
            flutter.Container(
              color: Colors.purple.shade100,
              child: SizedBox(
                width: 80,
                height: 80,
                child: flutter.Container(
                  color: Colors.purple,
                  child: const flutter.Center(
                    child: flutter.Text('80x80', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            const flutter.SizedBox(width: 16),
            flutter.Container(
              color: Colors.teal.shade100,
              child: SizedBox(
                width: 120,
                height: 60,
                child: flutter.Container(
                  color: Colors.teal,
                  child: const flutter.Center(
                    child: flutter.Text('120x60', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            const flutter.SizedBox(width: 16),
            flutter.Container(
              color: Colors.amber.shade100,
              child: SizedBox(
                width: 50,
                height: 100,
                child: flutter.Container(
                  color: Colors.amber,
                  child: const flutter.Center(
                    child: flutter.Text('50x100', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
