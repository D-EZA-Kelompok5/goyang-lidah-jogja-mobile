import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu.dart'; // Path ke file model

const baseUrl = 'http://10.0.2.2:8000/';

// Future<List<Menu>> fetchMenus() async {
//   final response = await http.get(Uri.parse('https://127.0.0.1:8000/api/menus/'));

//   if (response.statusCode == 200) {
//     List<dynamic> data = jsonDecode(response.body);
//     return data.map((json) => Menu.fromJson(json)).toList();
//   } else {
//     throw Exception('Failed to load menus');
//   }
// }

Future<List<MenuElement>> fetchMenus() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/menus/'),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Menu menuData = Menu.fromJson(jsonResponse);
      print(menuData);
      return menuData.menus;
    } else {
      throw Exception('Failed to load menus: ${response.statusCode}');
    }
  } catch (e) {
    print('Error details: $e');
    throw Exception('Failed to fetch menus: $e');
  }
}
