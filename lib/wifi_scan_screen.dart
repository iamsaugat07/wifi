// WiFi Scan Screen using Riverpod
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifihackerapp/wifi_scanner_provider.dart';

class WiFiScanScreen extends ConsumerStatefulWidget {
  const WiFiScanScreen({super.key});

  @override
  ConsumerState<WiFiScanScreen> createState() => _WiFiScanScreenState();
}

class _WiFiScanScreenState extends ConsumerState<WiFiScanScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize scan after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wifiScanProvider.notifier).initializeWiFiScan(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wifiState = ref.watch(wifiScanProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Networks'),
      ),
      body: Column(
        children: [
          // Status and error handling section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  wifiState.statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: wifiState.accessPoints.isEmpty
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                if (wifiState.permissionDenied)
                  ElevatedButton(
                    onPressed: () async {
                      // Open app settings to grant permissions
                      await openAppSettings();
                      // Reset the permission denied flag after returning from settings
                      ref
                          .read(wifiScanProvider.notifier)
                          .resetPermissionDenied();
                    },
                    child: Text('Open Settings to Grant Permissions'),
                  ),
                if (wifiState.locationServiceDisabled)
                  ElevatedButton(
                    onPressed: () async {
                      // Reset the location service disabled flag
                      ref
                          .read(wifiScanProvider.notifier)
                          .resetLocationServiceDisabled();
                      // Try again
                      ref
                          .read(wifiScanProvider.notifier)
                          .initializeWiFiScan(context);
                    },
                    child: Text('Enable Location Services'),
                  ),
              ],
            ),
          ),

          // WiFi networks list
          Expanded(
            child: wifiState.isScanning
                ? Center(child: CircularProgressIndicator())
                : wifiState.accessPoints.isEmpty
                    ? Center(
                        child: Text(
                          wifiState.permissionDenied ||
                                  wifiState.locationServiceDisabled
                              ? "Please grant permissions to scan WiFi"
                              : "No WiFi networks found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: wifiState.accessPoints.length,
                        itemBuilder: (context, index) {
                          final ap = wifiState.accessPoints[index];
                          return ListTile(
                            leading: Icon(Icons.wifi),
                            title: Text(ap.ssid.isNotEmpty
                                ? ap.ssid
                                : "Hidden Network"),
                            subtitle: Text("Signal: ${ap.level} dBm"),
                            trailing: ap.capabilities.contains("WPA")
                                ? Icon(Icons.lock, size: 16)
                                : Icon(Icons.lock_open, size: 16),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: wifiState.isScanning
            ? null
            : () =>
                ref.read(wifiScanProvider.notifier).initializeWiFiScan(context),
        tooltip: 'Scan again',
        child: Icon(Icons.refresh),
      ),
    );
  }
}