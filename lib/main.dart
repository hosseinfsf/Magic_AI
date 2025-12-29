import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/morning_mana_screen.dart';
import 'screens/night_summary_screen.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/floating_icon.dart';
import 'widgets/floating_panel.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ManaApp());
}

class ManaApp extends StatelessWidget {
  const ManaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserProfile()),
        ChangeNotifierProvider(create: (_) => ChatProvider()..loadMessages()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
      ],
      child: MaterialApp(
        title: 'مانا - دستیار هوشمند',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(context),
        darkTheme: AppTheme.darkTheme(context),
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/morning': (context) => const MorningManaScreen(),
          '/night': (context) => const NightSummaryScreen(),
        },
        // Wrap app content so we can overlay the floating icon with correct MediaQuery
        builder: (context, child) {
          final settings = Provider.of<SettingsProvider>(context);
          return Stack(
            children: [
              if (child != null) child,
              if (settings.floatingEnabled)
                FloatingManaIcon(
                  onDoubleTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => FractionallySizedBox(
                        heightFactor: 0.85,
                        child: const FloatingPanel(),
                      ),
                    );
                  },
                  onLongPress: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  clipboardActive: false,
                  size: settings.floatingSize,
                  opacity: settings.floatingOpacity,
                ),
            ],
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authService = AuthService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // بررسی ورود کاربر
    if (authService.isSignedIn) {
      await userProvider.loadUserProfile();
      final hasCompletedOnboarding = await userProvider.checkOnboardingStatus();
      
      if (!mounted) return;
      
      if (hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } else {
      // اگر لاگین نیست، به صفحه ورود برو
      final hasCompletedOnboarding = await userProvider.checkOnboardingStatus();
      
      if (!mounted) return;
      
      if (hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    duration: 1500.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                  ),
              const SizedBox(height: 24),
              const Text(
                'مانا',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'دستیار هوشمند شما',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 200.ms)
                  .slideY(begin: -0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

