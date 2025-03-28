import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifihackerapp/permission_services.dart';

final wifiScannerProvider = FutureProvider<List<WiFiAccessPoint>>((ref) async {
  final permissionService = PermissionsService();

  final ready = await permissionService.checkPermissionsAndLocationService();

  if (!ready) {
    throw Exception("Permissions or Location Services not ready");
  }

  // Check if scanning is supported
  final can = await WiFiScan.instance.canStartScan();
  if (can != CanStartScan.yes) {
    throw Exception("Cannot start WiFi scan: ${can.name}");
  }

  // Start the scan
  await WiFiScan.instance.startScan();

  // Get results
  final accessPoints = await WiFiScan.instance.getScannedResults();

  return accessPoints;
});
