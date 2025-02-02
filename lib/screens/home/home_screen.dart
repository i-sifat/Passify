import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/password_provider.dart';
import '../profile/profile_screen.dart';
import 'add_password_screen.dart';
import 'password_details_screen.dart';
import 'search_delegate.dart';
import 'update_password_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final passwords = ref.watch(passwordProvider);
    final compromisedPasswords = passwords.where((p) => p.isCompromised).toList();

    return Scaffold(
      body: _selectedIndex == 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Passify',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BebasNeue',
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
                                  passwords.length.toString(),
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
                          child: GestureDetector(
                            onTap: compromisedPasswords.isNotEmpty
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Compromised Passwords'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '⚠️ These passwords have been found in data breaches. Please update them immediately!',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            const SizedBox(height: 16),
                                            ...compromisedPasswords.map((entry) => ListTile(
                                              title: Text(entry.name),
                                              subtitle: Text(entry.email),
                                              trailing: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UpdatePasswordScreen(
                                                        entry: entry,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text('UPDATE'),
                                              ),
                                            )),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('CLOSE'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                : null,
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
                                    compromisedPasswords.length.toString(),
                                    style: TextStyle(
                                      color: compromisedPasswords.isNotEmpty
                                          ? Colors.red
                                          : Theme.of(context).primaryColor,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Passwords\nCompromised',
                                    style: TextStyle(
                                      color: compromisedPasswords.isNotEmpty
                                          ? Colors.red
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
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
                          delegate: PasswordSearchDelegate(passwords),
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
                      child: passwords.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 64,
                                    color: Theme.of(context).primaryColor.withAlpha(128),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('NO PASSWORDS'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first password by tapping the + button below',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withAlpha(128),
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: passwords.length,
                              itemBuilder: (context, index) {
                                final entry = passwords[index];
                                final platformName = entry.name.split(' ')[0].toLowerCase();
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PasswordDetailsScreen(
                                            entry: entry,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/icons/${Theme.of(context).brightness == Brightness.dark ? 'Dark' : 'Light'}/Platform=$platformName, Color=${Theme.of(context).brightness == Brightness.dark ? 'Negative' : 'Original'}.png',
                                        width: 35,
                                        height: 35,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.grey[200]
                                                  : Colors.grey[700],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.lock_outline,
                                              color: entry.isCompromised ? Colors.red : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      entry.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: entry.isCompromised ? Colors.red : null,
                                      ),
                                    ),
                                    subtitle: entry.isCompromised
                                        ? const Text(
                                            '⚠️ Password compromised',
                                            style: TextStyle(color: Colors.red),
                                          )
                                        : null,
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.content_copy,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: entry.password));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Password copied to clipboard'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            )
          : const ProfileScreen(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPasswordScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
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