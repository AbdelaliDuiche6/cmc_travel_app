import 'package:cmc_travel_app/pages/stagiaire/screens/home_stagaire.dart';
import 'package:cmc_travel_app/pages/stagiaire/screens/notifications_stagiare.dart';
import 'package:cmc_travel_app/pages/stagiaire/screens/profile_stagiaire.dart';
import 'package:cmc_travel_app/pages/stagiaire/screens/trips_stagiaire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cmc_travel_app/constants.dart';
import '../../models/travel.dart';

void main() => runApp(
  MaterialApp(debugShowCheckedModeBanner: false, home: TraineeScreen()),
);

class TraineeScreen extends StatefulWidget {
  const TraineeScreen({super.key});
  @override
  State<TraineeScreen> createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Travel> travels = [
    Travel("Jemaa el-Fnaa", "Marrakesh", "assets/images/gmail.svg", 4.5),
    Travel("Marina", "Agadir", "assets/images/gmail.svg", 4.5),
    Travel("Hassan II Mosque", "Casablanca", "assets/images/gmail.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/gmail.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/gmail.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/gmail.svg", 4.5),
  ];

  final screens = [
    HomeStagaire(),
    TripsStagiaire(),
    NotificationsStagiare(),
    ProfileStagiaire(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      bottomNavigationBar: buildBottomNavigationBar(),
      body: screens.elementAt(_selectedIndex),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _navigateBottomBar,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      selectedIconTheme: IconThemeData(color: kPrimaryColor),
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

  Container buildSearchContainer(Size size) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        left: kDefaultPadding / 3,
        right: kDefaultPadding / 2,
      ),
      margin: EdgeInsets.only(left: kDefaultPadding, right: kDefaultPadding),
      height: 50,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.black12.withAlpha(10),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                filled: false,
                focusedBorder: InputBorder.none,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(15),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset('assets/icons/Search.svg'),
                ),
                suffixIcon: VerticalDivider(
                  indent: 12,
                  endIndent: 12,
                  color: Colors.black12.withAlpha(30),
                  thickness: 2.0,
                ),
                hintText: 'Search Places',
                hintStyle: TextStyle(
                  color: Colors.black.withAlpha(60),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => {},
            child: Text(
              'Search',
              style: TextStyle(color: Colors.black.withAlpha(90), fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}
