class PlatformData {
  final String name;
  final String url;
  final String iconPath;

  const PlatformData({
    required this.name,
    required this.url,
    required this.iconPath,
  });
}

final platformsData = [
  PlatformData(
    name: 'Facebook',
    url: 'https://www.facebook.com',
    iconPath: 'assets/icons/Dark/Platform=Facebook, Color=Negative.png',
  ),
  PlatformData(
    name: 'Amazon',
    url: 'https://www.amazon.com',
    iconPath: 'assets/icons/Dark/Platform=Amazon, Color=Negative.png',
  ),
  PlatformData(
    name: 'Apple',
    url: 'https://www.apple.com',
    iconPath: 'assets/icons/Dark/Platform=Apple, Color=Negative.png',
  ),
  PlatformData(
    name: 'Netflix',
    url: 'https://www.netflix.com',
    iconPath: 'assets/icons/Dark/Platform=Netflix, Color=Negative.png',
  ),
  PlatformData(
    name: 'Discord',
    url: 'https://discord.com',
    iconPath: 'assets/icons/Dark/Platform=Discord, Color=Negative.png',
  ),
  PlatformData(
    name: 'Dribbble',
    url: 'https://dribbble.com',
    iconPath: 'assets/icons/Dark/Platform=Dribbble, Color=Negative.png',
  ),
  PlatformData(
    name: 'GitHub',
    url: 'https://github.com',
    iconPath: 'assets/icons/Dark/Platform=Github, Color=Negative.png',
  ),
  PlatformData(
    name: 'Google',
    url: 'https://google.com',
    iconPath: 'assets/icons/Dark/Platform=Google, Color=Negative.png',
  ),
  PlatformData(
    name: 'Instagram',
    url: 'https://instagram.com',
    iconPath: 'assets/icons/Dark/Platform=Instagram, Color=Negative.png',
  ),
  PlatformData(
    name: 'LinkedIn',
    url: 'https://linkedin.com',
    iconPath: 'assets/icons/Dark/Platform=LinkedIn, Color=Negative.png',
  ),
  // Add other platforms as needed
];
