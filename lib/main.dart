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

// AIChatbotPage එක import වී නොමැති නම් එය මෙහි ඇතුළත් කරන්න
// import 'ai_chatbot.dart'; 

void main() async {
  // 1. Flutter engine එක සහ SharedPreferences ලෑස්ති කිරීම
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase Initialize කිරීම
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    print("firebase connected successfully");
    runApp(const AiUnimindApp(isSetupComplete: false)); // Firebase සාර්ථකව සම්බන්ධ වූ පසු ඇප් එක පටන් ගන්න

  // 3. Shared Preferences වලින් status එක බලනවා
  final prefs = await SharedPreferences.getInstance();
  final bool isSetupComplete = prefs.getBool('isSetupComplete') ?? false;

  // 4. ඇප් එක පටන් ගන්න කොටම status එක යවනවා
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
      
      // logic එක: Setup එක ඉවර නම් FocusPage එකට, නැත්නම් SplashScreen හෝ SetupWizard එකට.
      // සාමාන්‍යයෙන් මුලින්ම පෙන්වන්නේ SplashScreen එකයි.
      home: isSetupComplete ? const FocusPage() : const SplashScreen(), 

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/setup': (context) => const SetupWizard(),
        '/focus': (context) => const FocusPage(),
        '/settings': (context) => const SettingsPage(),
        // AIChatbotPage එක ඔබේ file එකක තිබිය යුතුයි
        // '/ai_chatbot': (context) => const AIChatbotPage(),
      },
    );
  }
}