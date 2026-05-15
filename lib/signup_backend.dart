import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpBackend {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerUser(String name, String email, String password, String confirmPassword, BuildContext context) async {
    // Validate all fields first
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill all fields", context);
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match!", context);
      return;
    }

    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters", context);
      return;
    }

    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
    if (!emailRegex.hasMatch(email)) {
      _showMessage("Please enter a valid email address", context);
      return;
    }

    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Update display name for profile
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
      }

      if (context.mounted) {
        _showMessage("Registration Successful!", context);
        Navigator.pushReplacementNamed(context, '/setup');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'The password is too weak (minimum 6 characters).';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }

      if (context.mounted) {
        _showMessage(message, context);
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage("System Error: ${e.toString()}", context);
      }
    }
  }

  void _showMessage(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
