import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔥 Firebase initialized successfully!');
  
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
