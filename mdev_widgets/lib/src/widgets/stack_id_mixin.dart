String extractCallerId() {
  final trace = StackTrace.current.toString();
  final lines = trace.split('\n');

  final frames = <_StackFrame>[];
  String? targetFile;

  for (final line in lines.skip(1)) {
    if (_shouldSkipLine(line)) continue;
    if (line.trim().isEmpty) continue;

    final frame = _parseFrame(line);
    if (frame == null) continue;

    // First valid frame determines the target file
    if (targetFile == null) {
      targetFile = frame.file;
      frames.add(frame);
    } else if (frame.file == targetFile) {
      // Collect frames from the same file to show call hierarchy
      frames.add(frame);
    }
  }

  if (frames.isEmpty) return 'unknown';

  // Build hierarchical ID: [innerFunc] outerFunc > ... (file:line:col)
  if (frames.length == 1) {
    final f = frames.first;
    return '${f.function} (${f.file}:${f.location})';
  }

  // Multiple frames from same file - show hierarchy
  final firstFrame = frames.first;
  final functions = frames.map((f) => f.function).toList();

  // Format: [immediate] parent > grandparent (file:line:col)
  final hierarchy = functions.skip(1).join(' > ');
  return '[${functions.first}] $hierarchy (${firstFrame.file}:${firstFrame.location})';
}

class _StackFrame {
  final String function;
  final String file;
  final String location;

  _StackFrame(this.function, this.file, this.location);
}

_StackFrame? _parseFrame(String line) {
  // Native VM format: #0 functionName (file.dart:line:col)
  final nativeMatch = RegExp(
    r'#\d+\s+(\S+)\s+\((?:package:)?([^)]+\.dart):(\d+:\d+)\)',
  ).firstMatch(line);
  if (nativeMatch != null) {
    return _StackFrame(
      nativeMatch.group(1)!,
      nativeMatch.group(2)!,
      nativeMatch.group(3)!,
    );
  }

  // Web format: file.dart line:col functionName
  final webMatch = RegExp(
    r'(?:package:)?([\w./:-]+\.dart)\s+(\d+:\d+)\s+(\S+)',
  ).firstMatch(line);
  if (webMatch != null) {
    return _StackFrame(
      webMatch.group(3)!,
      webMatch.group(1)!,
      webMatch.group(2)!,
    );
  }

  return null;
}

bool _shouldSkipLine(String line) {
  return line.contains('stack_id_mixin.dart') ||
      line.contains('text.dart') ||
      line.contains('column.dart') ||
      line.contains('row.dart') ||
      line.contains('padding.dart') ||
      line.contains('wrap.dart') ||
      line.contains('stack.dart') ||
      line.contains('app_bar.dart') ||
      line.contains('container.dart') ||
      line.contains('sized_box.dart') ||
      line.contains('center.dart') ||
      line.contains('expanded.dart') ||
      line.contains('flexible.dart');
}
