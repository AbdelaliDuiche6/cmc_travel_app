import 'package:cmc_travel_app/services/auth/auth_gate.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:cmc_travel_app/components/my_button.dart';
import 'package:cmc_travel_app/pages/signup_screen.dart';
import 'package:cmc_travel_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void login() async {
  final email = _emailController.text;
  final password = _passwordController.text;

  try {
    final response = await authService.signInWithEmailPassword(email, password);

    if (response.session != null && mounted) {
      // Rebuild the widget tree and let AuthGate handle navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: const Color.fromARGB(255, 26, 142, 234),
            child: Stack(
              children: [
                
                Center(
                  child: SvgPicture.asset(
                    "images/2.svg",
                    width: 500.0,
                    height: 500.0,
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
                  "Sign In",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please enter a valid account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(child: Text("Forgot Password",style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold
                      ),)),
                  ],
                ),
                const SizedBox(height: 10),
                MyButton(text: "Sign In", onTap: ()=>login()), 
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Or Sign In with",style: TextStyle(
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
                    Text("Don't have an account?",style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 114, 112, 112),
                        fontWeight: FontWeight.bold
                      ),),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      )),
                      child: Text("Sign Up",style: TextStyle(
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
    );
  }
}