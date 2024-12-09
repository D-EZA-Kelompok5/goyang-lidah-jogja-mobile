// lib/widgets/left_drawer.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/user_profile.dart';
import 'package:goyang_lidah_jogja/screens/event_dashboard.dart'; // Import the EventDashboard screen
import 'package:goyang_lidah_jogja/screens/login.dart'; // Import Login Page
import 'package:goyang_lidah_jogja/screens/register.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goyang_lidah_jogja/screens/homepage.dart';

class LeftDrawer extends StatelessWidget {
  final UserProfile? userProfile;

  const LeftDrawer({super.key, this.userProfile});

  @override
  Widget build(BuildContext context) {
    final request = Provider.of<CookieRequest>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              userProfile != null ? userProfile!.username : 'Guest',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: userProfile != null
                ? Text(userProfile!.email)
                : Text('Please login'),
            currentAccountPicture: userProfile != null
                ? (userProfile!.profilePicture != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(userProfile!.profilePicture!),
                      )
                    : CircleAvatar(
                        child: Text(
                          userProfile!.username[0].toUpperCase(),
                          style: TextStyle(fontSize: 24),
                        ),
                      ))
                : CircleAvatar(
                    child: Icon(
                      Icons.person,
                      size: 30,
                    ),
                  ),
          ),

          // Menu Items
          // 1. Home Page
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Main Page'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Main Page button pressed")),
              );
            },
          ),

          // 2. Role-Based Dashboard Links
          if (userProfile != null) ...[
            // Event Manager Dashboard
            if (userProfile!.role == Role.EVENT_MANAGER)
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Manager Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventDashboard()),
                  );
                },
              ),

            // Customer Wishlist
            if (userProfile!.role == Role.CUSTOMER)
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Wishlists'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Wishlist button pressed")),
                  );
                },
              ),

            // Restaurant Owner Dashboard
            if (userProfile!.role == Role.RESTAURANT_OWNER)
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Restaurant Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Restaurant Dashboard button pressed")),
                  );
                },
              ),

            // Separator
            Divider(),

            // 3. Profile Page
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile button pressed")),
                );
              },
            ),

            // 4. My Reviews
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('My Reviews'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("My Reviews button pressed")),
                );
              },
            ),

            // 5. Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final response = await request.logout(
                    "http://10.0.2.2:8000/auth/logout/");
                if (response['status'] == true || response['status'] == 'success') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout berhasil!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'] ?? 'Logout gagal!'),
                    ),
                  );
                }
              },
            ),
          ] else ...[
            // If user is not authenticated, show Login
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login button pressed")),
                );
              },
            ),

            // Register Button (Optional)
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Register'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Register button pressed")),
                );
              },
            ),
          ],

          
        ],
      ),
    );
  }
}
