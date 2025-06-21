import 'package:cmc_travel_app/services/auth/auth_gate.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:cmc_travel_app/components/my_button.dart';
import 'package:cmc_travel_app/pages/signup_screen.dart';
import 'package:cmc_travel_app/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    // Validation des champs
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 26, 142, 234),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      "assets/images/logo.svg",
                      width: 500.0,
                      height: 500.0,
                      fit: BoxFit.fill,
                    ).animate(controller: _animationController)
                      .fade(duration: 800.ms)
                      .scale(delay: 400.ms),
                  ),
              
                  Positioned(
                    top: 20,
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
                    ).animate().scale(delay: 300.ms),
                  ),
                  
                  // Positioned(
                  //   bottom: 20,
                  //   left: 0,
                  //   right: 0,
                  //   child: Center(
                  //     child: SvgPicture.asset(
                  //       "assets/images/2.svg",
                  //       width: 80.0,
                  //       height: 80.0,
                  //       fit: BoxFit.contain,
                  //     ).animate()
                  //       .fade(duration: 800.ms)
                  //       .scale(delay: 400.ms),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 26, 142, 234),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(),
                  const SizedBox(height: 8),
                  const Text(
                    "Veuillez entrer vos identifiants",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.w500
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(),
                  const SizedBox(height: 32),
                  
                  FadeInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text("Email",
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     color: Color.fromARGB(255, 0, 0, 0),
                        //     fontWeight: FontWeight.bold
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        _buildTextField("Nom", Icons.email_outlined, _emailController),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  FadeInLeft(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text("Mot de passe",
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     color: Color.fromARGB(255, 0, 0, 0),
                        //     fontWeight: FontWeight.bold
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        _buildPasswordField()

                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  FadeInRight(
                    delay: const Duration(milliseconds: 700),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Fonctionnalité de mot de passe oublié
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Fonctionnalité à venir"))
                            );
                          },
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 26, 142, 234),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : MyButton(text: "Se connecter", onTap: login),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // FadeInUp(
                  //   delay: const Duration(milliseconds: 900),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Container(
                  //         height: 1,
                  //         width: 100,
                  //         color: Colors.grey[300],
                  //       ),
                  //       const Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 15),
                  //         child: Text(
                  //           "Ou connectez-vous avec",
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             color: Colors.grey,
                  //             fontWeight: FontWeight.w500
                  //           ),
                  //         ),
                  //       ),
                  //       Container(
                  //         height: 1,
                  //         width: 100,
                  //         color: Colors.grey[300],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  
                 // const SizedBox(height: 20),
                  
                  // FadeInUp(
                  //   delay: const Duration(milliseconds: 1000),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       _socialLoginButton(
                  //         "assets/images/gmail.svg",
                  //         () {
                  //           // Fonctionnalité de connexion avec Google
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(content: Text("Connexion avec Google à venir"))
                  //           );
                  //         },
                  //       ),
                  //       const SizedBox(width: 40),
                  //       _socialLoginButton(
                  //         "assets/images/facebook.svg",
                  //         () {
                  //           // Fonctionnalité de connexion avec Facebook
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(content: Text("Connexion avec Facebook à venir"))
                  //           );
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  
               //   const SizedBox(height: 30),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 1100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous n'avez pas de compte ?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 114, 112, 112),
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          )),
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 26, 142, 234),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
      ),
    );

  }
  
  Widget _socialLoginButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SvgPicture.asset(
          assetPath,
          width: 30.0,
          height: 30.0,
          fit: BoxFit.contain,
        ),
      ),
    ).animate()
      .scale(duration: 200.ms)
      .then(delay: 200.ms)
      .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1));
  }

  Widget _buildPasswordField() {
    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mot de passe",
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.grey[100],
              hintText: "********",
              hintStyle: TextStyle(color: Colors.grey[500]),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color.fromARGB(255, 26, 142, 234), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField(String label, IconData icon, TextEditingController controller,
    {TextInputType keyboardType = TextInputType.text}) {
  return FadeInUp(
    duration: const Duration(milliseconds: 600),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            hintText: "Votre $label".toLowerCase(),
            hintStyle: TextStyle(color: Colors.grey[500]),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color.fromARGB(255, 26, 142, 234), width: 2),
            ),
          ),
        ),
      ],
    ),
  );


}
