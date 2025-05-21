
import 'package:cmc_travel_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  await Supabase.initialize(
    anonKey:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoZHR6eGRyYXV3YWltb25iamt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NTAzNzUsImV4cCI6MjA2MzMyNjM3NX0.ht0Yn2byTGRjyRVJa7kFBVCwT3hk-PCuKf_jcVnQEvw",
    url: "https://fhdtzxdrauwaimonbjkz.supabase.co",
  );

runApp(const MyApp());
  }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

