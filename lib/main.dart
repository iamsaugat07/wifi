// Main app with platform detection and Riverpod
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wifihackerapp/wifi_scan_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: WiFiScreen(),
    );
  }
}

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
