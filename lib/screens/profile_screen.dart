import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart'; // For system navigator if needed for logout

// Placeholder ProfileScreen: Simple screen for Profile tab (expand with user settings)
class ProfileScreen extends StatefulWidget {
  final AuthService authService;

  const ProfileScreen({super.key, required this.authService});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool isDarkModeEnabled = false;
  String selectedLanguage = 'English';

  final List<String> languages = ['English', 'Tamil'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        children: [
          // AppBar
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header with Avatar and Info
                  Center(
                    child: Column(
                      children: [
                        // Circular Profile Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[100],
                          backgroundImage: _user!.photoURL != null
                              ? NetworkImage(_user!.photoURL!)
                              : null,
                          child: _user!.photoURL == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.blue[900],
                                )
                              : null,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _user!.displayName ?? 'No Name',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _user!.email ?? 'No Email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  // Settings Section
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Example Dark Mode Toggle
                  Card(
                    child: ListTile(
                      title: Text('Dark Mode'),
                      trailing: Switch(
                        value: isDarkModeEnabled,
                        onChanged: (val) =>
                            setState(() => isDarkModeEnabled = val),
                      ),
                    ),
                  ),

                  // Language Dropdown
                  Card(
                    child: ListTile(
                      title: Text('Language'),
                      trailing: DropdownButton<String>(
                        value: selectedLanguage,
                        underline: SizedBox(),
                        onChanged: (val) =>
                            setState(() => selectedLanguage = val!),
                        items: languages
                            .map(
                              (lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Support Section
                  Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Contact Us
                  Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text('Contact Us'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        // Functionality: Open contact dialog or navigate
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Contact Us'),
                              content: Text(
                                'For support, email us at support@app.com or call +1-123-456-7890.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Functionality: Show logout confirmation
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await widget.authService.signOut();
                                    // Return to login screen. Replace with routing logic as needed.
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Logged out successfully',
                                        ),
                                      ),
                                    );
                                  },
                                  /*   onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    // Perform logout: clear session, navigate to login
                                    // For demo, just show snackbar and pop to home
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Logged out successfully')),
                                    );
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },*/
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
