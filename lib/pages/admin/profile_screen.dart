import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/edit_profile.dart';
import 'package:cmc_travel_app/pages/admin/statestique_screen.dart';
import 'package:cmc_travel_app/pages/admin/edit_profile.dart';
import 'package:cmc_travel_app/pages/admin/statestique_screen.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {

  String name = '';
  String email = '';
  String phone = '';
  String createdAt = '';
  String profilePictureUrl = '';
  bool isLoading = true;

  late AnimationController _controller;
  late Animation<double> _avatarAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _nameAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _avatarAnimation = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _nameAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.2, 0.6, curve: Curves.easeIn)),
    );
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeIn)),
    );
    _loadProfile();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final userId = user.id;
    final userEmail = user.email ?? '';
    final createdAtRaw = user.createdAt;
    DateTime? createdDate = createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
    String createdDateFormatted = createdDate != null ? createdDate.toLocal().toString().split(" ").first : '';

    try {
      // Get profile info
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Count trips
      // final tripResponse = await Supabase.instance.client
      //     .from('Voyage')
      //     .select()
      //     .eq('organizer_id', userId);

      // Get profile picture path and generate URL
      final picturePath = profileResponse['image_url'];
      String finalProfilePicUrl = '';
      
      if (picturePath != null && picturePath.isNotEmpty) {
        try {
          // Generate the public URL
          finalProfilePicUrl = Supabase.instance.client.storage
              .from('profile-images')
              .getPublicUrl(picturePath);
          
          // Debug: Print the URL to check if it's correct
          print('Profile picture URL: $finalProfilePicUrl');
        } catch (e) {
          print('Error generating profile picture URL: $e');
        }
      }

      setState(() {
        name = profileResponse['name'] ?? 'Unknown';
        phone = profileResponse['phone_number'] ?? 'N/A';
        email = userEmail;
        createdAt = createdDateFormatted;
        //tripCount = tripResponse.length;
        profilePictureUrl = finalProfilePicUrl;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

Widget _buildInfoRow(IconData icon, String text, {
  Color? iconColor,
  Color? textColor,
  Color? backgroundColor,
  bool isHighlighted = false,
  VoidCallback? onTap,
}) {
  final effectiveIconColor = iconColor ?? 
    (isHighlighted ? const Color(0xFF3AB796) : const Color(0xFF64748B));
  final effectiveTextColor = textColor ?? 
    (isHighlighted ? const Color(0xFF1E293B) : const Color(0xFF64748B));
  final effectiveBackgroundColor = backgroundColor ?? 
    (isHighlighted ? const Color(0xFF3AB796).withOpacity(0.08) : Colors.transparent);

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: isHighlighted 
        ? Border.all(color: const Color(0xFF3AB796).withOpacity(0.2), width: 1)
        : null,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 15,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: effectiveIconColor.withOpacity(0.6),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
  final Color primaryColor =  const Color.fromARGB(255, 26, 142, 234);
  final Color secondaryColor = const Color.fromARGB(255, 0, 0, 0);
  int _selectedIndex = 3;


    void logout() async {
    final authService = AuthService();
    authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildProfileAvatar() {
    if (profilePictureUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            profilePictureUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return Icon(Icons.person, size: 60, color: Colors.grey);
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
  }

  // Widget _buildProfileAvatar() {
  //   if (profilePictureUrl.isNotEmpty) {
  //     return CircleAvatar(
  //       radius: 60,
  //       backgroundColor: Colors.grey[200],
  //       child: ClipOval(
  //         child: Image.network(
  //           profilePictureUrl,
  //           width: 120,
  //           height: 120,
  //           fit: BoxFit.cover,
  //           loadingBuilder: (context, child, loadingProgress) {
  //             if (loadingProgress == null) return child;
  //             return Center(
  //               child: CircularProgressIndicator(
  //                 value: loadingProgress.expectedTotalBytes != null
  //                     ? loadingProgress.cumulativeBytesLoaded / 
  //                       loadingProgress.expectedTotalBytes!
  //                     : null,
  //               ),
  //             );
  //           },
  //           errorBuilder: (context, error, stackTrace) {
  //             print('Error loading image: $error');
  //             return Icon(Icons.person, size: 60, color: Colors.grey);
  //           },
  //         ),
  //       ),
  //     );
  //   } else {
  //     return CircleAvatar(
  //       radius: 60,
  //       backgroundColor: Colors.grey[200],
  //       child: Icon(Icons.person, size: 60, color: Colors.grey),
  //     );
  //   }
  // }
  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home (can be AdminScreen itself or another screen)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UsersScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StatestiquePage()));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StatestiquePage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
  elevation: 0,
  shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        toolbarHeight: 70,
  backgroundColor: primaryColor,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.8),
        ],
      ),
    ),
  ),
  title:  const Text(
        "Profile",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
  actions: [
    Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.white,
          size: 22,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.red[600],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Sign Out",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  "Are you sure you want to sign out of your account?",
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "SIGN OUT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Sign Out',
      ),
    ),
  ],
  centerTitle: true,
),
body: isLoading
    ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3AB796)),
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Loading your profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      )
    : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              Colors.white,
              Colors.grey[50]!,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _avatarAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _avatarAnimation.value),
                            child: Opacity(
                              opacity: 1 - (_avatarAnimation.value.abs() / 80),
                              child: _buildProfileAvatar(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _nameAnimation,
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _nameAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.1),
                                primaryColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                size: 18,
                                color: secondaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Administrator",
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Information Card
                FadeTransition(
                  opacity: _cardAnimation,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: secondaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildEnhancedInfoRow(
                            Icons.email_outlined,
                            "Email Address",
                            email,
                          ),
                          _buildEnhancedInfoRow(
                            Icons.phone_outlined,
                            "Phone Number",
                            phone,
                          ),
                          _buildEnhancedInfoRow(
                            Icons.calendar_today_outlined,
                            "Member Since",
                            createdAt,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions Card
                FadeTransition(
                  opacity: _cardAnimation,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Quick Actions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfilePage()),
                                );
                                if (result == true) {
                                  _loadProfile();
                                }
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                              ),
                              label: const Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                shadowColor: primaryColor.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
     bottomNavigationBar: buildBottomNavigationBar()
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
  return BottomNavigationBar(
    onTap: (index) {
      HapticFeedback.lightImpact(); // Add haptic feedback
      setState(() {
        _selectedIndex = index;
      });
      _navigate(index); // Call your navigation method
    },
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: primaryColor,
    unselectedItemColor: Colors.grey,  // Added unselected item color
    selectedIconTheme: IconThemeData(color: primaryColor),
    elevation: 0.0,
    currentIndex: _selectedIndex,
    items: [
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/home.svg'),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/notification.svg'),  // Changed icon
        label: 'Notifications',
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/statistics.svg', width: 35, height: 35,),
        label: 'Statestique',
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/profile.svg'),
        label: 'Profile',
      ),
    ],
  );
}

  Widget _buildEnhancedProfileAvatar() {
  return Stack(
    children: [
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
      Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green[500],
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    ],
  );
}

// Enhanced Info Row Widget
Widget _buildEnhancedInfoRow(
  IconData icon,
  String title,
  String value, {
  bool isLast = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(
              bottom: BorderSide(
                color: Colors.grey[100]!,
                width: 1,
              ),
            ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: secondaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

NavigationDestination _buildAnimatedDestination({
  required int index,
  required IconData selectedIcon,
  required IconData unselectedIcon,
  required String label,
}) {
  final isSelected = _selectedIndex == index;
  
  return NavigationDestination(
    icon: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(
        begin: 0.0,
        end: isSelected ? 1.0 : 0.0,
      ),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.15), // Scale animation
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isSelected ? 8.0 : 4.0),
            decoration: BoxDecoration(
              color: isSelected 
                  ? primaryColor.withOpacity(0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected 
                    ? primaryColor
                    : secondaryColor.withOpacity(0.8),
                size: isSelected ? 26 : 24,
                key: ValueKey<bool>(isSelected),
              ),
            ),
          ),
        );
      },
    ),
    label: label,
  );
}
}