/// Coins, gems and power-ups lying (or floating) on the track.
library;

import '../../rendering/meshes/pickups/power_up_kind.dart';

enum PickupType { coin, gem, powerUp }

class Pickup {
  Pickup({required this.type, required this.x, required this.y, required this.z, this.powerUp});

  final PickupType type;
  final PowerUpKind? powerUp;
  double x;
  double y;
  double z;
  bool collected = false;
  double collectT = 0; // animation after pickup
  bool magnetized = false;
}
