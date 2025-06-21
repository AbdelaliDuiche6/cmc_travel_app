import 'package:cmc_travel_app/services/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController.forward();
    
    // Navigation automatique après un délai
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthGate(),
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 142, 234),
      body: Stack(
        children: [
          // Cercles animés en arrière-plan
          Positioned(
            top: -50,
            left: -50,
            child: FadeIn(
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Contenu principal centré
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo avec animations
                ZoomIn(
                  duration: const Duration(milliseconds: 1000),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthGate(),
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 250,
                      height: 250,
                      semanticsLabel: 'CMC TRAVEL',
                    ).animate(controller: _animationController)
                      .fade(duration: const Duration(milliseconds: 500))
                      .scale(delay: const Duration(milliseconds: 200))
                      .then(delay: 500.ms)
                      .shimmer(duration: 1200.ms, curve: Curves.easeInOutCubic),
                  ),
                ),
                const SizedBox(height: 40),
                // Texte animé
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  duration: const Duration(milliseconds: 800),
                  child: const Text(
                    "CMC TRAVEL",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 1000),
                  duration: const Duration(milliseconds: 800),
                  child: const Text(
                    "Voyagez en toute sérénité",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Indicateur de chargement
                FadeIn(
                  delay: const Duration(milliseconds: 1500),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
