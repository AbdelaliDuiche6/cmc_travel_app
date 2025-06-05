import 'package:flutter/material.dart';

import 'package:cmc_travel_app/constants.dart';
import '../../../models/travel.dart';

class TravelCard extends StatelessWidget {
  const TravelCard({
    super.key,
    required this.size,
    required this.travel,
    required this.onPress,
  });

  final Size size;
  final Travel travel;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // margin: EdgeInsets.only(left: kDefaultPadding),
      // width: size.width * 0.7,
      child: Column(
        children: [
          Image.asset(travel.imagePath),
          GestureDetector(
            onTap: onPress,
            child: Container(
              padding: EdgeInsets.all(kDefaultPadding / 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 50,
                    color: kPrimaryColor.withAlpha(100),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${travel.name}\n".toUpperCase(),
                            style: TextStyle(
                              color: Colors.black,
                              // overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: travel.location.toUpperCase(),
                            style: TextStyle(
                              color: kPrimaryColor.withAlpha(150),
                              overflow: TextOverflow.ellipsis,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.star_rounded, color: Colors.yellow),
                  Text(
                    '${travel.rating}',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(color: kPrimaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
