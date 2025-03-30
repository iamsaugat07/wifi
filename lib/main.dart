import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wifihackerapp/wifi_scan_screen.dart';

// Main app with Riverpod setup
void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: WiFiScanScreen(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    ),
  );
}
