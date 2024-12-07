import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goyang_lidah_jogja/screens/register.dart';
import 'package:goyang_lidah_jogja/screens/menu.dart';

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.fastfood, size: 30), // Logo size adjusted for mobile
                SizedBox(width: 10),
                Text('GoyangLidahJogja', style: TextStyle(fontSize: 20)),
              ],
            ),
            Icon(Icons.search), // Search icon
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2.0, // Light shadow for mobile look
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Nama Pengguna', style: TextStyle(fontSize: 18)),
              accountEmail: Text('email@domain.com', style: TextStyle(fontSize: 14)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.green[700]),
              ),
            ),
            ListTile(
              leading: Icon(Icons.login, color: Colors.green[700]),
              title: Text('Login', style: TextStyle(color: Colors.green[700])),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green[700]),
              title: Text('Settings', style: TextStyle(color: Colors.green[700])),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.green[700]),
              title: Text('Help', style: TextStyle(color: Colors.green[700])),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section: "Mau makan apa?"
              Center(
                child: Text(
                  'Mau makan apa?', 
                  style: TextStyle(
                    fontSize: 24,  // Slightly smaller for mobile
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
                height: MediaQuery.of(context).size.height * 0.6, // Limit the height
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,  // Adjust the number of columns for mobile view
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
                              image: DecorationImage(
                                image: AssetImage('assets/images/menu_placeholder.png'), // Placeholder image
                                fit: BoxFit.cover,
                              ),
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
