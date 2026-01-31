import 'package:flutter/widgets.dart' as flutter;
import 'package:mdev_widgets/mdev.dart';

class PaddingDemo extends StatelessWidget {
  const PaddingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'EdgeInsets.all()',
            'Equal padding on all sides',
            _allPaddingDemo(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'EdgeInsets.symmetric()',
            'Horizontal and vertical padding',
            _symmetricPaddingDemo(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'EdgeInsets.only()',
            'Individual side padding',
            _onlyPaddingDemo(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'EdgeInsets.fromLTRB()',
            'Left, Top, Right, Bottom values',
            _fromLTRBDemo(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Nested Padding',
            'Multiple Padding widgets combined',
            _nestedPaddingDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, Widget demo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        demo,
      ],
    );
  }

  Widget _allPaddingDemo() {
    return Row(
      children: [
        _paddingBox('8px', const EdgeInsets.all(8)),
        const SizedBox(width: 16),
        _paddingBox('16px', const EdgeInsets.all(16)),
        const SizedBox(width: 16),
        _paddingBox('24px', const EdgeInsets.all(24)),
      ],
    );
  }

  Widget _symmetricPaddingDemo() {
    return Row(
      children: [
        _paddingBox(
          'h:16, v:8',
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        const SizedBox(width: 16),
        _paddingBox(
          'h:8, v:24',
          const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        ),
        const SizedBox(width: 16),
        _paddingBox(
          'h:32, v:4',
          const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        ),
      ],
    );
  }

  Widget _onlyPaddingDemo() {
    return Row(
      children: [
        _paddingBox('left:16', const EdgeInsets.only(left: 16)),
        const SizedBox(width: 16),
        _paddingBox('top:16', const EdgeInsets.only(top: 16)),
        const SizedBox(width: 16),
        _paddingBox('right:16', const EdgeInsets.only(right: 16)),
        const SizedBox(width: 16),
        _paddingBox('bottom:16', const EdgeInsets.only(bottom: 16)),
      ],
    );
  }

  Widget _fromLTRBDemo() {
    return Row(
      children: [
        _paddingBox('4,8,12,16', const EdgeInsets.fromLTRB(4, 8, 12, 16)),
        const SizedBox(width: 16),
        _paddingBox('16,4,16,4', const EdgeInsets.fromLTRB(16, 4, 16, 4)),
        const SizedBox(width: 16),
        _paddingBox('0,16,0,16', const EdgeInsets.fromLTRB(0, 16, 0, 16)),
      ],
    );
  }

  Widget _nestedPaddingDemo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              color: Colors.blue.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue.shade200,
                  child: const flutter.Text(
                    'Nested Padding',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paddingBox(String label, EdgeInsets padding) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: padding,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(4),
          ),
          child: flutter.Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
