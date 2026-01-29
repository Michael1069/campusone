import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';



class LoginScreen extends StatefulWidget {
  final VoidCallback onSignupTap;

  const LoginScreen({
    super.key,
    required this.onSignupTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Stack(
        children: [
          // Background blur effects
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withValues(alpha:0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktopOrWeb =
                    kIsWeb ||
                        Theme.of(context).platform == TargetPlatform.windows ||
                        Theme.of(context).platform == TargetPlatform.macOS ||
                        Theme.of(context).platform == TargetPlatform.linux;

                final Widget scrollView = SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2B6CEE), Color(0xFF60A5FA)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary,
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.darkBackground,
                                      width: 4,
                                    ),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDj5cQs6BWQ9Sgq2vAbQRfnjmJnGvc-h9FkZTRyv2VnzQTBRYG_DPtiqe1Qaz7q48iMRdS_QGZJ_-DowdU9zz6zlyuw0IDNXUZf8NmegDpo37eZJ_Wz0yS08QPM7MWxVY5VKHtpaI6K-ouPkEgm4iWqhjO0lU083mtru9GVUGUhaTG0FHZ9WWLrdr8fu4wdRWLUm-EkHRnHsVU88RvAZX8H0BzwkL2KOx_38kR8oFOugmxB0Je7-1sCPUW2xG8GWRVSRdDhnxVLT_0',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Title
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Connect with friends and the world around you.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Email field
                              _buildTextFormField(
                                controller: _emailController,
                                hintText: 'Email or Username',
                                icon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Password field
                              _buildTextFormField(
                                controller: _passwordController,
                                hintText: 'Password',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  _formKey.currentState?.validate();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () async {
                                    if (!_formKey.currentState!.validate()) return;

                                    // Use read() to avoid unmounting
                                    final authProvider = context.read<AuthProvider>();
                                    
                                    // Clear previous error
                                    authProvider.clearError();

                                    try {
                                      await authProvider.login(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                      );
                                    } catch (e) {
                                      print('✅ Exception caught: $e');
                                    }
                                    
                                    print('🔍 After login - auth.error: ${authProvider.error}');
                                    print('🔍 context.mounted: ${context.mounted}');
                                    
                                    // Show error if login failed
                                    if (authProvider.error != null && context.mounted) {
                                      print('🚨 Showing error dialog!');
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: const Color(0xFF1E293B),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: const Row(
                                            children: [
                                              Icon(Icons.error_outline, color: Colors.red, size: 28),
                                              SizedBox(width: 12),
                                              Text(
                                                'Login Failed',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          content: Text(
                                            authProvider.error!,
                                            style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 15,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(color: Color(0xFF2B6CEE)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor:
                                    AppColors.primary.withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppColors.primary,
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Log In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withValues(alpha:0.1),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Or continue with',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withValues(alpha:0.1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Social buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton('G', Colors.white70),
                                  const SizedBox(width: 16),
                                  _buildSocialButton('♥', Colors.white),
                                  const SizedBox(width: 16),
                                  _buildSocialButton('f', const Color(0xFF1877F2)),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: widget.onSignupTap,
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Color(0xFF2B6CEE),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                return isDesktopOrWeb
                    ? Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  interactive: true,
                  child: scrollView,
                )
                    : scrollView;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, Color textColor) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha:0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}