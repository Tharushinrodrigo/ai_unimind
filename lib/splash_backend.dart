import 'package:flutter/material.dart';

class SplashBackend {
  
  void navigateToNext(BuildContext context) {
   
    Navigator.pushReplacementNamed(context, '/login');
  }
}
