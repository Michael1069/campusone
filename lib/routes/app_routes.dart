import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/auth_shell.dart';
import '../features/home/home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/auth': (context) => const AuthShell(),
    '/home': (context) => const HomeScreen(),
  };
}
