import 'dart:ui';

/// Rider / bike color scheme that can be bought with coins.
class Skin {
  const Skin({
    required this.id,
    required this.name,
    required this.price,
    required this.frame,
    required this.jersey,
    required this.accent,
    required this.helmet,
    required this.shorts,
  });

  final String id;
  final String name;
  final int price;
  final Color frame;
  final Color jersey;
  final Color accent;
  final Color helmet;
  final Color shorts;
}

const List<Skin> kSkins = [
  Skin(
    id: 'classic',
    name: 'Klasik',
    price: 0,
    frame: Color(0xffe63946),
    jersey: Color(0xff1d9bf0),
    accent: Color(0xffffd23f),
    helmet: Color(0xffffffff),
    shorts: Color(0xff1a1c22),
  ),
  Skin(
    id: 'forest',
    name: 'Orman',
    price: 150,
    frame: Color(0xff2e7d32),
    jersey: Color(0xff66bb6a),
    accent: Color(0xfff1f8e9),
    helmet: Color(0xff1b5e20),
    shorts: Color(0xff263238),
  ),
  Skin(
    id: 'sunset',
    name: 'Gün Batımı',
    price: 300,
    frame: Color(0xffff7043),
    jersey: Color(0xffff4081),
    accent: Color(0xffffe082),
    helmet: Color(0xffffab40),
    shorts: Color(0xff3e2723),
  ),
  Skin(
    id: 'neon',
    name: 'Neon',
    price: 600,
    frame: Color(0xff00e5ff),
    jersey: Color(0xff212121),
    accent: Color(0xff76ff03),
    helmet: Color(0xff00e5ff),
    shorts: Color(0xff000000),
  ),
  Skin(
    id: 'royal',
    name: 'Kraliyet',
    price: 1000,
    frame: Color(0xffffd700),
    jersey: Color(0xff4a148c),
    accent: Color(0xffffd700),
    helmet: Color(0xff7c4dff),
    shorts: Color(0xff1a0033),
  ),
  Skin(
    id: 'ghost',
    name: 'Hayalet',
    price: 1800,
    frame: Color(0xffeceff1),
    jersey: Color(0xffb0bec5),
    accent: Color(0xff80deea),
    helmet: Color(0xffffffff),
    shorts: Color(0xff607d8b),
  ),
];

Skin skinById(String id) => kSkins.firstWhere((s) => s.id == id, orElse: () => kSkins.first);
