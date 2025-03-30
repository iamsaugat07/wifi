// Riverpod notifier for managing WiFi scan state
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifihackerapp/wifi_scan_state.dart';

class WiFiScanNotifier extends StateNotifier<WiFiScanState> {
  WiFiScanNotifier() : super(WiFiScanState());

  Future<void> initializeWiFiScan(BuildContext context) async {
    state = state.copyWith(
      statusMessage: "Checking permissions...",
      isScanning: true,
    );

    // // Check if location services are enabled
    // bool locationEnabled = await _checkLocationServices();
    // if (!locationEnabled) {
    //   state = state.copyWith(
    //     locationServiceDisabled: true,
    //     statusMessage: "Location services are disabled",
    //     isScanning: false,
    //   );
    //   return;
    // }

    // Request permissions properly
    bool permissionsGranted = await _requestPermissions(context);
    if (!permissionsGranted) {
      state = state.copyWith(
        permissionDenied: true,
        statusMessage: "Required permissions not granted",
        isScanning: false,
      );
      return;
    }

    // Permissions are granted, start scanning
    await _startWiFiScan();
  }

  // Future<bool> _checkLocationServices() async {
  //   // Check if location services are enabled
  //   final info = NetworkInfo();
  //   try {
  //     await info.getLocationServiceAuthorization();
  //     return true;
  //   } catch (e) {
  //     print("Location services error: $e");
  //     return false;
  //   }
  // }

  Future<bool> _requestPermissions(BuildContext context) async {
    // Determine which permissions to request based on platform and version
    List<Permission> requiredPermissions = [];

    // Always need location permission
    requiredPermissions.add(Permission.location);

    // Check Android SDK version for additional permissions
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Add nearby devices permission for Android 12+
      if (await _isAndroid12OrHigher()) {
        requiredPermissions.add(Permission.nearbyWifiDevices);
      }
    }

    // Request all required permissions
    Map<Permission, PermissionStatus> statuses =
        await requiredPermissions.request();

    // Check if all permissions are granted
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
        print("Permission not granted: $permission");
      }
    });

    return allGranted;
  }

  Future<bool> _isAndroid12OrHigher() async {
    // In a real app, you'd check the Android SDK version
    // This is a simplified check - use a proper platform info package
    return true; // Assume Android 12+ for safety
  }

  Future<void> _startWiFiScan() async {
    state = state.copyWith(
      isScanning: true,
      statusMessage: "Scanning for WiFi networks...",
    );

    // Initialize WiFi scan
    final wifiScan = WiFiScan.instance;
    final canScan = await wifiScan.canStartScan();

    if (canScan != CanStartScan.yes) {
      state = state.copyWith(
        isScanning: false,
        statusMessage: "Cannot scan for WiFi: ${canScan.toString()}",
      );
      return;
    }

    // Start scan
    final result = await wifiScan.startScan();
    if (!result) {
      state = state.copyWith(
        isScanning: false,
        statusMessage: "Failed to start WiFi scan",
      );
      return;
    }

    // Get scan results
    final accessPoints = await wifiScan.getScannedResults();

    state = state.copyWith(
      accessPoints: accessPoints,
      isScanning: false,
      statusMessage: accessPoints.isEmpty
          ? "No WiFi networks found"
          : "Found ${accessPoints.length} networks",
    );
  }

  void resetPermissionDenied() {
    state = state.copyWith(permissionDenied: false);
  }

  void resetLocationServiceDisabled() {
    state = state.copyWith(locationServiceDisabled: false);
  }
}
