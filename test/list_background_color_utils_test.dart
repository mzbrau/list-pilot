import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/core/utils/list_background_color_utils.dart';

void main() {
  group('listBackgroundTitleColor', () {
    test('returns dark text for light backgrounds', () {
      const lightBlue = Color(0xFFBBDEFB);
      expect(listBackgroundTitleColor(lightBlue), Colors.black87);
    });

    test('returns light text for dark backgrounds', () {
      const darkBlue = Color(0xFF1976D2);
      expect(listBackgroundTitleColor(darkBlue), Colors.white);
    });
  });

  group('listBackgroundSubtitleColor', () {
    test('returns dark subtitle for light backgrounds', () {
      const lightBlue = Color(0xFFBBDEFB);
      expect(listBackgroundSubtitleColor(lightBlue), Colors.black54);
    });

    test('returns light subtitle for dark backgrounds', () {
      const darkBlue = Color(0xFF1976D2);
      expect(listBackgroundSubtitleColor(darkBlue), Colors.white70);
    });
  });

  group('listBackgroundIconColor', () {
    test('returns dark icon for light backgrounds', () {
      const lightBlue = Color(0xFFBBDEFB);
      expect(listBackgroundIconColor(lightBlue), Colors.black45);
    });

    test('returns light icon for dark backgrounds', () {
      const darkBlue = Color(0xFF1976D2);
      expect(listBackgroundIconColor(darkBlue), Colors.white60);
    });
  });
}
