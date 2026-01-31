import 'package:web/web.dart' as web;

/// Abstract session storage interface for cross-platform support.
abstract class SessionStorage {
  String? getItem(String key);
  void setItem(String key, String value);
}

/// Web-specific session storage using browser sessionStorage.
class WebSessionStorage implements SessionStorage {
  @override
  String? getItem(String key) => web.window.sessionStorage.getItem(key);

  @override
  void setItem(String key, String value) =>
      web.window.sessionStorage.setItem(key, value);
}

/// Factory to get the appropriate session storage for web.
SessionStorage createSessionStorage() => WebSessionStorage();
