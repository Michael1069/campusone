import 'package:flutter/material.dart';
import '../../core/widgets/auth_gate.dart';

class SplashController {
  static Future<void> start(BuildContext context) async {
    // ⏳ Minimum splash duration (sync with animation)
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    // 🚪 Hand off control to AuthGate ONLY
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
    );
  }
}
