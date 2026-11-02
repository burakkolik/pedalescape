import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pedalescape/engine/audio/wav_encoder.dart';

void main() {
  group('WavEncoder', () {
    String ascii(Uint8List bytes, int offset) =>
        latin1.decode(bytes.sublist(offset, offset + 4));

    test('writes a canonical PCM16 mono header', () {
      final samples = Float32List(100);
      final wav = WavEncoder.encode(samples, sampleRate: 22050);
      final view = ByteData.sublistView(wav);

      expect(ascii(wav, 0), 'RIFF');
      expect(view.getUint32(4, Endian.little), 36 + 200);
      expect(ascii(wav, 8), 'WAVE');
      expect(ascii(wav, 12), 'fmt ');
      expect(view.getUint32(16, Endian.little), 16);
      expect(view.getUint16(20, Endian.little), 1, reason: 'PCM format');
      expect(view.getUint16(22, Endian.little), 1, reason: 'mono');
      expect(view.getUint32(24, Endian.little), 22050);
      expect(view.getUint32(28, Endian.little), 22050 * 2, reason: 'byte rate');
      expect(view.getUint16(32, Endian.little), 2, reason: 'block align');
      expect(view.getUint16(34, Endian.little), 16, reason: 'bits/sample');
      expect(ascii(wav, 36), 'data');
      expect(view.getUint32(40, Endian.little), 200);
    });

    test('total length is header + 2 bytes per sample', () {
      for (final n in [0, 1, 441, 22050]) {
        final wav = WavEncoder.encode(Float32List(n));
        expect(wav.length, WavEncoder.headerSize + n * 2);
      }
    });

    test('encodes, clamps and sanitises sample values', () {
      final samples = Float32List.fromList([
        0,
        1,
        -1,
        0.5,
        2,
        -3,
        double.nan,
        double.infinity,
      ]);
      final wav = WavEncoder.encode(samples, sampleRate: 8000);
      final view = ByteData.sublistView(wav);
      int at(int i) =>
          view.getInt16(WavEncoder.headerSize + i * 2, Endian.little);

      expect(view.getUint32(24, Endian.little), 8000);
      expect(at(0), 0);
      expect(at(1), 32767);
      expect(at(2), -32767);
      expect(at(3), 16384);
      expect(at(4), 32767, reason: 'clamped high');
      expect(at(5), -32767, reason: 'clamped low');
      expect(at(6), 0, reason: 'NaN becomes silence');
      expect(at(7), 0, reason: 'infinity becomes silence');
    });

    test('rejects a non-positive sample rate', () {
      expect(
        () => WavEncoder.encode(Float32List(1), sampleRate: 0),
        throwsArgumentError,
      );
    });
  });
}
