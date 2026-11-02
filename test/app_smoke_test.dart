import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedalescape/main.dart';
import 'package:pedalescape/services/storage.dart';
import 'package:pedalescape/ui/game_screen.dart';

void main() {
  testWidgets('menu shows and a run starts without errors', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(PedalEscapeApp(storage: Storage.memory()));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('OYNA'), findsOneWidget);
    await tester.tap(find.text('OYNA'));
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final state = tester.state<GameScreenState>(find.byType(GameScreen));
    expect(state.game.distance > 0, isTrue);
    state.pauseGame();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('DURAKLATILDI'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
