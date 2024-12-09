// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goyang_lidah_jogja/screens/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'GoyangLidahJogja',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
          ).copyWith(secondary: const Color(0xFF76C7C0)),
          useMaterial3: true,
        ),
        home: const MyHomePage(), // Homepage diakses oleh semua pengguna, termasuk guest
      ),
    );
  }
}