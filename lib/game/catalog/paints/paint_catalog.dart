/// Cosmetic paint jobs. Index 0 = factory colors of each bike.
library;

import 'dart:ui';

class PaintJob {
  const PaintJob({
    required this.index,
    required this.priceCoins,
    this.frameColor,
    this.accentColor,
  });

  /// 0-based; localized name key is `paintName{index + 1}`.
  final int index;
  final int priceCoins;

  /// Null = keep the bike's factory color.
  final Color? frameColor;
  final Color? accentColor;
}

abstract final class PaintCatalog {
  static const List<PaintJob> all = [
    PaintJob(index: 0, priceCoins: 0),
    PaintJob(index: 1, priceCoins: 1500, frameColor: Color(0xFFC0392B), accentColor: Color(0xFF2C3E50)),
    PaintJob(index: 2, priceCoins: 1500, frameColor: Color(0xFF0984E3), accentColor: Color(0xFFDFE6E9)),
    PaintJob(index: 3, priceCoins: 2500, frameColor: Color(0xFF7BED9F), accentColor: Color(0xFF2F3542)),
    PaintJob(index: 4, priceCoins: 4000, frameColor: Color(0xFFFF7A1A), accentColor: Color(0xFFFF4D6D)),
    PaintJob(index: 5, priceCoins: 6000, frameColor: Color(0xFF130F40), accentColor: Color(0xFF686DE0)),
    PaintJob(index: 6, priceCoins: 12000, frameColor: Color(0xFFF9CA24), accentColor: Color(0xFF6D214F)),
    PaintJob(index: 7, priceCoins: 20000, frameColor: Color(0xFFFD79A8), accentColor: Color(0xFF81ECEC)),
  ];
}
