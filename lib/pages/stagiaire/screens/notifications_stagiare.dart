import 'package:flutter/material.dart';

import '../../../constants.dart';

class NotificationsStagiare extends StatefulWidget {
  const NotificationsStagiare({super.key});

  @override
  State<NotificationsStagiare> createState() => _NotificationsStagiareState();
}

class _NotificationsStagiareState extends State<NotificationsStagiare> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: kDefaultPadding / 2),
            child: TextButton(
              onPressed: () => {},
              child: Text(
                'Clear all',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(kDefaultPadding / 2),
        children: [
          Card(
            shadowColor: kPrimaryColor,
            color: Colors.white,
            elevation: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    // backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
                    child: Icon(Icons.person, size: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding * 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sender Name',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: kDefaultPadding),
                          child: Text(
                            'content',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'time received',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
