/// Small immutable 3D vector used by mesh builders (not in the hot render
/// loop, which works on raw doubles for speed).
library;

import 'dart:math' as math;

class Vec3 {
  const Vec3(this.x, this.y, this.z);

  static const zero = Vec3(0, 0, 0);
  static const up = Vec3(0, 1, 0);

  final double x;
  final double y;
  final double z;

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);
  Vec3 operator -() => Vec3(-x, -y, -z);

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;

  Vec3 cross(Vec3 o) =>
      Vec3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  double get length => math.sqrt(x * x + y * y + z * z);

  Vec3 normalized() {
    final l = length;
    return l < 1e-9 ? Vec3.zero : Vec3(x / l, y / l, z / l);
  }

  Vec3 lerp(Vec3 o, double t) =>
      Vec3(x + (o.x - x) * t, y + (o.y - y) * t, z + (o.z - z) * t);

  /// Any vector perpendicular to this one (used to build cylinder frames).
  Vec3 anyPerpendicular() {
    final a = x.abs() < 0.9 ? const Vec3(1, 0, 0) : const Vec3(0, 1, 0);
    return cross(a).normalized();
  }

  @override
  String toString() => 'Vec3($x, $y, $z)';
}
