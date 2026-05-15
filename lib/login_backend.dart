import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginBackend {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithEmail(String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields", context);
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      _showError("Login Successful!", context);
      _showError("Login Successful!", context);

    
      Navigator.pushReplacementNamed(context, '/setup');
      
      
    
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed", context);
    }
  }

  void _showError(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
 }
 
