import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu.dart'; // Path ke file model

const baseUrl = 'https://vissuta-gunawan-goyanglidahjogja.pbp.cs.ui.ac.id';

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
    print('Fetching menus from: $baseUrl/api/menus/'); // Debug URL

    final response = await http.get(
      Uri.parse('$baseUrl/api/menus/'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json", // Add Accept header
      },
    );

    print('Response status: ${response.statusCode}'); // Debug status code
    print('Response body: ${response.body}'); // Debug response body

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Menu menuData = Menu.fromJson(jsonResponse);
      return menuData.menus;
    } else {
      throw Exception('Server error: ${response.statusCode}\nBody: ${response.body}');
    }
  } catch (e) {
    if (e is FormatException) {
      print('JSON Parse Error: $e'); // Debug parsing errors
    }
    throw Exception('Network error: $e');
  }
}
