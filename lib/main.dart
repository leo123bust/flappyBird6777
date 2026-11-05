import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/game_data.dart';
import 'core/sprites.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  ));
  await GameData.init();
  await Sprites.load();
  runApp(const Flappy67App());
}

class Flappy67App extends StatelessWidget {
  const Flappy67App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy 67',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E90F0),
      ),
      home: const SplashScreen(),
    );
  }
}
