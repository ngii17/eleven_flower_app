import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';  // Placeholder

void main() {
  runApp(  // HAPUS 'const' INI UNTUK FIX ERROR
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // TAMBAH KEY PARAMETER

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eleven Flower',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return auth.isLoggedIn ? HomeScreen() : LoginScreen();
        },
      ),
    );
  }
}