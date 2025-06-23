import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _supabase = Supabase.instance.client;
  final String _bucketName = 'profile-images';

  File? _image;
  String _currentProfilePictureUrl = ''; // Add this to store current profile picture URL
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile(); // Load both phone and profile picture
  }

  Future<void> _loadCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('profiles')
          .select('phone_number, image_url')
          .eq('id', user.id)
          .single();

      setState(() {
        _phoneController.text = response['phone_number'] ?? '';
        
        // Load current profile picture URL
        final picturePath = response['image_url'];
        if (picturePath != null && picturePath.isNotEmpty) {
          // Clean the path - remove leading slash if present
          String cleanPath = picturePath.startsWith('/') ? picturePath.substring(1) : picturePath;
          
          _currentProfilePictureUrl = _supabase.storage
              .from(_bucketName)
              .getPublicUrl(cleanPath);
              
          print('Loaded profile picture URL: $_currentProfilePictureUrl');
        }
      });
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final fileExtension = path.extension(_image!.path);
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      await _supabase.storage.from(_bucketName).upload(
            fileName,
            _image!,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Return just the file name/path, not the full URL
      return fileName;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final userId = user.id;

      // Upload image and get the file path (not full URL)
      String? imagePath = await _uploadImage();

      // Update profile
      final updateData = {
        'phone_number': _phoneController.text,
        if (imagePath != null) 'image_url': imagePath, // Store the path, not full URL
      };

      await _supabase.from('profiles').update(updateData).eq('id', userId);

      // Update password if provided
      if (_newPasswordController.text.isNotEmpty && _currentPasswordController.text.isNotEmpty) {
        final res = await _supabase.auth.signInWithPassword(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        if (res.user == null) {
          throw Exception("Current password is incorrect.");
        }

        await _supabase.auth.updateUser(
          UserAttributes(password: _newPasswordController.text),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully.")),
      );
      Navigator.pop(context, true); // Return true to indicate successful update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileAvatar() {
    // Priority: New selected image > Current profile picture > Default icon
    if (_image != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: FileImage(_image!),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else if (_currentProfilePictureUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(_currentProfilePictureUrl),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        child: Stack(
          children: [
            Icon(Icons.person, size: 60, color: Colors.grey),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(35),
      borderSide: BorderSide(width: 2.0, color: Colors.black),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile"), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _buildProfileAvatar(),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: Icon(Icons.phone),
                        border: border,
                        enabledBorder: border.copyWith(borderSide: BorderSide(width: 2)),
                        focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.amber)),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.amber)),
                      ),
                      validator: (value) {
                        if (_newPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                          return 'Please enter current password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.amber)),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "Confirm New Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.amber)),
                      ),
                      validator: (value) {
                        if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                      ),
                      child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}