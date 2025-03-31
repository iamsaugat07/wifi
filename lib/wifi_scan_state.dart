// State class for WiFi
class WiFiScanState {
  final String? currentSSID;
  final String? ipAddress;
  final List<dynamic> availableNetworks;
  final bool isScanning;
  final bool isConnecting;
  final bool permissionDenied;
  final String statusMessage;

  WiFiScanState({
    this.currentSSID,
    this.ipAddress,
    this.availableNetworks = const [],
    this.isScanning = false,
    this.isConnecting = false,
    this.permissionDenied = false,
    this.statusMessage = "Initializing...",
  });

  get accessPoints => null;

  WiFiScanState copyWith({
    String? currentSSID,
    String? ipAddress,
    List<dynamic>? availableNetworks,
    bool? isScanning,
    bool? isConnecting,
    bool? permissionDenied,
    String? statusMessage,
  }) {
    return WiFiScanState(
      currentSSID: currentSSID ?? this.currentSSID,
      ipAddress: ipAddress ?? this.ipAddress,
      availableNetworks: availableNetworks ?? this.availableNetworks,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
