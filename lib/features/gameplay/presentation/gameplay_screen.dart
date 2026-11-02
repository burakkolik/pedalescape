/// Full-screen gameplay. STUB — being implemented.
/// Pops with a `RunResult` when the run ends.
library;

import 'package:flutter/material.dart';

import '../../../game/session/run_config.dart';

class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key, required this.config});

  final RunConfig config;

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}
