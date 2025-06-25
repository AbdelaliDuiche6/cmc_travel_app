import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        //margin: EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Text(text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .shimmer(duration: 1800.ms, color: Colors.white.withOpacity(0.2))
    .animate()
    .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 200.ms)
    .then(delay: 200.ms)
    .scale(begin: const Offset(1.02, 1.02), end: const Offset(1, 1), duration: 200.ms);
  }
}
