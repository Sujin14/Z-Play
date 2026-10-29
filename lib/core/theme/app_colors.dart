import 'package:flutter/material.dart';

abstract final class AppColors {
  static const neon = Color(0xFF39FF5A);
  static const aqua = Color(0xFF19D3A0);
  static const lime = Color(0xFFC9F31D);
  static const onAccent = Color(0xFF04200E); // text/icons on green

  static const dBase = Color(0xFF031109);
  static const dMid = Color(0xFF072A1B);
  static const dEnd = Color(0xFF0A3D38);
  static const dText = Color(0xFFEAF7EE);
  static const dText2 = Color(0xFFA0BEAC);
  static const dCard = Color(0x0FFFFFFF); // white 6%
  static const dLine = Color(0x1AFFFFFF); // white 10%
  static const dChip = Color(0x2639FF5A); // neon 15%
  static const dGlass = Color(0xCC082015); // nav, mini player
  static const dSheet = Color(0xFF0A261B);
  static const dHeart = Color(0xFFFF7A93);

  static const lPrimary =
      Color(0xFF16C24A); // fills and icons; too light for text
  static const lBase = Color(0xFFF6FFF8);
  static const lMid = Color(0xFFD9F7E3);
  static const lEnd = Color(0xFFC7EFEA);
  static const lText = Color(0xFF0A2415);
  static const lText2 = Color(0xFF46624F);
  static const lAccentText = Color(0xFF076322); // green used as TEXT on light
  static const lCard = Color(0x9EFFFFFF);
  static const lLine = Color(0x1F084623);
  static const lChip = Color(0x2E16C24A);
  static const lGlass = Color(0xDBFFFFFF);
  static const lSheet = Color(0xFFF4FFF8);
  static const lHeart = Color(0xFFC72A4B);

  static const darkBg = LinearGradient(
    begin: Alignment(-0.3, -1),
    end: Alignment(0.3, 1),
    colors: [dBase, dMid, dEnd],
    stops: [0, .5, 1],
  );
  static const lightBg = LinearGradient(
    begin: Alignment(-0.3, -1),
    end: Alignment(0.3, 1),
    colors: [lBase, lMid, lEnd],
    stops: [0, .52, 1],
  );
  // Primary buttons, selected chips, play button, seek fill.
  static const action = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neon, aqua],
  );

  // Fallback tiles for songs without embedded art, picked from a stable hash
  // of the title so a song always keeps the same tile.
  static const covers = <List<Color>>[
    [Color(0xFF39FF5A), Color(0xFF0B6B3A)],
    [Color(0xFF19D3A0), Color(0xFF0A3A66)],
    [Color(0xFFC9F31D), Color(0xFF1E7A3A)],
    [Color(0xFF2BD9FF), Color(0xFF0B4A5A)],
    [Color(0xFF7CFFB2), Color(0xFF1A5C4A)],
    [Color(0xFFA8FF3E), Color(0xFF0D5C2B)],
    [Color(0xFF0FD9C0), Color(0xFF1B4D3E)],
    [Color(0xFF5DFF9A), Color(0xFF126B55)],
  ];
}
