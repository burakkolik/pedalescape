import 'dart:math' as math;
import 'dart:typed_data';

import 'config.dart';
import 'util.dart';

/// Endless procedural road. Segments are generated ahead of the player into a
/// fixed size ring buffer, so memory use never grows during a run.
class Road {
  final Float32List _curve = Float32List(K.ring);
  final Float32List _y = Float32List(K.ring);

  math.Random _rng = math.Random(1);
  int _next = 0; // next segment index to generate

  // Current section being generated.
  int _secStart = 0;
  int _secLen = 0;
  double _secCurve = 0;
  double _secHillFrom = 0;
  double _secHillDelta = 0;

  /// 0..1 difficulty; affects how wild curves and hills get.
  double difficulty = 0;

  void reset(int seed) {
    _rng = math.Random(seed);
    _next = 0;
    _secStart = 0;
    _secLen = 70; // a straight, flat start
    _secCurve = 0;
    _secHillFrom = 0;
    _secHillDelta = 0;
    difficulty = 0;
    ensure(400);
  }

  /// Makes sure segments up to and including [n] exist.
  void ensure(int n) {
    while (_next <= n) {
      _generate(_next);
      _next++;
    }
  }

  void _newSection(int start, double lastY) {
    _secStart = start;
    final d = difficulty;
    _secLen = 40 + _rng.nextInt(70);
    final r = _rng.nextDouble();
    if (r < 0.28 - d * 0.1) {
      _secCurve = 0;
    } else {
      final maxC = 0.006 + 0.010 * d;
      _secCurve = (_rng.nextBool() ? 1 : -1) * (0.3 + 0.7 * _rng.nextDouble()) * maxC;
    }
    _secHillFrom = lastY;
    if (_rng.nextDouble() < 0.35) {
      _secHillDelta = 0;
    } else {
      final amp = 6 + 16 * d;
      var delta = (_rng.nextDouble() * 2 - 1) * amp;
      // Keep the absolute height in a reasonable band.
      if (lastY + delta > 45) delta = -delta.abs();
      if (lastY + delta < -45) delta = delta.abs();
      _secHillDelta = delta;
    }
  }

  void _generate(int n) {
    if (n >= _secStart + _secLen) {
      final lastY = n == 0 ? 0.0 : _y[(n - 1) & K.ringMask];
      _newSection(n, lastY);
    }
    final t = (n - _secStart) / _secLen;
    // Ease curve in for first 30%, out for last 30%.
    double cf;
    if (t < 0.3) {
      cf = easeInOut(t / 0.3);
    } else if (t > 0.7) {
      cf = easeInOut((1 - t) / 0.3);
    } else {
      cf = 1;
    }
    _curve[n & K.ringMask] = _secCurve * cf;
    _y[n & K.ringMask] = _secHillFrom + _secHillDelta * easeInOut(t);
  }

  double curveAt(int n) => _curve[n & K.ringMask];

  double yAt(int n) => _y[n & K.ringMask];

  /// Ground height at track distance [z] (interpolated).
  double heightAt(double z) {
    final f = z / K.segLen;
    final n = f.floor();
    final t = f - n;
    return lerpD(yAt(n), yAt(n + 1), t);
  }
}
