// Renders the scene off-screen at a few moments and writes PNGs to build/shots
// so the visuals can be inspected. Also acts as a smoke test for the renderer.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedalescape/game/game.dart';
import 'package:pedalescape/game/quality.dart';
import 'package:pedalescape/game/renderer.dart';
import 'package:pedalescape/game/skins.dart';

const _size = Size(540, 1170);

Future<void> _shot(GameRenderer r, Game g, String name) async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  r.paint(c, _size, g, 2);
  final pic = rec.endRecording();
  final img = await pic.toImage(_size.width.toInt(), _size.height.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  Directory('build/shots').createSync(recursive: true);
  File('build/shots/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  img.dispose();
  pic.dispose();
}

/// Runs the simulation (with a shield so the run never ends) for [frames].
void _run(Game g, GameRenderer r, int frames) {
  for (var i = 0; i < frames; i++) {
    g.update(1 / 60);
    if (g.phase != Phase.playing) g.revive();
    g.shield = true;
    if (i % 60 == 0) {
      final rec = ui.PictureRecorder();
      r.paint(Canvas(rec), _size, g, 2);
      rec.endRecording().dispose();
    }
  }
}

/// Teleports the run forward so a given time of day / biome is on screen.
void _jumpTo(Game g, GameRenderer r, double z) {
  final d = z - g.playerZ;
  if (d > 0) {
    g.playerZ += d;
    g.camZ += d;
  }
  _run(g, r, 90);
}

void main() {
  testWidgets('render shots', (tester) async {
    await tester.runAsync(() async {
      for (final q in [Quality.high, Quality.low]) {
        final tag = q == Quality.high ? '' : '_low';
        final g = Game();
        final r = GameRenderer(skin: kSkins.first, quality: q);
        // Warm up so the renderer writes player screen coords.
        _run(g, r, 30);
        await _shot(r, g, 'menu$tag');
        g.startRun(seed: 5);
        _run(g, r, 60 * 12);
        await _shot(r, g, 'play$tag');
        if (q == Quality.low) {
          r.dispose();
          continue;
        }
        _jumpTo(g, r, 1150); // meadow, day
        await _shot(r, g, 'meadow');
        _jumpTo(g, r, 1500); // sunset
        await _shot(r, g, 'sunset');
        _jumpTo(g, r, 2150); // boulevard at night
        await _shot(r, g, 'night');
        g.stormGap = 8;
        g.turboT = 2;
        g.update(1 / 60);
        await _shot(r, g, 'storm');
        _jumpTo(g, r, 2650); // dawn
        await _shot(r, g, 'dawn');
        r.dispose();
      }
    });
  });
}
