import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../providers/widget_config_provider.dart';

enum ConnectionState { disconnected, connecting, connected }

class ConfigSocket {
  final WidgetConfigProvider provider;
  final String url;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _disposed = false;
  ConnectionState _state = ConnectionState.disconnected;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectDelay = 30;

  final List<Map<String, dynamic>> _pendingMessages = [];
  Map<String, dynamic>? _pendingStyles;

  ConfigSocket(this.provider, {this.url = 'ws://localhost:8081'});

  ConnectionState get state => _state;
  bool get isConnected => _state == ConnectionState.connected;

  void connect() {
    if (_disposed || _state == ConnectionState.connecting) return;
    _connectAsync();
  }

  Future<void> _connectAsync() async {
    _state = ConnectionState.connecting;
    debugPrint('Connecting to $url...');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      await _channel!.ready.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );

      _state = ConnectionState.connected;
      final wasReconnect = _reconnectAttempts > 0;
      _reconnectAttempts = 0;
      debugPrint('Connected to $url');

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _handleDisconnect();
        },
      );

      provider.addListener(_onProviderChange);

      if (wasReconnect) {
        provider.reregisterAll();
      } else {
        // First connection - reset server state
        _send({'type': 'reset_all'});

        if (_pendingStyles != null) {
          debugPrint('Sending pending styles');
          _send({'type': 'styles', 'data': _pendingStyles});
          _pendingStyles = null;
        }

        debugPrint('Sending ${_pendingMessages.length} pending messages');
        for (final msg in _pendingMessages) {
          debugPrint('  -> ${msg['id']} (${msg['widgetType']})');
          _send(msg);
        }
        _pendingMessages.clear();
      }
    } catch (e) {
      debugPrint('Connection failed: $e');
      _state = ConnectionState.disconnected;
      _channel = null;
      _scheduleReconnect();
    }
  }

  void _handleDisconnect() {
    if (_disposed) return;

    _state = ConnectionState.disconnected;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    provider.removeListener(_onProviderChange);

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;

    _reconnectTimer?.cancel();

    final delay = (1 << _reconnectAttempts).clamp(1, _maxReconnectDelay);
    _reconnectAttempts++;

    debugPrint('Reconnecting in $delay seconds...');
    _reconnectTimer = Timer(Duration(seconds: delay), connect);
  }

  void _onMessage(dynamic message) {
    if (_disposed) return;
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      if (type == 'update') {
        final widgetData = data['data'] as Map<String, dynamic>;
        final id = widgetData['id'] as String;
        provider.updateFromServer(id, widgetData);
      } else if (type == 'styles') {
        final stylesData = data['data'] as Map<String, dynamic>;
        provider.updateStylesFromServer(stylesData);
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  void _onProviderChange() {}

  void register(String id, String type, Map<String, dynamic> properties, {List<Map<String, dynamic>>? schema}) {
    final msg = {
      'type': 'register',
      'id': id,
      'widgetType': type,
      'properties': properties,
      if (schema != null) 'schema': schema,
    };

    if (isConnected) {
      debugPrint('Sending registration: $id ($type)');
      _send(msg);
    } else {
      debugPrint('Queueing registration: $id ($type)');
      _pendingMessages.add(msg);
    }
  }

  void unregister(String id) {
    final msg = {'type': 'unregister', 'id': id};

    if (isConnected) {
      _send(msg);
    } else {
      _pendingMessages.removeWhere(
        (m) => m['type'] == 'register' && m['id'] == id,
      );
    }
  }

  void sendStyles(Map<String, dynamic> styles) {
    if (isConnected) {
      _send({'type': 'styles', 'data': styles});
    } else {
      _pendingStyles = styles;
    }
  }

  void resetServer() {
    _send({'type': 'reset_all'});
  }

  void _send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    provider.removeListener(_onProviderChange);
    _subscription?.cancel();
    _channel?.sink.close();
  }
}
