import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:cmc_travel_app/pages/admin/statestique_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
//import 'package:phosphor_flutter/phosphor_flutter.dart';
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final Color primaryColor = const Color.fromARGB(255, 26, 142, 234);
  final Color secondaryColor = const Color.fromARGB(255, 0, 0, 0);

  late var picfinal = '';
  List<dynamic> voyages = [];
  bool isLoading = true;
  late AnimationController _animationController;
  
  // Pour les animations de carte
  List<bool> _hoveredCards = [];
  int _selectedIndex = 0;
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [
    AdminScreen(),
    UsersScreen(),
    StatestiquePage(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchVoyages();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchVoyages() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await supabase
          .from('Voyage')
          .select('*, profiles(name,image_url)')
          .eq('status', 'en_cours')
          .order('date', ascending: true);

      setState(() {
        voyages = response;
        _hoveredCards = List.generate(response.length, (_) => false);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UsersScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StatestiquePage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }
  
  Future<void> _acceptVoyage(dynamic voyage, int index) async {
    try {
      final response = await supabase
          .from('Voyage')
          .update({'status': 'accepted'})
          .eq('id', voyage['id'])
          .select();

      if (response.isNotEmpty) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voyage accepté'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          voyages.removeAt(index);
        });
      } else {
        throw Exception("Update failed or returned no result.");
      }
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _rejectVoyage(dynamic voyage, int index) async {
    try {
      final response = await supabase
          .from('Voyage')
          .update({'status': 'rejected'})
          .eq('id', voyage['id'])
          .select();

      if (response.isNotEmpty) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voyage rejeté'),
            backgroundColor: Colors.orange,
          ),
        );

        setState(() {
          voyages.removeAt(index);
        });
      } else {
        throw Exception("Update failed or returned no result.");
      }
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previewVoyage(dynamic voyage) {

    // Animation pour l'ouverture du dialogue
    showDialog(

      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: FadeIn(
          duration: const Duration(milliseconds: 300),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(

                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          voyage['title'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ajout de l'image en haut du dialogue avec animation
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: voyage['image_url'] != null && voyage['image_url'].isNotEmpty
                            ? Image.network(
                                voyage['image_url'],
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
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.photo_camera,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(26),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.person,
                            "Organisateur: ${voyage['profiles']['name']}",
                            iconColor: primaryColor,
                          ),
                          _buildInfoRow(
                            Icons.category,
                            "Type: ${voyage['type']}",
                            iconColor: primaryColor,
                          ),
                          _buildInfoRow(
                            Icons.description,
                            "Description: ${voyage['description']}",
                            iconColor: primaryColor,
                          ),
                          _buildInfoRow(
                            Icons.calendar_today,
                            "Date: ${voyage['date']}",
                            iconColor: primaryColor,
                          ),
                          _buildInfoRow(
                            Icons.attach_money,
                            "Prix: ${voyage['price_per_person']} DH",
                            iconColor: primaryColor,
                          ),
                          _buildInfoRow(
                            Icons.people,
                            "Places disponibles: ${voyage['nbr_places']}",
                            iconColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Fermer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoyageCard(dynamic voyage, int index) {

    final picUrl = Supabase.instance.client.storage.from('profile-images')
    .getPublicUrl(voyage['profiles']['image_url']);


    //print(picUrl);
    // Utiliser un délai basé sur l'index pour l'animation d'entrée
    final delay = Duration(milliseconds: 100 * index);
    return FadeInUp(
      delay: delay,
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: _hoveredCards[index] ? 10 : 4,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
        shadowColor: primaryColor.withAlpha(60),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _previewVoyage(voyage),
          onHover: (isHovered) {
            setState(() {
              _hoveredCards[index] = isHovered;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideInLeft(
                  delay: Duration(milliseconds: 200 + (index * 50)),
                  duration: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(60),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            voyage['image_url'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voyage['title'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50), // pour l'effet rond
                                  child: picUrl != null && picUrl.isNotEmpty
                                      ? Image.network(
                                    picUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 32),
                                  )
                                      : const Icon(Icons.person, size: 32),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    voyage['profiles']?['name'] ?? 'Inconnu',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18, color: primaryColor),
                      const SizedBox(width: 7),
                      Text(
                        voyage['date'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.people_alt_rounded, size: 18, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "${voyage['nbr_places']} places",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SlideInRight(
                  delay: Duration(milliseconds: 300 + (index * 50)),
                  duration: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.remove_red_eye_rounded, size: 17),
                          label: const Text("Détails"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => _previewVoyage(voyage),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_rounded, size: 17),
                          label: const Text("Accepter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            _acceptVoyage(voyage, index);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cancel_rounded, size: 17),
                          label: const Text("Rejeter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            _rejectVoyage(voyage, index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
         title:  Text(
        "Commands Trips",
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

        centerTitle: true,
      ),
      // appBar: AppBar(
      //   title: FadeIn(
      //     duration: const Duration(milliseconds: 800),
      //     child: const Text(
      //       'Commandes Trips',
      //       style: TextStyle(
      //         fontSize: 20.0,
      //         fontWeight: FontWeight.bold,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: primaryColor,
      //   elevation: 0,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       bottom: Radius.circular(16),
      //     ),
      //   ),
      //   toolbarHeight: 70,
      //   // actions: [
      //   //   BounceInRight(
      //   //     duration: const Duration(milliseconds: 1000),
      //   //     child: IconButton(
      //   //       icon: const Icon(Icons.notifications, size: 26),
      //   //       onPressed: () {},
      //   //       color: Colors.white,
      //   //     ),
      //   //   ),
      //   // ],
      // ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha(30),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeIn(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      'Chargement des voyages...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
            )
          : voyages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(40),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Icon(
                            Icons.airplanemode_active,
                            size: 70,
                            color: primaryColor.withAlpha(180),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          'Aucun voyage en attente',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          'Tous les voyages ont été traités',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Actualiser"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: fetchVoyages,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: fetchVoyages,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: FadeIn(
                            duration: const Duration(milliseconds: 800),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor.withAlpha(30), Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withAlpha(30),
                                    spreadRadius: 1,
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: primaryColor,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Vous avez ${voyages.length} ${voyages.length > 1 ? "voyages" : "voyage"} en attente de validation',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              
                                ],
                              ),
                            ),
                            
                          ),
                          
                        ),

                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: voyages.length,
                            itemBuilder: (context, index) {
                              return _buildVoyageCard(voyages[index], index);
                            },
                          ),
                        ),
                        ],
                      ),

                    ),

                  ),

//     bottomNavigationBar: Container(
//   decoration: BoxDecoration(
//     gradient: LinearGradient(
//       begin: Alignment.topCenter,
//       end: Alignment.bottomCenter,
//       colors: [
//         Colors.white.withOpacity(0.95),
//         Colors.white,
//       ],
//     ),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.grey.withOpacity(0.08),
//         blurRadius: 20,
//         offset: const Offset(0, -8),
//         spreadRadius: 0,
//       ),
//       BoxShadow(
//         color: primaryColor.withOpacity(0.05),
//         blurRadius: 40,
//         offset: const Offset(0, -2),
//         spreadRadius: -5,
//       ),
//     ],
//     borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//   ),
//   child: ClipRRect(
//     borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//     child: NavigationBar(
//       height: 85,
//       selectedIndex: _selectedIndex,
//       onDestinationSelected: (index) {
//         HapticFeedback.lightImpact(); // Add haptic feedback
//         setState(() => _selectedIndex = index);
//         _navigate(index);
//       },
//       backgroundColor: Colors.transparent,
//       indicatorColor: primaryColor.withOpacity(0.15),
//       indicatorShape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
//       animationDuration: const Duration(milliseconds: 400),
//       destinations: [
//         _buildAnimatedDestination(
//           index: 0,
//           selectedIcon: Icons.home_rounded,
//           unselectedIcon: Icons.home_outlined,
//           label: 'Home',
//         ),
//         _buildAnimatedDestination(
//           index: 1,
//           selectedIcon: Icons.people_rounded,
//           unselectedIcon: Icons.people_outline_rounded,
//           label: 'Users',
//         ),
//         _buildAnimatedDestination(
//           index: 2,
//           selectedIcon: Icons.bar_chart_rounded,
//           unselectedIcon: Icons.bar_chart_outlined,
//           label: 'Stats',
//         ),
//         _buildAnimatedDestination(
//           index: 3,
//           selectedIcon: Icons.person_rounded,
//           unselectedIcon: Icons.person_outline_rounded,
//           label: 'Profile',
//         ),
//       ],
//     ),
//   ),
// ),
bottomNavigationBar: buildBottomNavigationBar(),
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