import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Loads the pixel-art bird sprites once at start-up so that they can be
/// drawn synchronously by both widgets and the game canvas.
class Sprites {
  Sprites._();

  static const List<String> skinIds = [
    'yellow',
    'red',
    'blue',
    'green',
    'purple',
    'black',
  ];

  static final Map<String, ui.Image> _birds = {};

  static Future<void> load() async {
    for (final id in skinIds) {
      for (var frame = 0; frame < 3; frame++) {
        final data = await rootBundle.load('assets/images/bird_${id}_$frame.png');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        final decoded = await codec.getNextFrame();
        _birds['${id}_$frame'] = decoded.image;
      }
    }
  }

  /// [frame]: 0 = wing up, 1 = wing middle, 2 = wing down.
  static ui.Image bird(String skinId, int frame) {
    final image = _birds['${skinId}_${frame % 3}'] ?? _birds['yellow_1'];
    return image!;
  }
}
