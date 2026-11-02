/// Generates obstacle / coin / power-up patterns ahead of the rider.
///
/// Patterns are chosen by difficulty tier and density; every row always keeps
/// at least one escape route. Deterministic for a given seed.
library;

import 'dart:math' as math;

import '../../rendering/meshes/obstacles/obstacle_kind.dart';
import '../../rendering/meshes/obstacles/obstacle_library.dart';
import '../../rendering/meshes/pickups/power_up_kind.dart';
import '../../rendering/meshes/vehicles/vehicle_library.dart';
import '../../simulation/entities/obstacle.dart';
import '../../simulation/entities/pickup.dart';

class SpawnSettings {
  const SpawnSettings({
    required this.worldIndex,
    required this.density,
    required this.tier,
    required this.luck,
    this.obstacles = true,
    this.trafficPerKm = 0,
  });

  final int worldIndex;
  final double density; // 0..1
  final int tier; // 0..5
  final double luck; // power-up chance multiplier
  final bool obstacles;
  final double trafficPerKm;
}

class PatternSpawner {
  PatternSpawner(int seed, this.settings) : _rnd = math.Random(seed);

  final math.Random _rnd;
  SpawnSettings settings;

  /// Next z where a pattern starts.
  double nextZ = 60;

  /// Stop spawning obstacles after this z (finish line).
  double endZ = double.infinity;

  void spawnUntil(double zLimit, double speed, List<Obstacle> obstacles, List<Pickup> pickups) {
    while (nextZ < zLimit) {
      if (nextZ > endZ - 30) {
        nextZ = zLimit + 1;
        return;
      }
      final z = nextZ;
      final gap = _gap(speed);
      if (!settings.obstacles) {
        _coinsOnly(z, pickups);
        if (settings.trafficPerKm > 0 && _rnd.nextDouble() < settings.trafficPerKm * gap / 1000) {
          _traffic(z, obstacles, speed);
        }
        if (_rnd.nextDouble() < 0.06) _ramp(z + 20, obstacles, pickups);
        nextZ += gap;
        continue;
      }
      _pattern(z, obstacles, pickups);
      if (_rnd.nextDouble() < 0.035 * settings.luck) {
        pickups.add(Pickup(
          type: PickupType.powerUp,
          powerUp: PowerUpKind.values[_rnd.nextInt(PowerUpKind.values.length)],
          x: Obstacle.laneX(_rnd.nextInt(3) - 1),
          y: 1.0,
          z: z + gap * 0.5,
        ));
      } else if (_rnd.nextDouble() < 0.012 * settings.luck) {
        pickups.add(Pickup(type: PickupType.gem, x: Obstacle.laneX(_rnd.nextInt(3) - 1), y: 0.9, z: z + gap * 0.5));
      }
      nextZ += gap;
    }
  }

  double _gap(double speed) {
    final d = settings.density;
    final secs = 2.6 - 1.55 * d + _rnd.nextDouble() * 0.6;
    return math.max(14, speed * secs);
  }

  int _lane() => _rnd.nextInt(3) - 1;

  Obstacle _ob(ObstacleKind k, int lane, double z, {double v = 0}) {
    final w = settings.worldIndex;
    final mesh = k == ObstacleKind.vehicle
        ? VehicleLibrary.random(_rnd.nextInt(1 << 30), w)
        : ObstacleLibrary.mesh(k, w, _rnd.nextInt(math.max(1, ObstacleLibrary.variantCount(k, w))));
    return Obstacle(kind: k, lane: lane, z: z, mesh: mesh, velocity: v);
  }

  void _coinLine(int lane, double z0, int n, List<Pickup> out, {double spacing = 2.2}) {
    for (var i = 0; i < n; i++) {
      out.add(Pickup(type: PickupType.coin, x: Obstacle.laneX(lane), y: 0.8, z: z0 + i * spacing));
    }
  }

  void _coinArc(int lane, double zc, List<Pickup> out, {double h = 1.8}) {
    for (var i = -3; i <= 3; i++) {
      final t = i / 3.0;
      out.add(Pickup(type: PickupType.coin, x: Obstacle.laneX(lane), y: 0.8 + h * (1 - t * t), z: zc + i * 1.4));
    }
  }

  void _coinsOnly(double z, List<Pickup> out) {
    if (_rnd.nextDouble() < 0.6) _coinLine(_lane(), z, 6 + _rnd.nextInt(6), out, spacing: 3);
  }

  void _traffic(double z, List<Obstacle> out, double speed) {
    final lane = _lane();
    // same-direction slow traffic (relative speed negative)
    out.add(_ob(ObstacleKind.vehicle, lane, z + 40, v: speed * (0.35 + _rnd.nextDouble() * 0.25)));
  }

  void _ramp(double z, List<Obstacle> out, List<Pickup> pickups) {
    final lane = _lane();
    out.add(_ob(ObstacleKind.ramp, lane, z));
    for (var i = 0; i < 8; i++) {
      final t = i / 7;
      pickups.add(Pickup(type: PickupType.coin, x: Obstacle.laneX(lane), y: 1.5 + 2.6 * math.sin(t * math.pi), z: z + 3 + i * 2.2));
    }
  }

  void _pattern(double z, List<Obstacle> obs, List<Pickup> pk) {
    final tier = settings.tier;
    final roll = _rnd.nextDouble();
    final options = <int>[0, 1, 2, 3];
    if (tier >= 1) options.addAll([4, 5]);
    if (tier >= 2) options.addAll([6, 7]);
    if (tier >= 3) options.addAll([8, 9]);
    if (tier >= 4) options.add(10);
    final p = options[(roll * options.length).floor().clamp(0, options.length - 1)];
    switch (p) {
      case 0: // single hurdle + coin arc over it
        final l = _lane();
        obs.add(_ob(ObstacleKind.hurdle, l, z));
        _coinArc(l, z, pk);
      case 1: // two blocks, free lane with coins
        final free = _lane();
        for (final l in [-1, 0, 1]) {
          if (l != free) obs.add(_ob(ObstacleKind.block, l, z));
        }
        _coinLine(free, z - 6, 6, pk);
      case 2: // coin run
        _coinLine(_lane(), z, 10, pk);
      case 3: // ramp
        _ramp(z, obs, pk);
      case 4: // full hurdle row (must jump)
        for (final l in [-1, 0, 1]) {
          obs.add(_ob(ObstacleKind.hurdle, l, z));
        }
        _coinArc(_lane(), z, pk);
      case 5: // full low beam (must duck)
        for (final l in [-1, 0, 1]) {
          obs.add(_ob(ObstacleKind.lowBeam, l, z));
        }
        _coinLine(_lane(), z - 2, 3, pk, spacing: 1.5);
      case 6: // oncoming car
        final l = _lane();
        obs.add(_ob(ObstacleKind.vehicle, l, z + 70, v: -(6 + _rnd.nextDouble() * 6)));
        _coinLine(-l == 0 ? 1 : -l, z, 8, pk);
      case 7: // block + hurdle mix
        final b = _lane();
        final h = (b + 2) % 3 - 1;
        obs.add(_ob(ObstacleKind.block, b, z));
        obs.add(_ob(ObstacleKind.hurdle, h, z));
        _coinArc(h, z, pk);
      case 8: // zig-zag blocks
        var l = _lane();
        for (var i = 0; i < 3; i++) {
          obs.add(_ob(ObstacleKind.block, l, z + i * 9));
          l = (l + 2) % 3 - 1;
        }
      case 9: // beam then hurdle
        for (final l in [-1, 0, 1]) {
          obs.add(_ob(ObstacleKind.lowBeam, l, z));
        }
        final hl = _lane();
        obs.add(_ob(ObstacleKind.hurdle, hl, z + 12));
      case 10: // block wall + parked car + free lane
        final free = _lane();
        final others = [-1, 0, 1]..remove(free);
        obs.add(_ob(ObstacleKind.block, others[0], z));
        obs.add(_ob(ObstacleKind.vehicle, others[1], z + 2));
        obs.add(_ob(ObstacleKind.hurdle, free, z + 10));
        _coinLine(free, z - 4, 5, pk);
    }
  }
}
