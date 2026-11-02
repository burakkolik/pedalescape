import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/game.dart';
import '../game/missions.dart';
import '../game/quality.dart';
import '../game/renderer.dart';
import '../game/skins.dart';
import '../services/storage.dart';
import 'hud.dart';
import 'menus.dart';

enum Screen { menu, playing, paused, over, shop, settings, missions }

/// Notifies listeners without rebuilding any widget: used as the CustomPaint
/// repaint trigger so a frame costs exactly one paint() call.
class _FrameSignal extends ChangeNotifier {
  void tick() => notifyListeners();
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.storage});

  final Storage storage;

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Game game = Game();
  late final GameRenderer renderer;
  late final Ticker _ticker;
  final _FrameSignal _frame = _FrameSignal();
  final FocusNode _focus = FocusNode();

  /// HUD refresh signal (~15 Hz, only while playing).
  final ValueNotifier<int> hudTick = ValueNotifier(0);

  Storage get storage => widget.storage;

  Screen screen = Screen.menu;
  Duration _last = Duration.zero;
  double _acc = 0;
  double _hudAcc = 0;

  // Auto quality.
  int _qualityIndex = 1;
  double _perfAcc = 0;
  int _perfFrames = 0;
  int _slowWindows = 0;
  int _fastWindows = 0;
  bool _autoLocked = false;

  // Run bookkeeping.
  int _committedCoins = 0;
  bool _runCounted = false;
  int reviveCost = 0;
  List<Mission> lastCompleted = const [];
  bool newRecord = false;
  bool showTutorial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final q = storage.quality;
    _qualityIndex = q < 0 ? 1 : q.clamp(0, 2);
    renderer = GameRenderer(skin: skinById(storage.skin), quality: Quality.levels[_qualityIndex]);
    game.onEvent = _onEvent;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _frame.dispose();
    hudTick.dispose();
    _focus.dispose();
    renderer.dispose();
    game.onEvent = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _last = Duration.zero;
      if (!_ticker.isActive && _needsTicker) _ticker.start();
    } else {
      // Pause immediately and stop rendering while in the background.
      if (screen == Screen.playing) pauseGame();
      if (_ticker.isActive) _ticker.stop();
      _last = Duration.zero;
    }
  }

  bool get _needsTicker => screen != Screen.paused && screen != Screen.over;

  void _ensureTicker() {
    _last = Duration.zero;
    if (_needsTicker) {
      if (!_ticker.isActive) _ticker.start();
    } else if (_ticker.isActive) {
      // Draw one last frame so the frozen scene is up to date.
      _frame.tick();
      _ticker.stop();
    }
  }

  // ------------------------------------------------------------------ loop

  void _onTick(Duration now) {
    if (_last == Duration.zero) {
      _last = now;
      return;
    }
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    _acc += dt;
    // Cap to ~60 fps on 120 Hz screens unless the user wants high fps
    // (90 Hz displays still run every frame).
    if (!storage.highFps && _acc < 1 / 95) return;
    final step = _acc;
    _acc = 0;

    game.update(step);
    _frame.tick();
    _autoQuality(step);

    if (screen == Screen.playing) {
      _hudAcc += step;
      if (_hudAcc > 1 / 15) {
        _hudAcc = 0;
        hudTick.value++;
      }
      if (showTutorial && game.distance > 160) {
        showTutorial = false;
        storage.tutorialSeen = true;
        setState(() {});
      }
      if (game.phase == Phase.over) _onGameOver();
    }
  }

  void _autoQuality(double dt) {
    if (storage.quality >= 0 || _autoLocked) return;
    if (screen != Screen.playing && screen != Screen.menu) return;
    _perfAcc += dt;
    _perfFrames++;
    if (_perfAcc < 2) return;
    final avg = _perfAcc / _perfFrames;
    _perfAcc = 0;
    _perfFrames = 0;
    if (avg > 1 / 48) {
      _slowWindows++;
      _fastWindows = 0;
    } else if (avg < 1 / 57) {
      _fastWindows++;
      _slowWindows = 0;
    } else {
      _slowWindows = 0;
      _fastWindows = 0;
    }
    if (_slowWindows >= 2 && _qualityIndex > 0) {
      _setQuality(_qualityIndex - 1);
      _autoLocked = true; // never bounce back up after a downgrade
    } else if (_fastWindows >= 3 && _qualityIndex < 2) {
      _setQuality(_qualityIndex + 1);
      _fastWindows = 0;
    }
  }

  void _setQuality(int i) {
    _qualityIndex = i;
    _slowWindows = 0;
    _fastWindows = 0;
    renderer.quality = Quality.levels[i];
  }

  void setQualitySetting(int v) {
    storage.quality = v;
    _autoLocked = false;
    _setQuality(v < 0 ? 1 : v);
    setState(() {});
  }

  // ---------------------------------------------------------------- events

  void _onEvent(GameEvent e) {
    if (!storage.haptics) return;
    switch (e) {
      case GameEvent.lane:
        HapticFeedback.selectionClick();
      case GameEvent.smallHit:
      case GameEvent.shieldBreak:
        HapticFeedback.mediumImpact();
      case GameEvent.crash:
      case GameEvent.caught:
      case GameEvent.smash:
        HapticFeedback.heavyImpact();
      case GameEvent.powerUp:
        HapticFeedback.lightImpact();
      default:
        break;
    }
  }

  // --------------------------------------------------------------- actions

  void startGame() {
    game.startRun();
    _committedCoins = 0;
    _runCounted = false;
    lastCompleted = const [];
    newRecord = false;
    reviveCost = 0;
    showTutorial = !storage.tutorialSeen;
    _setScreen(Screen.playing);
  }

  void pauseGame() {
    game.pause();
    _setScreen(Screen.paused);
  }

  void resumeGame() {
    game.resume();
    _setScreen(Screen.playing);
  }

  void toMenu() {
    game.toMenu();
    _setScreen(Screen.menu);
  }

  void openScreen(Screen s) => _setScreen(s);

  void refresh() => setState(() {});

  bool get canRevive => !game.revived && storage.wallet >= reviveCost;

  void revive() {
    if (!canRevive) return;
    storage.wallet = storage.wallet - reviveCost;
    game.revive();
    _setScreen(Screen.playing);
  }

  void selectSkin(Skin s) {
    storage.skin = s.id;
    renderer.setSkin(s);
    setState(() {});
  }

  bool buySkin(Skin s) {
    if (storage.owned.contains(s.id)) return true;
    if (storage.wallet < s.price) return false;
    storage.wallet = storage.wallet - s.price;
    storage.addOwned(s.id);
    selectSkin(s);
    return true;
  }

  void _setScreen(Screen s) {
    setState(() => screen = s);
    _ensureTicker();
    if (s == Screen.playing) _focus.requestFocus();
  }

  void _onGameOver() {
    final s = storage;
    final newCoins = game.coins - _committedCoins;
    _committedCoins = game.coins;
    s.wallet = s.wallet + newCoins;
    s.totalCoins = s.totalCoins + newCoins;
    final dist = game.distance.floor();
    if (!_runCounted) {
      _runCounted = true;
      s.runs = s.runs + 1;
    }
    s.totalDistance = s.totalDistance + dist - _countedDistance;
    _countedDistance = dist;
    newRecord = game.score > s.best;
    if (newRecord) s.best = game.score;
    if (dist > s.bestDistance) s.bestDistance = dist;
    lastCompleted = [
      ...lastCompleted,
      ...evaluateMissions(s, RunStats(distance: dist, coins: game.coins, score: game.score)),
    ];
    reviveCost = 60 + (dist ~/ 1000) * 20;
    _setScreen(Screen.over);
  }

  int _countedDistance = 0;

  // ----------------------------------------------------------------- input

  Offset? _down;
  bool _swiped = false;

  void _pointerDown(PointerDownEvent e) {
    _down = e.localPosition;
    _swiped = false;
  }

  void _pointerMove(PointerMoveEvent e) {
    final d = _down;
    if (d == null || _swiped || screen != Screen.playing) return;
    final delta = e.localPosition - d;
    final th = MediaQuery.sizeOf(context).shortestSide * 0.055;
    if (delta.distance < th) return;
    _swiped = true;
    if (delta.dx.abs() > delta.dy.abs()) {
      delta.dx < 0 ? game.moveLeft() : game.moveRight();
    } else {
      delta.dy < 0 ? game.jump() : game.duck();
    }
  }

  void _pointerUp(PointerUpEvent e) {
    final d = _down;
    _down = null;
    if (d == null || _swiped || screen != Screen.playing) return;
    // Tap fallback: left/right third changes lane, middle jumps. The top bar
    // (pause button, score) is excluded.
    final mq = MediaQuery.of(context);
    if (e.localPosition.dy < mq.padding.top + 96) return;
    final w = mq.size.width;
    final x = e.localPosition.dx;
    if (x < w * 0.33) {
      game.moveLeft();
    } else if (x > w * 0.67) {
      game.moveRight();
    } else {
      game.jump();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (screen == Screen.playing) {
      if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.keyA) {
        game.moveLeft();
      } else if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.keyD) {
        game.moveRight();
      } else if (k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.keyW || k == LogicalKeyboardKey.space) {
        game.jump();
      } else if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.keyS) {
        game.duck();
      } else if (k == LogicalKeyboardKey.escape || k == LogicalKeyboardKey.keyP) {
        pauseGame();
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }
    if (screen == Screen.paused && (k == LogicalKeyboardKey.escape || k == LogicalKeyboardKey.keyP)) {
      resumeGame();
      return KeyEventResult.handled;
    }
    if ((screen == Screen.menu || screen == Screen.over) &&
        (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space)) {
      startGame();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        switch (screen) {
          case Screen.playing:
            pauseGame();
          case Screen.paused:
            resumeGame();
          case Screen.shop:
          case Screen.settings:
          case Screen.missions:
          case Screen.over:
            toMenu();
          case Screen.menu:
            SystemNavigator.pop();
        }
      },
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _pointerDown,
          onPointerMove: _pointerMove,
          onPointerUp: _pointerUp,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _ScenePainter(renderer, game, _frame, dpr),
                  isComplex: true,
                  willChange: true,
                ),
              ),
              if (screen == Screen.playing) RepaintBoundary(child: Hud(state: this)),
              if (screen == Screen.playing && showTutorial) const IgnorePointer(child: TutorialOverlay()),
              if (screen != Screen.playing) Menus(state: this),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Screen>('screen', screen));
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.renderer, this.game, Listenable repaint, this.dpr) : super(repaint: repaint);

  final GameRenderer renderer;
  final Game game;
  final double dpr;

  @override
  void paint(Canvas canvas, Size size) => renderer.paint(canvas, size, game, dpr);

  @override
  bool shouldRepaint(_ScenePainter old) => old.renderer != renderer || old.dpr != dpr;
}
