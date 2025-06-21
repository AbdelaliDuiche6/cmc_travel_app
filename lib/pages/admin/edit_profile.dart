import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
      final Color primaryColor = const Color.fromARGB(255, 26, 142, 234);
  final Color secondaryColor = const Color.fromARGB(255, 0, 0, 0);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _supabase = Supabase.instance.client;
  final String _bucketName = 'profile-images';

  File? _image;
  String _currentProfilePictureUrl = '';
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _avatarController;
  late AnimationController _buttonController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _avatarController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _avatarScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _avatarController,
      curve: Curves.elasticOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _avatarController.dispose();
    _buttonController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
        
        final picturePath = response['image_url'];
        if (picturePath != null && picturePath.isNotEmpty) {
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

      return fileName;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Image upload failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return null;
    }
  }

  Future<void> _pickImage() async {
    // Animate avatar
    _avatarController.forward().then((_) {
      _avatarController.reverse();
    });

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

    // Animate button press
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in", false);
      return;
    }

    try {
      final userId = user.id;
      String? imagePath = await _uploadImage();

      final updateData = {
        'phone_number': _phoneController.text,
        if (imagePath != null) 'image_url': imagePath,
      };

      await _supabase.from('profiles').update(updateData).eq('id', userId);

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

      _showSnackBar("Profile updated successfully!", true);
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return AnimatedBuilder(
      animation: _avatarScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _avatarScaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: _buildAvatarContent(),
          ),
        );
      },
    );
  }

  Widget _buildAvatarContent() {
    Widget avatarChild;
    
    if (_image != null) {
      avatarChild = CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: FileImage(_image!),
      );
    } else if (_currentProfilePictureUrl.isNotEmpty) {
      avatarChild = CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(_currentProfilePictureUrl),
      );
    } else {
      avatarChild = CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }

    return Stack(
      children: [
        avatarChild,
        Positioned(
          bottom: 5,
          right: 5,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, const Color.fromARGB(255, 65, 222, 246)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    bool hasToggle = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Interval(
              delay * 0.1,
              (delay * 0.1) + 0.4,
              curve: Curves.easeOutBack,
            ),
          )),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                delay * 0.1,
                (delay * 0.1) + 0.6,
                curve: Curves.easeIn,
              ),
            )),
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                validator: validator,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.8), const Color.fromARGB(255, 72, 191, 255).withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(prefixIcon, color: Colors.white, size: 20),
                  ),
                  suffixIcon: hasToggle
                      ? IconButton(
                          icon: Icon(
                            obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[600],
                          ),
                          onPressed: onToggle,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Updating profile...",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: _buildProfileAvatar(),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tap to change photo",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 40),
                      
                      _buildAnimatedTextField(
                        controller: _phoneController,
                        label: "Phone Number",
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        delay: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      
                      _buildAnimatedTextField(
                        controller: _currentPasswordController,
                        label: "Current Password",
                        prefixIcon: Icons.lock,
                        obscureText: _obscureCurrentPassword,
                        hasToggle: true,
                        delay: 2,
                        onToggle: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                        validator: (value) {
                          if (_newPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                            return 'Please enter current password';
                          }
                          return null;
                        },
                      ),
                      
                      _buildAnimatedTextField(
                        controller: _newPasswordController,
                        label: "New Password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureNewPassword,
                        hasToggle: true,
                        delay: 3,
                        onToggle: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      _buildAnimatedTextField(
                        controller: _confirmPasswordController,
                        label: "Confirm New Password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        hasToggle: true,
                        delay: 4,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 20),
                      
                      AnimatedBuilder(
                        animation: _buttonScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScaleAnimation.value,
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, const Color.fromARGB(255, 65, 220, 255)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                                child: Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}