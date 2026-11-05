import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/sprites.dart';
import '../core/theme.dart';
import 'scenery.dart';

// ---------------------------------------------------------------------------
// Text
// ---------------------------------------------------------------------------

/// Heavy rounded-looking text with a dark outline and drop shadow, as used for
/// titles and button labels in the reference design.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    this.size = 28,
    this.fill = Colors.white,
    this.stroke = AppColors.outline,
    this.strokeWidth,
    this.gradient,
    this.shadow = true,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double size;
  final Color fill;
  final Color stroke;
  final double? strokeWidth;
  final List<Color>? gradient;
  final bool shadow;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final sw = strokeWidth ?? size * 0.18;
    final base = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 1.05,
      letterSpacing: size * 0.01,
    );
    final strokeStyle = base.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeJoin = StrokeJoin.round
        ..color = stroke,
      shadows: shadow
          ? [
              Shadow(
                color: const Color(0x55000000),
                offset: Offset(0, size * 0.07),
                blurRadius: size * 0.05,
              ),
            ]
          : null,
    );

    final colors = gradient;
    Widget fillText = Text(
      text,
      textAlign: textAlign,
      style: base.copyWith(color: colors == null ? fill : Colors.white),
    );
    if (colors != null) {
      fillText = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
        child: fillText,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(text, textAlign: textAlign, style: strokeStyle),
        fillText,
      ],
    );
  }
}

/// "Flappy" over a big gold "67".
class TitleLogo extends StatelessWidget {
  const TitleLogo({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: -0.06,
          child: OutlinedText('Flappy', size: 62 * scale),
        ),
        Transform.translate(
          offset: Offset(0, -16 * scale),
          child: Transform.rotate(
            angle: -0.06,
            child: OutlinedText(
              '67',
              size: 112 * scale,
              gradient: const [Color(0xFFFFE45C), Color(0xFFFFA400)],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

class ButtonPalette {
  const ButtonPalette(this.top, this.bottom, this.edge);

  final Color top;
  final Color bottom;
  final Color edge;

  static const gold =
      ButtonPalette(Color(0xFFFFD84A), Color(0xFFFFA800), Color(0xFFC96A00));
  static const green =
      ButtonPalette(Color(0xFF6BE04F), Color(0xFF2FB32A), Color(0xFF1B7A1B));
  static const blue =
      ButtonPalette(Color(0xFF3A9BFF), Color(0xFF1659D6), Color(0xFF0B2F7A));
}

/// Chunky 3D button with a pressed state.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.palette = ButtonPalette.gold,
    this.width,
    this.height = 60,
    this.radius = 16,
  });

  final VoidCallback onPressed;
  final Widget child;
  final ButtonPalette palette;
  final double? width;
  final double height;
  final double radius;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: p.edge,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius - 1),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [p.top, p.bottom],
              ),
              border: Border.all(color: p.edge, width: 2),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Yellow call-to-action label (white text, brown outline).
class GoldLabel extends StatelessWidget {
  const GoldLabel(this.text, {super.key, this.size = 28});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) =>
      OutlinedText(text, size: size, stroke: AppColors.brownOutline);
}

class BackSquareButton extends StatelessWidget {
  const BackSquareButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GameButton(
      width: 46,
      height: 46,
      radius: 13,
      palette: ButtonPalette.blue,
      onPressed: onPressed,
      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
    );
  }
}

// ---------------------------------------------------------------------------
// Small pieces
// ---------------------------------------------------------------------------

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFE680), Color(0xFFFFB400)],
        ),
        border: Border.all(color: const Color(0xFFB86A00), width: size * 0.1),
      ),
      child: Center(
        child: Container(
          width: size * 0.42,
          height: size * 0.42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD98A00), width: size * 0.08),
          ),
        ),
      ),
    );
  }
}

class CoinPill extends StatelessWidget {
  const CoinPill({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 14, 5),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x55FFFFFF), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoinIcon(size: 24),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class CrownIcon extends StatelessWidget {
  const CrownIcon({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(painter: _CrownPainter()),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.25)
      ..lineTo(w * 0.25, h * 0.55)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.75, h * 0.55)
      ..lineTo(w, h * 0.25)
      ..lineTo(w * 0.9, h)
      ..lineTo(w * 0.1, h)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFC21A));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFB8620A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The dark "Best | Score" panel.
class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    super.key,
    required this.best,
    required this.score,
    this.width = 270,
  });

  final int best;
  final int score;
  final double width;

  Widget _cell(String label, String value, {bool crown = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (crown) ...[const CrownIcon(size: 26), const SizedBox(width: 6)],
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(child: _cell('Best', '$best', crown: true)),
          const SizedBox(
            width: 2,
            height: 46,
            child: ColoredBox(color: Color(0x44FFFFFF)),
          ),
          Expanded(child: _cell('Score', '$score')),
        ],
      ),
    );
  }
}

/// Light-blue translucent card used for "How to Play" and dialogs.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF0C6E9FF), Color(0xF0A1D7FF)],
        ),
        border: Border.all(color: const Color(0xFF2E86F0), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Dialog that matches the game's look.
Future<void> showGameDialog(
  BuildContext context, {
  required String title,
  required Widget body,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: GameCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedText(title, size: 30),
            const SizedBox(height: 14),
            body,
            const SizedBox(height: 18),
            GameButton(
              width: 150,
              height: 54,
              onPressed: () => Navigator.of(ctx).pop(),
              child: const GoldLabel('Close', size: 22),
            ),
          ],
        ),
      ),
    ),
  );
}

const TextStyle kBodyInk = TextStyle(
  color: AppColors.ink,
  fontSize: 18,
  fontWeight: FontWeight.w800,
);

// ---------------------------------------------------------------------------
// Bird + animated scene background
// ---------------------------------------------------------------------------

/// Pixel bird for menus. Flaps and bobs when [animate] is true.
class BirdSprite extends StatefulWidget {
  const BirdSprite({
    super.key,
    required this.skin,
    this.width = 110,
    this.animate = true,
    this.frame = 1,
  });

  final String skin;
  final double width;
  final bool animate;
  final int frame;

  @override
  State<BirdSprite> createState() => _BirdSpriteState();
}

class _BirdSpriteState extends State<BirdSprite>
    with SingleTickerProviderStateMixin {
  static const _seq = [1, 0, 1, 2];

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final frame = widget.animate
            ? _seq[(_c.value * 8).floor() % _seq.length]
            : widget.frame;
        final dy =
            widget.animate ? math.sin(_c.value * 2 * math.pi) * w * 0.05 : 0.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: RawImage(
            image: Sprites.bird(widget.skin, frame),
            width: w,
            height: w * 14 / 20,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        );
      },
    );
  }
}

/// Sky, clouds, hazy city, bushes and ground behind every menu screen.
class SceneBackground extends StatefulWidget {
  const SceneBackground({super.key, this.decoPipes = false, this.child});

  final bool decoPipes;
  final Widget? child;

  @override
  State<SceneBackground> createState() => _SceneBackgroundState();
}

class _SceneBackgroundState extends State<SceneBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _MenuScenePainter(_c, widget.decoPipes),
            size: Size.infinite,
          ),
        ),
        if (child != null) child,
      ],
    );
  }
}

class _MenuScenePainter extends CustomPainter {
  _MenuScenePainter(this.animation, this.deco) : super(repaint: animation);

  final Animation<double> animation;
  final bool deco;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 600;
    final groundH = (size.height * 0.11).clamp(80.0, 130.0).toDouble();
    final groundY = size.height - groundH;

    Scenery.sky(canvas, size);
    Scenery.clouds(canvas, size, t);
    Scenery.city(canvas, size, groundY, 0);
    if (deco) {
      final pw = size.width * 0.16;
      Scenery.pipe(canvas, size.width * 0.03, pw, groundY - 150, groundY + 8,
          capAtBottom: false);
      Scenery.pipe(canvas, size.width * 0.80, pw, groundY - 190, groundY + 8,
          capAtBottom: false);
    }
    Scenery.bushes(canvas, size, groundY, 0);
    Scenery.ground(canvas, size, groundY, 0);
  }

  @override
  bool shouldRepaint(covariant _MenuScenePainter old) => old.deco != deco;
}
