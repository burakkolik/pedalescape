/// Mutable physical state of the player's bike during a run.
library;

class RiderState {
  int lane = 0;
  int previousLane = 0;
  double x = 0;
  double y = 0;
  double vy = 0;
  double z = 0; // distance travelled (road space)
  double speed = 0;
  double targetSpeed = 0;
  double duckTimer = 0;
  double stumbleTimer = 0;
  double invulnerableTimer = 0;
  double crankAngle = 0;
  double wheelAngle = 0;
  double lean = 0;
  double airPitch = 0;
  int armor = 0;
  bool crashed = false;
  double crashT = 0;

  bool get grounded => y <= 0.0001 && vy <= 0;
  bool get ducking => duckTimer > 0;
  bool get jumping => !grounded;
}
