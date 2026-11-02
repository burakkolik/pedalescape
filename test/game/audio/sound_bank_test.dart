import 'package:flutter_test/flutter_test.dart';
import 'package:pedalescape/engine/audio/synth_voice.dart';
import 'package:pedalescape/game/audio/sfx_id.dart';
import 'package:pedalescape/game/audio/sound_bank.dart';

void main() {
  group('SoundBank', () {
    for (final id in SfxId.values) {
      test('${id.name} renders non-empty, finite audio with peak <= 1', () {
        final samples = SoundBank.render(id);

        expect(samples, isNotEmpty);
        expect(samples.every((s) => s.isFinite), isTrue, reason: 'finite');
        final peak = peakOf(samples);
        expect(peak, lessThanOrEqualTo(1.0));
        expect(peak, greaterThan(0.05), reason: 'audible, not silent');
        expect(peak, closeTo(SoundBank.peakLevel(id), 1e-3));
        // Effects should be short enough to stay snappy.
        expect(samples.length / SoundBank.sampleRate, lessThan(4));
      });
    }

    test('rendering is deterministic', () {
      expect(SoundBank.render(SfxId.crash), SoundBank.render(SfxId.crash));
    });
  });
}
