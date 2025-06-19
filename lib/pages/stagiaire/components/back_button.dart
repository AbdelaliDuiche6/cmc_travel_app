import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    required this.backgroundColor,
    required this.onTap,
    required this.margin,
  });

  final Color backgroundColor;
  final void Function() onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
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
