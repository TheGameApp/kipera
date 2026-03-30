import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around connectivity_plus that provides a simple stream of
/// connection status (online / offline) and a synchronous check.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _lastKnown = true;

  ConnectivityService() {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = _isOnline(results);
      if (connected != _lastKnown) {
        _lastKnown = connected;
        _controller.add(connected);
        debugPrint('🌐 [Connectivity] status changed: ${connected ? "ONLINE" : "OFFLINE"}');
      }
    });
  }

  /// Stream that emits true when connectivity changes to online,
  /// false when it changes to offline. Only emits on *changes*.
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Check current connectivity (async, actual check).
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    _lastKnown = _isOnline(results);
    return _lastKnown;
  }

  /// Last known connectivity status (synchronous, may be stale).
  bool get lastKnownStatus => _lastKnown;

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
