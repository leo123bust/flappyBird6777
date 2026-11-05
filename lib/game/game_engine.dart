import 'dart:math';

enum GamePhase { ready, playing, dying, over }

class Pipe {
  Pipe(this.x, this.gapY, this.gap);

  double x;
  final double gapY;
  final double gap;
  bool scored = false;

  double get gapTop => gapY - gap / 2;
  double get gapBottom => gapY + gap / 2;
}

/// Pure game logic. Works in a virtual world that is always [worldH] units
/// tall; the painter scales it to the real screen, so gameplay feels the same
/// on every Android screen size.
class GameEngine {
  GameEngine({required this.width}) {
    reset();
  }

  // --- World / tuning constants -------------------------------------------
  static const double worldH = 800;
  static const double groundH = 100;
  static const double groundTop = worldH - groundH;
  static const double pipeW = 58;
  static const double capOverhang = 4;
  static const double birdW = 42;
  static const double birdH = 29.4;
  static const double _hitHalfW = 13;
  static const double _hitHalfH = 10;

  static const double gravity = 1500;
  static const double flapVelocity = -440;
  static const double maxFall = 720;

  /// Virtual world width (depends on the screen aspect ratio).
  final double width;

  final Random _rng = Random();

  GamePhase phase = GamePhase.ready;
  int score = 0;

  double birdX = 0;
  double birdY = 0;
  double birdVel = 0;
  double birdAngle = 0;

  final List<Pipe> pipes = [];

  double groundScroll = 0;
  double worldTime = 0;
  double wingTime = 0;
  double flash = 0;

  void Function()? onScore;
  void Function()? onHit;

  double get _startY => worldH * 0.42;

  /// Pipe speed rises with the score (difficulty curve).
  double get speed => min(150.0 + 2.5 * score, 210.0);

  /// The gap between pipes shrinks with the score.
  double get gap => max(180.0 - 1.5 * score, 140.0);

  /// Wing animation frame: 0 up, 1 middle, 2 down.
  int get birdFrame {
    if (phase == GamePhase.dying || phase == GamePhase.over) return 1;
    const seq = [1, 0, 1, 2];
    return seq[(wingTime * 12).floor() % seq.length];
  }

  void reset() {
    phase = GamePhase.ready;
    score = 0;
    pipes.clear();
    birdX = width * 0.30;
    birdY = _startY;
    birdVel = 0;
    birdAngle = 0;
    flash = 0;
  }

  void flap() {
    if (phase == GamePhase.ready) {
      phase = GamePhase.playing;
      _spawn(width + 100);
    }
    if (phase == GamePhase.playing) {
      birdVel = flapVelocity;
    }
  }

  void update(double rawDt) {
    final dt = rawDt.clamp(0.0, 0.033).toDouble();
    worldTime += dt;
    if (flash > 0) flash = max(0.0, flash - dt * 4);

    switch (phase) {
      case GamePhase.ready:
        wingTime += dt;
        groundScroll += 90 * dt;
        birdY = _startY + sin(worldTime * 5) * 7;
        birdAngle = 0;
        break;

      case GamePhase.playing:
        wingTime += dt;
        final v = speed;
        groundScroll += v * dt;

        birdVel = min(birdVel + gravity * dt, maxFall);
        birdY += birdVel * dt;
        if (birdY < birdH / 2) {
          birdY = birdH / 2;
          if (birdVel < 0) birdVel = 0;
        }
        birdAngle = (birdVel / 520).clamp(-0.45, 1.25).toDouble();

        for (final p in pipes) {
          p.x -= v * dt;
        }
        if (pipes.isNotEmpty && pipes.first.x + pipeW + capOverhang < -10) {
          pipes.removeAt(0);
        }
        if (pipes.isEmpty || (width + 30) - pipes.last.x >= v * 1.55) {
          _spawn(width + 30);
        }

        for (final p in pipes) {
          if (!p.scored && p.x + pipeW < birdX - _hitHalfW) {
            p.scored = true;
            score++;
            onScore?.call();
          }
          if (_hitsPipe(p)) {
            _die(false);
            break;
          }
        }
        if (phase == GamePhase.playing && birdY + _hitHalfH >= groundTop) {
          birdY = groundTop - _hitHalfH;
          _die(true);
        }
        break;

      case GamePhase.dying:
        birdVel = min(birdVel + gravity * dt, maxFall * 1.2);
        birdY += birdVel * dt;
        birdAngle = min(birdAngle + 7 * dt, 1.5);
        if (birdY + _hitHalfH >= groundTop) {
          birdY = groundTop - _hitHalfH;
          phase = GamePhase.over;
        }
        break;

      case GamePhase.over:
        break;
    }
  }

  bool _hitsPipe(Pipe p) {
    final left = birdX - _hitHalfW;
    final right = birdX + _hitHalfW;
    final top = birdY - _hitHalfH;
    final bottom = birdY + _hitHalfH;
    if (right < p.x - capOverhang || left > p.x + pipeW + capOverhang) {
      return false;
    }
    return top < p.gapTop || bottom > p.gapBottom;
  }

  void _die(bool onGround) {
    flash = 1;
    onHit?.call();
    if (onGround) {
      phase = GamePhase.over;
      birdVel = 0;
      birdAngle = 1.4;
    } else {
      phase = GamePhase.dying;
      birdVel = 0;
    }
  }

  void _spawn(double x) {
    final g = gap;
    const topMargin = 80.0;
    const bottomMargin = 60.0;
    final lo = topMargin + g / 2;
    final hi = groundTop - bottomMargin - g / 2;
    var c = lo + _rng.nextDouble() * (hi - lo);
    if (pipes.isNotEmpty) {
      // Keep consecutive gaps reachable.
      final prev = pipes.last.gapY;
      c = c.clamp(prev - 200, prev + 200).toDouble();
      c = c.clamp(lo, hi).toDouble();
    }
    pipes.add(Pipe(x, c, g));
  }
}
