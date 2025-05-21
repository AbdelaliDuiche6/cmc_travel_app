import 'package:cmc_travel_app/components/my_button.dart';
import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/services/auth/auth_gate.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:cmc_travel_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final authService = AuthService();
void signUp() async {
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  final phoneNumber = _phoneController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  try {
    final response = await authService.signUpWithEmailPassword(
      email,
      password,
      name,
      phoneNumber,
      "stagiaire",
    );

    if (response.user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: const Color.fromARGB(255, 26, 142, 234),
              child: Stack(
                children: [
                  
                  Center(
                    child: SvgPicture.asset(
                      "images/2.svg",
                      width: 200.0,
                      height: 300.0,
                      fit: BoxFit.fill,
                    ),
                  ),
              
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 4.0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create an account, it's free",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text("Name",
                      style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold
                    ),),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      hintText: "   your name",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Phone Number",
                      style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold
                    ),),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      hintText: "   phone number",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Email",
                      style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold
                    ),),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      hintText: "   youremail@gmail.com",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Password",style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold
                    ),),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      hintText: "   ********",
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  MyButton(text: "Sign Up", onTap:signUp),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Or Sign Up with",style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold
                        ),),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "images/gmail.svg",
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 40),
                      SvgPicture.asset(
                        "images/facebook.svg",
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Have account?",style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 114, 112, 112),
                          fontWeight: FontWeight.bold
                        ),),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>  const  LoginScreen(),
                        )),
                        child: Text("Sign In",style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold
                        ),)),
                    ],
                  ),
        
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}