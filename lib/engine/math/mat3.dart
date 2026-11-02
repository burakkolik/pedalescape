/// 3x3 rotation matrix (row-major) built from yaw / pitch / roll.
///
/// Convention: x = right, y = up, z = forward (into the screen).
/// R = Ry(yaw) * Rx(pitch) * Rz(roll).
library;

import 'dart:math' as math;

import 'vec3.dart';

class Mat3 {
  Mat3.identity()
      : m00 = 1, m01 = 0, m02 = 0,
        m10 = 0, m11 = 1, m12 = 0,
        m20 = 0, m21 = 0, m22 = 1;

  Mat3.rotation({double yaw = 0, double pitch = 0, double roll = 0})
      : m00 = 0, m01 = 0, m02 = 0, m10 = 0, m11 = 0, m12 = 0, m20 = 0, m21 = 0, m22 = 0 {
    setRotation(yaw: yaw, pitch: pitch, roll: roll);
  }

  double m00, m01, m02, m10, m11, m12, m20, m21, m22;

  void setRotation({double yaw = 0, double pitch = 0, double roll = 0}) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final cr = math.cos(roll), sr = math.sin(roll);
    // Ry * Rx
    final a00 = cy, a01 = sy * sp, a02 = sy * cp;
    const a10 = 0.0;
    final a11 = cp, a12 = -sp;
    final a20 = -sy, a21 = cy * sp, a22 = cy * cp;
    // (Ry*Rx) * Rz
    m00 = a00 * cr + a01 * sr;
    m01 = -a00 * sr + a01 * cr;
    m02 = a02;
    m10 = a10 * cr + a11 * sr;
    m11 = -a10 * sr + a11 * cr;
    m12 = a12;
    m20 = a20 * cr + a21 * sr;
    m21 = -a20 * sr + a21 * cr;
    m22 = a22;
  }

  Vec3 transform(Vec3 v) => Vec3(
        m00 * v.x + m01 * v.y + m02 * v.z,
        m10 * v.x + m11 * v.y + m12 * v.z,
        m20 * v.x + m21 * v.y + m22 * v.z,
      );
}
