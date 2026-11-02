/// Deterministic shape of the road: curvature and height as functions of the
/// travelled distance. Gameplay happens in straight "road space"; the curve is
/// purely visual (the renderer bends geometry ahead of the camera).
library;

import 'dart:typed_data';

import '../../../engine/math/value_noise.dart';

class TrackProfile {
  TrackProfile({required int seed, this.curviness = 0.6, this.hilliness = 0.5})
      : _curve = ValueNoise1D(seed),
        _hill = ValueNoise1D(seed + 991);

  final ValueNoise1D _curve;
  final ValueNoise1D _hill;
  final double curviness;
  final double hilliness;

  /// Sample spacing (m) of the bend tables.
  static const double step = 2;
  static const int samples = 150;

  final Float32List bendX = Float32List(samples);
  final Float32List bendY = Float32List(samples);

  /// Accumulated heading (radians-ish) used to scroll the sky silhouettes.
  double heading = 0;

  double curvatureAt(double s) {
    final c = _curve.fractal(s / 420, octaves: 2);
    // Flatten small values so there are straight sections too.
    final shaped = c.abs() < 0.25 ? 0.0 : (c - 0.25 * c.sign) / 0.75;
    return shaped * 0.0032 * curviness;
  }

  double heightAt(double s) => _hill.fractal(s / 380, octaves: 2) * 7 * hilliness;

  /// Rebuilds [bendX]/[bendY] for a camera at distance [cameraS].
  void update(double cameraS, double dt, double speed) {
    var slope = 0.0, x = 0.0;
    final h0 = heightAt(cameraS);
    for (var i = 0; i < samples; i++) {
      final s = cameraS + i * step;
      bendX[i] = x;
      bendY[i] = heightAt(s) - h0 - i * step * _slopeAt(cameraS);
      slope += curvatureAt(s) * step;
      x += slope * step;
    }
    heading += curvatureAt(cameraS + 20) * speed * dt;
  }

  double _slopeAt(double s) => (heightAt(s + 3) - heightAt(s - 3)) / 6 * 0.6;
}
