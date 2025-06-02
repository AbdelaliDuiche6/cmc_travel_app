import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() => runApp(const StagiaireScreen());

class StagiaireScreen extends StatefulWidget {
  const StagiaireScreen({super.key});

  @override
  State<StagiaireScreen> createState() => _StagiaireScreenState();
}

class _StagiaireScreenState extends State<StagiaireScreen> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Travel> travels = [
    Travel("Jemaa el-Fnaa", "Marrakesh", "assets/images/logo.svg", 4.5),
    Travel("Marina", "Agadir", "assets/images/logo.svg", 4.5),
    Travel("Hassan II Mosque", "Casablanca", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: buildBottomNavigationBar(),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _searchField(),
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterOptions('Nature'),
                    _filterOptions('Hiking'),
                    _filterOptions('Fishing'),
                    _filterOptions('Trip'),
                  ],
                ),
              ),
              SizedBox(height: 100),
              Padding(
                padding: EdgeInsets.all(20),
                child: GridView.builder(
                  itemCount: travels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    return TravelCard(travel: travels[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _navigateBottomBar,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color.fromARGB(255, 26, 142, 234),
      selectedIconTheme: IconThemeData(
        color: Color.fromARGB(255, 26, 142, 234),
      ),
      elevation: 0.0,
      currentIndex: _selectedIndex,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/home.svg'),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/trips.svg'),
          label: 'My Trips',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/notification.svg'),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/profile.svg'),
          label: 'Profile',
        ),
      ],
    );
  }
}

class TravelCard extends StatelessWidget {
  final Travel travel;

  const TravelCard({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withAlpha(20),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SvgPicture.asset(
              travel.imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              travel.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  travel.location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  travel.rating.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
