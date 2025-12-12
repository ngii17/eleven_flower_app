import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';        // tambah ini kalau belum ada
import 'theme/theme.dart';
import 'globals.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

// Tambahkan RouteObserver supaya CartScreen otomatis refresh setiap dibuka
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eleven Flower',
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: snackbarKey,

      // INI YANG PALING PENTING — SUPAYA CART SELALU REFRESH OTOMATIS!
      navigatorObservers: [routeObserver],

      // Kalau user belum login → WelcomeScreen
      // Kalau sudah login → langsung ke MainScreen (tab Home)
      home: WelcomeScreen(),
      
      // Kalau kamu pakai routes, tambahin ini juga:
      // routes: {
      //   '/main': (context) => MainScreen(key: MainScreen.navigatorKey),
      // },
    );
  }
}