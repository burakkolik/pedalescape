import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/storage.dart';
import 'ui/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The game draws everything procedurally; keep the image cache tiny so the
  // app's memory footprint can never creep up over time.
  PaintingBinding.instance.imageCache
    ..maximumSize = 20
    ..maximumSizeBytes = 8 << 20;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final storage = await Storage.open();
  runApp(PedalEscapeApp(storage: storage));
}

class PedalEscapeApp extends StatelessWidget {
  const PedalEscapeApp({super.key, required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedal Escape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffff5a36), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xff0b0f1e),
        body: GameScreen(storage: storage),
      ),
    );
  }
}
