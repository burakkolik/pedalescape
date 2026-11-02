/// 3D turntable preview of a bike (garage, home). STUB — being implemented.
library;

import 'package:flutter/material.dart';

import '../../catalog/bikes/bike_loadout.dart';

class BikeShowcase extends StatelessWidget {
  const BikeShowcase({
    super.key,
    required this.loadout,
    this.autoRotate = true,
    this.interactive = true,
    this.showRider = false,
  });

  final BikeLoadout loadout;
  final bool autoRotate;
  final bool interactive;
  final bool showRider;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
