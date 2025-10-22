import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For system navigator if needed for logout

// Placeholder ProfileScreen: Simple screen for Profile tab (expand with user settings)
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sample user data
  final String userName = 'Ethan Carter';
  final String userEmail = 'ethan.carter@email.com';

  // State for dark mode toggle
  bool isDarkModeEnabled = false;

  // State for language selection
  String selectedLanguage = 'English';

  // Languages list for dropdown
  final List<String> languages = ['English', 'Tamil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom AppBar to mimic the screenshot (no standard AppBar to allow full control)
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top, // Include status bar
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    // Functionality: Go back
                    Navigator.pop(context);
                  },
                ),
                // Title
                Expanded(
                  child: Center(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Empty space on right (no trailing icon in screenshot)
                SizedBox(width: 16),
              ],
            ),
          ),
          // Profile Content
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
                          child: ClipOval(
                            child: Image.asset(
                              'assets/profile_placeholder.png', // Replace with actual asset path
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback if image not found: use icon
                                return Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.blue[900],
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // User Name
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        // User Email
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
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
                  // Dark Mode Toggle
                  Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text('Dark Mode'),
                      trailing: Switch(
                        value: isDarkModeEnabled,
                        onChanged: (value) {
                          // Functionality: Toggle dark mode
                          setState(() {
                            isDarkModeEnabled = value;
                          });
                          // In a real app, this would switch the app's theme
                          // e.g., using Provider or SharedPreferences to persist
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value ? 'Dark mode enabled' : 'Light mode enabled'),
                            ),
                          );
                        },
                        activeColor: Colors.blue,
                        activeTrackColor: Colors.blue[50],
                        inactiveThumbColor: Colors.grey[350],
                        inactiveTrackColor: Colors.grey,
                      ),
                      onTap: () {
                        // Tap to toggle as well
                        setState(() {
                          isDarkModeEnabled = !isDarkModeEnabled;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  // Language Dropdown
                  Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text('Language'),
                      trailing: DropdownButton<String>(
                        value: selectedLanguage,
                        underline: SizedBox(), // Remove default underline
                        onChanged: (String? newValue) {
                          // Functionality: Change language
                          setState(() {
                            selectedLanguage = newValue!;
                          });
                          // In a real app, this would update localization
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Language changed to $newValue'),
                            ),
                          );
                        },
                        items: languages.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      onTap: () {
                        // Tap to open dropdown
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select Language'),
                              content: DropdownButton<String>(
                                value: selectedLanguage,
                                items: languages.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedLanguage = newValue!;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
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
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        // Functionality: Open contact dialog or navigate
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Contact Us'),
                              content: Text('For support, email us at support@app.com or call +1-123-456-7890.'),
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
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    // Perform logout: clear session, navigate to login
                                    // For demo, just show snackbar and pop to home
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Logged out successfully')),
                                    );
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: Text('Logout', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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