// lib/screens/homepage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goyang_lidah_jogja/screens/menu.dart';
import 'package:goyang_lidah_jogja/widgets/left_drawer.dart'; // Import LeftDrawer
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
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
                Icon(Icons.fastfood, size: 30, color: Colors.deepPurple), // Warna ditambahkan
                SizedBox(width: 10),
                Text('GoyangLidahJogja', style: TextStyle(fontSize: 20, color: Colors.deepPurple)),
              ],
            ),
            Icon(Icons.search, color: Colors.deepPurple), // Ikon search dengan warna
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2.0, // Bayangan ringan untuk tampilan mobile
      ),
      drawer: LeftDrawer(userProfile: userProfile), // Pass UserProfile ke LeftDrawer
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Section (Hanya tampilkan jika userProfile tidak null)
              if (userProfile != null)
                Row(
                  children: [
                    userProfile!.profilePicture != null
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(userProfile!.profilePicture!),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userProfile!.roleDisplay, // Menggunakan getter
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              if (userProfile != null)
                SizedBox(height: 20),
              
              // Header Section: "Mau makan apa?"
              Center(
                child: Text(
                  'Mau makan apa?', 
                  style: TextStyle(
                    fontSize: 24,  // Sedikit lebih kecil untuk tampilan mobile
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Search Bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ),
              
              // Main Section: Grid of Menu (Menu Grid)
              Container(
                height: MediaQuery.of(context).size.height * 0.6, // Batasi tinggi
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(), // Nonaktifkan scroll pada GridView
                  shrinkWrap: true, // Membatasi ukuran GridView
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,  // Sesuaikan jumlah kolom untuk tampilan mobile
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                              // image: DecorationImage(
                              //   image: AssetImage('assets/images/menu_placeholder.png'), // Placeholder image
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Menu ${index + 1}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            'Deskripsi Menu ${index + 1}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}