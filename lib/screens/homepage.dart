// lib/screens/homepage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goyang_lidah_jogja/screens/menu_detail.dart'; // Import MenuDetail page
import 'package:goyang_lidah_jogja/widgets/left_drawer.dart'; // Import LeftDrawer
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart'; // Import fetchMenus() dan model Menu
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goyang_lidah_jogja/models/menu.dart';

class MyHomePage extends StatefulWidget {
  final UserProfile? userProfile;

  const MyHomePage({super.key, this.userProfile});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchController = TextEditingController();

  UserProfile? userProfile;
  bool isLoading = true;

  List<MenuElement> menus = []; // Menyimpan data menu dari API
  bool isLoadingMenus = true; // Status loading untuk menu

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
    _fetchMenus(); // Fetch data menu dari API saat init
  }

  Future<void> _initializeUserProfile() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    if (request.loggedIn) {
      AuthService authService = AuthService(request);
      UserProfile? profile = await authService.getUserProfile();
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    } else {
      setState(() {
        userProfile = null;
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMenus() async {
    try {
      List<MenuElement> fetchedMenus =
          await fetchMenus(); // Ambil data dari API
      setState(() {
        menus = fetchedMenus;
        isLoadingMenus = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMenus = false;
      });
      print('Error fetching menus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Tampilkan indikator loading saat mengambil profil
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.fastfood,
                    size: 30, color: Colors.deepPurple), // Warna ditambahkan
                SizedBox(width: 10),
                Text('GoyangLidahJogja',
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
              ],
            ),
            Icon(Icons.search,
                color: Colors.deepPurple), // Ikon search dengan warna
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2.0, // Bayangan ringan untuk tampilan mobile
      ),
      drawer: LeftDrawer(
          userProfile: userProfile), // Pass UserProfile ke LeftDrawer
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section (Hanya tampilkan jika userProfile tidak null)
            if (userProfile != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    userProfile!.profilePicture != null
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(userProfile!.profilePicture!),
                          )
                        : const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person, size: 30),
                          ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile!.username,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userProfile!.roleDisplay, // Menggunakan getter
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (userProfile != null) SizedBox(height: 20),

            // Header Section: "Mau makan apa?"
            Center(
              child: Text(
                'Mau makan apa?',
                style: TextStyle(
                  fontSize: 24, // Sedikit lebih kecil untuk tampilan mobile
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari menu...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),
            ),

            // Main Section: Grid of Menu (Menu Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                physics:
                    NeverScrollableScrollPhysics(), // Nonaktifkan scroll pada GridView
                shrinkWrap: true, // Membatasi ukuran GridView
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2, // Responsiveness
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: MediaQuery.of(context).size.width > 600
                      ? 0.8
                      : 0.75, // Responsiveness
                ),
                itemCount: isLoadingMenus ? 6 : menus.length,
                itemBuilder: (context, index) {
                  if (isLoadingMenus) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 120,
                            color: Colors.grey[200],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Loading...',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final menu = menus[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuDetailPage(menu: menu),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              menu.image ?? '',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              menu.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Rp ${menu.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
