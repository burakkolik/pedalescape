/// Events emitted by the simulation for HUD popups, audio and haptics.
library;

enum GameEventType {
  coin,
  gem,
  powerUp,
  jump,
  land,
  duck,
  laneSwitch,
  nearMiss,
  perfectJump,
  stumble,
  crash,
  shieldHit,
  checkpoint,
  finish,
  stormClose,
  thunder,
  comboUp,
}

class GameEvent {
  const GameEvent(this.type, {this.value = 0});
  final GameEventType type;
  final int value;
}
