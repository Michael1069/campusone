  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  import '../providers/auth_provider.dart';
  import '../../features/auth/auth_shell.dart';
  import '../../features/home/home_screen.dart';

  class AuthGate extends StatelessWidget {
    const AuthGate({super.key});

    @override
    Widget build(BuildContext context) {
      final auth = context.watch<AuthProvider>();

      if (auth.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return auth.isLoggedIn
          ? const HomeScreen()
          : const AuthShell();
    }
  }
