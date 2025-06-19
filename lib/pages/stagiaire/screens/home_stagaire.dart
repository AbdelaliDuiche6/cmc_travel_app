import 'package:cmc_travel_app/pages/stagiaire/screens/travel_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../constants.dart';
import '../../../models/travel.dart';
import '../components/filter_option.dart';
import '../widgets/travel_card.dart';

class HomeStagaire extends StatefulWidget {
  const HomeStagaire({super.key});

  @override
  State<HomeStagaire> createState() => _HomeStagaireState();
}

class _HomeStagaireState extends State<HomeStagaire> {
  final supabase = Supabase.instance.client;
  List<Travel> travels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVoyages();
  }

  Future<void> fetchVoyages() async {
    final data = await supabase
        .from('Voyage')
        .select()
        .then((res) => res as List<dynamic>);

    setState(() {
      travels = data.map((item) => Travel.fromMap(item)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        buildSearchContainer(size),
        SizedBox(height: 30),
        SizedBox(
          height: 45,
          child: Padding(
            padding: const EdgeInsets.only(
              left: kDefaultPadding,
              right: kDefaultPadding,
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterOption(titleCategory: 'Hiking'),
                FilterOption(titleCategory: 'Beach'),
                FilterOption(titleCategory: 'Forrest'),
                FilterOption(titleCategory: 'Fishing'),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(kDefaultPadding),
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    )
                    : GridView.builder(
                      itemCount: travels.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3 / 4,
                          ),
                      itemBuilder: (context, index) {
                        return TravelCard(
                          size: size * 0.8,
                          travel: travels[index],
                          onPress:
                              () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TravelDetails(),
                                  ),
                                ),
                              },
                        );
                      },
                    ),
          ),
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
