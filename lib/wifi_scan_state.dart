// State class for WiFi scan
import 'package:wifi_scan/wifi_scan.dart';

class WiFiScanState {
  final List<WiFiAccessPoint> accessPoints;
  final bool isScanning;
  final bool permissionDenied;
  final bool locationServiceDisabled;
  final String statusMessage;

  WiFiScanState({
    this.accessPoints = const [],
    this.isScanning = false,
    this.permissionDenied = false,
    this.locationServiceDisabled = false,
    this.statusMessage = "Initializing...",
  });

  WiFiScanState copyWith({
    List<WiFiAccessPoint>? accessPoints,
    bool? isScanning,
    bool? permissionDenied,
    bool? locationServiceDisabled,
    String? statusMessage,
  }) {
    return WiFiScanState(
      accessPoints: accessPoints ?? this.accessPoints,
      isScanning: isScanning ?? this.isScanning,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      locationServiceDisabled:
          locationServiceDisabled ?? this.locationServiceDisabled,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
