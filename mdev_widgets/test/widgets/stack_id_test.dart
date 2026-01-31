import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/widgets/stack_id_mixin.dart';

/// Stack ID extraction is designed primarily for web platform stack traces.
/// On VM (dart:io platforms), the stack trace format differs significantly.
/// These tests verify basic functionality that works across platforms.
void main() {
  setUp(() {
    // Reset instance counts before each test to ensure isolation
    resetInstanceCounts();
  });

  group('extractCallerId', () {
    test('returns a non-empty string', () {
      final id = extractCallerId();
      expect(id, isNotEmpty);
    });

    test('first call from location returns base ID', () {
      String getId() => extractCallerId();
      final id1 = getId();
      // First call should return base ID without suffix
      expect(id1.contains('#'), isFalse);
    });

    test('subsequent calls from same location get indexed', () {
      String getId() => extractCallerId();

      final id1 = getId();
      final id2 = getId();
      final id3 = getId();

      // First is base, subsequent get #2, #3, etc.
      expect(id1.contains('#'), isFalse);
      expect(id2, endsWith('#2'));
      expect(id3, endsWith('#3'));

      // All should share the same base
      expect(id2.replaceAll(' #2', ''), equals(id1));
      expect(id3.replaceAll(' #3', ''), equals(id1));
    });

    test('returns different values for different call sites', () {
      String getId1() => extractCallerId();
      String getId2() => extractCallerId();

      final id1 = getId1();
      final id2 = getId2();

      // On web, different lines should produce different IDs
      // On VM, the parser may not be able to parse the stack format
      if (kIsWeb) {
        expect(id1, isNot(equals(id2)));
      } else {
        // Just verify the function runs without error on VM
        expect(id1, isNotNull);
        expect(id2, isNotNull);
      }
    });
  });

  group('ID stability', () {
    test('single call returns stable base ID', () {
      // Simulating a widget capturing its ID once at construction
      final id = _getIdFromFixedLocation();
      expect(id, isNotEmpty);
      expect(id.contains('#'), isFalse); // First call, no suffix
    });

    test('IDs have reasonable length', () {
      final id = extractCallerId();

      // Should contain some identifying information
      expect(id.length, greaterThan(3));
    });

    test('resetInstanceCounts clears counters', () {
      String getId() => extractCallerId();

      getId(); // First call
      final id2 = getId(); // Should be #2
      expect(id2, endsWith('#2'));

      resetInstanceCounts();

      final id3 = getId(); // Should be base again after reset
      expect(id3.contains('#'), isFalse);
    });
  });

  // Web-specific tests (stack trace parsing with file:line:col format)
  group('web platform parsing', () {
    test('parses file location on web', () {
      final id = extractCallerId();

      if (kIsWeb) {
        // On web, should contain .dart file reference
        expect(id, contains('.dart'));
        // Should contain line:column pattern
        expect(RegExp(r':\d+:\d+').hasMatch(id), isTrue);
      } else {
        // On VM, just verify it returns something
        expect(id, isNotEmpty);
      }
    }, skip: !kIsWeb ? 'Web-specific test' : null);
  });
}

String _getIdFromFixedLocation() => extractCallerId();
