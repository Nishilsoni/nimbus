import 'package:connectivity_plus/connectivity_plus.dart';

/// Answers "is there any network at all?" before we try a request.
///
/// It only catches the obvious offline case quickly. Being connected to a
/// network doesn't guarantee the internet is reachable, so [ApiClient] still
/// handles socket errors.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } on Exception {
      // If the platform can't tell us, let the request itself decide.
      return true;
    }
  }
}
