import 'package:flutter/material.dart';
import '../customs/customcolors.dart';

InputDecoration customInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: CustomColors.hintText),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: CustomColors.errorcolor),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: CustomColors.errorcolor),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: CustomColors.errorcolor),
    ),
    focusedErrorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: CustomColors.errorcolor),
    ),
    errorStyle: const TextStyle(color: CustomColors.errorcolor),
  );
}
