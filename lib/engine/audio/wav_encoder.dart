/// PCM16 mono WAV encoder.
///
/// Converts floating point samples in the range [-1, 1] into a complete,
/// self-contained RIFF/WAVE file (44 byte header + little-endian 16-bit PCM
/// data) that any platform media player can decode. Samples outside the
/// range are hard-clamped; non-finite samples are written as silence.
library;

import 'dart:typed_data';

/// Encodes mono float sample buffers into 16-bit PCM WAV files.
abstract final class WavEncoder {
  /// Size in bytes of the canonical RIFF/WAVE header written by [encode].
  static const int headerSize = 44;

  /// Bits per sample of the encoded PCM data.
  static const int bitsPerSample = 16;

  /// Number of channels of the encoded PCM data.
  static const int channels = 1;

  /// Encodes [samples] (nominally in [-1, 1]) at [sampleRate] Hz into a
  /// complete WAV file.
  static Uint8List encode(Float32List samples, {int sampleRate = 22050}) {
    if (sampleRate <= 0) {
      throw ArgumentError.value(sampleRate, 'sampleRate', 'must be positive');
    }
    const bytesPerSample = bitsPerSample ~/ 8;
    final dataSize = samples.length * bytesPerSample * channels;
    final bytes = Uint8List(headerSize + dataSize);
    final view = ByteData.sublistView(bytes);

    // RIFF chunk descriptor.
    _writeAscii(view, 0, 'RIFF');
    view.setUint32(4, 36 + dataSize, Endian.little);
    _writeAscii(view, 8, 'WAVE');

    // "fmt " sub-chunk (PCM).
    _writeAscii(view, 12, 'fmt ');
    view.setUint32(16, 16, Endian.little); // Sub-chunk size for PCM.
    view.setUint16(20, 1, Endian.little); // Audio format 1 = PCM.
    view.setUint16(22, channels, Endian.little);
    view.setUint32(24, sampleRate, Endian.little);
    view.setUint32(
      28,
      sampleRate * channels * bytesPerSample,
      Endian.little,
    ); // Byte rate.
    view.setUint16(32, channels * bytesPerSample, Endian.little); // Align.
    view.setUint16(34, bitsPerSample, Endian.little);

    // "data" sub-chunk.
    _writeAscii(view, 36, 'data');
    view.setUint32(40, dataSize, Endian.little);

    var offset = headerSize;
    for (var i = 0; i < samples.length; i++) {
      final s = samples[i];
      final clamped = s.isFinite ? s.clamp(-1.0, 1.0) : 0.0;
      view.setInt16(offset, (clamped * 32767).round(), Endian.little);
      offset += bytesPerSample;
    }
    return bytes;
  }

  /// Duration in seconds of a WAV produced by [encode] for [sampleCount]
  /// samples at [sampleRate].
  static double durationOf(int sampleCount, {int sampleRate = 22050}) =>
      sampleCount / sampleRate;

  static void _writeAscii(ByteData view, int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      view.setUint8(offset + i, text.codeUnitAt(i));
    }
  }
}
