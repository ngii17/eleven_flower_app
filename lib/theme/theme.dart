import 'package:flutter/material.dart';

class AppTheme {
  // --- PALET WARNA ---
  
  // Warna background sesuai screenshot Figma (Dusty Pink / Old Rose)
  static const Color dustyPink = Color(0xFFC48B8B); 
  
  // Warna pelengkap
  static const Color primaryGreen = Color(0xFF4CAF50); // Hijau daun
  static const Color blackColor = Color(0xFF1A1A1A);   // Hitam tidak pekat (lebih soft)
  static const Color whiteColor = Colors.white;
  static const Color borderColor = Color(0xFFEEEEEE);
  static const Color hintColor = Color(0xFF999999);
  
  // --- FONT ---
  static const String fontFamily = 'Poppins'; // Font utama (Body)
  // Font alternatif untuk judul agar terlihat klasik seperti di Figma
  static const String serifFont = 'Times New Roman'; 
  
  // --- KONFIGURASI TEMA ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Gunakan Material 3 untuk efek visual lebih modern
    
    // Warna Utama Aplikasi
    primaryColor: dustyPink,
    scaffoldBackgroundColor: whiteColor, // Default halaman dalam tetap putih
    fontFamily: fontFamily,
    
    // Skema Warna Global
    colorScheme: ColorScheme.light(
      primary: dustyPink,
      secondary: primaryGreen,
      surface: whiteColor,
      onPrimary: whiteColor, // Warna teks di atas warna primary
    ),
    
    // Style Header/AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: blackColor),
      titleTextStyle: TextStyle(
        color: blackColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
    ),
    
    // Style Input Form (TextFormField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: whiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      // Border saat tidak diklik
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(12), // Sudut lebih membulat
      ),
      // Border saat diklik (Fokus)
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: dustyPink, width: 2), // Warna pink saat ngetik
        borderRadius: BorderRadius.circular(12),
      ),
      // Border saat error
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: const TextStyle(color: hintColor),
    ),

    // Style Tombol (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: dustyPink,
        foregroundColor: whiteColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}