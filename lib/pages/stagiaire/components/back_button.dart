import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    required this.backgroundColor,
    required this.onTap,
  });

  final Color backgroundColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 35, left: 20),
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(Icons.arrow_back_ios_new_rounded),
        iconSize: 18,
      ),
    );
  }
}
