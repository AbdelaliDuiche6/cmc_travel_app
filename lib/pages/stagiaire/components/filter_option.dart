import 'package:flutter/material.dart';

import 'package:cmc_travel_app/constants.dart';

class FilterOption extends StatelessWidget {
  const FilterOption({super.key, required this.titleCategory});

  final String titleCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: kDefaultPadding),
      height: 45,
      width: 100,
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          titleCategory,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
