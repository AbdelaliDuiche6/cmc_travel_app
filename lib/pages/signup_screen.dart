import 'package:cmc_travel_app/components/my_button.dart';
import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:cmc_travel_app/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final authService = AuthService();

  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phoneNumber = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs"),backgroundColor: Colors.red,),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer une adresse email valide")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le mot de passe doit contenir au moins 6 caractères")),
      );
      return;
    }

    if (phoneNumber.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un numéro de téléphone valide")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
          SnackBar(content: Text("Échec de l'inscription: $e")),
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
                duration: const Duration(milliseconds: 600),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 26, 142, 234),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          "assets/images/logo.svg",
                          width: 200.0,
                          height: 300.0,
                          fit: BoxFit.fill,
                        ).animate(controller: _animationController)
                          .fade(duration: const Duration(milliseconds: 500))
                          .scale(delay: const Duration(milliseconds: 200)),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SplashScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInLeft(
                      duration: const Duration(milliseconds: 700),
                      child: const Text(
                        "Créez un compte, c'est gratuit",
                        style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 90, 90, 90)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField("Nom", Icons.person_outline, _nameController),
                    const SizedBox(height: 16),
                    _buildTextField("Numéro de téléphone", Icons.phone_outlined, _phoneController,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextField("Email", Icons.email_outlined, _emailController,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : MyButton(text: "S'inscrire", onTap: signUp),
                    ),
                   // const SizedBox(height: 24),
                    // FadeInUp(
                    //   duration: const Duration(milliseconds: 1100),
                    //   child: Row(
                    //     children: [
                    //       const Expanded(child: Divider(thickness: 1)),
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 16),
                    //         child: Text(
                    //           "Ou s'inscrire avec",
                    //           style: TextStyle(
                    //             fontSize: 14,
                    //             color: Colors.grey[600],
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //       ),
                    //       const Expanded(child: Divider(thickness: 1)),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // FadeInUp(
                    //   duration: const Duration(milliseconds: 1200),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       _socialLoginButton("images/gmail.svg"),
                    //       const SizedBox(width: 24),
                    //       _socialLoginButton("images/facebook.svg"),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Vous avez déjà un compte ?",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            ),
                            child: const Text(
                              "Se connecter",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 26, 142, 234),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ).animate()
                            .fadeIn()
                            .then(delay: 200.ms)
                            .shimmer(duration: 1200.ms, curve: Curves.easeInOutCubic),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _socialLoginButton(String assetPath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          assetPath,
          width: 30.0,
          height: 30.0,
          fit: BoxFit.contain,
        ),
      ),
    ).animate()
      .scale(duration: 200.ms, curve: Curves.easeInOut)
      .then(delay: 50.ms)
      .shimmer(duration: 1200.ms, curve: Curves.easeInOutCubic);
  }
}
