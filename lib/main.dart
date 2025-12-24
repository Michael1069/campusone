import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const CampusOneApp(),
    ),
  );
}

class CampusOneApp extends StatelessWidget {
  const CampusOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusOne',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // ✅ Splash is FIRST
      home: const SplashScreen(),
    );
  }
}
