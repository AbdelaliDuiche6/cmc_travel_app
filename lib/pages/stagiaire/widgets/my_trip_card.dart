import 'package:flutter/material.dart';

import 'package:cmc_travel_app/constants.dart';

class MyTripCard extends StatelessWidget {
  MyTripCard({
    super.key,
    required this.title,
    required this.date,
    required this.type,
    required this.organizer,
    required this.price,
    required this.imageUrl,
    required this.status,
  });

  String title;
  DateTime date;
  String type;
  String organizer;
  String price;
  String imageUrl;
  String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      elevation: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imageUrl, height: 190, width: 180),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    letterSpacing: 1,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  spacing: 7,
                  children: [
                    Icon(Icons.location_on_outlined, size: 15),
                    Text(type),
                  ],
                ),
                Row(
                  spacing: 7,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 15),
                    Text('Date :'),
                    Text(date.toString()),
                  ],
                ),
                Row(
                  spacing: 7,
                  children: [
                    Icon(Icons.person_outlined, size: 18),
                    Text('Organizer :'),
                    Text(organizer),
                  ],
                ),
                Row(
                  spacing: 7,
                  children: [
                    Icon(Icons.attach_money_rounded, size: 18),
                    Text('Paid :'),
                    Text(price),
                  ],
                ),
                Row(
                  spacing: 7,
                  children: [Text('Status :'), Text(status)],
                ),

                // The row for showing actions buttons based on each reservation status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding / 3,
                          vertical: kDefaultPadding / 3,
                        ),
                      ),
                      child: Text(
                        'Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding / 3,
                          vertical: kDefaultPadding / 3,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
