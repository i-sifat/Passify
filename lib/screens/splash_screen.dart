import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Reduced duration
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Reduced delay
    if (!mounted) return;

    final isAuthenticated =
        await ref.read(authProvider.notifier).isAuthenticated();

    if (isAuthenticated) {
      final email = await ref.read(authProvider.notifier).getUserEmail();
      if (email != null) {
        await ref.read(profileProvider.notifier).updateProfile(email: email);
      }
      ref.read(authProvider.notifier).state = true;
      _navigateTo(const HomeScreen());
    } else {
      final isFirstTime = await ref.read(authProvider.notifier).isFirstTime();
      final isOnboardingCompleted =
          await ref.read(authProvider.notifier).isOnboardingCompleted();

      if (isFirstTime || !isOnboardingCompleted) {
        _navigateTo(const OnboardingScreen());
      } else {
        _navigateTo(const LoginScreen());
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // Changed to end
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'Passify',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The only password manager you\'ll ever need',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48), // Added bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
