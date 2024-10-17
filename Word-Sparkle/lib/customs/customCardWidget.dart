import 'package:flutter/material.dart';
import 'CustomColors.dart';

class CustomCardWidget extends StatelessWidget {
  final String text;
  final TextStyle style;

  CustomCardWidget({required this.text, this.style = const TextStyle()});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(color: CustomColors.themecolor),
    );
  }
}
