import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // لوگو
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.purpleGoldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryGold.withAlpha((0.5 * 255).round()),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 60,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, delay: 200.ms)
                      .fadeIn(duration: 600.ms),
                  
                  const SizedBox(height: 32),
                  
                  // عنوان
                  const Text(
                    'خوش اومدی به مانا! 🐱✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'برای ادامه، وارد حساب کاربریت بشو',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 48),
                  
                  // دکمه Google
                  _buildSocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'ادامه با Google',
                    color: Colors.white,
                    textColor: Colors.black87,
                    onTap: _signInWithGoogle,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms)
                      .slideX(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // دکمه Apple
                  _buildSocialButton(
                    icon: Icons.apple,
                    label: 'ادامه با Apple',
                    color: Colors.black,
                    textColor: Colors.white,
                    onTap: _signInWithApple,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 1000.ms)
                      .slideX(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // یا
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withAlpha((0.3 * 255).round()))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'یا',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withAlpha((0.3 * 255).round()))),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // ادامه بدون ورود
                  TextButton(
                    onPressed: _continueWithoutLogin,
                    child: const Text(
                      'ادامه بدون ورود',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 1200.ms),
                  
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential?.user != null && mounted) {
        // بارگذاری پروفایل از ابر
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserProfile();
        
        // انتقال به صفحه اصلی
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ورود: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    
    try {
      final userCredential = await _authService.signInWithApple();
      
      if (userCredential?.user != null && mounted) {
        // بارگذاری پروفایل از ابر
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserProfile();
        
        // انتقال به صفحه اصلی
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ورود: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _continueWithoutLogin() {
    Navigator.pushReplacementNamed(context, '/home');
  }
}

