import 'session_storage.dart';

/// Factory to get the appropriate session storage for non-web platforms.
SessionStorage createSessionStorage() => InMemorySessionStorage();
