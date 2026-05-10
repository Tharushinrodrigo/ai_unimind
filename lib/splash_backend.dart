import 'package:flutter/material.dart';

class SplashBackend {
  // බටන් එක එබුවම Login පේජ් එකට යවන function එක
  void navigateToNext(BuildContext context) {
    // '/login' කියන route එකට යවනවා
    Navigator.pushReplacementNamed(context, '/login');
  }
}