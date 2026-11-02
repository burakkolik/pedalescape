import 'package:flutter/material.dart';

/// Shared visual building blocks for menus and HUD.

const kGold = Color(0xffffc62a);
const kAccent = Color(0xffff5a36);
const kPanel = Color(0xcc101425);

TextStyle titleStyle(double size, {Color color = Colors.white}) => TextStyle(
  fontSize: size,
  fontWeight: FontWeight.w900,
  color: color,
  letterSpacing: 1.5,
  shadows: const [Shadow(color: Color(0x88000000), blurRadius: 8, offset: Offset(0, 3))],
);

TextStyle bodyStyle(double size, {Color color = Colors.white70, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontSize: size, color: color, fontWeight: weight);

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x33ffffff), width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}

/// Chunky game button with a press animation.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.colors = const [Color(0xffff7a3d), Color(0xffff3d5e)],
    this.big = false,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final List<Color> colors;
  final bool big;
  final bool enabled;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.big ? 68.0 : 52.0;
    final colors = widget.enabled ? widget.colors : const [Color(0xff555a66), Color(0xff3a3e48)];
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _down = false);
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1,
        duration: const Duration(milliseconds: 90),
        child: Container(
          height: h,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(h / 2),
            border: Border.all(color: const Color(0x55ffffff), width: 1.5),
            boxShadow: [
              BoxShadow(color: colors.last.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: widget.big ? 30 : 22),
                const SizedBox(width: 10),
              ],
              Text(widget.label, style: titleStyle(widget.big ? 26 : 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class CoinPill extends StatelessWidget {
  const CoinPill({super.key, required this.value, this.size = 18});

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.6, vertical: size * 0.25),
      decoration: BoxDecoration(
        color: const Color(0x88000000),
        borderRadius: BorderRadius.circular(size * 2),
        border: Border.all(color: const Color(0x44ffc62a)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinIcon(size: size * 1.1),
          SizedBox(width: size * 0.35),
          Text('$value', style: titleStyle(size, color: kGold)),
        ],
      ),
    );
  }
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xfffff4a8), Color(0xffffc62a), Color(0xffcf8a00)],
        ),
      ),
      child: Icon(Icons.star_rounded, size: size * 0.62, color: const Color(0xfffff0b0)),
    );
  }
}

/// Fades + slides its child in when first built.
class Appear extends StatelessWidget {
  const Appear({super.key, required this.child, this.delay = 0, this.offset = 30});

  final Widget child;
  final int delay; // ms
  final double offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Interval(delay / (420 + delay), 1, curve: Curves.easeOutBack),
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, (1 - t) * offset), child: c),
      ),
      child: child,
    );
  }
}
