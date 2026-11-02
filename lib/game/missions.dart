import '../services/storage.dart';

enum MissionType { runDistance, runCoins, runScore, totalDistance, totalCoins, runs }

class Mission {
  const Mission(this.id, this.text, this.type, this.target, this.reward);

  final String id;
  final String text;
  final MissionType type;
  final int target;
  final int reward;
}

/// Ordered list; the first three unfinished ones are active.
const List<Mission> kMissions = [
  Mission('d300', 'Tek turda 300 m git', MissionType.runDistance, 300, 30),
  Mission('c20', 'Tek turda 20 altın topla', MissionType.runCoins, 20, 30),
  Mission('r3', '3 kez oyna', MissionType.runs, 3, 40),
  Mission('d800', 'Tek turda 800 m git', MissionType.runDistance, 800, 60),
  Mission('s1500', 'Tek turda 1500 puan yap', MissionType.runScore, 1500, 60),
  Mission('tc200', 'Toplam 200 altın topla', MissionType.totalCoins, 200, 80),
  Mission('c60', 'Tek turda 60 altın topla', MissionType.runCoins, 60, 90),
  Mission('d1500', 'Tek turda 1500 m git', MissionType.runDistance, 1500, 120),
  Mission('td5000', 'Toplam 5 km pedal çevir', MissionType.totalDistance, 5000, 120),
  Mission('r15', '15 kez oyna', MissionType.runs, 15, 100),
  Mission('s5000', 'Tek turda 5000 puan yap', MissionType.runScore, 5000, 150),
  Mission('d3000', 'Tek turda 3 km git', MissionType.runDistance, 3000, 200),
  Mission('tc1000', 'Toplam 1000 altın topla', MissionType.totalCoins, 1000, 200),
  Mission('c150', 'Tek turda 150 altın topla', MissionType.runCoins, 150, 250),
  Mission('td25000', 'Toplam 25 km pedal çevir', MissionType.totalDistance, 25000, 300),
  Mission('d6000', 'Tek turda 6 km git', MissionType.runDistance, 6000, 500),
];

class RunStats {
  const RunStats({required this.distance, required this.coins, required this.score});
  final int distance;
  final int coins;
  final int score;
}

int missionProgress(Mission m, Storage s, RunStats? run) {
  switch (m.type) {
    case MissionType.runDistance:
      return run?.distance ?? 0;
    case MissionType.runCoins:
      return run?.coins ?? 0;
    case MissionType.runScore:
      return run?.score ?? 0;
    case MissionType.totalDistance:
      return s.totalDistance;
    case MissionType.totalCoins:
      return s.totalCoins;
    case MissionType.runs:
      return s.runs;
  }
}

List<Mission> activeMissions(Storage s) {
  final done = s.missionsDone;
  return kMissions.where((m) => !done.contains(m.id)).take(3).toList();
}

/// Checks the active missions after a run (stats must already be saved).
/// Completed ones are stored and their rewards added to the wallet.
List<Mission> evaluateMissions(Storage s, RunStats run) {
  final completed = <Mission>[];
  for (final m in activeMissions(s)) {
    if (missionProgress(m, s, run) >= m.target) {
      s.completeMission(m.id);
      s.wallet = s.wallet + m.reward;
      completed.add(m);
    }
  }
  return completed;
}
