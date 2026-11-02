import 'package:flutter/material.dart';

import '../game/game.dart';
import 'game_screen.dart';
import 'widgets.dart';

/// In-game HUD. Rebuilt only ~15 times per second through [GameScreenState.hudTick],
/// never on every frame.
class Hud extends StatelessWidget {
  const Hud({super.key, required this.state});

  final GameScreenState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: state.hudTick,
        builder: (context, _, _) => _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final g = state.game;
    final stormK = (1 - g.stormGap / Game.stormMax).clamp(0.0, 1.0);
    final danger = g.stormGap < 14;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${g.score}', style: titleStyle(34)),
                    Text('${g.distance.floor()} m  •  ${(g.speed * 3.6).round()} km/sa', style: bodyStyle(14, color: Colors.white)),
                  ],
                ),
              ),
              CoinPill(value: g.coins),
              const SizedBox(width: 10),
              _RoundIcon(icon: Icons.pause_rounded, onTap: state.pauseGame),
            ],
          ),
          const SizedBox(height: 10),
          _StormBar(k: stormK, danger: danger, time: g.time),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (g.shield) const _PowerChip(icon: Icons.shield_rounded, color: Color(0xff3fc8ff), t: 1, label: 'Kalkan'),
            if (g.magnetT > 0)
              _PowerChip(icon: Icons.u_turn_left_rounded, color: const Color(0xffff4d6d), t: g.magnetT / Game.magnetDur, label: 'Mıknatıs'),
            if (g.turboT > 0)
              _PowerChip(icon: Icons.bolt_rounded, color: const Color(0xffff9a1f), t: g.turboT / Game.turboDur, label: 'Turbo'),
            if (g.x2T > 0) _PowerChip(icon: Icons.close_rounded, color: const Color(0xffa070ff), t: g.x2T / Game.x2Dur, label: 'x2 Puan'),
          ]),
          const Spacer(),
          if (g.combo >= 5)
            Center(
              child: Text('KOMBO x${g.combo}', style: titleStyle(22 + (g.combo.clamp(5, 30) - 5) * 0.4, color: kGold)),
            ),
          if (danger)
            Center(
              child: Opacity(
                opacity: (g.time * 4).floor().isEven ? 1 : 0.5,
                child: Text('FIRTINA YAKLAŞIYOR!', style: titleStyle(20, color: const Color(0xffff6b6b))),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0x88000000),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x44ffffff)),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _StormBar extends StatelessWidget {
  const _StormBar({required this.k, required this.danger, required this.time});

  final double k;
  final bool danger;
  final double time;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(const Color(0xffffd23f), const Color(0xffff3b3b), k)!;
    return Row(children: [
      Icon(Icons.thunderstorm_rounded, color: color, size: 20),
      const SizedBox(width: 6),
      Expanded(
        child: Container(
          height: 10,
          decoration: BoxDecoration(color: const Color(0x66000000), borderRadius: BorderRadius.circular(5)),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: k.clamp(0.02, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xff6a4cff), color]),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _PowerChip extends StatelessWidget {
  const _PowerChip({required this.icon, required this.color, required this.t, required this.label});

  final IconData icon;
  final Color color;
  final double t;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
      decoration: BoxDecoration(
        color: const Color(0x88000000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: bodyStyle(12, color: Colors.white)),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: t.clamp(0.0, 1.0), color: color, backgroundColor: const Color(0x33ffffff)),
          ),
        ),
      ]),
    );
  }
}

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    Widget hint(IconData i, String t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(i, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(t, style: bodyStyle(16, color: Colors.white)),
          ]),
        );
    return Align(
      alignment: const Alignment(0, 0.1),
      child: Appear(
        child: Panel(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('NASIL OYNANIR', style: titleStyle(20, color: kGold)),
            const SizedBox(height: 8),
            hint(Icons.swap_horiz_rounded, 'Sağa / sola kaydır: şerit değiştir'),
            hint(Icons.arrow_upward_rounded, 'Yukarı kaydır: zıpla (bariyer)'),
            hint(Icons.arrow_downward_rounded, 'Aşağı kaydır: eğil (alçak geçit)'),
            hint(Icons.thunderstorm_rounded, 'Yavaşlama! Fırtına arkanda.'),
          ]),
        ),
      ),
    );
  }
}
