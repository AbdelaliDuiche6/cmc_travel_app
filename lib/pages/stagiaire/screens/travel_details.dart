import 'package:flutter/material.dart';

import 'package:cmc_travel_app/constants.dart';

import '../components/back_button.dart';

class TravelDetails extends StatelessWidget {
  const TravelDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/travel.png'),
                  ),
                  CustomBackButton(
                    backgroundColor: Colors.white,
                    onTap: () => {Navigator.of(context).pop()},
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _travelInfo('via', 'CMC'),
                    _travelInfo('type', 'Fishing'),
                    _travelInfo('rating', '4.5'),
                    _travelInfo('seats', '40'),
                  ],
                ),
              ),
              Divider(
                color: Colors.black.withAlpha(70),
                thickness: 1.5,
                indent: 40,
                endIndent: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: kDefaultPadding),
                child: Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: kDefaultPadding / 2,
                  left: kDefaultPadding,
                  right: kDefaultPadding,
                ),
                child: Text(
                  'this is a description of the travelsdkvsfgnbotinb dp fdgrmdpievm nfeirgpgmmbmtoiunbvmkdfvlmeituyhjldmbnoognbitnkbmbbntoiprevmd;fmdbitrbniroreppbm botir', // textAlign: TextAlign.start,
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: kDefaultPadding / 2,
                      left: kDefaultPadding,
                    ),
                    child: Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      // textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(
                      top: kDefaultPadding / 2,
                      left: kDefaultPadding,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withAlpha(70),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '15 Dec - 20 Dec 2025',
                      style: TextStyle(color: Colors.black.withAlpha(150)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: r'$59/',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        TextSpan(
                          text: 'Person',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withAlpha(90),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => {},
                    style: TextButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 1.5,
                        vertical: kDefaultPadding / 2,
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _travelInfo(String label, String content) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.black.withAlpha(70),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
