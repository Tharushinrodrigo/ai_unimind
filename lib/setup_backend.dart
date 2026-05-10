import 'package:shared_preferences/shared_preferences.dart'; // මේක අනිවාර්යයෙන්ම උඩින් දාන්න

class SetupBackend {
  // User තෝරන data තාවකාලිකව තියාගන්න map එක
  Map<String, dynamic> userData = {
    "gender":"" ,
    "ageRange":"18-24", // Default එකක් දාන්න dropdown එකට ලේසි වෙන්න
    "income": "",
    "mainGoal": "",
    "sleepHours": "",
    "stressLevel": "",
    "studyTime": "",
    "notifications": "Enabled",
    "language": "English",
    "aiTips": "Yes, please!",
  };

  // Data update කරන function එක
  void updateData(String key, dynamic value) {
    userData[key] = value;
  }

  // Database එකට සහ Local මතකයට data යවන function එක
  Future<bool> saveFinalData() async {
    try {
      print("Saving to Database: $userData");
      
      // 1. මෙතන තමයි ඔයාගේ Firebase/Backend සේව් කරන ලොජික් එක තියෙන්නේ
      await Future.delayed(const Duration(seconds: 2)); // Simulate saving time

      // 2. Setup එක සාර්ථකව ඉවරයි කියලා Local storage එකේ සේව් කරනවා
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSetupComplete', true); 

      print("Flag 'SETUP STATUS SAVED : true.");
      return true;
    } catch (e) {
      print("Error saving data: $e");
      return false;
    }
  }
}