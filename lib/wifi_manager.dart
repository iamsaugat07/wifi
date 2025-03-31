// Abstract class for platform implementation
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

abstract class PlatformWiFiManager {
  Future<Map<String, dynamic>> getCurrentWiFiInfo();
  Future<List<dynamic>> scanForNetworks();
  Future<bool> connectToNetwork(String ssid, {String? password});
  Future<bool> disconnectFromNetwork();
  Future<bool> openWiFiSettings();
}

// iOS implementation
class IOSWiFiManager implements PlatformWiFiManager {
  @override
  Future<Map<String, dynamic>> getCurrentWiFiInfo() async {
    try {
      final NetworkInfo networkInfo = NetworkInfo();
      final String? ssid = await networkInfo.getWifiName();
      final String? bssid = await networkInfo.getWifiBSSID();
      final String? ipAddress = await networkInfo.getWifiIP();
      
      return {
        'ssid': ssid?.replaceAll('"', ''),
        'bssid': bssid,
        'ipAddress': ipAddress,
      };
    } catch (e) {
      print('Error getting WiFi info: $e');
      return {'error': e.toString()};
    }
  }
  
  @override
  Future<List<dynamic>> scanForNetworks() async {
    // iOS can't scan for networks programmatically
    // Return empty list with a note
    return [{'error': 'WiFi scanning not available on iOS'}];
  }
  
  @override
  Future<bool> connectToNetwork(String ssid, {String? password}) async {
    // iOS can't connect to networks programmatically
    return false;
  }
  
  @override
  Future<bool> disconnectFromNetwork() async {
    // iOS can't disconnect from networks programmatically
    return false;
  }
  
  @override
  Future<bool> openWiFiSettings() async {
    try {
      // iOS URL scheme to open WiFi settings
      final Uri url = Uri.parse('App-Prefs:root=WIFI');
      if (await canLaunchUrl(url)) {
        return await launchUrl(url);
      } else {
        print('Could not launch $url');
        return false;
      }
    } catch (e) {
      print('Error opening WiFi settings: $e');
      return false;
    }
  }
}

// Android implementation
class AndroidWiFiManager implements PlatformWiFiManager {
  @override
  Future<Map<String, dynamic>> getCurrentWiFiInfo() async {
    try {
      final NetworkInfo networkInfo = NetworkInfo();
      final String? ssid = await networkInfo.getWifiName();
      final String? bssid = await networkInfo.getWifiBSSID();
      final String? ipAddress = await networkInfo.getWifiIP();
      
      return {
        'ssid': ssid?.replaceAll('"', ''),
        'bssid': bssid,
        'ipAddress': ipAddress,
      };
    } catch (e) {
      print('Error getting WiFi info: $e');
      return {'error': e.toString()};
    }
  }
  
  @override
  Future<List<dynamic>> scanForNetworks() async {
    try {
      final wifiScan = WiFiScan.instance;
      final canScan = await wifiScan.canStartScan();
      
      if (canScan != CanStartScan.yes) {
        return [{'error': 'Cannot scan for WiFi: ${canScan.toString()}'}];
      }
      
      // Start scan
      final result = await wifiScan.startScan();
      if (!result) {
        return [{'error': 'Failed to start WiFi scan'}];
      }
      
      // Get scan results
      final accessPoints = await wifiScan.getScannedResults();
      return accessPoints;
    } catch (e) {
      print('Error scanning for networks: $e');
      return [{'error': e.toString()}];
    }
  }
  
  @override
  Future<bool> connectToNetwork(String ssid, {String? password}) async {
    try {
      if (password != null && password.isNotEmpty) {
        // Connect to secure network
        return await WiFiForIoTPlugin.connect(
          ssid,
          password: password,
          security: NetworkSecurity.WPA,
        );
      } else {
        // Connect to open network
        return await WiFiForIoTPlugin.connect(
          ssid,
          security: NetworkSecurity.NONE,
        );
      }
    } catch (e) {
      print('Error connecting to network: $e');
      return false;
    }
  }
  
  @override
  Future<bool> disconnectFromNetwork() async {
    try {
      return await WiFiForIoTPlugin.disconnect();
    } catch (e) {
      print('Error disconnecting from network: $e');
      return false;
    }
  }
  
  @override
  Future<bool> openWiFiSettings() async {
    try {
      return await WiFiForIoTPlugin.forceWifiUsage(false);
    } catch (e) {
      print('Error opening WiFi settings: $e');
      return false;
    }
  }
}

// Factory to get appropriate platform implementation
class WiFiManagerFactory {
  static PlatformWiFiManager getManager() {
    if (Platform.isIOS) {
      return IOSWiFiManager();
    } else {
      return AndroidWiFiManager();
    }
  }
}