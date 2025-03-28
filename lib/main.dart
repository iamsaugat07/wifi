import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wifihackerapp/wifi_scanner_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Scanner',
      home: WifiScannerScreen(),
    );
  }
}

class WifiScannerScreen extends ConsumerWidget {
  const WifiScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wifiScan = ref.watch(wifiScannerProvider);

    return Scaffold(
      appBar: AppBar(title: Text("WiFi Scanner")),
      body: wifiScan.when(
        data: (networks) {
          if (networks.isEmpty) {
            return Center(child: Text("No WiFi networks found"));
          }
          return ListView.builder(
            itemCount: networks.length,
            itemBuilder: (_, index) {
              final wifi = networks[index];
              return ListTile(
                title: Text(wifi.ssid),
                subtitle: Text('Signal: ${wifi.level} dBm'),
                onTap: () => print(wifi),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: ${err.toString()}")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.refresh(wifiScannerProvider),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
