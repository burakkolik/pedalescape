/// The heart of a run: advances physics, spawns patterns and scenery,
/// resolves collisions, power-ups, the chasing storm, combos and rewards.
///
/// Pure Dart (no Flutter widgets) so it is unit-testable; the painter only
/// reads its state and the screen forwards input.
library;

import 'dart:math' as math;

import '../../engine/math/easing.dart';
import '../catalog/bikes/bike_loadout.dart';
import '../catalog/levels/level_spec.dart';
import '../economy/economy_rules.dart';
import '../rendering/meshes/obstacles/obstacle_kind.dart';
import '../rendering/meshes/pickups/power_up_kind.dart';
import '../rendering/meshes/scenery/scenery_library.dart';
import '../rendering/meshes/scenery/scenery_prop.dart';
import '../session/game_mode.dart';
import '../session/run_config.dart';
import '../session/run_result.dart';
import '../world/spawning/pattern_spawner.dart';
import '../world/track/track_profile.dart';
import 'entities/obstacle.dart';
import 'entities/particle.dart';
import 'entities/pickup.dart';
import 'entities/rider_state.dart';
import 'entities/scenery_instance.dart';
import 'game_event.dart';
import 'power_up_state.dart';
import 'run_phase.dart';
import 'swipe_action.dart';

class GameSession {
  GameSession(this.config)
      : loadout = config.loadout,
        level = config.level,
        _rnd = math.Random(config.level?.seed ?? DateTime.now().millisecondsSinceEpoch) {
    final seed = config.level?.seed ?? _rnd.nextInt(1 << 30);
    track = TrackProfile(
      seed: seed,
      curviness: level?.curviness ?? 0.7,
      hilliness: level?.hilliness ?? 0.5,
    );
    spawner = PatternSpawner(seed + 1, _spawnSettings(0));
    if (level != null) spawner.endZ = level!.lengthMeters;
    _scenery = SceneryLibrary.forWorld(config.worldIndex);
    rider.armor = loadout.armorPoints;
    rider.speed = 0;
    timeOfDay = switch (config.mode) {
      GameMode.mission => (level?.timeOfDay ?? TimeOfDay.noon).index.toDouble(),
      GameMode.freeRide => config.freeRide.timeOfDay.index.toDouble(),
      GameMode.endless => 1,
    };
    weather = switch (config.mode) {
      GameMode.mission => level?.weather ?? Weather.clear,
      GameMode.freeRide => config.freeRide.weather,
      GameMode.endless => Weather.clear,
    };
    _spawnScenery(260);
  }

  final RunConfig config;
  final BikeLoadout loadout;
  final LevelSpec? level;
  final math.Random _rnd;

  late final TrackProfile track;
  late final PatternSpawner spawner;
  late final List<SceneryProp> _scenery;

  final RiderState rider = RiderState();
  final List<Obstacle> obstacles = [];
  final List<Pickup> pickups = [];
  final List<SceneryInstance> scenery = [];
  final List<Particle> particles = [];
  final PowerUpState powerUps = PowerUpState();
  final List<GameEvent> _events = [];

  RunPhase phase = RunPhase.countdown;
  double countdown = 3.2;
  double time = 0;
  double coinsExact = 0;
  int gems = 0;
  int crashes = 0;
  int jumps = 0;
  int ducks = 0;
  int nearMisses = 0;
  int powerUpsUsed = 0;
  int comboCount = 0;
  int bestCombo = 1;
  double comboTimer = 0;
  int revives = 0;

  /// Storm distance behind the rider (m). Smaller = more danger.
  double stormGap = 30;
  double lastStumbleTime = -100;
  double lightningFlash = 0;
  double shake = 0;

  /// 0..4 continuous (morning, noon, sunset, night, → morning).
  double timeOfDay = 1;
  Weather weather = Weather.clear;

  double _sceneryNextZ = -10;
  double _lastCheckpoint = 0;

  // ------------------------------------------------------------- getters --
  int get coins => coinsExact.floor();
  int get combo => (1 + comboCount ~/ 3).clamp(1, 10);
  bool get hasStorm => config.mode != GameMode.freeRide;
  double get distance => rider.z;
  double get lengthMeters => level?.lengthMeters ?? double.infinity;
  double get progress => level == null ? 0 : (rider.z / level!.lengthMeters).clamp(0.0, 1.0);
  int get worldIndex => config.worldIndex;
  double get checkpointZ => _lastCheckpoint;

  List<GameEvent> drainEvents() {
    final list = List<GameEvent>.of(_events);
    _events.clear();
    return list;
  }

  SpawnSettings _spawnSettings(double z) {
    final luck = loadout.luckMultiplier;
    switch (config.mode) {
      case GameMode.mission:
        return SpawnSettings(
          worldIndex: config.worldIndex,
          density: level!.obstacleDensity,
          tier: level!.unlockedObstacleTier,
          luck: luck,
        );
      case GameMode.endless:
        final km = z / 1000;
        return SpawnSettings(
          worldIndex: config.worldIndex,
          density: (0.25 + km * 0.06).clamp(0.25, 0.95),
          tier: (km * 0.8).floor().clamp(0, 5),
          luck: luck,
        );
      case GameMode.freeRide:
        return SpawnSettings(
          worldIndex: config.worldIndex,
          density: 0.2,
          tier: 0,
          luck: luck,
          obstacles: false,
          trafficPerKm: switch (config.freeRide.traffic) {
            TrafficLevel.none => 0,
            TrafficLevel.light => 6,
            TrafficLevel.heavy => 16,
          },
        );
    }
  }

  // -------------------------------------------------------------- speed --
  double _targetSpeed() {
    final mul = loadout.speedMultiplier;
    double base;
    switch (config.mode) {
      case GameMode.mission:
        final t = progress;
        base = Easing.lerp(level!.startSpeed, level!.maxSpeed, math.sqrt(t));
      case GameMode.endless:
        base = 12 + 22 * (1 - math.exp(-rider.z / 9000));
      case GameMode.freeRide:
        base = 13;
    }
    var s = base * mul;
    if (powerUps.isActive(PowerUpKind.turbo)) s *= 1.55;
    return s;
  }

  // ------------------------------------------------------------- input --
  void input(SwipeAction a) {
    if (phase != RunPhase.running || rider.crashed) return;
    switch (a) {
      case SwipeAction.left:
        _changeLane(-1);
      case SwipeAction.right:
        _changeLane(1);
      case SwipeAction.up:
        if (rider.grounded) {
          rider.vy = math.sqrt(2 * _gravity * loadout.jumpHeight);
          rider.duckTimer = 0;
          _events.add(const GameEvent(GameEventType.jump));
        }
      case SwipeAction.down:
        if (!rider.grounded) rider.vy = -14; // slam down
        rider.duckTimer = 0.85;
        _events.add(const GameEvent(GameEventType.duck));
    }
  }

  void _changeLane(int dir) {
    final target = (rider.lane + dir).clamp(-1, 1);
    if (target == rider.lane) return;
    rider.previousLane = rider.lane;
    rider.lane = target;
    _events.add(const GameEvent(GameEventType.laneSwitch));
  }

  static const double _gravity = 26;

  // ------------------------------------------------------------- update --
  void update(double dtRaw) {
    final dt = dtRaw.clamp(0.0, 1 / 20);
    _updateParticles(dt);
    lightningFlash = math.max(0, lightningFlash - dt * 3);
    shake = math.max(0, shake - dt * 2.5);
    track.update(rider.z - 4.6, dt, rider.speed);

    if (phase == RunPhase.countdown) {
      countdown -= dt;
      if (countdown <= 0) phase = RunPhase.running;
      return;
    }
    if (phase == RunPhase.crashed) {
      rider.crashT += dt;
      rider.speed = Easing.approach(rider.speed, 0, 3, dt);
      rider.z += rider.speed * dt;
      return;
    }
    if (phase == RunPhase.finished) {
      rider.speed = Easing.approach(rider.speed, 0, 1.2, dt);
      rider.z += rider.speed * dt;
      _advanceAnimation(dt);
      return;
    }

    time += dt;
    if (config.mode == GameMode.freeRide && config.freeRide.dayNightCycle) {
      timeOfDay = (timeOfDay + dt / 120) % 4;
    }
    powerUps.tick(dt);
    rider.invulnerableTimer = math.max(0, rider.invulnerableTimer - dt);
    rider.stumbleTimer = math.max(0, rider.stumbleTimer - dt);
    if (rider.grounded) rider.duckTimer = math.max(0, rider.duckTimer - dt);

    // speed
    rider.targetSpeed = _targetSpeed();
    final accel = loadout.accelerationPerSecond * (powerUps.isActive(PowerUpKind.turbo) ? 2 : 1);
    if (rider.speed < rider.targetSpeed) {
      rider.speed = math.min(rider.targetSpeed, rider.speed + accel * dt);
    } else {
      rider.speed = math.max(rider.targetSpeed, rider.speed - 6 * dt);
    }
    rider.z += rider.speed * dt;

    // lateral
    final tx = Obstacle.laneX(rider.lane);
    final latSpeed = Obstacle.laneWidth / loadout.laneSwitchSeconds;
    final dx = tx - rider.x;
    final step = latSpeed * dt;
    rider.x = dx.abs() <= step ? tx : rider.x + step * dx.sign;
    rider.lean = Easing.approach(rider.lean, -dx.sign * math.min(1, dx.abs()) * 0.35, 12, dt);

    // vertical
    if (!rider.grounded || rider.vy > 0) {
      rider.vy -= _gravity * dt;
      rider.y += rider.vy * dt;
      if (rider.y <= 0) {
        rider.y = 0;
        rider.vy = 0;
        _events.add(const GameEvent(GameEventType.land));
        _dust(8);
      }
    }
    rider.airPitch = Easing.approach(rider.airPitch, rider.grounded ? 0 : -rider.vy * 0.02, 8, dt);
    _advanceAnimation(dt);

    // storm
    if (hasStorm) {
      stormGap = math.min(30, stormGap + 2.4 * dt);
      if (_rnd.nextDouble() < dt * 0.12) {
        lightningFlash = 1;
        _events.add(const GameEvent(GameEventType.thunder));
      }
    }

    // combo decay
    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) comboCount = 0;
    }

    // spawning
    spawner.settings = _spawnSettings(rider.z);
    spawner.spawnUntil(rider.z + 230, rider.speed, obstacles, pickups);
    _spawnScenery(rider.z + 260);

    _updateObstacles(dt);
    _updatePickups(dt);
    _cleanup();

    // checkpoints & finish
    if (level != null) {
      final cp = (rider.z / LevelSpec.checkpointSpacing).floor() * LevelSpec.checkpointSpacing;
      if (cp > _lastCheckpoint && cp < level!.lengthMeters) {
        _lastCheckpoint = cp;
        _events.add(const GameEvent(GameEventType.checkpoint));
      }
      if (rider.z >= level!.lengthMeters) {
        phase = RunPhase.finished;
        _events.add(const GameEvent(GameEventType.finish));
        _confetti();
      }
    }

    // trail particles
    if (loadout.bike.style.trailColor != null || powerUps.isActive(PowerUpKind.turbo)) {
      final c = powerUps.isActive(PowerUpKind.turbo)
          ? 0xFFFF8A1F
          : loadout.bike.style.trailColor!.toARGB32();
      for (var i = 0; i < 2; i++) {
        particles.add(Particle(
          rider.x + (_rnd.nextDouble() - 0.5) * 0.3, rider.y + 0.3 + _rnd.nextDouble() * 0.3,
          rider.z - 0.6, (_rnd.nextDouble() - 0.5), _rnd.nextDouble(), -rider.speed * 0.15,
          0.45, c, 0.12, emissive: true));
      }
    }
    if (rider.grounded && _rnd.nextDouble() < rider.speed * dt * 0.6) _dust(1);
  }

  void _advanceAnimation(double dt) {
    final wr = loadout.bike.style.wheelRadius;
    rider.wheelAngle += rider.speed * dt / wr;
    // gear ratio ~2.6 wheel turns per crank turn
    rider.crankAngle += rider.speed * dt / wr / 2.6 * (rider.grounded ? 1 : 0.3);
  }

  // ---------------------------------------------------------- obstacles --
  void _updateObstacles(double dt) {
    for (final o in obstacles) {
      if (o.velocity != 0) o.z += o.velocity * dt;
      if (o.smashed) o.smashT += dt;
      if (o.resolved) continue;
      final dz = o.z - rider.z;
      final lat = (o.x - rider.x).abs();
      final zOverlap = dz.abs() < o.halfDepth + 0.45;

      if (o.kind == ObstacleKind.ramp) {
        if (zOverlap && lat < 1.0 && rider.grounded && dz < 0.5) {
          rider.vy = math.sqrt(2 * _gravity * (loadout.jumpHeight + 2.2));
          o.resolved = true;
          jumps++;
          _events.add(const GameEvent(GameEventType.jump));
        } else if (dz < -o.halfDepth - 1) {
          o.resolved = true;
        }
        continue;
      }

      if (zOverlap && lat < 1.15) {
        final hit = switch (o.kind) {
          ObstacleKind.hurdle => rider.y < 0.72,
          ObstacleKind.lowBeam => !rider.ducking,
          ObstacleKind.block => rider.y < 1.85,
          ObstacleKind.vehicle => rider.y < 1.5,
          ObstacleKind.ramp => false,
        };
        if (hit) {
          _hit(o);
          continue;
        }
      }
      // passed?
      if (dz < -(o.halfDepth + 0.6)) {
        o.resolved = true;
        if (lat < 1.15) {
          if (o.kind == ObstacleKind.hurdle) {
            jumps++;
            if (rider.y < 1.35 || jumpsCleanPerfect(o)) {
              _bumpCombo(GameEventType.perfectJump);
            }
          } else if (o.kind == ObstacleKind.lowBeam) {
            ducks++;
            _bumpCombo(GameEventType.comboUp);
          }
        } else if (lat < 2.9 && (o.kind == ObstacleKind.block || o.kind == ObstacleKind.vehicle)) {
          nearMisses++;
          _bumpCombo(GameEventType.nearMiss);
        }
      }
    }
  }

  bool jumpsCleanPerfect(Obstacle o) => false;

  void _bumpCombo(GameEventType t) {
    comboCount++;
    comboTimer = 5;
    bestCombo = math.max(bestCombo, combo);
    _events.add(GameEvent(t, value: combo));
  }

  void _hit(Obstacle o) {
    o.resolved = true;
    if (powerUps.isActive(PowerUpKind.ghost)) return;
    if (powerUps.isActive(PowerUpKind.turbo) || rider.invulnerableTimer > 0) {
      _smash(o);
      return;
    }
    if (powerUps.isActive(PowerUpKind.shield)) {
      powerUps.remaining[PowerUpKind.shield] = 0;
      _smash(o);
      rider.invulnerableTimer = 1;
      _events.add(const GameEvent(GameEventType.shieldHit));
      return;
    }
    if (config.mode == GameMode.freeRide) {
      _smash(o);
      _stumble(canCatch: false);
      return;
    }
    if (o.kind == ObstacleKind.hurdle) {
      _smash(o);
      _stumble();
      return;
    }
    if (rider.armor > 0) {
      rider.armor--;
      _smash(o);
      _stumble();
      return;
    }
    _crash();
  }

  void _smash(Obstacle o) {
    o.smashed = true;
    shake = 0.6;
    for (var i = 0; i < 18; i++) {
      particles.add(Particle(
        o.x + (_rnd.nextDouble() - 0.5) * 1.6, 0.4 + _rnd.nextDouble(), o.z,
        (_rnd.nextDouble() - 0.5) * 8, 3 + _rnd.nextDouble() * 6, rider.speed * 0.6 + _rnd.nextDouble() * 4,
        0.9, 0xFFFFC530, 0.14, gravity: 18, emissive: true));
    }
  }

  void _stumble({bool canCatch = true}) {
    rider.speed *= 1 - loadout.stumbleSlowdown;
    rider.stumbleTimer = 0.9;
    rider.invulnerableTimer = 1.2;
    shake = 1;
    comboCount = 0;
    if (hasStorm && canCatch) {
      if (time - lastStumbleTime < 7 && stormGap < 16) {
        lastStumbleTime = time;
        _crash();
        return;
      }
      lastStumbleTime = time;
      stormGap = 5;
      _events.add(const GameEvent(GameEventType.stormClose));
    }
    _events.add(const GameEvent(GameEventType.stumble));
  }

  void _crash() {
    crashes++;
    rider.crashed = true;
    rider.crashT = 0;
    phase = RunPhase.crashed;
    shake = 1.5;
    _events.add(const GameEvent(GameEventType.crash));
    for (var i = 0; i < 30; i++) {
      particles.add(Particle(
        rider.x, 0.6, rider.z, (_rnd.nextDouble() - 0.5) * 6, 2 + _rnd.nextDouble() * 5,
        rider.speed * 0.3 + _rnd.nextDouble() * 3, 1.1, 0xFFB0A080, 0.12, gravity: 14));
    }
  }

  /// Continue right where the crash happened (gems already paid).
  void revive() {
    revives++;
    _resume();
    // clear nearby obstacles
    obstacles.removeWhere((o) => (o.z - rider.z).abs() < 40);
  }

  /// Gem cost of the next revive.
  int get reviveCost => EconomyRules.reviveCost(revives);

  /// Free restart from the last checkpoint (mission only).
  void restartFromCheckpoint() {
    rider.z = _lastCheckpoint;
    obstacles.clear();
    pickups.clear();
    scenery.clear();
    _sceneryNextZ = rider.z - 10;
    spawner.nextZ = rider.z + 50;
    _spawnScenery(rider.z + 260);
    rider.speed = 0;
    _resume();
    phase = RunPhase.countdown;
    countdown = 2.2;
  }

  void _resume() {
    rider.crashed = false;
    rider.y = 0;
    rider.vy = 0;
    rider.invulnerableTimer = 2.5;
    rider.armor = loadout.armorPoints;
    stormGap = 30;
    lastStumbleTime = -100;
    phase = RunPhase.running;
    rider.speed = math.max(rider.speed, 8);
  }

  // ------------------------------------------------------------ pickups --
  void _updatePickups(double dt) {
    final magnet = powerUps.isActive(PowerUpKind.magnet) || powerUps.isActive(PowerUpKind.turbo);
    final ry = rider.y + 0.9;
    for (final p in pickups) {
      if (p.collected) {
        p.collectT += dt;
        continue;
      }
      final dz = p.z - rider.z;
      if (magnet && p.type == PickupType.coin && dz < 14 && dz > -2) p.magnetized = true;
      if (p.magnetized) {
        final k = math.min(1.0, dt * 12);
        p.x += (rider.x - p.x) * k;
        p.y += (ry - p.y) * k;
        p.z += (rider.z + 0.3 - p.z) * k;
      }
      if ((p.z - rider.z).abs() < 0.9 && (p.x - rider.x).abs() < 0.95 && (p.y - ry).abs() < 1.2) {
        p.collected = true;
        _collect(p);
      }
    }
  }

  void _collect(Pickup p) {
    switch (p.type) {
      case PickupType.coin:
        var v = loadout.coinMultiplier;
        if (powerUps.isActive(PowerUpKind.doubleCoins)) v *= 2;
        if (config.mode == GameMode.freeRide) v *= EconomyRules.freeRideCoinFactor;
        coinsExact += v;
        _events.add(const GameEvent(GameEventType.coin));
      case PickupType.gem:
        gems++;
        _events.add(const GameEvent(GameEventType.gem));
      case PickupType.powerUp:
        final k = p.powerUp!;
        powerUpsUsed++;
        powerUps.activate(k, switch (k) {
          PowerUpKind.magnet => loadout.magnetSeconds,
          PowerUpKind.shield => loadout.shieldSeconds,
          PowerUpKind.turbo => loadout.turboSeconds,
          PowerUpKind.doubleCoins => loadout.doubleCoinsSeconds,
          PowerUpKind.ghost => 6,
        });
        _events.add(GameEvent(GameEventType.powerUp, value: k.index));
    }
    for (var i = 0; i < 5; i++) {
      particles.add(Particle(p.x, p.y, p.z, (_rnd.nextDouble() - 0.5) * 3, _rnd.nextDouble() * 3,
          rider.speed * 0.9, 0.35, p.type == PickupType.coin ? 0xFFFFE27A : 0xFF7DF9FF, 0.07,
          emissive: true));
    }
  }

  // ------------------------------------------------------------ scenery --
  void _spawnScenery(double until) {
    if (_scenery.isEmpty) return;
    final quality = switch (config.settings.graphics) {
      GraphicsQuality.low => 0.5,
      GraphicsQuality.medium => 0.8,
      GraphicsQuality.high => 1.0,
    };
    final totalW = _scenery.fold<double>(0, (a, p) => a + p.weight);
    while (_sceneryNextZ < until) {
      for (final side in [-1.0, 1.0]) {
        if (_rnd.nextDouble() > 0.85 * quality) continue;
        var pick = _rnd.nextDouble() * totalW;
        var prop = _scenery.first;
        for (final p in _scenery) {
          pick -= p.weight;
          if (pick <= 0) {
            prop = p;
            break;
          }
        }
        if (!prop.bothSides && side < 0 && _rnd.nextBool()) continue;
        final off = prop.minOffset + _rnd.nextDouble() * (prop.maxOffset - prop.minOffset);
        scenery.add(SceneryInstance(
          prop.mesh,
          side * (_roadHalf + off),
          _sceneryNextZ + _rnd.nextDouble() * 4,
          _rnd.nextDouble() * math.pi * 2,
          0.85 + _rnd.nextDouble() * 0.35,
        ));
      }
      _sceneryNextZ += 7.5 + _rnd.nextDouble() * 5;
    }
  }

  static const double _roadHalf = 4.6;

  // ---------------------------------------------------------- particles --
  void _dust(int n) {
    for (var i = 0; i < n; i++) {
      particles.add(Particle(
        rider.x + (_rnd.nextDouble() - 0.5) * 0.3, 0.05, rider.z - 0.5,
        (_rnd.nextDouble() - 0.5) * 1.5, 0.5 + _rnd.nextDouble(), rider.speed * 0.5,
        0.6, 0x99D8C8A8, 0.1, gravity: 1));
    }
  }

  void _confetti() {
    const colors = [0xFFFF4D6D, 0xFFFFD23F, 0xFF16C2B0, 0xFF3DE0FF, 0xFFFF7A1A, 0xFFB388FF];
    for (var i = 0; i < 120; i++) {
      particles.add(Particle(
        (_rnd.nextDouble() - 0.5) * 8, 3 + _rnd.nextDouble() * 3, rider.z + 6 + _rnd.nextDouble() * 6,
        (_rnd.nextDouble() - 0.5) * 6, _rnd.nextDouble() * 4, (_rnd.nextDouble() - 0.5) * 4,
        2.6, colors[i % colors.length], 0.1, gravity: 4, emissive: true));
    }
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.age += dt;
      p.vy -= p.gravity * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.z += p.vz * dt;
      if (p.y < 0) {
        p.y = 0;
        p.vy *= -0.3;
      }
    }
    particles.removeWhere((p) => p.dead);
    if (particles.length > 600) particles.removeRange(0, particles.length - 600);
  }

  void _cleanup() {
    final behind = rider.z - 8;
    obstacles.removeWhere((o) => o.z + 5 < behind || o.z > rider.z + 400);
    pickups.removeWhere((p) => p.z < behind || (p.collected && p.collectT > 0.4));
    scenery.removeWhere((s) => s.z < behind - 4);
  }

  // ------------------------------------------------------------- result --
  RunResult buildResult({bool quit = false}) {
    final lv = level;
    final completed = phase == RunPhase.finished;
    var starCoins = false, starThird = false;
    if (lv != null && completed) {
      starCoins = coins >= lv.coinTarget;
      starThird = lv.thirdStar == ThirdStarObjective.noCrash
          ? crashes == 0
          : time <= lv.timeLimitSeconds;
    }
    return RunResult(
      mode: config.mode,
      levelNumber: lv?.number,
      completed: completed,
      distanceMeters: rider.z,
      coins: coins,
      gems: gems,
      timeSeconds: time,
      starFinish: completed,
      starCoins: starCoins,
      starThird: starThird,
      crashes: crashes,
      jumps: jumps,
      ducks: ducks,
      nearMisses: nearMisses,
      powerUpsUsed: powerUpsUsed,
      bestCombo: bestCombo,
      quitByUser: quit,
    );
  }
}
