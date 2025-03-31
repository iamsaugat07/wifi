// Notifier for WiFi state
import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifihackerapp/wifi_manager.dart';
import 'package:wifihackerapp/wifi_scan_state.dart';

class WiFiNotifier extends StateNotifier<WiFiScanState> {
  final PlatformWiFiManager _manager = WiFiManagerFactory.getManager();
  
  WiFiNotifier() : super(WiFiScanState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(
      statusMessage: "Checking permissions...",
    );

    // Check permissions
    PermissionStatus locationStatus = await Permission.locationWhenInUse.status;
    
    if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
      state = state.copyWith(
        permissionDenied: true,
        statusMessage: "Location permission required",
      );
      return;
    }

    // Get current WiFi info
    await refreshWiFiInfo();
    
    // If on Android, scan for networks
    if (Platform.isAndroid) {
      await scanForNetworks();
    }
  }

  Future<void> requestPermissions() async {
    state = state.copyWith(
      statusMessage: "Requesting permissions...",
    );

    PermissionStatus locationStatus = await Permission.locationWhenInUse.request();
    
    if (locationStatus.isGranted) {
      // Additional Android permissions for Android 12+
      if (Platform.isAndroid) {
        await Permission.nearbyWifiDevices.request();
      }
      
      state = state.copyWith(
        permissionDenied: false,
      );
      
      await refreshWiFiInfo();
      
      if (Platform.isAndroid) {
        await scanForNetworks();
      }
    } else {
      state = state.copyWith(
        permissionDenied: true,
        statusMessage: "Location permission denied",
      );
    }
  }

  Future<void> refreshWiFiInfo() async {
    state = state.copyWith(
      statusMessage: "Getting WiFi information...",
    );

    final wifiInfo = await _manager.getCurrentWiFiInfo();
    
    if (wifiInfo.containsKey('error')) {
      state = state.copyWith(
        statusMessage: "Error: ${wifiInfo['error']}",
      );
      return;
    }

    state = state.copyWith(
      currentSSID: wifiInfo['ssid'],
      ipAddress: wifiInfo['ipAddress'],
      statusMessage: wifiInfo['ssid'] != null 
          ? "Connected to: ${wifiInfo['ssid']}" 
          : "Not connected to any WiFi network",
    );
  }

  Future<void> scanForNetworks() async {
    if (Platform.isIOS) {
      state = state.copyWith(
        statusMessage: "WiFi scanning not available on iOS",
      );
      return;
    }

    state = state.copyWith(
      isScanning: true,
      statusMessage: "Scanning for WiFi networks...",
    );

    final networks = await _manager.scanForNetworks();
    
    state = state.copyWith(
      availableNetworks: networks,
      isScanning: false,
      statusMessage: networks.isEmpty || (networks.length == 1 && networks[0] is Map && networks[0].containsKey('error'))
          ? "No networks found"
          : "Found ${networks.length} networks",
    );
  }

  Future<void> connectToNetwork(String ssid, {String? password}) async {
    if (Platform.isIOS) {
      await openWiFiSettings();
      return;
    }

    state = state.copyWith(
      isConnecting: true,
      statusMessage: "Connecting to $ssid...",
    );

    final result = await _manager.connectToNetwork(ssid, password: password);
    
    if (result) {
      state = state.copyWith(
        isConnecting: false,
        currentSSID: ssid,
        statusMessage: "Connected to $ssid",
      );
      
      // Refresh to get updated info
      await Future.delayed(Duration(seconds: 2));
      await refreshWiFiInfo();
    } else {
      state = state.copyWith(
        isConnecting: false,
        statusMessage: "Failed to connect to $ssid",
      );
    }
  }

  Future<void> disconnectFromNetwork() async {
    if (Platform.isIOS) {
      await openWiFiSettings();
      return;
    }

    state = state.copyWith(
      isConnecting: true,
      statusMessage: "Disconnecting...",
    );

    final result = await _manager.disconnectFromNetwork();
    
    if (result) {
      state = state.copyWith(
        isConnecting: false,
        currentSSID: null,
        statusMessage: "Disconnected",
      );
      
      // Refresh to get updated info
      await Future.delayed(Duration(seconds: 2));
      await refreshWiFiInfo();
    } else {
      state = state.copyWith(
        isConnecting: false,
        statusMessage: "Failed to disconnect",
      );
    }
  }

  Future<void> openWiFiSettings() async {
    state = state.copyWith(
      statusMessage: "Opening WiFi settings...",
    );

    await _manager.openWiFiSettings();
    
    // Refresh after returning from settings
    await Future.delayed(Duration(seconds: 3));
    await refreshWiFiInfo();
  }
}