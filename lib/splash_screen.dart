import 'package:flutter/material.dart';
import 'splash_backend.dart'; // Backend එක import කරමු

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Figma එකේ තියෙන Gradient එක
          gradient: LinearGradient(
            colors: [Color(0xFFB8C6E3), Color(0xFFE5B2CA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo එක (දැනට Icon එකක්, ඔයාට ඕනේ නම් Image එකක් දාන්න පුළුවන්)
            const Icon(Icons.psychology, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "UniMind AI",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              "Balance Study • Mind • Life",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 60),
            
            // Get Started Button
            GestureDetector(
              onTap: () => SplashBackend().navigateToNext(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}