import 'package:flutter/material.dart';

import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/ui.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'skins_screen.dart';

/// Reference screen 2: logo, Best/Score, bird, Play and three icon buttons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return GameButton(
      width: 76,
      height: 76,
      radius: 18,
      palette: ButtonPalette.blue,
      onPressed: onTap,
      child: Icon(icon, color: color, size: 42),
    );
  }

  void _showStats(BuildContext context) {
    final d = GameData.instance;
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(child: Text(label, style: kBodyInk)),
              Text(value, style: kBodyInk.copyWith(fontSize: 22)),
            ],
          ),
        );
    showGameDialog(
      context,
      title: 'Statistics',
      body: SizedBox(
        width: 260,
        child: Column(
          children: [
            row('Best score', '${d.best}'),
            row('Games played', '${d.gamesPlayed}'),
            row('Pipes passed', '${d.totalPipes}'),
            row('Coins', '${d.coins}'),
          ],
        ),
      ),
    );
  }

  void _showAchievements(BuildContext context) {
    final best = GameData.instance.best;
    const goals = <MapEntry<int, String>>[
      MapEntry(10, 'Rookie flyer'),
      MapEntry(25, 'Sky pilot'),
      MapEntry(50, 'Pipe master'),
      MapEntry(67, 'Flappy 67!'),
    ];
    showGameDialog(
      context,
      title: 'Trophies',
      body: SizedBox(
        width: 260,
        child: Column(
          children: [
            for (final g in goals)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(
                      best >= g.key
                          ? Icons.emoji_events_rounded
                          : Icons.lock_rounded,
                      color: best >= g.key
                          ? const Color(0xFFE8A200)
                          : const Color(0x88152B5E),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(g.value, style: kBodyInk)),
                    Text('${g.key}', style: kBodyInk),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showGameDialog(context, title: 'Settings', body: const _SettingsBody());
  }

  @override
  Widget build(BuildContext context) {
    final u = uiScale(context);
    return Scaffold(
      body: SceneBackground(
        decoPipes: true,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: GameData.instance,
            builder: (context, _) {
              final d = GameData.instance;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 22 * u),
                      TitleLogo(scale: 0.8 * u),
                      SizedBox(height: 14 * u),
                      ScoreBoard(best: d.best, score: d.lastScore),
                      const Spacer(),
                      BirdSprite(skin: d.selectedSkin, width: 100 * u),
                      const Spacer(),
                      GameButton(
                        width: 190 * u,
                        height: 76,
                        radius: 20,
                        palette: ButtonPalette.green,
                        onPressed: () => Navigator.of(context)
                            .push(fadeRoute(const GameScreen())),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 58),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _iconButton(Icons.bar_chart_rounded, Colors.white,
                              () => _showStats(context)),
                          const SizedBox(width: 12),
                          _iconButton(Icons.emoji_events_rounded,
                              const Color(0xFFFFC21A),
                              () => _showAchievements(context)),
                          const SizedBox(width: 12),
                          _iconButton(Icons.star_rounded, Colors.white, () {
                            Navigator.of(context)
                                .push(fadeRoute(const SkinsScreen()));
                          }),
                        ],
                      ),
                      SizedBox(height: groundSpace(context) * 0.95),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _showSettings(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.settings_rounded,
                            color: Colors.white,
                            size: 36,
                            shadows: [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsBody extends StatefulWidget {
  const _SettingsBody();

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  @override
  Widget build(BuildContext context) {
    final d = GameData.instance;
    return SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Vibration', style: kBodyInk)),
              Switch(
                value: d.vibration,
                activeTrackColor: const Color(0xFF3CC13B),
                onChanged: (v) async {
                  await d.setVibration(v);
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          GameButton(
            width: 220,
            height: 54,
            palette: ButtonPalette.blue,
            onPressed: () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(fadeRoute(const HowToPlayScreen()));
            },
            child: const OutlinedText('How to Play', size: 22),
          ),
        ],
      ),
    );
  }
}
