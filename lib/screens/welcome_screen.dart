import 'package:flutter/material.dart';
import 'login_screen.dart'; 
import '../theme/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.dustyPink, 
      
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, 
        onTap: () {
          // --- BAGIAN INI YANG DIGANTI AGAR ADA ANIMASI ---
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800), // Durasi 0.8 detik (bisa diatur)
              pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Efek FADE (Muncul perlahan)
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
                
                /* 
                 OPSIONAL: Kalau mau efek SLIDE (Geser dari bawah),
                 Ganti return FadeTransition(...) di atas dengan kode ini:
                 
                 const begin = Offset(0.0, 1.0);
                 const end = Offset.zero;
                 const curve = Curves.ease;
                 var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                 return SlideTransition(
                   position: animation.drive(tween),
                   child: child,
                 );
                */
              },
            ),
          );
          // -----------------------------------------------
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. GAMBAR LOGO 
              Image.asset(
                'assets/images/logo_eleven.png', 
                width: size.width * 0.85, // Lebar gambar 85% dari layar
                fit: BoxFit.contain,
              ),
              
              const SizedBox(height: 60), 

              // 2. TULISAN WELCOME
              const Text(
                'WELCOME',
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: 2.0,
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}