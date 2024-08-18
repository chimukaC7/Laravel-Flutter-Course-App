import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  void startListening(Function(ConnectivityResult) onConnectivityChanged) {
    _subscription = _connectivity.onConnectivityChanged.listen(onConnectivityChanged as void Function(List<ConnectivityResult> event)?) as StreamSubscription<ConnectivityResult>;
  }

  void stopListening() {
    _subscription.cancel();
  }
}
