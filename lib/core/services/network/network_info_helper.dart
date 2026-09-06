import 'dart:io';

/// Utility to detect network interface types using native [NetworkInterface.list]
/// without requiring extra platform plugins.
class NetworkInfoHelper {
  /// Checks if the device has an active Wi-Fi connection.
  static Future<bool> isWifiConnected() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      if (interfaces.isEmpty) return false;

      for (final iface in interfaces) {
        final name = iface.name.toLowerCase();
        // Wi-Fi interface patterns across Android (wlan, wifi, p2p, ap),
        // iOS (en0, en1), Windows/Desktop (wi-fi, wireless, wlan)
        final isWifiPattern = name.contains('wlan') ||
            name.contains('wifi') ||
            name.contains('wi-fi') ||
            name.contains('wireless') ||
            name == 'en0' ||
            name == 'en1';

        if (isWifiPattern) {
          // Check if interface has an active, valid IP address
          final hasValidIp = iface.addresses.any(
            (addr) => !addr.isLoopback && !addr.isLinkLocal,
          );
          if (hasValidIp) {
            return true;
          }
        }
      }
      return false;
    } catch (_) {
      // In case of permission/exception, fail-safe to true so we don't block downloads erroneously
      return true;
    }
  }
}
