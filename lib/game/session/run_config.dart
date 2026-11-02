/// Everything the gameplay screen needs to start a run. Built by the menus
/// (level select, endless, free ride) and passed to `GameplayScreen`.
library;

import '../catalog/bikes/bike_loadout.dart';
import '../catalog/levels/level_spec.dart';
import 'game_mode.dart';

/// Traffic density in free ride.
enum TrafficLevel { none, light, heavy }

/// Graphics quality preset (scales scenery density, particles, draw distance).
enum GraphicsQuality { low, medium, high }

class FreeRideOptions {
  const FreeRideOptions({
    this.timeOfDay = TimeOfDay.morning,
    this.dayNightCycle = true,
    this.weather = Weather.clear,
    this.traffic = TrafficLevel.light,
  });

  final TimeOfDay timeOfDay;
  final bool dayNightCycle;
  final Weather weather;
  final TrafficLevel traffic;
}

class GameplaySettings {
  const GameplaySettings({
    this.graphics = GraphicsQuality.high,
    this.swipeSensitivity = 0.5,
    this.vibration = true,
    this.showTutorial = false,
  });

  final GraphicsQuality graphics;

  /// 0..1 (0 = long swipe needed, 1 = tiny flick).
  final double swipeSensitivity;
  final bool vibration;
  final bool showTutorial;
}

/// Asked when the rider crashes; return true if [gemCost] gems were spent.
typedef ReviveHandler = Future<bool> Function(int gemCost);

class RunConfig {
  const RunConfig({
    required this.mode,
    required this.worldIndex,
    required this.loadout,
    this.level,
    this.freeRide = const FreeRideOptions(),
    this.settings = const GameplaySettings(),
    this.availableGems = 0,
    this.onReviveRequested,
    this.endlessBestMeters = 0,
  });

  final GameMode mode;
  final int worldIndex;
  final BikeLoadout loadout;

  /// Required for [GameMode.mission].
  final LevelSpec? level;
  final FreeRideOptions freeRide;
  final GameplaySettings settings;
  final int availableGems;
  final ReviveHandler? onReviveRequested;
  final double endlessBestMeters;
}
