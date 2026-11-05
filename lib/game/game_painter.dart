import 'package:flutter/material.dart';

import '../core/sprites.dart';
import '../widgets/scenery.dart';
import 'game_engine.dart';

/// Paints the whole game world. Repaints on every [repaint] notification
/// (one per frame) without rebuilding any widgets.
class GamePainter extends CustomPainter {
  GamePainter(this.engine, Listenable repaint, this.skin)
      : super(repaint: repaint);

  final GameEngine engine;
  final String skin;

  static final Paint _birdPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;
  static final Paint _flashPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / GameEngine.worldH;
    final world = Size(size.width / s, GameEngine.worldH);

    canvas.save();
    canvas.scale(s, s);

    Scenery.sky(canvas, world);
    Scenery.clouds(canvas, world, engine.worldTime);
    Scenery.city(canvas, world, GameEngine.groundTop, engine.groundScroll);
    Scenery.bushes(canvas, world, GameEngine.groundTop, engine.groundScroll);

    for (final p in engine.pipes) {
      Scenery.pipe(canvas, p.x, GameEngine.pipeW, -60, p.gapTop,
          capAtBottom: true);
      Scenery.pipe(canvas, p.x, GameEngine.pipeW, p.gapBottom,
          GameEngine.groundTop + 6,
          capAtBottom: false);
    }

    Scenery.ground(canvas, world, GameEngine.groundTop, engine.groundScroll);
    _drawBird(canvas);

    if (engine.flash > 0) {
      _flashPaint.color = Color.fromRGBO(255, 255, 255, engine.flash * 0.7);
      canvas.drawRect(Offset.zero & world, _flashPaint);
    }
    canvas.restore();
  }

  void _drawBird(Canvas canvas) {
    final image = Sprites.bird(skin, engine.birdFrame);
    canvas.save();
    canvas.translate(engine.birdX, engine.birdY);
    canvas.rotate(engine.birdAngle);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromCenter(
        center: Offset.zero,
        width: GameEngine.birdW,
        height: GameEngine.birdH,
      ),
      _birdPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GamePainter old) =>
      old.engine != engine || old.skin != skin;
}
