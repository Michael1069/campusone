import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthShell extends StatefulWidget {
  const AuthShell({super.key});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  bool showLogin = true;

  void toggle() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: showLogin
          ? LoginScreen(
        key: const ValueKey('login'),
        onSignupTap: toggle,
      )
          : SignUpScreen(
        key: const ValueKey('signup'),
        onLoginTap: toggle,
      ),
    );
  }
}
