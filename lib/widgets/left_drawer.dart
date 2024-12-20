import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/user_profile.dart';
import 'package:goyang_lidah_jogja/screens/event_dashboard.dart';
import 'package:goyang_lidah_jogja/screens/login.dart';
import 'package:goyang_lidah_jogja/screens/register.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goyang_lidah_jogja/screens/homepage.dart';
import 'package:goyang_lidah_jogja/screens/edit_profile.dart';
import 'package:goyang_lidah_jogja/services/user_service.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  _LeftDrawerState createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  UserProfile? userProfile;
  late CookieRequest request;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    request = Provider.of<CookieRequest>(context, listen: false);
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    if (!mounted) return;
    
    try {
      UserProfile profile = await UserService(request).fetchUserProfile();
      if (mounted) {
        setState(() {
          userProfile = profile;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userProfile = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer Header dengan gambar profil yang diperbarui
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
            if (userProfile!.role == Role.EVENT_MANAGER)
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Manager Dashboard'),
                onTap: () {
                  if (!mounted) return;
                  Navigator.pop(context); // Tutup drawer
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
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Wishlist button pressed")),
                  );
                  Navigator.pop(context); // Tutup drawer
                },
              ),

            // Restaurant Owner Dashboard
            if (userProfile!.role == Role.RESTAURANT_OWNER)
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Restaurant Dashboard'),
                onTap: () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Restaurant Dashboard button pressed")),
                  );
                  Navigator.pop(context); // Tutup drawer
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
                Navigator.pop(context); // Tutup drawer

                // Navigasi ke EditProfileScreen dan tunggu hasilnya
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );

                // Refresh profil setelah kembali
                fetchUserProfile();

                // Jika hasilnya true, tampilkan SnackBar sukses
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profil berhasil diperbarui")),
                  );
                }
              },
            ),

            // 4. My Reviews
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('My Reviews'),
              onTap: () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("My Reviews button pressed")),
                );
                Navigator.pop(context); // Tutup drawer
              },
            ),

            // 5. Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final response = await request.logout(
                    "http://127.0.0.1:8000/auth/logout/");
                if (!mounted) return;
                
                if (response['status'] == true ||
                    response['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout berhasil!'),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
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
            // Jika pengguna belum autentikasi, tampilkan Login
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login button pressed")),
                );
                Navigator.pop(context); // Tutup drawer
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
                Navigator.pop(context); // Tutup drawer
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