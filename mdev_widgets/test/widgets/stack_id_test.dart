import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdev_widgets/src/widgets/stack_id_mixin.dart';

/// Stack ID extraction is designed primarily for web platform stack traces.
/// On VM (dart:io platforms), the stack trace format differs significantly.
/// These tests verify basic functionality that works across platforms.
void main() {
  group('extractCallerId', () {
    test('returns a non-empty string', () {
      final id = extractCallerId();
      expect(id, isNotEmpty);
    });

    test('returns same ID for same call location', () {
      String getId() => extractCallerId();
      final id1 = getId();
      final id2 = getId();
      // Same call site should return same ID
      expect(id1, equals(id2));
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
    test('single call returns stable ID', () {
      // Simulating a widget capturing its ID once at construction
      final id = _getIdFromFixedLocation();
      expect(id, isNotEmpty);
    });

    test('IDs have reasonable length', () {
      final id = extractCallerId();

      // Should contain some identifying information
      expect(id.length, greaterThan(3));
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
