import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/screens/homepage.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        // Contoh: Anda bisa mengganti CookieRequest dengan class yang Anda butuhkan
        CookieRequest request = CookieRequest();// Asumsi anda memiliki class CookieRequest
        return request;
      },
      child: MaterialApp(
        title: 'GoyangLidahJogja',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
          ).copyWith(secondary: const Color(0xFF76C7C0)), // Adjusted secondary color
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// Anda harus mengganti 'CookieRequest' dengan class yang relevan yang Anda gunakan
// Jika Anda tidak memiliki class seperti itu, Anda perlu membuat atau mengkonfigurasinya
// sesuai dengan kebutuhan aplikasi Anda.
