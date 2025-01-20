import 'package:flutter/material.dart';
import '../../models/password_entry.dart';
import 'password_tile.dart';
import 'password_details_screen.dart';

class PasswordSearchDelegate extends SearchDelegate<String> {
  final List<PasswordEntry> passwords;

  PasswordSearchDelegate(this.passwords);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = passwords.where((password) {
      return password.name.toLowerCase().contains(query.toLowerCase()) ||
          password.url.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (query.isEmpty) {
      return const SizedBox();
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text('NO RESULTS'),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find anything. Try searching for something else.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return PasswordTile(
          entry: results[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PasswordDetailsScreen(
                  entry: results[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}