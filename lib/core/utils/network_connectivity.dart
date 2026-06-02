import 'dart:io';

class NetworkConnectivity {
  NetworkConnectivity._();

  /// Checks if the device has a valid internet connection.
  static Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
