import 'package:flutter/material.dart';

EdgeInsets keyboardAwareSheetPadding(BuildContext context) {
  return EdgeInsets.fromLTRB(
    16,
    8,
    16,
    16 + MediaQuery.viewInsetsOf(context).bottom,
  );
}
