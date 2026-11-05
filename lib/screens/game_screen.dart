import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../core/game_data.dart';
import '../game/game_engine.dart';
import '../game/game_painter.dart';
import '../widgets/ui.dart';

/// The playable game: tap to flap, avoid the pipes.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  GameEngine? _engine;
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  final ValueNotifier<GamePhase> _phase =
      ValueNotifier<GamePhase>(GamePhase.ready);
  final ValueNotifier<int> _score = ValueNotifier<int>(0);

  late final String _skin;
  RunResult? _result;

  @override
  void initState() {
    super.initState();
    _skin = GameData.instance.selectedSkin;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    _phase.dispose();
    _score.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final engine = _engine;
    if (engine == null) {
      _last = elapsed;
      return;
    }
    final dt = (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    engine.update(dt);
    if (_phase.value != engine.phase) {
      _phase.value = engine.phase;
      if (engine.phase == GamePhase.over) _finish(engine.score);
    }
    _frame.value++;
  }

  Future<void> _finish(int score) async {
    final result = await GameData.instance.recordRun(score);
    if (!mounted) return;
    setState(() => _result = result);
  }

  GameEngine _createEngine(double screenW, double screenH) {
    final scale = screenH / GameEngine.worldH;
    final engine = GameEngine(width: screenW / scale);
    engine.onScore = () {
      _score.value = engine.score;
      if (GameData.instance.vibration) HapticFeedback.selectionClick();
    };
    engine.onHit = () {
      if (GameData.instance.vibration) HapticFeedback.mediumImpact();
    };
    return engine;
  }

  void _restart() {
    _engine?.reset();
    _score.value = 0;
    _phase.value = GamePhase.ready;
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final engine =
              _engine ??= _createEngine(box.maxWidth, box.maxHeight);
          final topInset = MediaQuery.paddingOf(context).top;
          return Stack(
            fit: StackFit.expand,
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) => engine.flap(),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: GamePainter(engine, _frame, _skin),
                    size: Size.infinite,
                  ),
                ),
              ),
              Positioned(
                top: topInset + 40,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _score,
                    builder: (context, value, _) =>
                        Center(child: OutlinedText('$value', size: 76)),
                  ),
                ),
              ),
              ValueListenableBuilder<GamePhase>(
                valueListenable: _phase,
                builder: (context, phase, _) {
                  if (phase == GamePhase.ready) {
                    return const IgnorePointer(child: _ReadyHint());
                  }
                  final result = _result;
                  if (phase == GamePhase.over && result != null) {
                    return _GameOverPanel(
                      score: engine.score,
                      best: GameData.instance.best,
                      result: result,
                      onRestart: _restart,
                      onHome: () => Navigator.of(context).pop(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReadyHint extends StatelessWidget {
  const _ReadyHint();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0, 0.42),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedText('Tap to fly!', size: 32),
          SizedBox(height: 8),
          Icon(
            Icons.touch_app_rounded,
            size: 56,
            color: Colors.white,
            shadows: [Shadow(color: Color(0xFF14246B), offset: Offset(2, 2))],
          ),
        ],
      ),
    );
  }
}

class _GameOverPanel extends StatelessWidget {
  const _GameOverPanel({
    required this.score,
    required this.best,
    required this.result,
    required this.onRestart,
    required this.onHome,
  });

  final int score;
  final int best;
  final RunResult result;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, v, child) =>
          Transform.scale(scale: 0.6 + 0.4 * v, child: child),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OutlinedText('Game Over', size: 48),
            const SizedBox(height: 18),
            ScoreBoard(best: best, score: score, width: 270),
            const SizedBox(height: 12),
            if (result.newBest)
              const OutlinedText(
                'New best!',
                size: 28,
                gradient: [Color(0xFFFFE45C), Color(0xFFFFA400)],
              ),
            if (result.coinsEarned > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CoinIcon(size: 26),
                    const SizedBox(width: 8),
                    OutlinedText('+${result.coinsEarned}', size: 26),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            GameButton(
              width: 220,
              height: 64,
              palette: ButtonPalette.green,
              onPressed: onRestart,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.replay_rounded, color: Colors.white, size: 34),
                  SizedBox(width: 8),
                  OutlinedText('Play again', size: 24),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GameButton(
              width: 220,
              height: 56,
              onPressed: onHome,
              child: const GoldLabel('Home', size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
