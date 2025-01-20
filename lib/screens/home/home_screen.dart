import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/password_entry.dart';
import 'password_details_screen.dart';
import 'password_tile.dart';
import 'search_delegate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<PasswordEntry> _passwords = [
    PasswordEntry(
      name: 'Facebook',
      url: 'www.facebook.com',
      email: 'james.smith@mail.gg',
      password: '********',
      lastUpdated: DateTime(2022, 5, 25),
      icon: Icons.facebook,
    ),
    PasswordEntry(
      name: 'Amazon',
      url: 'www.amazon.com',
      email: 'james.smith@mail.gg',
      password: '********',
      lastUpdated: DateTime.now(),
      icon: Icons.shopping_cart,
    ),
    PasswordEntry(
      name: 'Apple',
      url: 'www.apple.com',
      email: 'james.smith@mail.gg',
      password: '********',
      lastUpdated: DateTime.now(),
      icon: Icons.apple,
    ),
    PasswordEntry(
      name: 'Netflix',
      url: 'www.netflix.com',
      email: 'james.smith@mail.gg',
      password: '********',
      lastUpdated: DateTime.now(),
      icon: Icons.movie,
    ),
    PasswordEntry(
      name: 'Google',
      url: 'www.google.com',
      email: 'james.smith@mail.gg',
      password: '********',
      lastUpdated: DateTime.now(),
      icon: Icons.search,
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[100]
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _passwords.length.toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Passwords\nStored'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[100]
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Passwords\nCompromised'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: PasswordSearchDelegate(_passwords),
                  );
                },
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search Websites...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _passwords.length,
                  itemBuilder: (context, index) {
                    return PasswordTile(
                      entry: _passwords[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordDetailsScreen(
                              entry: _passwords[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add password
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}