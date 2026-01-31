import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/widget_config_provider.dart';
import 'services/config_socket.dart';

class MdevSetup {
  final WidgetConfigProvider provider;
  final ConfigSocket _socket;

  MdevSetup._(this.provider, this._socket);

  static Future<MdevSetup> init({String? serverUrl}) async {
    final provider = WidgetConfigProvider();
    await provider.init();

    final socket = serverUrl != null
        ? ConfigSocket(provider, url: serverUrl)
        : ConfigSocket(provider);

    provider.onRegister = socket.register;
    provider.onUnregister = socket.unregister;
    provider.onStyleChange = socket.sendStyles;

    return MdevSetup._(provider, socket);
  }

  /// Wraps the app with the required ChangeNotifierProvider
  Widget wrapApp(Widget child) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: child,
    );
  }

  void connect() {
    _socket.connect();
  }
}
