/// Abstract session storage interface for cross-platform support.
abstract class SessionStorage {
  String? getItem(String key);
  void setItem(String key, String value);
}

/// In-memory session storage for testing and non-web platforms.
class InMemorySessionStorage implements SessionStorage {
  static final Map<String, String> _store = {};

  @override
  String? getItem(String key) => _store[key];

  @override
  void setItem(String key, String value) => _store[key] = value;

  /// Clear all stored items (useful for testing).
  static void clear() => _store.clear();
}

/// Factory to get the appropriate session storage (stub for non-web).
SessionStorage createSessionStorage() => InMemorySessionStorage();
