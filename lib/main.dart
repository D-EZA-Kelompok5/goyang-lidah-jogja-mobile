import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goyang_lidah_jogja/screens/homepage.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CookieRequest>(
          create: (_) => CookieRequest(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) {
            print("Creating UserProvider..."); // Tambahkan ini
            return UserProvider(context.read<CookieRequest>());
          },
        ),
      ],
      child: MaterialApp(
        title: 'GoyangLidahJogja',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
          ).copyWith(secondary: const Color(0xFF76C7C0)),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            print("Building MyHomePage..."); // Tambahkan ini
            return const MyHomePage();
          },
        ),
      ),
    );
  }
}