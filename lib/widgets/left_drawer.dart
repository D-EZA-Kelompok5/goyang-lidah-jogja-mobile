import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../screens/event_dashboard.dart';
import '../screens/login.dart';
import '../screens/register.dart';
import '../screens/restaurant_dashboard.dart';
import '../screens/homepage.dart';
import '../screens/edit_profile.dart';
import '../screens/wishlist_list.dart';
import '../screens/myreview_screen.dart';
import 'package:goyang_lidah_jogja/models/user_profile.dart';

class LeftDrawer extends StatefulWidget {
  final VoidCallback onWishlistChanged;
  const LeftDrawer({Key? key, required this.onWishlistChanged}) : super(key: key);

  @override
  _LeftDrawerState createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  late CookieRequest request;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    request = Provider.of<CookieRequest>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserProfile? userProfile = userProvider.userProfile;

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
              userProfile != null ? userProfile.username : 'Guest',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: userProfile != null
                ? Text(userProfile.email)
                : const Text('Please login'),
            currentAccountPicture: userProfile != null
                ? (userProfile.profilePicture != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(userProfile.profilePicture!),
                      )
                    : CircleAvatar(
                        child: Text(
                          userProfile.username[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ))
                : const CircleAvatar(
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
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Main Page button pressed")),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),

          // 2. Role-Based Dashboard Links
          if (userProfile != null) ...[
            // Event Manager Dashboard
            if (userProfile.role == Role.EVENT_MANAGER)
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Manager Dashboard'),
                onTap: () {
                  if (!mounted) return;
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventDashboard()),
                  );
                },
              ),

            // Customer Wishlist
            if (userProfile.role == Role.CUSTOMER)
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Wishlists'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WishlistList(onWishlistChanged: widget.onWishlistChanged)),
                  );
                },
              ),

            // Restaurant Owner Dashboard
            if (userProfile.role == Role.RESTAURANT_OWNER)
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Restaurant Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RestaurantDashboardPage(),
                    ),
                  );
                },
              ),

            // Separator
            const Divider(),

            // 3. Profile Page
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () async {
                if (!mounted) return;
                Navigator.pop(context); // Close drawer

                // Navigate to EditProfileScreen and wait for result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );

                // Refresh profile after returning
                await userProvider.refreshUserProfile();

                // If result is true, show success SnackBar
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully")),
                  );
                }
              },
            ),

            // 4. My Reviews
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('My Reviews'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyReviewsPage()),
                );
              },
            ),

            // 5. Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await userProvider.logout();
                if (!userProvider.isLoading && userProvider.userProfile == null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout successful!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(userProvider.errorMessage ?? 'Logout failed!'),
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
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login button pressed")),
                );
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),

            // Register Button
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Register'),
              onTap: () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Register button pressed")),
                );
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}