import 'package:cmc_travel_app/constants.dart';
import 'package:flutter/material.dart';

class ProfileStagiaire extends StatefulWidget {
  const ProfileStagiaire({super.key});

  @override
  State<ProfileStagiaire> createState() => _ProfileStagiaireState();
}

class _ProfileStagiaireState extends State<ProfileStagiaire> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: kDefaultPadding / 2),
            child: TextButton(
              onPressed: () => {},
              child: Text(
                'Done',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  // backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
                  child: Icon(Icons.person, size: 60),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Username',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => {},
              child: Text(
                'Change Profile Picture',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20),
            _infoLabel('Full Name'),
            _infosField(TextInputType.text, null),
            SizedBox(height: 15),
            _infoLabel('Phone Number'),
            _infosField(
              TextInputType.number,
              Text('+212 | ', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Row _infosField(TextInputType? keyBoard, Widget? prefix) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black12.withAlpha(10),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: TextField(
              keyboardType: keyBoard,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                filled: false,
                focusedBorder: InputBorder.none,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.only(left: 10, right: 20),
                constraints: BoxConstraints(maxHeight: 35),
                prefix: prefix,
                suffixIcon: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row _infoLabel(String content) {
    return Row(
      children: [
        Text(
          content,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
