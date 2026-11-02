import 'package:flutter_test/flutter_test.dart';
import 'package:pedalescape/game/config.dart';
import 'package:pedalescape/game/entities.dart';
import 'package:pedalescape/game/game.dart';
import 'package:pedalescape/game/missions.dart';
import 'package:pedalescape/game/road.dart';
import 'package:pedalescape/services/storage.dart';

void main() {
  test('road is continuous and deterministic', () {
    final a = Road()..reset(9);
    final b = Road()..reset(9);
    a.ensure(900);
    b.ensure(900);
    for (var n = 0; n < 900; n++) {
      expect(a.yAt(n), b.yAt(n));
      expect((a.yAt(n + 1) - a.yAt(n)).abs() < 2, isTrue);
    }
  });

  test('object pool never grows during a long run', () {
    final g = Game()..startRun(seed: 1);
    g.shield = true;
    for (var i = 0; i < 60 * 120; i++) {
      g.update(1 / 60);
      if (g.phase != Phase.playing) {
        g.phase = Phase.over;
        g.revive();
        g.revived = false;
      }
    }
    expect(g.objects.length, K.maxObjects);
    expect(g.smoke.count <= g.smoke.capacity, isTrue);
    expect(g.sparks.count <= g.sparks.capacity, isTrue);
    expect(g.distance > 1000, isTrue);
  });

  test('car in lane causes crash, jump clears barrier', () {
    final g = Game()..startRun(seed: 2);
    for (final o in g.objects) {
      o.active = false;
    }
    g.objects[0].reset(Kind.car, 0, g.playerZ + 1);
    g.update(1 / 60);
    expect(g.phase, Phase.crashing);

    final h = Game()..startRun(seed: 3);
    for (final o in h.objects) {
      o.active = false;
    }
    h.jump();
    for (var i = 0; i < 10; i++) {
      h.update(1 / 60);
    }
    h.objects[0].reset(Kind.barrier, 0, h.playerZ + 0.3);
    h.update(1 / 60);
    expect(h.phase, Phase.playing);
  });

  test('coins are collected and missions pay out', () {
    final g = Game()..startRun(seed: 4);
    for (final o in g.objects) {
      o.active = false;
    }
    g.objects[0].reset(Kind.coin, 0, g.playerZ + 0.2, y0: 0.85);
    g.update(1 / 60);
    expect(g.coins, 1);

    final s = Storage.memory();
    s.runs = 3;
    final done = evaluateMissions(s, const RunStats(distance: 350, coins: 25, score: 100));
    expect(done.map((m) => m.id), containsAll(['d300', 'c20', 'r3']));
    expect(s.wallet, 100);
  });
}
