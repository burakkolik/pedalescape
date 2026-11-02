/// Rendering helpers: notes, sweeps, chirps, noise bursts and additive
/// partials, plus buffer utilities (mixing, gain, fades, delay, soft clip).
///
/// All render functions *add* into a caller-provided [Float32List] so voices
/// can be layered cheaply. Positions are given in seconds. When `wrap` is
/// true, samples past the end of the buffer wrap around to the start, which
/// makes seamless loops trivial (note tails spill into the loop head).
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'envelope.dart';
import 'filters.dart';
import 'oscillators.dart';

/// Shape of a frequency or cutoff sweep over time.
enum SweepCurve { linear, exponential }

/// One partial of an additive / inharmonic sound (e.g. a bell).
class Partial {
  /// Creates a partial at [ratio] × fundamental with relative [gain] and an
  /// exponential decay time constant [decay] (seconds).
  const Partial(this.ratio, this.gain, this.decay);

  /// Frequency ratio relative to the fundamental.
  final double ratio;

  /// Relative amplitude.
  final double gain;

  /// Exponential decay time constant in seconds.
  final double decay;
}

/// Number of samples for [seconds] at [sampleRate] (never negative).
int samplesFor(double seconds, int sampleRate) =>
    math.max(0, (seconds * sampleRate).round());

/// Allocates a silent buffer of [seconds] length.
Float32List silence(double seconds, {required int sampleRate}) =>
    Float32List(samplesFor(seconds, sampleRate));

/// Renders an oscillator tone (optionally sweeping) into [out].
///
/// * [duration] is the gate time; the [envelope] release is appended.
/// * [endFrequency] sweeps the pitch over [sweepTime] (default: full length).
/// * [vibratoDepth] is in semitones at [vibratoRate] Hz.
/// * [lowPass] adds a resonant low pass whose cutoff optionally sweeps to
///   [lowPassEnd] over the note.
void renderTone(
  Float32List out, {
  required int sampleRate,
  required double frequency,
  required double duration,
  double start = 0,
  double? endFrequency,
  SweepCurve sweep = SweepCurve.exponential,
  double? sweepTime,
  Waveform waveform = Waveform.sine,
  Adsr envelope = const Adsr(),
  double gain = 0.5,
  double vibratoDepth = 0,
  double vibratoRate = 5.5,
  double vibratoDelay = 0,
  double pulseWidth = 0.5,
  double? lowPass,
  double? lowPassEnd,
  double lowPassQ = 0.7071,
  double phase = 0,
  int seed = 1,
  bool wrap = false,
}) {
  final total = envelope.totalLength(duration);
  final n = samplesFor(total, sampleRate);
  if (n == 0 || out.isEmpty) return;
  final startIdx = samplesFor(start, sampleRate);
  final osc = Oscillator(
    waveform,
    sampleRate: sampleRate,
    phase: phase,
    pulseWidth: pulseWidth,
    seed: seed,
  );
  final filter = lowPass == null
      ? null
      : Biquad.lowPass(lowPass, sampleRate, q: lowPassQ);
  final sweepLen = math.max(1e-4, sweepTime ?? total);
  final f1 = endFrequency ?? frequency;
  final hasSweep = endFrequency != null && endFrequency != frequency;
  final lpEnd = lowPassEnd ?? lowPass ?? 0;
  final lpSweeps = filter != null && lowPassEnd != null;
  final invSr = 1 / sampleRate;

  for (var k = 0; k < n; k++) {
    var idx = startIdx + k;
    if (idx >= out.length) {
      if (!wrap) break;
      idx %= out.length;
    }
    final t = k * invSr;
    var f = frequency;
    if (hasSweep) {
      final x = math.min(1.0, t / sweepLen);
      f = sweep == SweepCurve.exponential
          ? expLerp(math.max(1, frequency), math.max(1, f1), x)
          : lerp(frequency, f1, x);
    }
    if (vibratoDepth != 0 && t > vibratoDelay) {
      final ramp = math.min(1.0, (t - vibratoDelay) / 0.15);
      f *= semitoneRatio(
        vibratoDepth * ramp * math.sin(twoPi * vibratoRate * t),
      );
    }
    var s = osc.next(f);
    if (filter != null) {
      if (lpSweeps && (k & 31) == 0) {
        filter.configure(
          frequency: expLerp(lowPass!, math.max(1, lpEnd), t / total),
        );
      }
      s = filter.process(s);
    }
    out[idx] += s * envelope.valueAt(t, duration) * gain;
  }
}

/// Renders MIDI note [midi] (69 = A4); a thin wrapper around [renderTone].
void renderNote(
  Float32List out, {
  required int sampleRate,
  required num midi,
  required double duration,
  double start = 0,
  Waveform waveform = Waveform.sine,
  Adsr envelope = const Adsr(),
  double gain = 0.5,
  double vibratoDepth = 0,
  double vibratoRate = 5.5,
  double vibratoDelay = 0.1,
  double pulseWidth = 0.5,
  double? lowPass,
  double? lowPassEnd,
  double lowPassQ = 0.7071,
  double detuneCents = 0,
  bool wrap = false,
}) {
  renderTone(
    out,
    sampleRate: sampleRate,
    frequency: midiToHz(midi + detuneCents / 100),
    duration: duration,
    start: start,
    waveform: waveform,
    envelope: envelope,
    gain: gain,
    vibratoDepth: vibratoDepth,
    vibratoRate: vibratoRate,
    vibratoDelay: vibratoDelay,
    pulseWidth: pulseWidth,
    lowPass: lowPass,
    lowPassEnd: lowPassEnd,
    lowPassQ: lowPassQ,
    wrap: wrap,
  );
}

/// Renders a short percussive pitch chirp from [from] to [to] Hz.
void renderChirp(
  Float32List out, {
  required int sampleRate,
  required double from,
  required double to,
  required double duration,
  double start = 0,
  Waveform waveform = Waveform.sine,
  double gain = 0.5,
  double attack = 0.003,
  SweepCurve sweep = SweepCurve.exponential,
  double? lowPass,
  bool wrap = false,
}) {
  renderTone(
    out,
    sampleRate: sampleRate,
    frequency: from,
    endFrequency: to,
    sweep: sweep,
    sweepTime: duration,
    duration: duration * 0.6,
    start: start,
    waveform: waveform,
    envelope: Adsr(
      attack: attack,
      decay: duration * 0.6,
      sustain: 0.35,
      release: duration * 0.4,
    ),
    gain: gain,
    lowPass: lowPass,
    wrap: wrap,
  );
}

/// Renders a filtered noise burst into [out].
///
/// The amplitude follows [envelope] (gated for [duration]) or, when
/// [decay] is given, an attack/exponential decay with time constant [decay]
/// lasting [duration] seconds. [filter] selects an optional biquad whose
/// [cutoff] can sweep to [cutoffEnd].
void renderNoise(
  Float32List out, {
  required int sampleRate,
  required double duration,
  double start = 0,
  Adsr? envelope,
  double? decay,
  double attack = 0.001,
  double gain = 0.5,
  BiquadType? filter,
  double cutoff = 2000,
  double? cutoffEnd,
  double q = 0.7071,
  SweepCurve sweep = SweepCurve.exponential,
  int seed = 7,
  bool wrap = false,
}) {
  final env = envelope ?? const Adsr(attack: 0.001, decay: 0, sustain: 1);
  final total = decay != null ? duration : env.totalLength(duration);
  final n = samplesFor(total, sampleRate);
  if (n == 0 || out.isEmpty) return;
  final startIdx = samplesFor(start, sampleRate);
  final noise = NoiseSource(seed: seed);
  final bq = filter == null
      ? null
      : Biquad(type: filter, frequency: cutoff, sampleRate: sampleRate, q: q);
  final invSr = 1 / sampleRate;
  final fadeOut = math.min(0.004, total * 0.2);

  for (var k = 0; k < n; k++) {
    var idx = startIdx + k;
    if (idx >= out.length) {
      if (!wrap) break;
      idx %= out.length;
    }
    final t = k * invSr;
    var s = noise.next();
    if (bq != null) {
      if (cutoffEnd != null && (k & 15) == 0) {
        final x = t / total;
        bq.configure(
          frequency: sweep == SweepCurve.exponential
              ? expLerp(cutoff, cutoffEnd, x)
              : lerp(cutoff, cutoffEnd, x),
        );
      }
      s = bq.process(s);
    }
    var a = decay != null
        ? attackDecay(t, attack: attack, tau: decay)
        : env.valueAt(t, duration);
    // Tiny linear fade at the very end to avoid clicks on truncation.
    final remain = total - t;
    if (remain < fadeOut) a *= remain / fadeOut;
    out[idx] += s * a * gain;
  }
}

/// Renders a sum of decaying sine [partials] above [frequency] Hz.
///
/// Ideal for bells, chimes and metallic hits (use inharmonic ratios).
void renderPartials(
  Float32List out, {
  required int sampleRate,
  required double frequency,
  required List<Partial> partials,
  double start = 0,
  double gain = 0.5,
  double attack = 0.002,
  double? length,
  bool wrap = false,
}) {
  if (partials.isEmpty || out.isEmpty) return;
  final longest = partials.map((p) => p.decay).reduce(math.max);
  final total = length ?? longest * 6.9;
  final n = samplesFor(total, sampleRate);
  final startIdx = samplesFor(start, sampleRate);
  final invSr = 1 / sampleRate;
  final fadeOut = math.min(0.01, total * 0.2);
  final nyquist = sampleRate * 0.45;

  for (final p in partials) {
    final f = frequency * p.ratio;
    if (f >= nyquist) continue;
    final w = twoPi * f * invSr;
    // Recursive sine oscillator via rotating phasor (cheap & exact).
    final c = math.cos(w), s = math.sin(w);
    var re = 1.0, im = 0.0;
    final decayPerSample = math.exp(-invSr / p.decay);
    var amp = p.gain * gain;
    for (var k = 0; k < n; k++) {
      var idx = startIdx + k;
      if (idx >= out.length) {
        if (!wrap) break;
        idx %= out.length;
      }
      final t = k * invSr;
      var a = amp;
      if (t < attack) a *= t / attack;
      final remain = total - t;
      if (remain < fadeOut) a *= remain / fadeOut;
      out[idx] += im * a;
      final nre = re * c - im * s;
      im = re * s + im * c;
      re = nre;
      amp *= decayPerSample;
      if ((k & 1023) == 0) {
        // Renormalise the phasor to stop numerical drift.
        final mag = math.sqrt(re * re + im * im);
        re /= mag;
        im /= mag;
      }
    }
  }
}

/// Adds [src] × [gain] into [dst] starting at [at] seconds.
void mixInto(
  Float32List dst,
  Float32List src, {
  required int sampleRate,
  double at = 0,
  double gain = 1,
  bool wrap = false,
}) {
  if (dst.isEmpty) return;
  final startIdx = samplesFor(at, sampleRate);
  for (var k = 0; k < src.length; k++) {
    var idx = startIdx + k;
    if (idx >= dst.length) {
      if (!wrap) break;
      idx %= dst.length;
    }
    dst[idx] += src[k] * gain;
  }
}

/// Concatenates buffers end to end.
Float32List concat(List<Float32List> parts) {
  final out = Float32List(parts.fold(0, (sum, p) => sum + p.length));
  var offset = 0;
  for (final p in parts) {
    out.setAll(offset, p);
    offset += p.length;
  }
  return out;
}

/// Multiplies every sample of [buf] by [gain] in place.
void applyGain(Float32List buf, double gain) {
  for (var i = 0; i < buf.length; i++) {
    buf[i] *= gain;
  }
}

/// Runs [filter] over [buf] in place.
void applyFilter(Float32List buf, AudioFilter filter) {
  for (var i = 0; i < buf.length; i++) {
    buf[i] = filter.process(buf[i]);
  }
}

/// Absolute peak value of [buf] (non-finite samples count as infinity).
double peakOf(Float32List buf) {
  var peak = 0.0;
  for (final s in buf) {
    if (!s.isFinite) return double.infinity;
    final a = s.abs();
    if (a > peak) peak = a;
  }
  return peak;
}

/// Root mean square level of [buf].
double rmsOf(Float32List buf) {
  if (buf.isEmpty) return 0;
  var sum = 0.0;
  for (final s in buf) {
    sum += s * s;
  }
  return math.sqrt(sum / buf.length);
}

/// Scales [buf] so its peak equals [target]. When [onlyDown] is true quiet
/// buffers are left untouched.
void normalize(Float32List buf, {double target = 0.9, bool onlyDown = false}) {
  final peak = peakOf(buf);
  if (peak <= 0 || !peak.isFinite) return;
  if (onlyDown && peak <= target) return;
  applyGain(buf, target / peak);
}

/// Smooth tanh saturation that never exceeds ±1.
///
/// With [drive] <= 1 small signals pass at unity gain; larger drive adds
/// warmth and loudness while a full-scale input still maps to ±1.
void softClip(Float32List buf, {double drive = 1}) {
  final norm = drive > 1 ? 1 / _tanh(drive) : 1.0;
  for (var i = 0; i < buf.length; i++) {
    final s = buf[i];
    buf[i] = s.isFinite ? (_tanh(s * drive) * norm).clamp(-1.0, 1.0) : 0;
  }
}

double _tanh(double x) {
  if (x > 20) return 1;
  if (x < -20) return -1;
  final e = math.exp(2 * x);
  return (e - 1) / (e + 1);
}

/// Applies linear fade-in / fade-out ramps (seconds) in place.
void fadeEdges(
  Float32List buf, {
  required int sampleRate,
  double fadeIn = 0.002,
  double fadeOut = 0.01,
}) {
  final nIn = math.min(buf.length, samplesFor(fadeIn, sampleRate));
  for (var i = 0; i < nIn; i++) {
    buf[i] *= i / nIn;
  }
  final nOut = math.min(buf.length, samplesFor(fadeOut, sampleRate));
  for (var i = 0; i < nOut; i++) {
    buf[buf.length - 1 - i] *= i / nOut;
  }
}

/// Feedback echo in place. With [wrap] the echo tail wraps (for loops).
void applyEcho(
  Float32List buf, {
  required int sampleRate,
  double time = 0.25,
  double feedback = 0.35,
  double mix = 0.3,
  double damping = 3500,
  bool wrap = false,
}) {
  final d = samplesFor(time, sampleRate);
  if (d <= 0 || d >= buf.length) return;
  final line = Float32List(buf.length);
  final lp = OnePoleLowPass(cutoff: damping, sampleRate: sampleRate);
  // Two passes when wrapping so the loop head receives the tail's echoes.
  final passes = wrap ? 2 : 1;
  for (var pass = 0; pass < passes; pass++) {
    for (var i = 0; i < buf.length; i++) {
      final j = i - d;
      final delayed = j >= 0 ? line[j] : (wrap ? line[j + buf.length] : 0.0);
      line[i] = buf[i] + lp.process(delayed) * feedback;
    }
  }
  for (var i = 0; i < buf.length; i++) {
    final j = i - d;
    final delayed = j >= 0 ? line[j] : (wrap ? line[j + buf.length] : 0.0);
    buf[i] += delayed * mix;
  }
}

/// Makes a percussive "trim": finds the last sample above [threshold] and
/// returns a view ending shortly after, with a short fade.
Float32List trimTail(
  Float32List buf, {
  required int sampleRate,
  double threshold = 1e-4,
}) {
  var end = buf.length;
  while (end > 0 && buf[end - 1].abs() < threshold) {
    end--;
  }
  final keep = math.min(buf.length, end + samplesFor(0.01, sampleRate));
  final out = Float32List.fromList(buf.sublist(0, math.max(1, keep)));
  fadeEdges(out, sampleRate: sampleRate, fadeIn: 0, fadeOut: 0.008);
  return out;
}
