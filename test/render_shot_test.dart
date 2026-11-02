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

Future<void> _shot(GameRenderer r, Game g, String name) async {
  const size = Size(540, 1170);
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  r.paint(c, size, g, 2);
  final pic = rec.endRecording();
  final img = await pic.toImage(size.width.toInt(), size.height.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  Directory('build/shots').createSync(recursive: true);
  File('build/shots/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  img.dispose();
  pic.dispose();
}

void main() {
  testWidgets('render shots', (tester) async {
    await tester.runAsync(() async {
      final g = Game();
      final r = GameRenderer(skin: kSkins.first, quality: Quality.high);
      // Warm up so the renderer writes player screen coords.
      for (var i = 0; i < 30; i++) {
        g.update(1 / 60);
      }
      await _shot(r, g, 'menu');
      g.startRun(seed: 5);
      g.shield = true;
      for (var i = 0; i < 60 * 12; i++) {
        g.update(1 / 60);
        if (g.phase != Phase.playing) g.revive();
        if (i % 60 == 0) {
          final rec = ui.PictureRecorder();
          r.paint(Canvas(rec), const Size(540, 1170), g, 2);
          rec.endRecording().dispose();
        }
      }
      await _shot(r, g, 'play');
      // Jump to night.
      g.playerZ += 1800;
      for (var i = 0; i < 60; i++) {
        g.update(1 / 60);
        if (g.phase != Phase.playing) g.revive();
      }
      g.stormGap = 8;
      g.turboT = 2;
      await _shot(r, g, 'night');
      r.dispose();
    });
  });
}
