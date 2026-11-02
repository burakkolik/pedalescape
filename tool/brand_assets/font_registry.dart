// Loads the Noto fonts used by the brand-asset generator into the Flutter
// engine (via FontLoader) so that text is shaped by the engine's HarfBuzz.
//
// CJK fonts on Linux ship only as TrueType Collections (.ttc). The engine's
// FontLoader always takes face #0 of a collection (Japanese), so for Korean
// and Traditional Chinese we extract the wanted face (located by its family
// name) into a standalone OpenType font in memory before registering it.
//
// Every failure is fatal: a missing font would otherwise silently fall back
// to the test font and produce tofu boxes in the store art.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Engine family names registered by [FontRegistry.loadAll].
abstract final class BrandFonts {
  static const latin = 'BrandNotoSans';
  static const latinItalic = 'BrandNotoSansItalic';
  static const arabic = 'BrandNotoSansArabic';
  static const devanagari = 'BrandNotoSansDevanagari';
  static const cjkJp = 'BrandNotoSansCJKjp';
  static const cjkKr = 'BrandNotoSansCJKkr';
  static const cjkTc = 'BrandNotoSansCJKtc';
}

class FontRegistry {
  FontRegistry._();

  static const _searchDirs = [
    '/usr/share/fonts/truetype/noto',
    '/usr/share/fonts/opentype/noto',
    '/usr/share/fonts/noto',
    '/usr/share/fonts/noto-cjk',
    '/usr/share/fonts/google-noto',
    '/usr/share/fonts/google-noto-cjk',
  ];

  static bool _loaded = false;

  /// Loads all brand fonts. Throws [StateError] if anything is missing.
  static Future<void> loadAll() async {
    if (_loaded) return;
    await _loadFile(BrandFonts.latin, _find(['NotoSans-Bold.ttf']));
    await _loadFile(
        BrandFonts.latinItalic, _find(['NotoSans-BoldItalic.ttf', 'NotoSans-Bold.ttf']));
    await _loadFile(BrandFonts.arabic, _find(['NotoSansArabic-Bold.ttf']));
    await _loadFile(BrandFonts.devanagari, _find(['NotoSansDevanagari-Bold.ttf']));

    // CJK: prefer standalone regional OTFs if present, else extract from TTC.
    await _loadCjk(BrandFonts.cjkJp, 'JP', 'Noto Sans CJK JP');
    await _loadCjk(BrandFonts.cjkKr, 'KR', 'Noto Sans CJK KR');
    await _loadCjk(BrandFonts.cjkTc, 'TC', 'Noto Sans CJK TC');

    // Sanity check: every family must actually differ from the engine's
    // fallback, otherwise the font silently failed to register.
    _verify(BrandFonts.latin, 'Pedal Escape');
    _verify(BrandFonts.latinItalic, 'Pedal Escape');
    _verify(BrandFonts.arabic, 'هروب الدواسة');
    _verify(BrandFonts.devanagari, 'पेडल एस्केप');
    _verify(BrandFonts.cjkJp, 'ペダルエスケープ');
    _verify(BrandFonts.cjkKr, '페달 이스케이프');
    _verify(BrandFonts.cjkTc, '踏板逃脫');
    _loaded = true;
  }

  static String _find(List<String> names) {
    for (final name in names) {
      for (final dir in _searchDirs) {
        final f = File('$dir/$name');
        if (f.existsSync()) return f.path;
      }
    }
    throw StateError('Brand font not found: tried ${names.join(', ')} in '
        '${_searchDirs.join(', ')}. Install the Noto fonts '
        '(e.g. apt-get install fonts-noto-core fonts-noto-cjk).');
  }

  static Future<void> _loadFile(String family, String path) async {
    final bytes = File(path).readAsBytesSync();
    await _register(family, bytes, path);
  }

  static Future<void> _register(String family, Uint8List bytes, String source) async {
    try {
      final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    } catch (e) {
      throw StateError('FontLoader failed for $family ($source): $e');
    }
    // ignore: avoid_print
    print('[fonts] $family <- $source');
  }

  static Future<void> _loadCjk(String family, String region, String faceName) async {
    // 1) Standalone OTF variants (e.g. NotoSansTC-Bold.otf, NotoSansCJKtc-Bold.otf).
    final standalone = [
      'NotoSansCJK${region.toLowerCase()}-Bold.otf',
      'NotoSans$region-Bold.otf',
      'NotoSans$region-Bold.ttf',
    ];
    for (final name in standalone) {
      for (final dir in _searchDirs) {
        final f = File('$dir/$name');
        if (f.existsSync()) {
          await _loadFile(family, f.path);
          return;
        }
      }
    }
    // 2) Extract the face from the TrueType Collection.
    final ttcPath = _find(['NotoSansCJK-Bold.ttc', 'NotoSansCJK-Black.ttc', 'NotoSansCJK-Regular.ttc']);
    final ttc = File(ttcPath).readAsBytesSync();
    final face = extractTtcFace(ttc, faceName);
    await _register(family, face, '$ttcPath [$faceName]');
  }

  static void _verify(String family, String sample) {
    ui.Paragraph build(String fam) {
      final b = ui.ParagraphBuilder(ui.ParagraphStyle(fontFamily: fam, fontSize: 40))
        ..pushStyle(ui.TextStyle(fontFamily: fam, fontSize: 40))
        ..addText(sample);
      return b.build()..layout(const ui.ParagraphConstraints(width: 4000));
    }

    final real = build(family);
    final fallback = build('__brand_missing_font__');
    final same = (real.maxIntrinsicWidth - fallback.maxIntrinsicWidth).abs() < 0.01 &&
        (real.alphabeticBaseline - fallback.alphabeticBaseline).abs() < 0.01 &&
        (real.height - fallback.height).abs() < 0.01;
    if (same) {
      throw StateError('Font family $family did not register (renders identical to fallback).');
    }
  }
}

// ---------------------------------------------------------------------------
// Minimal TrueType Collection splitter.
// ---------------------------------------------------------------------------

/// Returns a standalone sfnt font containing the face of [ttc] whose family
/// name (name ID 1 or 16) equals [familyName]. Throws if not found.
Uint8List extractTtcFace(Uint8List ttc, String familyName) {
  final data = ByteData.sublistView(ttc);
  if (String.fromCharCodes(ttc.sublist(0, 4)) != 'ttcf') {
    throw StateError('Not a TrueType Collection');
  }
  final numFonts = data.getUint32(8);
  final found = <String>[];
  for (var i = 0; i < numFonts; i++) {
    final offset = data.getUint32(12 + 4 * i);
    final names = _faceFamilyNames(data, offset);
    found.addAll(names);
    if (names.contains(familyName)) return _buildSfnt(ttc, data, offset);
  }
  throw StateError('Face "$familyName" not in collection (found: ${found.toSet().join(', ')})');
}

Set<String> _faceFamilyNames(ByteData data, int fontOffset) {
  final numTables = data.getUint16(fontOffset + 4);
  for (var t = 0; t < numTables; t++) {
    final rec = fontOffset + 12 + 16 * t;
    final tag = String.fromCharCodes([
      data.getUint8(rec),
      data.getUint8(rec + 1),
      data.getUint8(rec + 2),
      data.getUint8(rec + 3),
    ]);
    if (tag != 'name') continue;
    final tableOff = data.getUint32(rec + 8);
    final count = data.getUint16(tableOff + 2);
    final strOff = tableOff + data.getUint16(tableOff + 4);
    final result = <String>{};
    for (var n = 0; n < count; n++) {
      final r = tableOff + 6 + 12 * n;
      final platform = data.getUint16(r);
      final nameId = data.getUint16(r + 6);
      final len = data.getUint16(r + 8);
      final off = data.getUint16(r + 10);
      if (nameId != 1 && nameId != 16) continue;
      if (platform == 3 || platform == 0) {
        final units = <int>[];
        for (var k = 0; k + 1 < len; k += 2) {
          units.add(data.getUint16(strOff + off + k));
        }
        result.add(String.fromCharCodes(units));
      } else if (platform == 1) {
        result.add(String.fromCharCodes(
            List.generate(len, (k) => data.getUint8(strOff + off + k))));
      }
    }
    return result;
  }
  return const {};
}

Uint8List _buildSfnt(Uint8List ttc, ByteData data, int fontOffset) {
  final numTables = data.getUint16(fontOffset + 4);
  final headerLen = 12 + 16 * numTables;
  final records = <({int tag, int checksum, int offset, int length})>[];
  var total = headerLen;
  for (var t = 0; t < numTables; t++) {
    final rec = fontOffset + 12 + 16 * t;
    final length = data.getUint32(rec + 12);
    records.add((
      tag: data.getUint32(rec),
      checksum: data.getUint32(rec + 4),
      offset: data.getUint32(rec + 8),
      length: length,
    ));
    total += (length + 3) & ~3;
  }
  final out = Uint8List(total);
  final o = ByteData.sublistView(out);
  // Offset table (sfntVersion, numTables, searchRange, entrySelector, rangeShift).
  for (var k = 0; k < 12; k++) {
    out[k] = ttc[fontOffset + k];
  }
  var cursor = headerLen;
  for (var t = 0; t < records.length; t++) {
    final r = records[t];
    final rec = 12 + 16 * t;
    o.setUint32(rec, r.tag);
    o.setUint32(rec + 4, r.checksum);
    o.setUint32(rec + 8, cursor);
    o.setUint32(rec + 12, r.length);
    out.setRange(cursor, cursor + r.length, ttc, r.offset);
    cursor += (r.length + 3) & ~3;
  }
  return out;
}
