import 'package:flutter/material.dart';

import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/ui.dart';
import 'home_screen.dart';
import 'how_to_play_screen.dart';

/// Reference screen 1: logo, bird, "Tap to fly!" and "Get Started".
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _start(BuildContext context) {
    final seen = GameData.instance.tutorialSeen;
    Navigator.of(context).pushReplacement(
      fadeRoute(seen ? const HomeScreen() : const HowToPlayScreen(firstRun: true)),
    );
  }

  Widget _speedLines() {
    Widget line(double w) => Container(
          width: w,
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xD9FFFFFF),
            borderRadius: BorderRadius.circular(3),
          ),
        );
    return Column(children: [line(30), line(22), line(30)]);
  }

  @override
  Widget build(BuildContext context) {
    final u = uiScale(context);
    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              TitleLogo(scale: 1.0 * u),
              SizedBox(height: 22 * u),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _speedLines(),
                  const SizedBox(width: 14),
                  BirdSprite(
                    skin: GameData.instance.selectedSkin,
                    width: 140 * u,
                  ),
                ],
              ),
              SizedBox(height: 22 * u),
              OutlinedText('Tap to fly!', size: 28 * u),
              const Spacer(flex: 3),
              GameButton(
                width: 230 * u,
                height: 62,
                onPressed: () => _start(context),
                child: GoldLabel('Get Started', size: 28 * u),
              ),
              SizedBox(height: groundSpace(context) * 0.9),
            ],
          ),
        ),
      ),
    );
  }
}
