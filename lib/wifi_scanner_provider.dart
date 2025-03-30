// // Provider for WiFi scan state
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wifihackerapp/wifi_scan_notifier.dart';
import 'package:wifihackerapp/wifi_scan_state.dart';

final wifiScanProvider =
    StateNotifierProvider<WiFiScanNotifier, WiFiScanState>((ref) {
  return WiFiScanNotifier();
});
