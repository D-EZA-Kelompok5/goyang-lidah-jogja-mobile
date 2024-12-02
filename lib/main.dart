import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoyangLidahJogja',
      theme: ThemeData(
        primarySwatch: Colors.green, // Tema hijau
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GoyangLidahJogja', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700], // AppBar dengan hijau lebih gelap
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.green[50], // Background Drawer lebih soft hijau
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Nama Pengguna', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                accountEmail: Text('email@domain.com', style: TextStyle(fontSize: 14)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.green[700]),
                ),
              ),
              ListTile(
                leading: Icon(Icons.login, color: Colors.green[700]),
                title: Text('Login', style: TextStyle(color: Colors.green[700])),
                onTap: () {
                  // Aksi untuk login
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.green[700]),
                title: Text('Settings', style: TextStyle(color: Colors.green[700])),
                onTap: () {
                  // Aksi untuk pengaturan
                },
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.green[700]),
                title: Text('Help', style: TextStyle(color: Colors.green[700])),
                onTap: () {
                  // Aksi untuk bantuan
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            // Konten Utama (misal daftar menu)
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Misalnya ada 10 menu
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: ListTile(
                      leading: Icon(Icons.fastfood, color: Colors.green[700]),
                      title: Text('Menu ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Deskripsi Menu ${index + 1}', style: TextStyle(color: Colors.grey.shade600)),
                      onTap: () {
                        // Aksi saat menu dipilih
                      },
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
