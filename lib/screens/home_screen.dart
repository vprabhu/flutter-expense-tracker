import 'package:expense_tracker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// HomeScreen displays user financial summary, recent expense list, and a custom logout flow.
///
/// User data is passed in from login, so every widget can show the actual displayName, email, photoURL, etc.
/// This is fully scalable: replace dummy data with real backend or Firestore later.
///
class HomeScreen extends StatelessWidget {
  final User user; // The authenticated user
  final AuthService authService; // For seamless logout

  const HomeScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  // Sample category data for spending breakdown.
  static const categories = [
    {'name': 'Food', 'color': Color(0xFF247CFF)},
    {'name': 'Transport', 'color': Color(0xFF61AAFF)},
    {'name': 'Entertainment', 'color': Color(0xFF97C9FF)},
    {'name': 'Utilities', 'color': Color(0xFFC6E4FF)}
  ];

  // Sample expense list. Replace with model/backend fetch later.
  static const expenses = [
    {'title': 'Fresh Foods Market', 'subtitle': 'Grocery', 'amount': -75, 'icon': Icons.shopping_bag},
    {'title': 'Gas Station', 'subtitle': 'Gas', 'amount': -45, 'icon': Icons.local_gas_station},
    {'title': 'Cinema', 'subtitle': 'Movie', 'amount': -20, 'icon': Icons.tv},
    {'title': 'Utility Company', 'subtitle': 'Electricity', 'amount': -150, 'icon': Icons.flash_on},
    {'title': 'Fashion Store', 'subtitle': 'Clothing', 'amount': -100, 'icon': Icons.shopping_cart},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Displays user's name & photo
        title: Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          CircleAvatar(
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? Icon(Icons.person) : null,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: () async {
              await authService.signOut();
              // Return to login screen. Replace with routing logic as needed.
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spending Breakdown with a chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Spending Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Row(
                children: [
                  // Dummy chart (replace with real chart widget for full effect)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.8, // percentage spent, fake
                          strokeWidth: 10,
                          valueColor: AlwaysStoppedAnimation(categories[0]['color'] as Color),
                          backgroundColor: categories[2]['color'] as Color,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Total Spent", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("\$1,250", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categories.map((c) => Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: c['color'] as Color, shape: BoxShape.circle),
                            ),
                            SizedBox(width: 8),
                            Text(c['name'] as String),
                          ],
                        )).toList(),
                      )
                  )
                ],
              ),
            ),
          ),

          // Recent Expenses List
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 0, 10),
            child: Text('Recent Expenses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: expenses.length,
              itemBuilder: (_, i) {
                final e = expenses[i];
                return Card(
                  margin: EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 21,
                      backgroundColor: Colors.blue[50],
                      child: Icon(e['icon'] as IconData, color: Colors.blue[700]),
                    ),
                    title: Text(e['title'] as String,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(e['subtitle'] as String,
                        style: TextStyle(color: Colors.blueGrey)),
                    trailing: Text(
                      "\$${e['amount']}.00",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation Bar (fake, for showcase. Replace with real PageView/BottomNavBar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(icon: Icons.home, label: "Home", selected: true),
                _BottomNavItem(icon: Icons.bar_chart, label: "Summary"),
                _BottomNavItem(icon: Icons.person, label: "Profile"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Simple widget for bottom navigation bar icon, not interactive, but beautiful for mockups.
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _BottomNavItem({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: selected ? Colors.blue[700] : Colors.blueGrey[400]),
        SizedBox(height: 5),
        Text(label,
            style: TextStyle(
              color: selected ? Colors.blue[700] : Colors.blueGrey[400],
              fontWeight: selected ? FontWeight.bold : FontWeight.w400,
              fontSize: 15,
            )
        ),
      ],
    );
  }
}
