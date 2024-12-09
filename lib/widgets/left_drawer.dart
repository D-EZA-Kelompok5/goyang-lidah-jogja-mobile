import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/screens/homepage.dart';
import 'package:goyang_lidah_jogja/screens/restaurant_page.dart';
import '../screens/restaurant_page.dart'; // Adjust the import path based on your project structure

// class LeftDrawer extends StatelessWidget {
//   const LeftDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             child: const Column(
//               children: [
//                 Text(
//                   'Goyang Lidah Jogja',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Padding(padding: EdgeInsets.all(8)),
//                 Text(
//                   "testesttest",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 15.0,
//                     color: Colors.white,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.home_outlined),
//             title: const Text('Main Page'),
//             onTap: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => MyHomePage()),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.restaurant_menu),
//             title: const Text('Restaurants'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => RestaurantPage()),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.mood),
//             title: const Text('Add Product'),
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Add Product button pressed")),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.add_reaction_rounded),
//             title: const Text('Product List'),
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Product List button pressed")),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Container(
              color:
                  const Color(0xFF76B947), // Green color from your screenshot
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Nama Pengguna',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'email@domain.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login, color: Color(0xFF76B947)),
              title: const Text(
                'Login',
                style: TextStyle(color: Color(0xFF76B947)),
              ),
              onTap: () {
                // Add your login navigation here
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.restaurant_menu, color: Color(0xFF76B947)),
              title: const Text(
                'Restaurant',
                style: TextStyle(color: Color(0xFF76B947)),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF76B947)),
              title: const Text(
                'Settings',
                style: TextStyle(color: Color(0xFF76B947)),
              ),
              onTap: () {
                // Add your settings navigation here
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Color(0xFF76B947)),
              title: const Text(
                'Help',
                style: TextStyle(color: Color(0xFF76B947)),
              ),
              onTap: () {
                // Add your help navigation here
              },
            ),
          ],
        ),
      ),
    );
  }
}
