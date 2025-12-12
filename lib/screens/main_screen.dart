import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'category_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart'; // Pastikan file ini ada, jika tidak bisa dihapus baris ini

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static final GlobalKey<MainScreenState> navigatorKey = GlobalKey<MainScreenState>();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // 1. Kunci Rahasia untuk me-refresh halaman Cart
  Key _cartScreenKey = UniqueKey();

  void _onItemTapped(int index) {
    setState(() {
      // 2. LOGIKA REFRESH:
      // Jika yang ditekan adalah index 3 (Keranjang), kita ganti kuncinya.
      // Ini memaksa Flutter membuang halaman lama dan memuat ulang data baru.
      if (index == 3) {
        _cartScreenKey = UniqueKey();
      }
      
      _selectedIndex = index;
    });
  }

  // Fungsi untuk pindah tab dari halaman lain (misal dari Catalog)
  void goToTab(int index) {
    _onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    // 3. Daftar Halaman ditaruh di dalam build agar bisa membaca Key yang berubah
    final List<Widget> pages = [
      const CatalogScreen(),
      const CategoryScreen(),
      const OrderHistoryScreen(), // Ganti dengan Center(child: Text("Order")) jika file tidak ada
      CartScreen(key: _cartScreenKey), // <--- Pasang Kunci Dinamis di sini
      const ProfileScreen(),
    ];

    return Scaffold(
      key: MainScreen.navigatorKey, // Penting agar navigasi berfungsi
      
      // Menggunakan IndexedStack agar halaman lain tidak ikut ter-reset (hanya Cart yang kita reset manual)
      body: IndexedStack(
        index: _selectedIndex, 
        children: pages
      ),
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white, 
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF09AB8),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), activeIcon: Icon(Icons.grid_view_rounded), label: 'Category'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}