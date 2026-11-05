import 'package:flutter/material.dart';

import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/ui.dart';
import 'home_screen.dart';

/// Reference screen 3: "How to Play" card with "Got it!" button.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key, this.firstRun = false});

  /// When true, "Got it!" continues to the home screen instead of going back.
  final bool firstRun;

  Future<void> _done(BuildContext context) async {
    await GameData.instance.markTutorialSeen();
    if (!context.mounted) return;
    final nav = Navigator.of(context);
    if (firstRun) {
      nav.pushReplacement(fadeRoute(const HomeScreen()));
    } else {
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = uiScale(context);
    return Scaffold(
      body: SceneBackground(
        decoPipes: true,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * u),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BackSquareButton(onPressed: () => _done(context)),
                    ),
                    const OutlinedText('How to Play', size: 34),
                  ],
                ),
                SizedBox(height: 26 * u),
                GameCard(
                  padding: EdgeInsets.fromLTRB(20, 30 * u, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            BirdSprite(
                              skin: GameData.instance.selectedSkin,
                              width: 110 * u,
                            ),
                            const Positioned(
                              right: -10,
                              bottom: -34,
                              child: Icon(
                                Icons.touch_app_rounded,
                                size: 58,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: AppColors.navy,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 46 * u),
                        Text(
                          'Tap to fly!',
                          style: kBodyInk.copyWith(fontSize: 26 * u),
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFF3F8FE8), thickness: 2),
                        const SizedBox(height: 14),
                        Text(
                          'Avoid the pipes and get the highest score!',
                          textAlign: TextAlign.center,
                          style: kBodyInk.copyWith(fontSize: 21 * u),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GameButton(
                  width: 200 * u,
                  height: 58,
                  onPressed: () => _done(context),
                  child: GoldLabel('Got it!', size: 28 * u),
                ),
                SizedBox(height: groundSpace(context) * 0.9),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
