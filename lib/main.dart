import 'package:cmc_travel_app/pages/splash_screen.dart';

import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoZHR6eGRyYXV3YWltb25iamt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NTAzNzUsImV4cCI6MjA2MzMyNjM3NX0.ht0Yn2byTGRjyRVJa7kFBVCwT3hk-PCuKf_jcVnQEvw",
    url: "https://fhdtzxdrauwaimonbjkz.supabase.co",
  );

  // Stripe.publishableKey =
  // "pk_test_51RdeASH8W1zP12YHZ2CCCN70B9xCkair4FEgfaCQJdLlkzAT7HbKHuAqUK5WJrjN7Ei5wMy5rYMdLB4VXQoH3Y4600E5K0SlIp"; // ta clé publique
  // await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: SplashScreen(),
    );
  }
}
