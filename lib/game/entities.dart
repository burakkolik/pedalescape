import 'dart:typed_data';

/// Every kind of thing that lives on the track.
enum Kind {
  car(width: 1.8, length: 4.2, deadly: true),
  truck(width: 2.2, length: 7.0, deadly: true),
  barrier(width: 1.8, length: 0.5, deadly: true),
  gate(width: 1.9, length: 0.4, deadly: true),
  cone(width: 0.5, length: 0.5, deadly: false),
  puddle(width: 1.6, length: 2.4, deadly: false),
  coin(width: 0.7, length: 0.7, deadly: false),
  shield(width: 0.9, length: 0.9, deadly: false),
  magnet(width: 0.9, length: 0.9, deadly: false),
  turbo(width: 0.9, length: 0.9, deadly: false),
  x2(width: 0.9, length: 0.9, deadly: false);

  const Kind({required this.width, required this.length, required this.deadly});

  final double width;
  final double length;
  final bool deadly;

  bool get isObstacle => index <= Kind.puddle.index;
  bool get isPowerUp => index >= Kind.shield.index;
}

/// Pooled world object. Instances are created once and recycled forever.
class WorldObject {
  bool active = false;
  Kind kind = Kind.coin;
  double x = 0; // lateral meters from road center
  double y = 0; // height above ground
  double z = 0; // absolute track distance
  double vx = 0, vy = 0, vz = 0;
  double rot = 0, vrot = 0;
  double phase = 0;
  int variant = 0;
  bool hit = false; // already collided / collected
  bool knocked = false; // flying away after being smashed

  void reset(Kind k, double x0, double z0, {double y0 = 0, int variant0 = 0}) {
    active = true;
    kind = k;
    x = x0;
    y = y0;
    z = z0;
    vx = 0;
    vy = 0;
    vz = 0;
    rot = 0;
    vrot = 0;
    phase = (x0 * 1.7 + z0 * 0.31) % 6.28;
    variant = variant0;
    hit = false;
    knocked = false;
  }
}

/// Fixed-capacity, struct-of-arrays particle system in screen space.
/// Nothing is allocated after construction.
class Particles {
  Particles(this.capacity)
    : x = Float32List(capacity),
      y = Float32List(capacity),
      vx = Float32List(capacity),
      vy = Float32List(capacity),
      life = Float32List(capacity),
      maxLife = Float32List(capacity),
      size = Float32List(capacity),
      grow = Float32List(capacity),
      drag = Float32List(capacity),
      gravity = Float32List(capacity),
      color = Int32List(capacity);

  final int capacity;
  final Float32List x, y, vx, vy, life, maxLife, size, grow, drag, gravity;
  final Int32List color;
  int count = 0;

  /// Effective limit, can be lowered by the quality setting.
  int limit = 1 << 30;

  void clear() => count = 0;

  void spawn(
    double px,
    double py,
    double pvx,
    double pvy,
    double lifeS,
    double sz,
    int argb, {
    double growPerS = 0,
    double dragPerS = 0,
    double grav = 0,
  }) {
    final cap = limit < capacity ? limit : capacity;
    if (count >= cap) return;
    final i = count++;
    x[i] = px;
    y[i] = py;
    vx[i] = pvx;
    vy[i] = pvy;
    life[i] = lifeS;
    maxLife[i] = lifeS;
    size[i] = sz;
    grow[i] = growPerS;
    drag[i] = dragPerS;
    gravity[i] = grav;
    color[i] = argb;
  }

  void update(double dt) {
    var i = 0;
    while (i < count) {
      final l = life[i] - dt;
      if (l <= 0) {
        // swap-remove
        final last = --count;
        if (i != last) {
          x[i] = x[last];
          y[i] = y[last];
          vx[i] = vx[last];
          vy[i] = vy[last];
          life[i] = life[last];
          maxLife[i] = maxLife[last];
          size[i] = size[last];
          grow[i] = grow[last];
          drag[i] = drag[last];
          gravity[i] = gravity[last];
          color[i] = color[last];
        }
        continue;
      }
      life[i] = l;
      final d = 1 - drag[i] * dt;
      final k = d < 0 ? 0.0 : d;
      vx[i] *= k;
      vy[i] = vy[i] * k + gravity[i] * dt;
      x[i] += vx[i] * dt;
      y[i] += vy[i] * dt;
      size[i] += grow[i] * dt;
      if (size[i] < 0.1) size[i] = 0.1;
      i++;
    }
  }

  /// Shift every particle (used when the player moves on screen).
  void shift(double dx, double dy) {
    for (var i = 0; i < count; i++) {
      x[i] += dx;
      y[i] += dy;
    }
  }
}
