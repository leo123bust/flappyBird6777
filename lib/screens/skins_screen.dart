import 'package:flutter/material.dart';

import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/ui.dart';

/// Reference screen 4: 2x3 grid of skins with prices and a coin counter.
class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  Future<void> _onTap(BuildContext context, Skin skin) async {
    final d = GameData.instance;
    if (d.unlocked.contains(skin.id)) {
      await d.selectSkin(skin);
      return;
    }
    final ok = await d.buySkin(skin);
    if (!ok && context.mounted) {
      final missing = skin.price - d.coins;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Not enough coins. You need $missing more.'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = uiScale(context);
    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: GameData.instance,
            builder: (context, _) {
              final d = GameData.instance;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * u),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: BackSquareButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const OutlinedText('Skins', size: 36),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CoinPill(coins: d.coins),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.18,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final s in kSkins)
                            _SkinCard(
                              skin: s,
                              selected: d.selectedSkin == s.id,
                              owned: d.unlocked.contains(s.id),
                              onTap: () => _onTap(context, s),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GameButton(
                      width: 190 * u,
                      height: 56,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const GoldLabel('Back', size: 26),
                    ),
                    SizedBox(height: groundSpace(context) * 0.75),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.skin,
    required this.selected,
    required this.owned,
    required this.onTap,
  });

  final Skin skin;
  final bool selected;
  final bool owned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? const [Color(0xFFFFF0C2), Color(0xFFFFD98A)]
                : const [Color(0x99D7F0FF), Color(0x6694D2FF)],
          ),
          border: Border.all(
            color: selected ? const Color(0xFFFFB000) : const Color(0xAAFFFFFF),
            width: selected ? 4 : 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BirdSprite(skin: skin.id, width: 74, animate: false),
                  const SizedBox(height: 10),
                  if (!owned)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CoinIcon(size: 22),
                        const SizedBox(width: 6),
                        Text('${skin.price}',
                            style: kBodyInk.copyWith(fontSize: 21)),
                      ],
                    )
                  else if (!selected)
                    Text('Owned', style: kBodyInk.copyWith(fontSize: 18)),
                ],
              ),
            ),
            if (selected)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3CC13B),
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 19),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
