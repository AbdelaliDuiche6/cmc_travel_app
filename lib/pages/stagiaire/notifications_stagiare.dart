import 'package:flutter/material.dart';

class NotificationsStagiare extends StatefulWidget {
  const NotificationsStagiare({super.key});

  @override
  State<NotificationsStagiare> createState() => _NotificationsStagiareState();
}

class _NotificationsStagiareState extends State<NotificationsStagiare> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Notifications',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 26, 142, 234),
        ),
      ),
    );
  }
}
