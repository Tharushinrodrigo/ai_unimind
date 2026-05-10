import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Setup pages වලින් ලැබෙන දත්ත මෙහි ගබඩා වේ
  String firstName = "Tharushi";
  String lastName = "Rodrigo";
  String userEmail = "tharushi77@gmail.com";
  String userPassword = "password123";
  int age = 22;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB5B2FF), Colors.white, Color(0xFFB5B2FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
                      onPressed: () {
                        // Focus Page එකට යාම
                        Navigator.pop(context); 
                      },
                    ),
                    const Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Icon(Icons.email_outlined, size: 30),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text("Account & Privacy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    // Profile Card
                    GestureDetector(
                      onTap: () => _navigateToEditProfile(),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 30, 
                              backgroundColor: Colors.white, 
                              child: Icon(Icons.person, color: Colors.deepPurple)
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("$firstName $lastName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(userEmail, style: const TextStyle(color: Colors.black54)),
                                  const SizedBox(height: 5),
                                  // My Preferences කොටසේ Age එක පෙන්වීම
                                  Text("My Preferences: Age $age", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    _buildSectionTitle("Security"),
                    _buildSettingTile("Change Password", onTap: () => _navigateToEditProfile()),
                    _buildSettingTile("App Notification", trailingText: "Enabled"),
                    
                    _buildSectionTitle("Wellness"),
                    _buildSettingTile("Smart Study Schedule"),
                    _buildSettingTile("Mood Tracking", trailingText: "Enabled"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Edit Profile Page එකට ගොස් දත්ත රැගෙන ඒම
  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          firstName: firstName,
          lastName: lastName,
          email: userEmail,
          password: userPassword,
          age: age,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        firstName = result['firstName'];
        lastName = result['lastName'];
        userEmail = result['email'];
        userPassword = result['password'];
        age = result['age'];
      });
    }
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
  );

  Widget _buildSettingTile(String title, {String? trailingText, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                if (trailingText != null) Text(trailingText, style: const TextStyle(color: Colors.black54)),
                const Icon(Icons.chevron_right, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Edit Profile Page ---
class EditProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final int age;

  const EditProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.age,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController fNameController;
  late TextEditingController lNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    fNameController = TextEditingController(text: widget.firstName);
    lNameController = TextEditingController(text: widget.lastName);
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
    ageController = TextEditingController(text: widget.age.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: const Color(0xFFB5B2FF)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(fNameController, "First Name"),
            _buildTextField(lNameController, "Last Name"),
            _buildTextField(emailController, "Email"),
            _buildTextField(passwordController, "Password", isObscure: true),
            _buildTextField(ageController, "Age", isNumber: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'firstName': fNameController.text,
                    'lastName': lNameController.text,
                    'email': emailController.text,
                    'password': passwordController.text,
                    'age': int.tryParse(ageController.text) ?? widget.age,
                  });
                },
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isObscure = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}