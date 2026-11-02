/// Simple 3D particle (dust, sparks, debris, confetti, turbo flames).
library;

class Particle {
  Particle(this.x, this.y, this.z, this.vx, this.vy, this.vz, this.life, this.color, this.size,
      {this.gravity = 0, this.emissive = false});

  double x, y, z, vx, vy, vz;
  double life;
  double age = 0;
  final int color;
  final double size;
  final double gravity;
  final bool emissive;

  bool get dead => age >= life;
  double get t => (age / life).clamp(0.0, 1.0);
}
