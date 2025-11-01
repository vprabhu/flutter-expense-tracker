import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// A screen that displays the user's profile information and provides access to
/// settings and a logout button.
class ProfileScreen extends StatefulWidget {
  /// An instance of the [AuthService], used for handling sign-out operations.
  final AuthService authService;

  const ProfileScreen({super.key, required this.authService});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // The currently authenticated user.
  User? _user;
  // A boolean to toggle dark mode.
  bool isDarkModeEnabled = false;
  // The currently selected language.
  String selectedLanguage = 'English';

  // A list of available languages.
  final List<String> languages = ['English', 'Tamil'];

  @override
  void initState() {
    super.initState();
    // Load the current user when the screen is initialized.
    _loadUser();
  }

  /// Loads the current user from Firebase Authentication.
  void _loadUser() {
    _user = FirebaseAuth.instance.currentUser;
    // Rebuild the widget to display the user's information.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // If the user is not yet loaded, show a loading indicator.
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The profile header with the user's avatar, name, and email.
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: _user!.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                    child: _user!.photoURL == null
                        ? Icon(Icons.person, size: 50, color: Colors.blue[900])
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.displayName ?? 'No Name',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user!.email ?? 'No Email',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // The settings section.
            const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 16),
            // A toggle for dark mode.
            Card(
              child: ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkModeEnabled,
                  onChanged: (val) => setState(() => isDarkModeEnabled = val),
                ),
              ),
            ),
            // A dropdown for selecting the language.
            Card(
              child: ListTile(
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: selectedLanguage,
                  underline: const SizedBox(),
                  onChanged: (val) => setState(() => selectedLanguage = val!),
                  items: languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // The support section.
            const Text('Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 16),
            // A button to contact support.
            Card(
              elevation: 1,
              child: ListTile(
                title: const Text('Contact Us'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  // Show a dialog with contact information.
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Contact Us'),
                        content: const Text('For support, email us at support@app.com or call +1-123-456-7890.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // The logout button.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Show a confirmation dialog before logging out.
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Sign the user out and navigate to the login screen.
                              await widget.authService.signOut();
                              Navigator.of(context).pushReplacementNamed('/');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logged out successfully')),
                              );
                            },
                            child: const Text('Logout', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
