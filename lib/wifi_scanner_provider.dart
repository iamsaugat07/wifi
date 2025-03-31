import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wifihackerapp/wifi_scan_notifier.dart';
import 'package:wifihackerapp/wifi_scan_state.dart';

final wifiProvider = StateNotifierProvider<WiFiNotifier, WiFiScanState>((ref) {
  return WiFiNotifier();
});