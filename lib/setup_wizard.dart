import 'package:flutter/material.dart';



import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'setup_backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(const MaterialApp(home: SetupWizard(), debugShowCheckedModeBanner: false));

class SetupWizard extends StatefulWidget {
  const SetupWizard({super.key});

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  final PageController _controller = PageController();
  final SetupBackend _backend = SetupBackend();
  int _currentPage = 0;
  bool _isSaving = false;

  void _onDataChange(String key, dynamic value) {
    setState(() {
      _backend.updateData(key, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB8C6E3), Color(0xFFE5B2CA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 6,
                backgroundColor: Colors.black12,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _pageIntroduction(),
                  _pagePersonalInfo(),
                  _pageLifestyle(),
                  _pageWellness(),
                  _pageSchedule(),
                  _pageAiSetup(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _stressOption(String emoji, String label, String level) {
    bool isSelected = _backend.userData["stressLevel"] == level;
    return GestureDetector(
      onTap: () => _onDataChange("stressLevel", level),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 45, color: isSelected ? null : Colors.black26)),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _pageIntroduction() {
    return _buildBasePage(
      title: "Let’s get to know you!",
      content: Column(
        children: const [
          SizedBox(height: 20),
          Icon(Icons.waving_hand, size: 80, color: Colors.black), 
          SizedBox(height: 20),
          Text(
            "Welcome to UniMind AI. We'll help you balance your University life and Mental health.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _pagePersonalInfo() {
    return _buildBasePage(
      title: "Personal Info",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gender -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _radioOption("Male", "gender"),
          _radioOption("Female", "gender"),
          const SizedBox(height: 20),
          const Text("Age Range -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _buildDropdown(),
        ],
      ),
    );
  }

  Widget _pageLifestyle() {
    return _buildBasePage(
      title: "Lifestyle & Income",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Income (RS) -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          TextField(
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(filled: true, fillColor: Colors.white70, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            onChanged: (val) => _onDataChange("income", val),
          ),
          const SizedBox(height: 20),
          const Text("Main Goal -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _radioOption("Study Focus", "mainGoal"),
          _radioOption("Mental Wellness", "mainGoal"),
          _radioOption("Job Balance", "mainGoal"),
        ],
      ),
    );
  }

  Widget _pageWellness() {
    return _buildBasePage(
      title: "Wellness & Sleep",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Average Sleep Hours -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _radioOption("6-8 hrs", "sleepHours"),
          _radioOption("Less than 6 hrs", "sleepHours"),
          const SizedBox(height: 30),
          const Text("Stress Level -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stressOption("😊", "Low", "low"),
              _stressOption("😐", "Medium", "medium"),
              _stressOption("😫", "High", "high"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageSchedule() {
    return _buildBasePage(
      title: "Schedule",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Study Time -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _radioOption("Morning", "studyTime"),
          _radioOption("Night", "studyTime"),
          const SizedBox(height: 20),
          const Text("Notifications -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _radioOption("Enabled", "notifications"),
          _radioOption("Disabled", "notifications"),
        ],
      ),
    );
  }

  Widget _pageAiSetup() {
    return _buildBasePage(
      title: "Final Step",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Language -", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _radioOption("English", "language"),
          _radioOption("Sinhala", "language"),
          const SizedBox(height: 20),
          const Text("Enable AI Daily Tips?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          _radioOption("Yes, please!", "aiTips"),
          _radioOption("No, thanks", "aiTips"),
        ],
      ),
    );
  }

  Widget _buildBasePage({required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/images/logo.png', height: 60, errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, size: 50, color: Colors.black)),
            const SizedBox(height: 10),
            Text("UniMind AI", style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.5))),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 30),
            content,
          ],
        ),
      ),
    );
  }

  Widget _radioOption(String label, String key) {
    return Theme(
      data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.black),
      child: RadioListTile(
        title: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        value: label,
        groupValue: _backend.userData[key],
        activeColor: Colors.black,
        onChanged: (val) => _onDataChange(key, val),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<String>(
        dropdownColor: Colors.white,
        isExpanded: true,
        underline: const SizedBox(),
        value: _backend.userData["ageRange"],
        items: ["18-24", "25-30", "30+"].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(color: Colors.black)))).toList(),
        onChanged: (val) => _onDataChange("ageRange", val),
      ),
    );
  }

   Widget _buildNavigationButtons() {
  return Padding(
    padding: const EdgeInsets.all(40.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0 && !_isSaving)
          TextButton(
            onPressed: () => _controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
            child: const Text("BACK", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
        const Spacer(),
        _isSaving
            ? const CircularProgressIndicator(color: Colors.black)
            : ElevatedButton(
                onPressed: () async {
                  if (_currentPage < 5) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  } else {
                   
                    setState(() => _isSaving = true);
                    
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                       
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                              'name': _backend.userData['name'] ?? 'User',
                              'gender': _backend.userData['gender'] ?? '',
                              'age': _backend.userData['ageRange'] ?? '',
                              'language': _backend.userData['language'] ?? 'English',
                              'mood': 'Neutral',
                              'setupComplete': true,
                              'lastUpdated': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true))
                            .timeout(const Duration(seconds: 10)); 

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isSetupComplete', true);

                        debugPrint("✅ Firestore Success: Data saved for ${user.uid}");

                       
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/focus'); 
                        }
                      } else {
                        debugPrint("❌ Error: User not logged in!");
                      }
                    } catch (e) {
                      debugPrint("❌ Firestore Error: $e");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("හදිසි දෝෂයක්: $e")),
                        );
                      }
                    } finally {
                      
                      if (mounted) setState(() => _isSaving = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(_currentPage == 5 ? "FINISH" : "NEXT", style: const TextStyle(color: Colors.white)),
              ),
      ],
    ),
  );
} 
}
