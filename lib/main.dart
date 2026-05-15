import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dashboard_page.dart';

// ඔයාගේ Files (File Names නිවැරදිදැයි බලන්න)
import 'splash_screen.dart';
import 'login_frontend.dart';
import 'signup_frontend.dart';
import 'forgotpassword_frontend.dart';
import 'setup_wizard.dart';
import 'focus_page.dart'; 
import 'settings_page.dart'; 

 

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    print("firebase connected successfully");
    runApp(const AiUnimindApp(isSetupComplete: false));
 
  final prefs = await SharedPreferences.getInstance();
  final bool isSetupComplete = prefs.getBool('isSetupComplete') ?? false;

 
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: AiUnimindApp(isSetupComplete: isSetupComplete),
    ),
  );
}

class AiUnimindApp extends StatelessWidget {
  final bool isSetupComplete;

  const AiUnimindApp({super.key, required this.isSetupComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Unimind',
      
     
      home: isSetupComplete ? const FocusPage() : const SplashScreen(), 

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/setup': (context) => const SetupWizard(),
        '/focus': (context) => const FocusPage(),
        '/settings': (context) => const SettingsPage(),
       
      },
    );
  }
}
