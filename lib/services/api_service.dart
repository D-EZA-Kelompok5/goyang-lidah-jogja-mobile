import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu.dart'; // Path ke file model

Future<List<Menu>> fetchMenus() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/menus/'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Menu.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load menus');
  }
}
