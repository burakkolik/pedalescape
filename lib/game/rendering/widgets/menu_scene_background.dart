/// Animated full-screen 3D scene behind menus. STUB — being implemented.
library;

import 'package:flutter/material.dart';

import '../../catalog/bikes/bike_loadout.dart';

class MenuSceneBackground extends StatelessWidget {
  const MenuSceneBackground({super.key, this.worldIndex = 0, this.loadout});

  final int worldIndex;
  final BikeLoadout? loadout;

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: Color(0xFF1B1440), child: SizedBox.expand());
}
