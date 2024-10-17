import 'package:flutter/material.dart';
import 'customcolors.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onpressed;
  final String content;

  const CustomElevatedButton({
    super.key,
    required this.onpressed,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(230, 100),
        backgroundColor: CustomColors.buttoncolor,
      ),
      child: Text(
        content,
        style: const TextStyle(
          color: CustomColors.themecolor,
          fontSize: 20,
        ),
      ),
    );
  }
}
