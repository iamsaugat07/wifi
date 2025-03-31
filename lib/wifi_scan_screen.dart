// Main WiFi screen
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifihackerapp/wifi_scanner_provider.dart';

class WiFiScreen extends ConsumerStatefulWidget {
  const WiFiScreen({super.key});

  @override
  ConsumerState<WiFiScreen> createState() => _WiFiScreenState();
}

class _WiFiScreenState extends ConsumerState<WiFiScreen> {
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No need to manually initialize - the provider will do it
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showPasswordDialog(String ssid) {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to $ssid'),
        content: TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter WiFi password',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(wifiProvider.notifier).connectToNetwork(
                ssid,
                password: _passwordController.text,
              );
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wifiState = ref.watch(wifiProvider);
    final isIOS = Platform.isIOS;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Manager'),
        actions: [
          if (!isIOS && wifiState.currentSSID != null)
            IconButton(
              icon: Icon(Icons.wifi_off),
              onPressed: () {
                ref.read(wifiProvider.notifier).disconnectFromNetwork();
              },
              tooltip: 'Disconnect',
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Status card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Connection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        wifiState.currentSSID != null 
                            ? Icons.wifi 
                            : Icons.wifi_off,
                        color: wifiState.currentSSID != null 
                            ? Colors.green 
                            : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          wifiState.currentSSID ?? 'Not connected to any WiFi network',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (wifiState.ipAddress != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.laptop, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('IP: ${wifiState.ipAddress}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Status message
          Text(
            wifiState.statusMessage,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 16),
          
          // iOS info
          if (isIOS)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'iOS Limitations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Due to iOS security restrictions, this app cannot directly scan for or connect to WiFi networks. '
                      'Please use the button below to open WiFi settings.',
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.settings),
                        label: Text('Open WiFi Settings'),
                        onPressed: () {
                          ref.read(wifiProvider.notifier).openWiFiSettings();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Permission request button
          if (wifiState.permissionDenied) ...[
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Grant Location Permission'),
              onPressed: () {
                ref.read(wifiProvider.notifier).requestPermissions();
              },
            ),
          ],
          
          // Available networks (Android only)
          if (!isIOS && !wifiState.permissionDenied) ...[
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Networks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!wifiState.isScanning)
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      ref.read(wifiProvider.notifier).scanForNetworks();
                    },
                    tooltip: 'Rescan',
                  ),
              ],
            ),
            SizedBox(height: 12),
            
            // Network list or loading indicator
            wifiState.isScanning
                ? Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Scanning...'),
                      ],
                    ),
                  )
                : wifiState.availableNetworks.isEmpty || 
                  (wifiState.availableNetworks.length == 1 && 
                   wifiState.availableNetworks[0] is Map && 
                   wifiState.availableNetworks[0].containsKey('error'))
                    ? Center(
                        child: Text('No WiFi networks found'),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: wifiState.availableNetworks.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final network = wifiState.availableNetworks[index];
                          
                          // Handle both WiFiAccessPoint from wifi_scan and other formats
                          String ssid = '';
                          bool isSecure = false;
                          int signalStrength = 0;
                          
                          if (network is WiFiAccessPoint) {
                            ssid = network.ssid;
                            isSecure = network.capabilities.contains("WPA");
                            signalStrength = network.level;
                          } else if (network is Map) {
                            ssid = network['ssid'] ?? 'Unknown';
                            isSecure = network['isSecure'] ?? false;
                            signalStrength = network['signalStrength'] ?? 0;
                          }
                          
                          // Skip empty SSIDs
                          if (ssid.isEmpty) {
                            ssid = "Hidden Network";
                          }
                          
                          // Check if this is the currently connected network
                          final isConnected = ssid == wifiState.currentSSID;
                          
                          return ListTile(
                            leading: Icon(
                              Icons.wifi,
                              color: isConnected ? Colors.green : null,
                            ),
                            title: Text(
                              ssid,
                              style: TextStyle(
                                fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  isSecure ? Icons.lock_outline : Icons.lock_open_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(isSecure ? 'Secured' : 'Open'),
                                SizedBox(width: 8),
                                Icon(
                                  _getSignalIcon(signalStrength),
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text('${signalStrength}dBm'),
                              ],
                            ),
                            trailing: isConnected
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : IconButton(
                                    icon: Icon(Icons.link),
                                    onPressed: wifiState.isConnecting
                                        ? null
                                        : () {
                                            if (isSecure) {
                                              _showPasswordDialog(ssid);
                                            } else {
                                              ref.read(wifiProvider.notifier).connectToNetwork(ssid);
                                            }
                                          },
                                  ),
                          );
                        },
                      ),
          ],
        ],
      ),
      floatingActionButton: !isIOS && !wifiState.permissionDenied
          ? FloatingActionButton(
              onPressed: wifiState.isScanning || wifiState.isConnecting
                  ? null
                  : () => ref.read(wifiProvider.notifier).refreshWiFiInfo(),
              child: Icon(Icons.refresh),
              tooltip: 'Refresh',
            )
          : null,
    );
  }
  
  IconData _getSignalIcon(int strength) {
    if (strength >= -50) {
      return Icons.signal_wifi_4_bar;
    } else if (strength >= -60) {
      return Icons.network_wifi;
    } else if (strength >= -70) {
      return Icons.signal_wifi_4_bar_lock;
    } else {
      return Icons.signal_wifi_0_bar;
    }
  }
}
