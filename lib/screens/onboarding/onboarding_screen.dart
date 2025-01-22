import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'GENERATE\nSECURE\nPASSWORDS.',
      subtitle:
          'Stop using unsecure passwords for your online accounts, level up with Passify. Get the most secure and difficult-to-crack passwords.',
    ),
    OnboardingPageData(
      title: 'ALL YOUR\nPASSWORDS ARE\nHERE.',
      subtitle:
          'Store and manage all of your passwords from one place. Don\'t remember hundreds of passwords, just remember one.',
    ),
    OnboardingPageData(
      title: 'DON\'T TYPE,\nAUTOFILL YOUR\nCREDENTIALS.',
      subtitle:
          'Don\'t compromise your passwords by typing them in public, let Passify autofill those and keep your credentials secure.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    await ref.read(authProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '***',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return OnboardingPage(data: _pages[index]);
                    },
                  ),
                  Positioned(
                    left: 24,
                    bottom: 24,
                    child: Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: _currentPage == index ? 24 : 16,
                              fontWeight: _currentPage == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                            ),
                            child: Text('${index + 1}'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _completeOnboarding();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('REGISTER'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _completeOnboarding();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('LOGIN'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
