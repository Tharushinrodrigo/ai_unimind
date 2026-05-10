import 'package:flutter/material.dart';
import 'login_backend.dart'; 
import 'signup_frontend.dart'; 
import 'forgotpassword_frontend.dart'; // දැන් මේක පාවිච්චි කරන නිසා warning එක නැති වෙයි

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Container(
        width: double.infinity,
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
              const SizedBox(height: 80),
              const Text("UniMind AI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("WELCOME BACK!", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white, fontSize: 16)),
              const SizedBox(height: 50),
              
              _buildTextField("Email", _emailController, Icons.email, false),
              const SizedBox(height: 20),
              
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              
              // Forgot Password Link (මෙතනදී තමයි අර import එක පාවිච්චි වෙන්නේ)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigator එක පාවිච්චි කළාම අර කහ ඉර (Warning) මැකිලා යනවා
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                  },
                  child: const Text("Forgot password?", style: TextStyle(color: Colors.black54)),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19B0E5),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => LoginBackend().signInWithEmail(_emailController.text, _passwordController.text, context),
                child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 50),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New here? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                    },
                    child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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
}