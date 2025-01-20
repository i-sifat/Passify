import 'package:flutter/material.dart';

class OnboardingPageData {
  final String title;
  final String subtitle;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            data.title,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 24),
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}