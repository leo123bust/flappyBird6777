import 'package:flutter/material.dart';

/// Procedural drawing helpers for the pixel-style world seen in the
/// reference: gradient sky, clouds, hazy city, bushes, pipes and the
/// grass/dirt ground strip.
class Scenery {
  Scenery._();

  static final Paint _p = Paint();

  static void _rect(Canvas c, Rect r, Color color) {
    _p.color = color;
    c.drawRect(r, _p);
  }

  static void sky(Canvas c, Size s) {
    final r = Offset.zero & s;
    _p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1C8CF0), Color(0xFF55BAFB), Color(0xFFA8E4FF)],
      stops: [0.0, 0.55, 1.0],
    ).createShader(r);
    c.drawRect(r, _p);
    _p.shader = null;
  }

  static void clouds(Canvas c, Size s, double t) {
    _p.color = const Color(0xD9FFFFFF);
    final span = s.width + 260;
    const defs = <List<double>>[
      [0.05, 0.13, 1.0, 6.0],
      [0.55, 0.22, 0.75, 9.0],
      [0.30, 0.42, 0.6, 5.0],
      [0.85, 0.50, 0.85, 7.0],
    ];
    for (final d in defs) {
      final x = ((d[0] * s.width + t * d[3]) % span) - 130;
      final y = s.height * d[1];
      final u = 22.0 * d[2];
      c.drawCircle(Offset(x, y), u, _p);
      c.drawCircle(Offset(x + u * 1.2, y - u * 0.5), u * 1.2, _p);
      c.drawCircle(Offset(x + u * 2.5, y), u, _p);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - u, y, u * 4.5, u * 0.9),
          Radius.circular(u * 0.45),
        ),
        _p,
      );
    }
  }

  static void city(Canvas c, Size s, double groundY, double scroll) {
    const widths = [34.0, 26.0, 44.0, 30.0, 38.0, 24.0, 48.0, 32.0];
    const heights = [70.0, 110.0, 90.0, 140.0, 80.0, 120.0, 100.0, 150.0];
    final total = widths.fold<double>(0, (a, b) => a + b);
    var x = -((scroll * 0.15) % total);
    var i = 0;
    _p.color = const Color(0x3D3F78C4);
    while (x < s.width) {
      final w = widths[i % widths.length];
      final h = heights[i % heights.length];
      c.drawRect(Rect.fromLTWH(x, groundY - h, w - 3, h), _p);
      x += w;
      i++;
    }
  }

  static void bushes(Canvas c, Size s, double groundY, double scroll) {
    const tile = 150.0;
    final off = (scroll * 0.4) % tile;
    for (var tx = -off - tile; tx < s.width + tile; tx += tile) {
      _p.color = const Color(0xFF2E9E3F);
      c.drawCircle(Offset(tx + 20, groundY - 10), 34, _p);
      c.drawCircle(Offset(tx + 70, groundY - 14), 42, _p);
      c.drawCircle(Offset(tx + 120, groundY - 6), 30, _p);
      _p.color = const Color(0xFF4DBF4A);
      c.drawCircle(Offset(tx, groundY), 28, _p);
      c.drawCircle(Offset(tx + 45, groundY - 4), 30, _p);
      c.drawCircle(Offset(tx + 95, groundY - 2), 34, _p);
      c.drawCircle(Offset(tx + 140, groundY), 26, _p);
      _p.color = const Color(0xFF7AE060);
      c.drawCircle(Offset(tx + 36, groundY - 14), 8, _p);
      c.drawCircle(Offset(tx + 86, groundY - 16), 9, _p);
    }
  }

  static void ground(Canvas c, Size s, double groundY, double scroll) {
    final w = s.width;
    final h = s.height - groundY;
    _rect(c, Rect.fromLTWH(0, groundY, w, h), const Color(0xFFB97A3C));

    // Dithered dirt dots
    const step = 28.0;
    final off = scroll % step;
    for (var row = 0; row < 7; row++) {
      final y = groundY + 38 + row * 16;
      if (y > s.height) break;
      final shift = (row.isEven ? 0.0 : step / 2) - off;
      final color =
          row.isEven ? const Color(0xFF8F5726) : const Color(0xFFD9A260);
      for (var x = shift - step; x < w + step; x += step) {
        _rect(c, Rect.fromLTWH(x, y, 7, 5), color);
      }
    }

    // Grass band with diagonal stripes
    _rect(c, Rect.fromLTWH(0, groundY, w, 24), const Color(0xFF68D32B));
    _rect(c, Rect.fromLTWH(0, groundY, w, 6), const Color(0xFF9DEB4E));
    _p.color = const Color(0xFF4DB820);
    const sw = 22.0;
    final so = scroll % sw;
    for (var x = -so - sw; x < w + sw; x += sw) {
      final path = Path()
        ..moveTo(x, groundY + 7)
        ..lineTo(x + 11, groundY + 7)
        ..lineTo(x + 3, groundY + 23)
        ..lineTo(x - 8, groundY + 23)
        ..close();
      c.drawPath(path, _p);
    }
    _rect(c, Rect.fromLTWH(0, groundY + 24, w, 5), const Color(0xFF2E8B1E));
  }

  /// Draws one pipe between [y1] and [y2]. The decorative cap sits at the
  /// bottom end for a hanging pipe and at the top end for a standing pipe.
  static void pipe(Canvas c, double x, double w, double y1, double y2,
      {required bool capAtBottom}) {
    final capH = w * 0.45;
    final ex = w * 0.07;
    Rect body;
    Rect cap;
    if (capAtBottom) {
      cap = Rect.fromLTRB(x - ex, y2 - capH, x + w + ex, y2);
      body = Rect.fromLTRB(x, y1, x + w, y2 - capH);
    } else {
      cap = Rect.fromLTRB(x - ex, y1, x + w + ex, y1 + capH);
      body = Rect.fromLTRB(x, y1 + capH, x + w, y2);
    }
    if (body.height > 0) _pipePart(c, body);
    _pipePart(c, cap);
  }

  static void _pipePart(Canvas c, Rect r) {
    _rect(c, r, const Color(0xFF215B14));
    final i = r.deflate(3);
    if (i.width <= 0 || i.height <= 0) return;
    _rect(c, i, const Color(0xFF5DC729));
    final w = i.width;
    _rect(c, Rect.fromLTWH(i.left, i.top, w * 0.18, i.height),
        const Color(0xFF9CEC56));
    _rect(c, Rect.fromLTWH(i.left + w * 0.26, i.top, w * 0.07, i.height),
        const Color(0xFF8AE04A));
    _rect(c, Rect.fromLTRB(i.right - w * 0.25, i.top, i.right, i.bottom),
        const Color(0xFF3E9C1D));
  }
}
