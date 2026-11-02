// Generates the Android launcher icons from the game's own rider art.
// Run manually: flutter test tool/icon_gen_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedalescape/game/bike_painter.dart';
import 'package:pedalescape/game/skins.dart';

Future<void> _icon(int px, String path) async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  final s = px.toDouble();
  final r = Rect.fromLTWH(0, 0, s, s);
  c.drawRect(r, Paint()
    ..shader = ui.Gradient.linear(Offset.zero, Offset(0, s), const [Color(0xff3b3f8f), Color(0xffff7a5c), Color(0xffffc070)], const [0, 0.6, 1]));
  c.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.2, Paint()..color = const Color(0xfffff1c8));
  // Road in perspective.
  final road = Path()
    ..moveTo(s * 0.47, s * 0.56)
    ..lineTo(s * 0.53, s * 0.56)
    ..lineTo(s * 0.95, s)
    ..lineTo(s * 0.05, s)
    ..close();
  c.drawRect(Rect.fromLTWH(0, s * 0.56, s, s * 0.44), Paint()..color = const Color(0xff3f8a4a));
  c.drawPath(road, Paint()..color = const Color(0xff4a4d55));
  c.drawLine(Offset(s * 0.5, s * 0.6), Offset(s * 0.5, s * 0.98), Paint()
    ..color = const Color(0xfff5f5f0)
    ..strokeWidth = s * 0.015);
  final bike = BikePainter(kSkins.first);
  c.save();
  c.translate(s * 0.5, s * 0.95);
  c.scale(s * 0.42, s * 0.42);
  bike.paintShadow(c, 0);
  bike.paint(c, pedal: 0.6, duck: 0, lean: 0.12, night: 0, shield: false, time: 0, crash: 0);
  c.restore();
  final pic = rec.endRecording();
  final img = await pic.toImage(px, px);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  testWidgets('generate icons', (tester) async {
    await tester.runAsync(() async {
      const sizes = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
      for (final e in sizes.entries) {
        await _icon(e.value, 'android/app/src/main/res/mipmap-${e.key}/ic_launcher.png');
      }
      await _icon(512, 'build/icon_512.png');
    });
  });
}
