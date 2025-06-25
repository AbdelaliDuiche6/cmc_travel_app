// import 'dart:io';
// import 'package:cmc_travel_app/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../services/auth/auth_service.dart';
// import '../../login_screen.dart';

// class ProfileStagiaire extends StatefulWidget {
//   const ProfileStagiaire({super.key});

//   @override
//   State<ProfileStagiaire> createState() => _ProfileStagiaireState();
// }

// class _ProfileStagiaireState extends State<ProfileStagiaire> {
//   final supabase = Supabase.instance.client;

//   String name = '';
//   String email = '';
//   String phone = '';
//   String profilePictureUrl = '';

//   File? _newImage;

//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchProfileData();
//   }

//   Future<void> fetchProfileData() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     try {
//       final profile =
//           await supabase
//               .from('profiles')
//               .select('name, phone_number, image_url')
//               .eq('id', user.id)
//               .single();

//       String? picturePath = profile['image_url'];
//       String imageUrl = '';
//       if (picturePath != null && picturePath.isNotEmpty) {
//         imageUrl = supabase.storage
//             .from('profile-images')
//             .getPublicUrl(
//               picturePath.startsWith('/')
//                   ? picturePath.substring(1)
//                   : picturePath,
//             );
//       }

//       setState(() {
//         name = profile['name'] ?? 'Unknown';
//         phone = profile['phone_number'] ?? '';
//         email = user.email ?? '';
//         profilePictureUrl = imageUrl;
//         _emailController.text = email;
//         _phoneController.text = phone;
//       });
//     } catch (e) {
//       debugPrint('Error loading profile: $e');
//     }
//   }

//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _newImage = File(picked.path);
//       });
//     }
//   }

//   Future<void> updateProfile() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     String? uploadedImagePath;

//     try {
//       if (_newImage != null) {
//         final fileExt = _newImage!.path.split('.').last;
//         final fileName = 'profile_${user.id}.$fileExt';
//         await supabase.storage
//             .from('profile-images')
//             .upload(
//               fileName,
//               _newImage!,
//               fileOptions: const FileOptions(upsert: true),
//             );
//         uploadedImagePath = fileName;
//       }

//       final updateData = {
//         'phone_number': _phoneController.text,
//         if (uploadedImagePath != null) 'image_url': uploadedImagePath,
//       };

//       await supabase.from('profiles').update(updateData).eq('id', user.id);

//       if (_emailController.text.isNotEmpty && _emailController.text != email) {
//         await supabase.auth.updateUser(
//           UserAttributes(email: _emailController.text),
//         );
//       }

//       if (_passwordController.text.isNotEmpty) {
//         await supabase.auth.updateUser(
//           UserAttributes(password: _passwordController.text),
//         );
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Profile updated successfully')),
//       );

//       await fetchProfileData();
//       _passwordController.clear();
//     } catch (e) {
//       debugPrint('Profile update failed: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('❌ Failed to update: $e')));
//     }
//   }

//   Future<void> _handleDone() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             backgroundColor: Colors.white,
//             title: const Text('Confirm Changes'),
//             content: const Text('Do you want to save the changes?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
//                 child: const Text('Confirm'),
//               ),
//             ],
//           ),
//     );

//     if (confirm == true) {
//       await updateProfile();
//     }
//   }

//   void logout() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             backgroundColor: Colors.white,
//             title: const Text('Log Out'),
//             content: const Text('Are you sure you want to log out?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
//                 child: const Text('Log Out'),
//               ),
//             ],
//           ),
//     );

//     if (confirm == true) {
//       final authService = AuthService();
//       await authService.signOut();
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         elevation: 0.0,
//         title: const Text(
//           'Edit Profile',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: kDefaultPadding / 2),
//             child: IconButton(
//               icon: const Icon(Icons.logout, color: kPrimaryColor),
//               onPressed: logout,
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(kDefaultPadding),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 60,
//                   backgroundImage:
//                       _newImage != null
//                           ? FileImage(_newImage!)
//                           : (profilePictureUrl.isNotEmpty
//                                   ? NetworkImage(profilePictureUrl)
//                                   : null)
//                               as ImageProvider?,
//                   child:
//                       (_newImage == null && profilePictureUrl.isEmpty)
//                           ? const Icon(Icons.person, size: 60)
//                           : null,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text(
//               name,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             TextButton(
//               onPressed: pickImage,
//               child: const Text(
//                 'Change Profile Picture',
//                 style: TextStyle(
//                   color: kPrimaryColor,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _infoLabel('Email'),
//             _infosField(
//               keyboardType: TextInputType.emailAddress,
//               controller: _emailController,
//               prefix: null,
//               hintText: 'Enter new email',
//               isEnabled: true,
//             ),
//             const SizedBox(height: 15),
//             _infoLabel('Phone Number'),
//             _infosField(
//               keyboardType: TextInputType.phone,
//               controller: _phoneController,
//               prefix: const Text(
//                 '+212 | ',
//                 style: TextStyle(color: Colors.grey),
//               ),
//               hintText: '',
//               isEnabled: false,
//             ),
//             const SizedBox(height: 15),
//             _infoLabel('Password'),
//             _infosField(
//               keyboardType: TextInputType.visiblePassword,
//               controller: _passwordController,
//               prefix: null,
//               hintText: 'Enter new password',
//               isEnabled: false,
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _handleDone,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kPrimaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text(
//                   'Done',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infosField({
//     required TextInputType keyboardType,
//     required TextEditingController controller,
//     Widget? prefix,
//     required String hintText,
//     required bool isEnabled,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             margin: const EdgeInsets.only(top: 10),
//             alignment: Alignment.center,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.black12.withAlpha(10),
//               borderRadius: BorderRadius.circular(16.0),
//             ),
//             child: TextField(
//               readOnly: isEnabled,
//               controller: controller,
//               keyboardType: keyboardType,
//               obscureText: keyboardType == TextInputType.visiblePassword,
//               cursorColor: kPrimaryColor,
//               decoration: InputDecoration(
//                 filled: false,
//                 focusedBorder: InputBorder.none,
//                 border: const OutlineInputBorder(borderSide: BorderSide.none),
//                 contentPadding: const EdgeInsets.only(left: 10, right: 20),
//                 constraints: const BoxConstraints(maxHeight: 35),
//                 prefix: prefix,
//                 hintText: hintText,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _infoLabel(String content) {
//     return Row(
//       children: [
//         Text(
//           content,
//           style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
// }

import 'dart:io';
import 'package:cmc_travel_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/auth/auth_service.dart';
import '../../login_screen.dart';

class ProfileStagiaire extends StatefulWidget {
  const ProfileStagiaire({super.key});

  @override
  State<ProfileStagiaire> createState() => _ProfileStagiaireState();
}

class _ProfileStagiaireState extends State<ProfileStagiaire> {
  final supabase = Supabase.instance.client;

  String name = '';
  String email = '';
  String phone = '';
  String profilePictureUrl = '';

  File? _newImage;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile =
          await supabase
              .from('profiles')
              .select('name, phone_number, image_url')
              .eq('id', user.id)
              .single();

      String? picturePath = profile['image_url'];
      String imageUrl = '';
      if (picturePath != null && picturePath.isNotEmpty) {
        imageUrl = supabase.storage
            .from('profile-images')
            .getPublicUrl(
              picturePath.startsWith('/')
                  ? picturePath.substring(1)
                  : picturePath,
            );
      }

      setState(() {
        name = profile['name'] ?? 'Unknown';
        phone = profile['phone_number'] ?? '';
        email = user.email ?? '';
        profilePictureUrl = imageUrl;
        _emailController.text = email;
        _phoneController.text = phone;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });
    }
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    String? uploadedImagePath;

    try {
      if (_newImage != null) {
        final fileExt = _newImage!.path.split('.').last;
        final fileName = 'profile_${user.id}.$fileExt';
        await supabase.storage
            .from('profile-images')
            .upload(
              fileName,
              _newImage!,
              fileOptions: const FileOptions(upsert: true),
            );
        uploadedImagePath = fileName;
      }

      final updateData = {
        'phone_number': _phoneController.text,
        if (uploadedImagePath != null) 'image_url': uploadedImagePath,
      };

      await supabase.from('profiles').update(updateData).eq('id', user.id);

      if (_emailController.text.isNotEmpty && _emailController.text != email) {
        await supabase.auth.updateUser(
          UserAttributes(email: _emailController.text),
        );
      }

      if (_passwordController.text.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated successfully')),
      );

      await fetchProfileData();
      _passwordController.clear();
    } catch (e) {
      debugPrint('Profile update failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to update: $e')));
    }
  }

  Future<void> _handleDone() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Confirm Changes'),
            content: const Text('Do you want to save the changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await updateProfile();
    }
  }

  void logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                child: const Text('Log Out'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final authService = AuthService();
      await authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _showRoleChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.swap_horiz, color: Colors.blue),
              SizedBox(width: 8),
              Text("Change Role"),
            ],
          ),
          content: Text(
            "Are you sure you want to switch to Organizer mode?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await changRol();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Role changed to Organizer"),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Switch Role"),
            ),
          ],
        );
      },
    );
  }

  Future<void> changRol() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final userId = user.id;
    try {
      await supabase
          .from("profiles")
          .update({'role': 'organisateur'})
          .eq('id', userId);
      logout();
    } catch (e) {
      print('Error change role: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to change role')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        leading: IconButton(
          icon: Icon(Icons.swap_horiz_outlined, color: Colors.blue.shade600),
          tooltip: "Switch to Organizer Mode",
          onPressed: () => _showRoleChangeDialog(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: kDefaultPadding / 2),
            child: IconButton(
              icon: const Icon(Icons.logout, color: kPrimaryColor),
              onPressed: logout,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _newImage != null
                          ? FileImage(_newImage!)
                          : (profilePictureUrl.isNotEmpty
                                  ? NetworkImage(profilePictureUrl)
                                  : null)
                              as ImageProvider?,
                  child:
                      (_newImage == null && profilePictureUrl.isEmpty)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: pickImage,
              child: const Text(
                'Change Profile Picture',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _infoLabel('Email'),
            _infosField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              prefix: null,
              hintText: 'Enter new email',
              isEnabled: true,
            ),
            const SizedBox(height: 15),
            _infoLabel('Phone Number'),
            _infosField(
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              prefix: const Text(
                '+212 | ',
                style: TextStyle(color: Colors.grey),
              ),
              hintText: '',
              isEnabled: false,
            ),
            const SizedBox(height: 15),
            _infoLabel('Password'),
            _infosField(
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              prefix: null,
              hintText: 'Enter new password',
              isEnabled: false,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infosField({
    required TextInputType keyboardType,
    required TextEditingController controller,
    Widget? prefix,
    required String hintText,
    required bool isEnabled,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black12.withAlpha(10),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: TextField(
              readOnly: isEnabled,
              controller: controller,
              keyboardType: keyboardType,
              obscureText: keyboardType == TextInputType.visiblePassword,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                filled: false,
                focusedBorder: InputBorder.none,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.only(left: 10, right: 20),
                constraints: const BoxConstraints(maxHeight: 35),
                prefix: prefix,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoLabel(String content) {
    return Row(
      children: [
        Text(
          content,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
