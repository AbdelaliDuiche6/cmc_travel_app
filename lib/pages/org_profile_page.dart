import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final OutlineInputBorder border = OutlineInputBorder();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(image: AssetImage("Images/pfp.jpg")),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "My Organize",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("myorganize@gmail.com"),
                SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Divider(),
                SizedBox(height: 30),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
