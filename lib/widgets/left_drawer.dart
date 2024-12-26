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
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class LeftDrawer extends StatefulWidget {
  final VoidCallback onWishlistChanged;
  const LeftDrawer({Key? key, required this.onWishlistChanged}) : super(key: key);

  @override
  _LeftDrawerState createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  late CookieRequest request;
  UserProfile? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
  }

  Future<void> _initializeUserProfile() async {
    request = Provider.of<CookieRequest>(context, listen: false);
    
    if (request.loggedIn) {
      AuthService authService = AuthService(request);
      UserProfile? profile = await authService.getUserProfile();
      
      if (mounted) {
        setState(() {
          userProfile = profile;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          userProfile = null;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Drawer(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              userProfile != null ? userProfile!.username : 'Guest',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: userProfile != null
                ? Text(userProfile!.email)
                : const Text('Please login'),
            currentAccountPicture: userProfile != null
                ? (userProfile!.profilePicture != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(userProfile!.profilePicture!),
                      )
                    : CircleAvatar(
                        child: Text(
                          userProfile!.username[0].toUpperCase(),
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

          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Main Page'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),

          if (userProfile != null) ...[
            if (userProfile!.role == Role.EVENT_MANAGER)
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Manager Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventDashboard()),
                  );
                },
              ),

            if (userProfile!.role == Role.CUSTOMER)
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Wishlists'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WishlistList(
                            onWishlistChanged: widget.onWishlistChanged)),
                  );
                },
              ),

            if (userProfile!.role == Role.RESTAURANT_OWNER)
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Restaurant Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RestaurantDashboardPage(),
                    ),
                  );
                },
              ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () async {
                Navigator.pop(context);
                
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );

                if (result == true) {
                  await _initializeUserProfile();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated successfully")),
                    );
                  }
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('My Reviews'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyReviewsPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.logout();
                
                if (!userProvider.isLoading && userProvider.userProfile == null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout successful!')),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(userProvider.errorMessage ?? 'Logout failed!'),
                      ),
                    );
                  }
                }
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Register'),
              onTap: () {
                Navigator.pop(context);
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