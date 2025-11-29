// lib/core/network/connecting(wifiORserver)/connection_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ use flutter_bloc, not bloc
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'package:build4front/core/config/env.dart';

import 'connection_status.dart';

/// State model holding current connection status + optional message
class ConnectionStateModel {
  final ConnectionStatus status;
  final String? message;

  const ConnectionStateModel({required this.status, this.message});

  ConnectionStateModel copyWith({ConnectionStatus? status, String? message}) {
    return ConnectionStateModel(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

/// Possible states:
/// - online       → everything is fine
/// - offline      → device has no internet (Wi-Fi/mobile off)
/// - serverDown   → device has internet, but backend is not responding
class ConnectionCubit extends Cubit<ConnectionStateModel> {
  final Connectivity _connectivity;

  // ✅ In your connectivity_plus version, onConnectivityChanged is:
  //    Stream<List<ConnectivityResult>>
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Heartbeat timer to ping backend regularly
  Timer? _heartbeatTimer;

  ConnectionCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(const ConnectionStateModel(status: ConnectionStatus.online)) {
    _init();
  }

  /// Initialize:
  /// 1) Check initial connectivity (Wi-Fi / mobile)
  /// 2) Listen for connectivity changes
  /// 3) Start heartbeat when there is internet
  Future<void> _init() async {
    // 1) initial status
    final results = await _connectivity
        .checkConnectivity(); // List<ConnectivityResult>
    _updateFromResults(results);

    // 2) listen to changes (also List<ConnectivityResult>)
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateFromResults,
    );
  }

  /// Handle List<ConnectivityResult> from connectivity_plus
  void _updateFromResults(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateFromConnectivity(result);
  }

  /// Handle pure connectivity (Wi-Fi / mobile) changes.
  /// This does NOT check backend, only if device has internet.
  void _updateFromConnectivity(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      // No internet at all → offline
      emit(
        const ConnectionStateModel(
          status: ConnectionStatus.offline,
          message: 'No internet connection',
        ),
      );
      _stopHeartbeat();
    } else {
      // Internet is available (Wi-Fi or mobile)
      // If we were offline, move back to online first,
      // then heartbeat will keep it in sync with backend.
      if (state.status == ConnectionStatus.offline) {
        emit(const ConnectionStateModel(status: ConnectionStatus.online));
      }
      _startHeartbeat();
    }
  }

  /// Start periodic heartbeat to ping the backend.
  /// If backend dies while Wi-Fi is ON, this will detect it and set serverDown.
  void _startHeartbeat() {
    _heartbeatTimer ??= Timer.periodic(
      const Duration(seconds: 10),
      (_) => _pingServer(),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Ping the backend with a very small GET request.
  /// - If it returns any HTTP response (even 404): backend is reachable → online.
  /// - If it throws / times out: backend unreachable → serverDown (if not already offline).
  Future<void> _pingServer() async {
    // If we are already offline (no internet), don't bother pinging backend
    if (state.status == ConnectionStatus.offline) return;

    try {
      final uri = Uri.parse(Env.apiBaseUrl);
      await http.get(uri).timeout(const Duration(seconds: 5));

      // If we got ANY response, that means the server is reachable.
      // We don't care if it's 200 or 404, only that TCP connection worked.
      if (state.status != ConnectionStatus.online) {
        emit(const ConnectionStateModel(status: ConnectionStatus.online));
      }
    } catch (_) {
      // If we have internet but the backend doesn't answer → serverDown
      if (state.status != ConnectionStatus.offline) {
        emit(
          const ConnectionStateModel(
            status: ConnectionStatus.serverDown,
            message: 'Server is not responding',
          ),
        );
      }
    }
  }

  /// Manually mark server as down (used by ApiFetch when a request fails)
  void setServerDown([String? message]) {
    emit(
      ConnectionStateModel(
        status: ConnectionStatus.serverDown,
        message: message ?? 'Server is not responding',
      ),
    );
  }

  /// Manually mark as online (used by ApiFetch after a successful call)
  void setOnline() {
    emit(const ConnectionStateModel(status: ConnectionStatus.online));
  }

  @override
  Future<void> close() async {
    _subscription?.cancel();
    _stopHeartbeat();
    return super.close();
  }
}
