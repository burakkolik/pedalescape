/// Identifiers for every sound effect in Pedal Escape.
///
/// Each value maps to a procedural recipe in `sound_bank.dart`; no audio
/// files are bundled with the game.
library;

/// All sound effects the game can trigger via `AudioService.playSfx`.
enum SfxId {
  uiTap,
  uiBack,
  uiPurchase,
  uiUpgrade,
  uiError,
  uiReward,
  coin,
  gem,
  jump,
  land,
  duck,
  laneSwitch,
  nearMiss,
  crash,
  stumble,
  powerUp,
  shieldHit,
  turboStart,
  magnetOn,
  levelComplete,
  starEarned,
  gameOver,
  countdownBeep,
  countdownGo,
  chestOpen,
  spinTick,
  levelUp,
  bell,
  thunder,
  whoosh,
}
