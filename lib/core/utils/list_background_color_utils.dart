import 'package:flutter/material.dart';

bool isLightListBackground(Color color) =>
    ThemeData.estimateBrightnessForColor(color) == Brightness.light;

Color listBackgroundTitleColor(Color background) =>
    isLightListBackground(background) ? Colors.black87 : Colors.white;

Color listBackgroundSubtitleColor(Color background) =>
    isLightListBackground(background) ? Colors.black54 : Colors.white70;

Color listBackgroundIconColor(Color background) =>
    isLightListBackground(background) ? Colors.black45 : Colors.white60;
