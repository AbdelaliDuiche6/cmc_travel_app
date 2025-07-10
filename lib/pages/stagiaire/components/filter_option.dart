import 'package:flutter/material.dart';

import 'package:cmc_travel_app/constants.dart';

class FilterOption extends StatelessWidget {
  const FilterOption({super.key, required this.titleCategory, required this.isSelected, required this.onTap});

  final String titleCategory;
  final bool isSelected;
  final void Function() onTap;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: kDefaultPadding),
        height: 40,
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            titleCategory,
            style: TextStyle(
              color:isSelected ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
