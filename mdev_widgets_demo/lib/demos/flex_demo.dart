import 'package:flutter/material.dart' as flutter;
import 'package:mdev_widgets/mdev_shadow.dart';
class FlexDemo extends StatelessWidget {
  const FlexDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expanded & Flexible',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const flutter.SizedBox(height: 4),
        Text(
          'Flex widgets for flexible layouts',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const flutter.SizedBox(height: 12),
        // Expanded demo
        Text('Expanded (flex: 1, 2, 1):', style: const TextStyle(fontWeight: FontWeight.w500)),
        const flutter.SizedBox(height: 8),
        flutter.Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: flutter.Row(
            children: [
              Expanded(
                flex: 1,
                child: flutter.Container(
                  color: Colors.red.shade300,
                  child: const flutter.Center(child: flutter.Text('flex: 1')),
                ),
              ),
              Expanded(
                flex: 2,
                child: flutter.Container(
                  color: Colors.green.shade300,
                  child: const flutter.Center(child: flutter.Text('flex: 2')),
                ),
              ),
              Expanded(
                flex: 1,
                child: flutter.Container(
                  color: Colors.blue.shade300,
                  child: const flutter.Center(child: flutter.Text('flex: 1')),
                ),
              ),
            ],
          ),
        ),
        const flutter.SizedBox(height: 16),
        // Flexible demo
        Text('Flexible (loose vs tight):', style: const TextStyle(fontWeight: FontWeight.w500)),
        const flutter.SizedBox(height: 8),
        flutter.Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: flutter.Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: flutter.Container(
                  color: Colors.orange.shade300,
                  padding: const EdgeInsets.all(8),
                  child: const flutter.Text('loose'),
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: flutter.Container(
                  color: Colors.purple.shade300,
                  child: const flutter.Center(child: flutter.Text('tight')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
