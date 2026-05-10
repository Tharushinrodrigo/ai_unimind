import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordBackend {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(String email, BuildContext context) async {
    if (email.isEmpty) {
      _showMessage("Please enter your email", context);
      return;
    }

    try {
      // Firebase එකෙන් Reset link එක Email එකට යවනවා
      await _auth.sendPasswordResetEmail(email: email.trim());
      
      _showMessage("Password reset link sent! Check your email.", context);
      
      // තත්පර 2කට පස්සේ ආපහු Login පේජ් එකට යනවා
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
      
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "An error occurred", context);
    }
  }

  void _showMessage(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }
}