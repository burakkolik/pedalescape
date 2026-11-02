import 'dart:math' as math;

import 'config.dart';
import 'entities.dart';
import 'road.dart';
import 'util.dart';

enum Phase { menu, playing, crashing, over, paused }

enum GameEvent { coin, powerUp, smallHit, shieldBreak, smash, crash, caught, jump, land, lane, nearMiss }

enum EndReason { crash, storm }

/// Pure game simulation: no Flutter widgets, no drawing. The renderer reads
/// this state every frame. All collections are fixed size and recycled.
class Game {
  Game() {
    road.reset(7);
  }

  final Road road = Road();
  final List<WorldObject> objects = List<WorldObject>.generate(K.maxObjects, (_) => WorldObject(), growable: false);

  /// Smoke / dust (normal blending) and sparks (additive blending).
  final Particles smoke = Particles(110);
  final Particles sparks = Particles(150);

  math.Random _rng = math.Random(3);

  Phase phase = Phase.menu;
  Phase _phaseBeforePause = Phase.playing;
  EndReason endReason = EndReason.crash;

  /// Called for gameplay events (haptics, sounds, UI).
  void Function(GameEvent e)? onEvent;

  double time = 0;

  // Track position.
  double playerZ = 0;
  double distance = 0;
  double speed = 11;
  double baseSpeed = K.startSpeed;
  double speedFactor = 1;
  double difficulty = 0;

  // Lateral.
  int lane = 0;
  double x = 0;
  double lean = 0;
  double _prevX = 0;

  // Vertical.
  double jumpY = 0;
  double jumpV = 0;
  double duckT = 0;
  bool get airborne => jumpY > 0.0001 || jumpV > 0;
  bool get ducking => duckT > 0;

  // Camera.
  double camZ = -K.playerDist;
  double camX = 0;
  double camY = K.camHeight;

  // Score.
  int coins = 0;
  double _score = 0;
  int get score => _score.floor();
  int combo = 0;
  double comboT = 0;

  // Power-ups (remaining seconds).
  double magnetT = 0;
  double turboT = 0;
  double x2T = 0;
  bool shield = false;
  double invulnT = 0;

  static const double magnetDur = 9;
  static const double turboDur = 4.5;
  static const double x2Dur = 12;

  /// Meters between the player and the storm chasing them.
  double stormGap = 40;
  static const double stormMax = 55;

  // Effects state read by the renderer.
  double shake = 0;
  double flash = 0; // white flash (lightning / smash)
  double hurt = 0; // red vignette after a hit
  double crashT = 0;
  double pedal = 0; // pedal crank angle
  double skyOffset = 0; // horizontal parallax of the backdrop
  double lightning = 0;
  double _nextLightning = 4;

  bool revived = false;

  /// Written by the renderer: where the player is on screen (pixels) and the
  /// pixel size of one meter at the player. Used for screen-space particles.
  double playerScreenX = 0;
  double playerScreenY = 0;
  double playerPxPerM = 100;

  // Spawning.
  double _nextRowZ = 0;
  double _autoLaneT = 2;

  // --------------------------------------------------------------- control

  void startRun({int? seed}) {
    final s = seed ?? DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
    _rng = math.Random(s);
    road.reset(s);
    for (final o in objects) {
      o.active = false;
    }
    smoke.clear();
    sparks.clear();
    phase = Phase.playing;
    time = 0;
    playerZ = 0;
    distance = 0;
    baseSpeed = K.startSpeed;
    speed = K.startSpeed;
    speedFactor = 1;
    difficulty = 0;
    lane = 0;
    x = 0;
    _prevX = 0;
    lean = 0;
    jumpY = 0;
    jumpV = 0;
    duckT = 0;
    coins = 0;
    _score = 0;
    combo = 0;
    comboT = 0;
    magnetT = 0;
    turboT = 0;
    x2T = 0;
    shield = false;
    invulnT = 0;
    stormGap = 40;
    shake = 0;
    flash = 0;
    hurt = 0;
    crashT = 0;
    revived = false;
    lightning = 0;
    _nextLightning = 5;
    _nextRowZ = 60;
    _updateCamera(1);
  }

  void toMenu() {
    phase = Phase.menu;
    for (final o in objects) {
      o.active = false;
    }
    speed = 11;
    turboT = 0;
    magnetT = 0;
    x2T = 0;
    shield = false;
    crashT = 0;
    jumpY = 0;
    jumpV = 0;
  }

  void pause() {
    if (phase == Phase.playing || phase == Phase.crashing) {
      _phaseBeforePause = phase;
      phase = Phase.paused;
    }
  }

  void resume() {
    if (phase == Phase.paused) phase = _phaseBeforePause;
  }

  /// Continue after a game over (costs coins in the UI).
  void revive() {
    if (phase != Phase.over) return;
    revived = true;
    phase = Phase.playing;
    crashT = 0;
    jumpY = 0;
    jumpV = 0;
    invulnT = 2.5;
    speedFactor = 0.8;
    if (stormGap < 28) stormGap = 28;
    for (final o in objects) {
      if (o.active && o.kind.isObstacle && o.z > playerZ - 6 && o.z < playerZ + 45) {
        o.active = false;
      }
    }
  }

  void moveLeft() => _changeLane(-1);
  void moveRight() => _changeLane(1);

  void _changeLane(int d) {
    if (phase != Phase.playing) return;
    final n = (lane + d).clamp(-1, 1);
    if (n != lane) {
      lane = n;
      onEvent?.call(GameEvent.lane);
    }
  }

  void jump() {
    if (phase != Phase.playing) return;
    if (!airborne) {
      jumpV = K.jumpVel;
      jumpY = 0.0001;
      duckT = 0;
      onEvent?.call(GameEvent.jump);
    }
  }

  void duck() {
    if (phase != Phase.playing) return;
    if (airborne) {
      // Fast drop.
      if (jumpV > -14) jumpV = -14;
    }
    duckT = K.duckTime;
  }

  // ---------------------------------------------------------------- update

  void update(double dt) {
    if (dt > 1 / 30) dt = 1 / 30; // never explode after a hitch
    if (phase == Phase.paused || phase == Phase.over) {
      // Effects fade even when frozen.
      flash = math.max(0, flash - dt * 2);
      return;
    }
    time += dt;

    if (phase == Phase.menu) {
      _updateMenu(dt);
    } else if (phase == Phase.crashing) {
      _updateCrash(dt);
    } else {
      _updatePlaying(dt);
    }

    // Shared effects.
    shake = math.max(0, shake - dt * 3.2);
    flash = math.max(0, flash - dt * 2.5);
    hurt = math.max(0, hurt - dt * 1.6);
    lightning = math.max(0, lightning - dt * 3);
    smoke.update(dt);
    sparks.update(dt);
  }

  void _updateMenu(double dt) {
    speed = lerpD(speed, 12, approach(2, dt));
    _advance(speed * dt);
    _autoLaneT -= dt;
    if (_autoLaneT <= 0) {
      _autoLaneT = 2.2 + _rng.nextDouble() * 2.5;
      final choices = lane == 0 ? [-1, 1] : [0];
      lane = choices[_rng.nextInt(choices.length)];
    }
    _updateLateral(dt);
    pedal += dt * speed * 0.75;
    _wheelDust(dt);
    _updateCamera(dt);
  }

  void _updateCrash(double dt) {
    crashT += dt;
    final slow = dt * (crashT < 0.25 ? 1 : 0.35);
    speed = math.max(0, speed - 60 * slow);
    _advance(speed * slow);
    jumpV -= K.gravity * slow;
    jumpY += jumpV * slow;
    if (jumpY < 0) {
      jumpY = 0;
      jumpV = 0;
    }
    lean = lerpD(lean, 1.25 * (x >= 0 ? 1 : -1), approach(4, dt));
    _updateObjects(slow, collide: false);
    _updateCamera(dt);
    if (crashT > 1.5) {
      phase = Phase.over;
    }
  }

  void _updatePlaying(double dt) {
    difficulty = clampD(distance / K.difficultyDistance, 0, 1);
    road.difficulty = difficulty;
    baseSpeed = lerpD(K.startSpeed, K.maxSpeed, math.pow(difficulty, 0.85).toDouble());

    // Speed recovery after small hits.
    if (speedFactor < 1) speedFactor = math.min(1, speedFactor + dt * 0.55);
    final turbo = turboT > 0;
    final target = baseSpeed * speedFactor * (turbo ? 1.5 : 1);
    speed = lerpD(speed, target, approach(turbo ? 3 : 5, dt));

    final dz = speed * dt;
    _advance(dz);
    distance += dz;
    _score += dz * (x2T > 0 ? 2 : 1);

    // Storm chase: the storm moves a bit slower than the base speed, so a clean
    // run slowly gains distance; every slowdown lets it catch up.
    final stormSpeed = baseSpeed * 0.965;
    stormGap = math.min(stormMax, stormGap + (speed - stormSpeed) * dt);
    if (stormGap <= 0) {
      stormGap = 0;
      endReason = EndReason.storm;
      phase = Phase.crashing;
      crashT = 0.3;
      flash = 1;
      onEvent?.call(GameEvent.caught);
    }
    _nextLightning -= dt * (stormGap < 20 ? 2.5 : 1);
    if (_nextLightning <= 0) {
      _nextLightning = 4 + _rng.nextDouble() * 7;
      if (stormGap < 30) lightning = 1;
    }

    _updateLateral(dt);
    _updateVertical(dt);

    pedal += dt * speed * (turbo ? 1.1 : 0.8);
    magnetT = math.max(0, magnetT - dt);
    turboT = math.max(0, turboT - dt);
    x2T = math.max(0, x2T - dt);
    invulnT = math.max(0, invulnT - dt);
    comboT -= dt;
    if (comboT <= 0) combo = 0;

    _updateObjects(dt, collide: true);
    _spawn();
    _wheelDust(dt);
    if (turbo) _turboTrail(dt);
    _updateCamera(dt);
  }

  void _advance(double dz) {
    playerZ += dz;
    final seg = (playerZ / K.segLen).floor();
    road.ensure(seg + 420);
    skyOffset += road.curveAt(seg) * dz * 1.6;
  }

  void _updateLateral(double dt) {
    final targetX = lane * K.laneW;
    x = lerpD(x, targetX, approach(13, dt));
    final vx = (x - _prevX) / (dt <= 0 ? 1 : dt);
    _prevX = x;
    final seg = (playerZ / K.segLen).floor();
    final targetLean = clampD(vx * 0.05 + road.curveAt(seg) * 12, -0.45, 0.45);
    lean = lerpD(lean, targetLean, approach(10, dt));
  }

  void _updateVertical(double dt) {
    duckT = math.max(0, duckT - dt);
    if (airborne) {
      jumpV -= K.gravity * dt;
      jumpY += jumpV * dt;
      if (jumpY <= 0) {
        jumpY = 0;
        jumpV = 0;
        onEvent?.call(GameEvent.land);
        _landingDust();
      }
    }
  }

  void _updateCamera(double dt) {
    camZ = playerZ - K.playerDist;
    camX = lerpD(camX, x * 0.7, approach(8, dt));
    final ground = math.max(road.heightAt(playerZ), road.heightAt(camZ));
    final target = ground + K.camHeight + jumpY * 0.35;
    camY = lerpD(camY, target, approach(10, dt));
  }

  // --------------------------------------------------------------- objects

  void _updateObjects(double dt, {required bool collide}) {
    final pz = playerZ;
    for (final o in objects) {
      if (!o.active) continue;
      if (o.knocked) {
        o.vy -= K.gravity * dt;
        o.x += o.vx * dt;
        o.y += o.vy * dt;
        o.z += o.vz * dt;
        o.rot += o.vrot * dt;
        if (o.y < -3) o.active = false;
      } else {
        o.z += o.vz * dt;
        o.phase += dt * 4;
      }
      if (o.z < camZ - 4) {
        o.active = false;
        continue;
      }
      if (!collide || o.hit) continue;
      final dz = (o.z - pz).abs();
      if (dz > 8) {
        if (o.kind == Kind.coin && magnetT > 0 && o.z > pz && o.z < pz + 20) {
          _magnetPull(o, dt);
        }
        continue;
      }
      if (o.kind == Kind.coin && magnetT > 0) _magnetPull(o, dt);
      _collide(o, dz);
    }
  }

  void _magnetPull(WorldObject o, double dt) {
    final k = approach(9, dt);
    o.x = lerpD(o.x, x, k);
    o.y = lerpD(o.y, jumpY + 0.9, k);
    o.z = lerpD(o.z, playerZ, approach(3, dt));
  }

  void _collide(WorldObject o, double dz) {
    final kind = o.kind;
    final dx = (o.x - x).abs();
    if (kind == Kind.coin || kind.isPowerUp) {
      if (dz < 1.1 && dx < 0.95 && (o.y - (jumpY + 0.8)).abs() < 1.2) {
        o.hit = true;
        o.active = false;
        if (kind == Kind.coin) {
          coins++;
          combo++;
          comboT = 1.2;
          _score += 5 * (x2T > 0 ? 2 : 1);
          _burst(10, 0xffffd54a, 260, 0.45, 5);
          onEvent?.call(GameEvent.coin);
        } else {
          _applyPowerUp(kind);
          _burst(22, _powerColor(kind), 360, 0.7, 7);
          onEvent?.call(GameEvent.powerUp);
        }
      }
      return;
    }

    final halfLen = kind.length * 0.5 + 0.7;
    final halfW = kind.width * 0.5 + 0.25;
    if (dz >= halfLen || dx >= halfW) {
      // Near miss bonus when passing a deadly obstacle very closely.
      if (kind.deadly && dz < 0.6 && dx < halfW + 0.5 && !o.hit) {
        o.hit = true;
        _score += 10;
        onEvent?.call(GameEvent.nearMiss);
      }
      return;
    }

    switch (kind) {
      case Kind.barrier:
        if (jumpY > 0.75) return;
        _bigHit(o);
      case Kind.gate:
        if (ducking) return;
        _bigHit(o);
      case Kind.car:
      case Kind.truck:
        _bigHit(o);
      case Kind.cone:
        if (jumpY > 0.45) return;
        o.hit = true;
        _knock(o, 0.7);
        if (turboT > 0 || invulnT > 0) return;
        _smallHit(0.6);
      case Kind.puddle:
        if (airborne) return;
        o.hit = true;
        _splash();
        if (turboT > 0 || invulnT > 0) return;
        _smallHit(0.72);
      default:
        break;
    }
  }

  void _knock(WorldObject o, double power) {
    o.knocked = true;
    o.vz = speed * power;
    o.vy = 5 + _rng.nextDouble() * 3;
    o.vx = (o.x - x >= 0 ? 1 : -1) * (2 + _rng.nextDouble() * 3);
    o.vrot = (_rng.nextBool() ? 1 : -1) * (6 + _rng.nextDouble() * 6);
  }

  void _smallHit(double factor) {
    speedFactor = math.min(speedFactor, factor);
    shake = math.max(shake, 0.5);
    hurt = 0.7;
    combo = 0;
    _burst(8, 0xffffffff, 200, 0.35, 4);
    onEvent?.call(GameEvent.smallHit);
  }

  void _bigHit(WorldObject o) {
    o.hit = true;
    if (turboT > 0) {
      // Smash through!
      _knock(o, 1.1);
      shake = 1;
      flash = 0.5;
      _score += 25;
      _burst(26, 0xffffb340, 520, 0.6, 7);
      onEvent?.call(GameEvent.smash);
      return;
    }
    if (invulnT > 0) return;
    if (shield) {
      shield = false;
      invulnT = 1.6;
      speedFactor = math.min(speedFactor, 0.75);
      shake = 1;
      flash = 0.6;
      if (o.kind == Kind.cone || o.kind == Kind.barrier) _knock(o, 0.9);
      _burst(30, 0xff6fd8ff, 480, 0.6, 7);
      onEvent?.call(GameEvent.shieldBreak);
      return;
    }
    // Crash.
    endReason = EndReason.crash;
    phase = Phase.crashing;
    crashT = 0;
    shake = 1.4;
    flash = 0.8;
    hurt = 1;
    jumpV = 5;
    jumpY = math.max(jumpY, 0.01);
    _burst(36, 0xffffd080, 600, 0.7, 6);
    onEvent?.call(GameEvent.crash);
  }

  void _applyPowerUp(Kind k) {
    switch (k) {
      case Kind.shield:
        shield = true;
      case Kind.magnet:
        magnetT = magnetDur;
      case Kind.turbo:
        turboT = turboDur;
        flash = 0.35;
      case Kind.x2:
        x2T = x2Dur;
      default:
        break;
    }
  }

  static int _powerColor(Kind k) {
    switch (k) {
      case Kind.shield:
        return 0xff6fd8ff;
      case Kind.magnet:
        return 0xffff5a7a;
      case Kind.turbo:
        return 0xffffa030;
      case Kind.x2:
        return 0xffb88cff;
      default:
        return 0xffffffff;
    }
  }

  // ------------------------------------------------------------- particles

  void _burst(int n, int color, double power, double life, double size) {
    final px = playerScreenX, py = playerScreenY - playerPxPerM * 1.0;
    final s = playerPxPerM / 100;
    for (var i = 0; i < n; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final v = power * (0.3 + _rng.nextDouble() * 0.7) * s;
      sparks.spawn(
        px,
        py,
        math.cos(a) * v,
        math.sin(a) * v - 120 * s,
        life * (0.6 + _rng.nextDouble() * 0.6),
        size * s * (0.6 + _rng.nextDouble() * 0.8),
        color,
        dragPerS: 2.2,
        grav: 500 * s,
        growPerS: -size * s,
      );
    }
  }

  double _dustAcc = 0;

  void _wheelDust(double dt) {
    if (airborne) return;
    _dustAcc += dt * (6 + speed * 0.6);
    final s = playerPxPerM / 100;
    while (_dustAcc >= 1) {
      _dustAcc -= 1;
      final wx = playerScreenX + (_rng.nextDouble() - 0.5) * 18 * s;
      final wy = playerScreenY - 2 * s;
      smoke.spawn(
        wx,
        wy,
        (_rng.nextDouble() - 0.5) * 80 * s,
        40 * s + _rng.nextDouble() * 50 * s,
        0.5 + _rng.nextDouble() * 0.4,
        7 * s,
        0x55cfc6b8,
        growPerS: 34 * s,
        dragPerS: 1.5,
      );
    }
  }

  void _landingDust() {
    final s = playerPxPerM / 100;
    for (var i = 0; i < 14; i++) {
      final dir = i.isEven ? 1 : -1;
      smoke.spawn(
        playerScreenX + dir * _rng.nextDouble() * 20 * s,
        playerScreenY,
        dir * (80 + _rng.nextDouble() * 160) * s,
        -_rng.nextDouble() * 40 * s,
        0.6,
        9 * s,
        0x66d8d0c4,
        growPerS: 40 * s,
        dragPerS: 2.5,
      );
    }
  }

  void _splash() {
    final s = playerPxPerM / 100;
    for (var i = 0; i < 24; i++) {
      final a = -math.pi * (0.1 + 0.8 * _rng.nextDouble());
      final v = (220 + _rng.nextDouble() * 260) * s;
      sparks.spawn(
        playerScreenX,
        playerScreenY,
        math.cos(a) * v,
        math.sin(a) * v,
        0.6,
        4.5 * s,
        0xcc9fd8ff,
        grav: 900 * s,
        dragPerS: 0.8,
      );
    }
  }

  void _turboTrail(double dt) {
    final s = playerPxPerM / 100;
    for (var i = 0; i < 2; i++) {
      sparks.spawn(
        playerScreenX + (_rng.nextDouble() - 0.5) * 30 * s,
        playerScreenY - 40 * s,
        (_rng.nextDouble() - 0.5) * 60 * s,
        260 * s,
        0.35,
        8 * s,
        0xffff9a30,
        growPerS: -14 * s,
      );
    }
  }

  // --------------------------------------------------------------- spawning

  WorldObject? _alloc() {
    for (final o in objects) {
      if (!o.active) return o;
    }
    return null; // pool exhausted: simply skip (never grows)
  }

  void _put(Kind k, int laneIdx, double z, {double y = 0, double vz = 0, int variant = 0}) {
    final o = _alloc();
    if (o == null) return;
    // Moving vehicles are placed so that they meet the player at row [z].
    var z0 = z;
    if (vz > 0) {
      final t = (z - playerZ) / math.max(1, baseSpeed);
      z0 = z - vz * t;
      if (z0 < playerZ + 60) z0 = playerZ + 60;
    }
    o.reset(k, laneIdx * K.laneW, z0, y0: y, variant0: variant);
    o.vz = vz;
  }

  void _coinLine(int laneIdx, double zStart, int n, {double spacing = 3.2}) {
    for (var i = 0; i < n; i++) {
      _put(Kind.coin, laneIdx, zStart + i * spacing, y: 0.85);
    }
  }

  void _coinArc(int laneIdx, double zCenter) {
    const n = 7;
    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      _put(Kind.coin, laneIdx, zCenter - 7 + t * 14, y: 0.85 + math.sin(t * math.pi) * 1.6);
    }
  }

  int _randLane() => _rng.nextInt(3) - 1;

  void _spawn() {
    while (_nextRowZ < playerZ + K.spawnAhead) {
      _spawnRow(_nextRowZ);
      final d = difficulty;
      _nextRowZ += lerpD(36, 19, d) + _rng.nextDouble() * 8;
    }
  }

  Kind _smallKind() => _rng.nextBool() ? Kind.cone : Kind.puddle;

  Kind _blockKind() {
    final r = _rng.nextDouble();
    if (r < 0.5) return Kind.car;
    if (r < 0.7 + difficulty * 0.1) return Kind.truck;
    return Kind.cone;
  }

  void _vehicle(int l, double z) {
    final k = _rng.nextDouble() < 0.72 ? Kind.car : Kind.truck;
    final moving = difficulty > 0.15 && _rng.nextDouble() < 0.6;
    final vz = moving ? 2 + _rng.nextDouble() * (2 + 4 * difficulty) : 0.0;
    _put(k, l, z, vz: vz, variant: _rng.nextInt(4));
  }

  void _spawnRow(double z) {
    final d = difficulty;
    final r = _rng.nextDouble();

    // Occasional power-up.
    if (_rng.nextDouble() < 0.07) {
      const kinds = [Kind.shield, Kind.magnet, Kind.turbo, Kind.x2];
      final k = kinds[_rng.nextInt(kinds.length)];
      final l = _randLane();
      _put(k, l, z, y: 0.9);
      _coinLine(l, z + 6, 4);
      return;
    }

    if (r < 0.22) {
      // Single obstacle with coins beside it.
      final l = _randLane();
      if (_rng.nextDouble() < 0.5) {
        _vehicle(l, z);
      } else {
        _put(_smallKind(), l, z);
      }
      final free = _otherLane(l);
      _coinLine(free, z - 6, 5);
    } else if (r < 0.42) {
      // Two lanes blocked.
      final freeL = _randLane();
      for (var l = -1; l <= 1; l++) {
        if (l == freeL) continue;
        final k = _blockKind();
        if (k == Kind.car || k == Kind.truck) {
          _vehicle(l, z);
        } else {
          _put(k, l, z);
        }
      }
      _coinLine(freeL, z - 8, 5);
    } else if (r < 0.56) {
      // Barrier wall — jump!
      for (var l = -1; l <= 1; l++) {
        _put(Kind.barrier, l, z, variant: l + 1);
      }
      _coinArc(_randLane(), z);
    } else if (r < 0.66 && d > 0.08) {
      // Low gate wall — duck!
      for (var l = -1; l <= 1; l++) {
        _put(Kind.gate, l, z);
      }
      _coinLine(_randLane(), z - 4, 4, spacing: 2.6);
    } else if (r < 0.78 && d > 0.3) {
      // Mixed: each lane needs a different move.
      final ls = [-1, 0, 1]..shuffle(_rng);
      _put(Kind.barrier, ls[0], z);
      _put(Kind.gate, ls[1], z);
      _vehicle(ls[2], z);
    } else if (r < 0.9) {
      // Coins, sometimes zig-zag.
      if (_rng.nextBool()) {
        _coinLine(_randLane(), z - 8, 8);
      } else {
        var l = _randLane();
        for (var i = 0; i < 9; i++) {
          if (i % 3 == 0 && i > 0) l = _otherLane(l);
          _put(Kind.coin, l, z - 10 + i * 3.0, y: 0.85);
        }
      }
      if (d > 0.2 && _rng.nextDouble() < 0.5) {
        _put(_smallKind(), _randLane(), z + 14);
      }
    } else {
      // Small hazards field.
      for (var i = 0; i < 3; i++) {
        _put(_smallKind(), _randLane(), z - 6 + i * 6);
      }
    }
  }

  int _otherLane(int l) {
    final opts = l == 0 ? const [-1, 1] : const [0];
    return opts[_rng.nextInt(opts.length)];
  }
}
