import 'package:flutter_test/flutter_test.dart';
import 'package:pedalescape/engine/audio/synth_voice.dart';
import 'package:pedalescape/game/audio/music_composer.dart';
import 'package:pedalescape/game/audio/music_track.dart';

void main() {
  group('MusicComposer', () {
    for (final track in MusicTrack.values) {
      test('${track.name} renders a 20-40 s finite loop', () {
        final seconds = MusicComposer.loopSeconds(track);
        expect(seconds, inInclusiveRange(20, 40));

        final samples = MusicComposer.render(track);
        expect(samples.length, closeTo(seconds * MusicComposer.sampleRate, 1));
        expect(samples.every((s) => s.isFinite), isTrue);
        expect(peakOf(samples), lessThanOrEqualTo(1.0));
        expect(rmsOf(samples), greaterThan(0.05), reason: 'not silent');
      });
    }
  });
}
