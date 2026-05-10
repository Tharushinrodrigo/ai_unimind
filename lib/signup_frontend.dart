import 'package:flutter/material.dart';
import 'signup_backend.dart'; 
import 'login_frontend.dart'; // මෙන්න මේ import එක දැන් පාවිච්චි වෙනවා

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _isObscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Container(
        width: double.infinity,
        // මුළු Screen එකේම උස ගන්නවා, එතකොට යට සුදු වෙන්නේ නැහැ
        height: MediaQuery.of(context).size.height, 
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB8C6E3), Color(0xFFE5B2CA)], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "UniMind AI", 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const Text(
                "CREATE AN ACCOUNT", 
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white, fontSize: 16)
              ),
              const SizedBox(height: 40),
              
              _buildTextField("Full Name", _nameController, Icons.person, false),
              const SizedBox(height: 20),
              _buildTextField("Email", _emailController, Icons.email, false),
              const SizedBox(height: 20),
              _buildPasswordField("Password", _passwordController, _isObscurePassword, () {
                setState(() => _isObscurePassword = !_isObscurePassword);
              }),
              const SizedBox(height: 20),
              _buildPasswordField("Confirm Password", _confirmPasswordController, _isObscureConfirm, () {
                setState(() => _isObscureConfirm = !_isObscureConfirm);
              }),
              
              const SizedBox(height: 40),
              
              // Sign Up Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19B0E5), 
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => SignUpBackend().registerUser(
                  _nameController.text,
                  _emailController.text,
                  _passwordController.text,
                 _confirmPasswordController.text, 
                  context,
                ),
                child: const Text("SIGN UP", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 30),
              
              // Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      // මෙතනදී තමයි අර 'login_frontend.dart' එක පාවිච්චි වෙන්නේ
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    },
                    child: const Text(
                      "Login", 
                      style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}