import 'package:shared_preferences/shared_preferences.dart'; 

class SetupBackend {
 
  Map<String, dynamic> userData = {
    "gender":"" ,
    "ageRange":"18-24",
    "income": "",
    "mainGoal": "",
    "sleepHours": "",
    "stressLevel": "",
    "studyTime": "",
    "notifications": "Enabled",
    "language": "English",
    "aiTips": "Yes, please!",
  };

  
  void updateData(String key, dynamic value) {
    userData[key] = value;
  }

 
  Future<bool> saveFinalData() async {
    try {
      print("Saving to Database: $userData");
      
    
      await Future.delayed(const Duration(seconds: 2));
      
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
