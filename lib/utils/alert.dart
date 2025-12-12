// lib/utils/alert.dart
import 'package:flutter/material.dart';
import '../globals.dart';

class Alert {
  static void show(String message, {bool isError = true}) {
    snackbarKey.currentState?.hideCurrentSnackBar();
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void loading() {
    snackbarKey.currentState?.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text("Sedang memproses..."),
          ],
        ),
        backgroundColor: Colors.pink,
        duration: Duration(minutes: 5), // panjang biar ga ilang
      ),
    );
  }

  static void hide() {
    snackbarKey.currentState?.hideCurrentSnackBar();
  }
}