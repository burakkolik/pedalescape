import 'package:flutter/material.dart';

import '../game/bike_painter.dart';
import '../game/game.dart';
import '../game/missions.dart';
import '../game/quality.dart';
import '../game/skins.dart';
import 'game_screen.dart';
import 'widgets.dart';

/// All non-gameplay overlays. The 3D scene keeps running behind them.
class Menus extends StatelessWidget {
  const Menus({super.key, required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (state.screen) {
      case Screen.menu:
        child = _MainMenu(state: state);
      case Screen.paused:
        child = _PauseMenu(state: state);
      case Screen.over:
        child = _GameOver(state: state);
      case Screen.shop:
        child = _Shop(state: state);
      case Screen.settings:
        child = _Settings(state: state);
      case Screen.missions:
        child = _Missions(state: state);
      case Screen.playing:
        child = const SizedBox.shrink();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(state.screen), child: child),
    );
  }
}

class _Dim extends StatelessWidget {
  const _Dim({required this.child, this.alpha = 0.45});

  final Widget child;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromRGBO(5, 8, 20, alpha * 0.6), Color.fromRGBO(5, 8, 20, alpha)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// ------------------------------------------------------------------- main

class _MainMenu extends StatelessWidget {
  const _MainMenu({required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    final s = state.storage;
    return _Dim(
      alpha: 0.35,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                CoinPill(value: s.wallet),
                const Spacer(),
                Text('EN İYİ  ${s.best}', style: titleStyle(16, color: Colors.white)),
              ],
            ),
            const Spacer(flex: 2),
            Appear(
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xffffe066), Color(0xffff7a3d), Color(0xffff3d6e)],
                ).createShader(r),
                child: Text('PEDAL\nESCAPE', textAlign: TextAlign.center, style: titleStyle(64).copyWith(height: 0.95)),
              ),
            ),
            Appear(
              delay: 120,
              child: Text('BIKE RUN', style: titleStyle(22, color: Colors.white).copyWith(letterSpacing: 10)),
            ),
            const Spacer(flex: 3),
            Appear(
              delay: 200,
              child: _Pulse(
                child: GameButton(label: 'OYNA', icon: Icons.play_arrow_rounded, big: true, onTap: state.startGame),
              ),
            ),
            const SizedBox(height: 22),
            Appear(
              delay: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SmallButton(
                    icon: Icons.storefront_rounded,
                    label: 'Mağaza',
                    onTap: () => state.openScreen(Screen.shop),
                  ),
                  _SmallButton(
                    icon: Icons.flag_rounded,
                    label: 'Görevler',
                    onTap: () => state.openScreen(Screen.missions),
                  ),
                  _SmallButton(
                    icon: Icons.settings_rounded,
                    label: 'Ayarlar',
                    onTap: () => state.openScreen(Screen.settings),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text('Kaydır: şerit • Yukarı: zıpla • Aşağı: eğil', style: bodyStyle(13)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.96, end: 1.04).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: kPanel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x44ffffff)),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 6),
            Text(label, style: bodyStyle(13, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ pause

class _PauseMenu extends StatelessWidget {
  const _PauseMenu({required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    return _Dim(
      alpha: 0.6,
      child: Center(
        child: Appear(
          child: Panel(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('DURAKLATILDI', style: titleStyle(28)),
                const SizedBox(height: 6),
                Text('${state.game.score} puan • ${state.game.distance.floor()} m', style: bodyStyle(15)),
                const SizedBox(height: 22),
                GameButton(label: 'DEVAM', icon: Icons.play_arrow_rounded, onTap: state.resumeGame),
                const SizedBox(height: 12),
                GameButton(
                  label: 'ANA MENÜ',
                  icon: Icons.home_rounded,
                  colors: const [Color(0xff4a5070), Color(0xff2c3048)],
                  onTap: state.toMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- game over

class _GameOver extends StatelessWidget {
  const _GameOver({required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    final g = state.game;
    final s = state.storage;
    final caught = g.endReason == EndReason.storm;
    return _Dim(
      alpha: 0.65,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Appear(
            child: Panel(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(caught ? Icons.thunderstorm_rounded : Icons.car_crash_rounded, size: 52, color: kAccent),
                  Text(caught ? 'FIRTINA YAKALADI!' : 'ÇARPTIN!', style: titleStyle(28)),
                  const SizedBox(height: 14),
                  if (state.newRecord)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(12)),
                      child: Text('YENİ REKOR!', style: titleStyle(16, color: const Color(0xff3a2400))),
                    ),
                  Text('${g.score}', style: titleStyle(54, color: kGold)),
                  Text('PUAN', style: bodyStyle(13)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(label: 'Mesafe', value: '${g.distance.floor()} m'),
                      _Stat(label: 'Altın', value: '${g.coins}'),
                      _Stat(label: 'En iyi', value: '${s.best}'),
                    ],
                  ),
                  if (state.lastCompleted.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    for (final m in state.lastCompleted)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xff5ee07a), size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text('${m.text}  +${m.reward}', style: bodyStyle(13, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),
                  GameButton(label: 'TEKRAR', icon: Icons.replay_rounded, big: true, onTap: state.startGame),
                  const SizedBox(height: 12),
                  if (!g.revived)
                    GameButton(
                      label: 'DEVAM ET  (${state.reviveCost})',
                      icon: Icons.favorite_rounded,
                      enabled: state.canRevive,
                      colors: const [Color(0xff36c26b), Color(0xff1f8f4c)],
                      onTap: state.revive,
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: state.toMenu,
                    child: Text('Ana menü', style: bodyStyle(15, color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  CoinPill(value: s.wallet, size: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: titleStyle(20)),
        Text(label, style: bodyStyle(12)),
      ],
    );
  }
}

// ------------------------------------------------------------------- page

class _Page extends StatelessWidget {
  const _Page({required this.state, required this.title, required this.child});

  final GameScreenState state;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Dim(
      alpha: 0.75,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: state.toMenu,
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 4),
                Text(title, style: titleStyle(26)),
                const Spacer(),
                CoinPill(value: state.storage.wallet),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- shop

class _Shop extends StatelessWidget {
  const _Shop({required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    final s = state.storage;
    final owned = s.owned;
    return _Page(
      state: state,
      title: 'MAĞAZA',
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: kSkins.length,
        itemBuilder: (context, i) {
          final skin = kSkins[i];
          final has = owned.contains(skin.id);
          final selected = s.skin == skin.id;
          return GestureDetector(
            onTap: () {
              if (has) {
                state.selectSkin(skin);
              } else if (!state.buySkin(skin)) {
                ScaffoldMessenger.maybeOf(
                  context,
                )?.showSnackBar(const SnackBar(content: Text('Yeterli altının yok!'), duration: Duration(seconds: 1)));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: kPanel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? kGold : const Color(0x33ffffff), width: selected ? 3 : 1.2),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xff3a6fd0), Color(0xff9fd0ff), Color(0xff5a5e66)],
                          stops: [0, 0.62, 0.63],
                        ),
                      ),
                      child: RepaintBoundary(
                        child: CustomPaint(painter: _SkinPreview(skin), size: Size.infinite),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(skin.name, style: titleStyle(16)),
                  const SizedBox(height: 4),
                  if (selected)
                    Text(
                      'SEÇİLİ',
                      style: bodyStyle(13, color: kGold, weight: FontWeight.w800),
                    )
                  else if (has)
                    Text('Seç', style: bodyStyle(13, color: Colors.white))
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CoinIcon(size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${skin.price}',
                          style: bodyStyle(14, color: s.wallet >= skin.price ? kGold : Colors.white38),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SkinPreview extends CustomPainter {
  _SkinPreview(this.skin) : _bike = BikePainter(skin);

  final Skin skin;
  final BikePainter _bike;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 2.2;
    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.9);
    canvas.scale(s, s);
    _bike.paintShadow(canvas, 0);
    _bike.paint(canvas, pedal: 0.6, duck: 0, lean: 0.08, night: 0, shield: false, time: 0, crash: 0);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkinPreview old) => old.skin.id != skin.id;
}

// --------------------------------------------------------------- missions

class _Missions extends StatelessWidget {
  const _Missions({required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    final s = state.storage;
    final active = activeMissions(s);
    final done = s.missionsDone;
    return _Page(
      state: state,
      title: 'GÖREVLER',
      child: ListView(
        children: [
          Text('Aktif görevler', style: bodyStyle(14)),
          const SizedBox(height: 8),
          if (active.isEmpty) Text('Tüm görevleri tamamladın! 🏆', style: titleStyle(18, color: kGold)),
          for (final m in active) _MissionTile(m: m, progress: missionProgress(m, s, null), done: false),
          const SizedBox(height: 16),
          Text('Tamamlanan: ${done.length}/${kMissions.length}', style: bodyStyle(14)),
          const SizedBox(height: 8),
          for (final m in kMissions.where((m) => done.contains(m.id)))
            _MissionTile(m: m, progress: m.target, done: true),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.m, required this.progress, required this.done});

  final Mission m;
  final int progress;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final perRun =
        m.type == MissionType.runDistance || m.type == MissionType.runCoins || m.type == MissionType.runScore;
    final t = (progress / m.target).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? const Color(0x5524a148) : kPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33ffffff)),
      ),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle_rounded : Icons.flag_rounded, color: done ? const Color(0xff5ee07a) : kAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.text,
                  style: bodyStyle(15, color: Colors.white, weight: FontWeight.w700),
                ),
                if (!done && !perRun) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: t,
                      minHeight: 6,
                      color: kGold,
                      backgroundColor: const Color(0x33ffffff),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('$progress / ${m.target}', style: bodyStyle(12)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const CoinIcon(size: 16),
          const SizedBox(width: 4),
          Text('${m.reward}', style: titleStyle(15, color: kGold)),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- settings

class _Settings extends StatelessWidget {
  const _Settings({required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    final s = state.storage;
    final q = s.quality;
    Widget qChip(int v, String label) => Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: q == v,
        onSelected: (_) => state.setQualitySetting(v),
        selectedColor: kAccent,
        labelStyle: bodyStyle(14, color: Colors.white),
        backgroundColor: const Color(0xff262b40),
      ),
    );
    return _Page(
      state: state,
      title: 'AYARLAR',
      child: ListView(
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grafik kalitesi', style: titleStyle(17)),
                const SizedBox(height: 4),
                Text('Otomatik: telefonun hızına göre kendini ayarlar.', style: bodyStyle(12)),
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    qChip(-1, 'Otomatik'),
                    for (var i = 0; i < Quality.levels.length; i++) qChip(i, Quality.levels[i].name),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Panel(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  value: s.haptics,
                  onChanged: (v) {
                    s.haptics = v;
                    state.refresh();
                  },
                  title: Text('Titreşim', style: bodyStyle(16, color: Colors.white)),
                  activeThumbColor: kAccent,
                ),
                SwitchListTile(
                  value: s.highFps,
                  onChanged: (v) {
                    s.highFps = v;
                    state.refresh();
                  },
                  title: Text('Yüksek FPS (90/120 Hz)', style: bodyStyle(16, color: Colors.white)),
                  subtitle: Text('Kapalıyken pil tasarrufu için 60 FPS sınırı.', style: bodyStyle(12)),
                  activeThumbColor: kAccent,
                ),
                SwitchListTile(
                  value: !s.tutorialSeen,
                  onChanged: (v) {
                    s.tutorialSeen = !v;
                    state.refresh();
                  },
                  title: Text('Nasıl oynanır ipuçları', style: bodyStyle(16, color: Colors.white)),
                  activeThumbColor: kAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('İstatistikler', style: titleStyle(17)),
                const SizedBox(height: 8),
                Text('Oynanan tur: ${s.runs}', style: bodyStyle(14)),
                Text('En iyi puan: ${s.best}', style: bodyStyle(14)),
                Text('En uzun mesafe: ${s.bestDistance} m', style: bodyStyle(14)),
                Text('Toplam mesafe: ${(s.totalDistance / 1000).toStringAsFixed(1)} km', style: bodyStyle(14)),
                Text('Toplam altın: ${s.totalCoins}', style: bodyStyle(14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
